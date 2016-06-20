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
import ZAlertView

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
    
    var pitchPlayer: PitchPlayer!
    var currentPitch: String?
    var pitchView: PitchView!
    
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
        "E":"E",
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
        
        // set up pitch gesture
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SongsTableViewController.longPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.2
        self.view.addGestureRecognizer(longPressRecognizer)
        pitchPlayer = PitchPlayer()
        
        pitchView = PitchView(frame: self.view.frame)
        
        // play with mute switch on
        do {
           try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("audio error")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        pitchPlayer.changeOctave()
        
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
        
        // swipe for delete
        let delete = UITableViewRowAction(style: .Destructive, title: "Delete") {action, index in
            
            let deleteAlert = ZAlertView(title: "Delete", message: "Are you sure you want to delete " + songItem.name + "?", isOkButtonLeft: true, okButtonText: "Cancel", cancelButtonText: "Delete",
                okButtonHandler: {alert in
                    self.tableView.editing = false
                    alert.dismiss()
                }, cancelButtonHandler: {alert in
                    self.tableView.editing = false
                    songItem.ref?.removeValue()
                    if self.searchController.active && self.searchController.searchBar.text != "" {
                        self.filteredSongs.removeAtIndex(index.row)
                    }
                    self.tableView.reloadData()
                    alert.dismiss()
            })
            
            deleteAlert.show()
        }
        return [delete]
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
        }
    }
    
    func longPress(longPressRecognizer: UILongPressGestureRecognizer) {
        let touchPoint = longPressRecognizer.locationInView(self.view)
        
        if longPressRecognizer.state == .Began {
            if let indexPath = tableView.indexPathForRowAtPoint(touchPoint) {
                
                let songItem: SongItem
                
                if searchController.active && searchController.searchBar.text != "" {
                    songItem = filteredSongs[indexPath.row]
                } else {
                    songItem = songs[indexPath.row]
                }
                
                let pitchText = songItem.key
                currentPitch = self.pitchDict[pitchText]!
                pitchPlayer.play(self.pitchDict[pitchText]!)
                tableView.cellForRowAtIndexPath(indexPath)?.selected = true
                pitchView.showInView(self.tabBarController?.view, withMessage: pitchText, animated: true)
            }
        }
        
        if longPressRecognizer.state == .Ended {
            if currentPitch != nil {
                pitchPlayer.stop(currentPitch!)
            }
            let visibleRows = tableView.indexPathsForVisibleRows
            for row in visibleRows! {
                tableView.cellForRowAtIndexPath(row)?.selected = false
            }
            pitchView.removeFromView()
        }
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
            let destination = destinationNav.topViewController as! AddSongFormViewController
            destination.groupKey = groupKey!
        }
    }

    
}
