//
//  SongsTableViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 3/29/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import Firebase
import Foundation

class SongsTableViewController: UITableViewController {
    var myRootRef = Firebase(url:"https://popping-inferno-1963.firebaseio.com")
    var songs = [SongItem]()
    
    override func viewDidLoad() {
//        let groups = myRootRef.childByAppendingPath("groups")
//        let group1 = groups.childByAutoId()
//        let song1 = ["name":"Love Yourself", "solo":"Charlie Coburn", "key":"Ab"]
//        let song2 = ["name":"Kiss Him Goodbye", "solo":"Will Plunkett", "key":"C#"]
//        group1.childByAppendingPath("name").setValue("Footnotes")
//        let songref = group1.childByAppendingPath("songs")
//        songref.childByAutoId().setValue(song1)
//        songref.childByAutoId().setValue(song2)
    }
    
    override func viewDidAppear(animated: Bool) {
        let songsRef = myRootRef.childByAppendingPath("groups").childByAppendingPath("-KE2t-HbseflgtLhuV8-").childByAppendingPath("songs")

        songsRef.observeEventType(.Value, withBlock: { snapshot in
            var newSongs = [SongItem]()
            
            for item in snapshot.children {
                let songItem = SongItem(snapshot: item as! FDataSnapshot)
                newSongs.append(songItem)
            }
            
            self.songs = newSongs
            self.songs.sortInPlace({$0.name < $1.name})
            self.tableView.reloadData()
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongCell")! as UITableViewCell
        
        let songItem = songs[indexPath.row]
        
        cell.textLabel?.text = songItem.name
        cell.detailTextLabel?.text = songItem.soloist
        
        return cell
    }
    
    @IBAction func addButtonDidTouch(sender: AnyObject) {
        let alert = UIAlertController(title: "Add a Song",
            message: "Enter information here",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction!) -> Void in
                
                let nameField = alert.textFields![0] as UITextField
                let keyField = alert.textFields![1] as UITextField
                let soloField = alert.textFields![2] as UITextField
                let songItem = SongItem(name: nameField.text!, key: keyField.text!, soloist: soloField.text!)
                let songItemRef = self.myRootRef.childByAppendingPath("groups").childByAppendingPath("-KE2t-HbseflgtLhuV8-").childByAppendingPath("songs").childByAutoId()
                songItemRef.setValue(songItem.toAnyObject())
                self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Title"
        }
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Key"
        }
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Soloist"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
    }
    
    
    
}
