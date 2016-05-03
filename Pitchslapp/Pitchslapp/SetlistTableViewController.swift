//
//  SetlistTableViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 4/22/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import AVFoundation

class SetlistTableViewController: UITableViewController {

    var myRootRef = Firebase(url:"https://popping-inferno-1963.firebaseio.com")
    var songs = [SongItem]()
    var user: User!
    var setlist: Setlist!
    var groupKey: String?
    var player: AVAudioPlayer!
    
    let pitchDict = [
        "A":"A",
        "A#":"Bb",
        "Ab":"Ab",
        "B":"B",
        "Bb":"Bb",
        "C":"C",
        "C#":"C#",
        "D":"D",
        "Db":"C#",
        "D#":"Eb",
        "Eb":"Eb",
        "E":"EHigh",
        "F":"F",
        "F#":"F#",
        "G":"G",
        "Gb":"F#",
        "G#":"Ab"
    ]

    override func viewWillAppear(animated: Bool) {
       
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = setlist.name
        
        let songIdsRef = myRootRef.childByAppendingPath("groups").childByAppendingPath(groupKey).childByAppendingPath("setlists").childByAppendingPath(setlist.id).childByAppendingPath("songIds")
        
        
        
        songIdsRef.observeEventType(.Value, withBlock: {snapshot in
            var newSongs = [SongItem]()
            for item in snapshot.children {
                let songId = (item as! FDataSnapshot).value as! String
                self.myRootRef.childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("songs").childByAppendingPath(songId).observeSingleEventOfType(.Value, withBlock: { songData in
                    let songItem = SongItem(snapshot: songData as FDataSnapshot)
                    
                    newSongs.append(songItem)
                    self.songs = newSongs
                    self.tableView.reloadData()
                })
            }
        })
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
         self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            setlist.songIds.removeAtIndex(indexPath.row)

            
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // swipe actions for pitch and delete
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let pitchText = songs[indexPath.row].key as String
        let pitch = UITableViewRowAction(style: .Normal, title: " " + pitchText + " ") {action, index in
            let path = NSBundle.mainBundle().pathForResource(self.pitchDict[pitchText], ofType:"mp3", inDirectory: "Pitches")!
            let url = NSURL(fileURLWithPath: path)
            let stopAlert = UIAlertController(title: "Playing: " + pitchText, message: "Make sure your volume switch is on!", preferredStyle: .Alert)
            let stopAction = UIAlertAction(title: "Stop", style: .Destructive) { (action: UIAlertAction!) -> Void in
                if self.player != nil {
                    self.player.stop()
                    self.player = nil
                }
                self.tableView.editing = false
            }
            stopAlert.addAction(stopAction)
            do {
                let sound = try AVAudioPlayer(contentsOfURL: url)
                self.player = sound
                sound.play()
                self.presentViewController(stopAlert, animated: true, completion: nil)
            } catch {
                // couldn't load file :(
            }
        }
        pitch.backgroundColor = UIColor.init(red: 107/255, green: 80/255, blue: 176/255, alpha: 1)

        return [pitch]
    }

    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        let songToMove = setlist.songIds[fromIndexPath.row]
        setlist.songIds.removeAtIndex(fromIndexPath.row)
        setlist.songIds.insert(songToMove, atIndex: toIndexPath.row)
        
        let setlistRef = myRootRef.childByAppendingPath("groups").childByAppendingPath(groupKey).childByAppendingPath("setlists").childByAppendingPath(setlist.id)
        setlistRef.childByAppendingPath("songIds").setValue(setlist.songIds)
        
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "ShowSong" {
            let destination = segue.destinationViewController as! SongInfoViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            destination.song = songs[indexPath.row]
            destination.groupKey = groupKey!
        }
        if segue.identifier == "AddSongs" {
            let destinationNav = segue.destinationViewController as! UINavigationController
            let destination = destinationNav.viewControllers[0] as! ChooseSongsTableViewController
            destination.setlist = setlist
            destination.groupKey = groupKey
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        
    }

}
