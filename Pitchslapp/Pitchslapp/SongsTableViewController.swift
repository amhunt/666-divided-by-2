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
import AVFoundation

class SongsTableViewController: UITableViewController {
    var myRootRef = Firebase(url:"https://popping-inferno-1963.firebaseio.com")
    var songs = [SongItem]()
    var user: User!
    var groupKey: String?
//    var groupName = [String]()
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
    
    override func viewDidAppear(animated: Bool) {
        myRootRef.observeAuthEventWithBlock { (authData) in
            if authData != nil {
                self.user = User(authData: authData)
                
                // get user's group id
                self.myRootRef.childByAppendingPath("users").childByAppendingPath(self.user.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    // try to get it from the group-choose segue (first-time users)
                    // otherwise, check the user data
                    if self.groupKey == nil {
                        self.groupKey = snapshot.value["groupid"] as? String
                    }
                    
//                    self.myRootRef.childByAppendingPath("groups").childByAppendingPath(self.groupKey).observeSingleEventOfType(.Value, withBlock: { snapshot in
//                        if self.groupName.count == 0 {
//                            self.groupName = [""]
//                            self.groupName[0] = (snapshot.value["name"] as? String)!
//                            self.tableView.reloadData()
//                        }
//                    })
                    
                    // populate table with songs for that group
                    let songsRef = self.myRootRef.childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("songs")
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
                })
            } else {
                self.performSegueWithIdentifier("LogoutSegue", sender: nil)
            }
        }
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//        return 2
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if (section == 1) {
            return songs.count
//        } else {
//            return groupName.count
//        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongCell", forIndexPath: indexPath) as! SongTableViewCell
        
//        if indexPath.section == 0 {
//            let group = groupName[indexPath.row]
//            let cell = tableView.dequeueReusableCellWithIdentifier("GroupNameCell", forIndexPath: indexPath) as UITableViewCell
//            cell.textLabel!.text = group
//            
//        } else if indexPath.section == 1 {
            let songItem = songs[indexPath.row]
            
            cell.titleLabel?.text = songItem.name
            cell.soloLabel?.text = songItem.soloist
            cell.keyLabel?.text = songItem.key
//        }
    
        return cell
    }
    
    // swipe actions for pitch and delete
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        if (indexPath.section == 1) {
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
            let delete = UITableViewRowAction(style: .Destructive, title: "Delete") {action, index in
                let confirmDeleteAlert = UIAlertController(title: "Delete", message: "Are you sure you want to delete " + self.songs[indexPath.row].name + "?", preferredStyle: .Alert)
                let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action: UIAlertAction!) -> Void in
                    let songItem = self.songs[indexPath.row]
                    songItem.ref?.removeValue()
                    self.tableView.reloadData()
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction!) -> Void in
                    self.tableView.editing = false
                }
                confirmDeleteAlert.addAction(cancelAction)
                confirmDeleteAlert.addAction(deleteAction)
                self.presentViewController(confirmDeleteAlert, animated: true, completion: nil)
            }
            return [pitch, delete]
//        }
//        return []
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
        }
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
                let songItemRef = self.myRootRef.childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("songs").childByAutoId()
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
    
    @IBAction func logoutButtonDidTouch(sender: AnyObject) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout of your account?", preferredStyle: .Alert)
        
        let logoutAction = UIAlertAction(title: "Logout", style: .Destructive) { (action: UIAlertAction!) -> Void in
                self.myRootRef.unauth()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSong" {
            let destination = segue.destinationViewController as! SongInfoViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            destination.song = songs[indexPath.row]
            destination.groupKey = groupKey!
        }
    }

    
}
