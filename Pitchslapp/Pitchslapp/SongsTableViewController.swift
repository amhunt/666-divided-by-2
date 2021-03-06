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

extension SongsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

extension SongsTableViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

class SongsTableViewController: UITableViewController {
    var myRootRef = Firebase(url:"https://popping-inferno-1963.firebaseio.com")
    var songs = [SongItem]()
    var user: User!
    var groupKey: String?
    var player: AVAudioPlayer!
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredSongs = [SongItem]()
    
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
    
    override func viewDidLoad() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.scopeButtonTitles = ["Title", "Soloist", "Tags"]
        searchController.searchBar.barTintColor = UIColor.init(red: 107/255, green: 80/255, blue: 176/255, alpha: 1)
        searchController.searchBar.tintColor = UIColor.whiteColor()
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        // play with mute switch on
        do {
           try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("audio error")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        myRootRef.observeAuthEventWithBlock { (authData) in
            if authData != nil {
                self.user = User(authData: authData)
                
                self.myRootRef.childByAppendingPath("users").childByAppendingPath(self.user.uid).observeSingleEventOfType(.Value, withBlock: {
                    snapshot in
                    self.user = User(snapshot: snapshot)
                })
                
                // get user's group id
                self.myRootRef.childByAppendingPath("users").childByAppendingPath(self.user.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    
                    self.user = User(snapshot: snapshot)
                    
                    // try to get it from the group-choose segue (first-time users)
                    // otherwise, check the user data
                    if self.groupKey == nil {
                        self.groupKey = self.user.groupKey
                    }
                    
                    // populate table with songs for that group
                    let songsRef = self.myRootRef.childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("songs")
                    songsRef.observeEventType(.Value, withBlock: { snapshot in
                        var newSongs = [SongItem]()
                        
                        for item in snapshot.children {
                            var songItem = SongItem(snapshot: item as! FDataSnapshot)
                            if snapshot.hasChild("tags") {
                                songItem.tags = snapshot.valueForKey("tags") as! [String]
                            }
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
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredSongs.count
        }
        return songs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongCell", forIndexPath: indexPath) as! SongTableViewCell

        let songItem: SongItem
        
        if searchController.active && searchController.searchBar.text != "" {
            songItem = filteredSongs[indexPath.row]
        } else {
            songItem = songs[indexPath.row]
        }
        
        cell.titleLabel?.text = songItem.name
        cell.soloLabel?.text = songItem.soloist
        cell.keyLabel?.text = songItem.key
    
        return cell
    }
    
    // swipe actions for pitch and delete
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let songItem: SongItem
        if self.searchController.active && self.searchController.searchBar.text != "" {
            songItem = self.filteredSongs[indexPath.row]
        } else {
            songItem = self.songs[indexPath.row]
        }
        
        // swipe for pitch
        let pitchText = songItem.key as String
        let pitch = UITableViewRowAction(style: .Normal, title: " " + pitchText + " ") {action, index in
            let path = NSBundle.mainBundle().pathForResource(self.pitchDict[pitchText], ofType:"mp3", inDirectory: "Pitches")!
            let url = NSURL(fileURLWithPath: path)
            let stopAlert = UIAlertController(title: "Playing: " + pitchText, message: "Tap below to stop the pitch.", preferredStyle: .Alert)
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
        
        // swipe for delete
        let delete = UITableViewRowAction(style: .Destructive, title: "Delete") {action, index in
            let confirmDeleteAlert = UIAlertController(title: "Delete", message: "Are you sure you want to delete " + songItem.name + "?", preferredStyle: .Alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) { (action: UIAlertAction!) -> Void in
                songItem.ref?.removeValue()
                if self.searchController.active && self.searchController.searchBar.text != "" {
                    self.filteredSongs.removeAtIndex(index.row)
                }
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
    
    
    // update view based on search
    func filterContentForSearchText(searchText: String, scope: String = "Title") {
        filteredSongs = songs.filter { song in
            if scope == "Soloist" {
                return song.soloist.lowercaseString.containsString(searchText.lowercaseString)
            } else if scope == "Tags" {
                //come back to this
                let lowerTags = song.tags.map({tag in tag.lowercaseString})
                var contains = false
                for tag in lowerTags {
                    if tag.containsString(searchText.lowercaseString) {
                        contains = true
                    }
                }
                return contains
            } else {
                return song.name.lowercaseString.containsString(searchText.lowercaseString)
            }
        }
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowSong" {
            let destination = segue.destinationViewController as! SongInfoViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            if searchController.active && searchController.searchBar.text != "" {
                destination.song = filteredSongs[indexPath.row]
            } else {
                destination.song = songs[indexPath.row]
            }
            destination.groupKey = groupKey!
        }
        else if segue.identifier == "ShowSettings" {
            let destinationNav = segue.destinationViewController as! UINavigationController
            let destination = destinationNav.topViewController as! SettingsViewController
            destination.user = self.user
        }
        else if segue.identifier == "AddSong" {
            let destinationNav = segue.destinationViewController as! UINavigationController
            let destination = destinationNav.topViewController as! AddSongViewController
            destination.groupKey = groupKey!
        }
    }

    
}
