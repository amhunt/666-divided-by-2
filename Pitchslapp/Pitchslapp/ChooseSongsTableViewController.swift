//
//  ChooseSongsTableViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 4/22/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class ChooseSongsTableViewController: UITableViewController {

    var myRootRef = Firebase(url:"https://popping-inferno-1963.firebaseio.com")
    var setlist: Setlist!
    var groupKey: String?
    var songs = [SongItem]()
    var checked = [Bool]()
    
    override func viewWillAppear(animated: Bool) {
        let songsRef = self.myRootRef.childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("songs")
        songsRef.observeEventType(.Value, withBlock: { snapshot in
            var newSongs = [SongItem]()
            
            for item in snapshot.children {
                var songItem = SongItem(snapshot: item as! FDataSnapshot)
                if snapshot.hasChild("tags") {
                    songItem.tags = snapshot.valueForKey("tags") as! [String]
                }
                if self.setlist.songIds.contains(songItem.id) != true {
                    newSongs.append(songItem)
                }
            }
            
            self.songs = newSongs
            self.songs.sortInPlace({$0.name < $1.name})
            self.tableView.reloadData()
            
            self.checked = [Bool](count: self.songs.count, repeatedValue: false)
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.allowsMultipleSelection = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return songs.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongCell", forIndexPath: indexPath) as! SongTableViewCell
        
        let songItem = songs[indexPath.row]
        
        cell.titleLabel?.text = songItem.name
        cell.soloLabel?.text = songItem.soloist
        cell.keyLabel?.text = songItem.key
        
        if !checked[indexPath.row] {
            cell.accessoryType = .None
        } else if checked[indexPath.row] {
            cell.accessoryType = .Checkmark
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            if cell.accessoryType == .Checkmark {
                cell.accessoryType = .None
                checked[indexPath.row] = false
            } else {
                cell.accessoryType = .Checkmark
                checked[indexPath.row] = true
            }
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
    }
    
    @IBAction func cancelDidTouch(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addDidTouch(sender: AnyObject) {
        // get indices of selected items
        let rows = self.tableView.indexPathsForSelectedRows?.map{$0.row}
        
        if rows != nil {
            var selectedSongs = [SongItem]()
            for index in rows! {
                selectedSongs.append(songs[index])
            }
            
            for song in selectedSongs {
                // check if song has already been added to setlist
                if setlist.songIds.contains(song.id) != true {
                    setlist.songIds.append(song.id)
                }
            }
            
            let setlistRef = myRootRef.childByAppendingPath("groups").childByAppendingPath(groupKey).childByAppendingPath("setlists").childByAppendingPath(setlist.id)
            setlistRef.childByAppendingPath("songIds").setValue(self.setlist.songIds)
        }
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
