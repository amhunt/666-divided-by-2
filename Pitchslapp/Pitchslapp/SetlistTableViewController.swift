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
import ZAlertView

class SetlistTableViewController: UITableViewController {

    var myRootRef = Firebase(url:"https://popping-inferno-1963.firebaseio.com")
    var songs = [SongItem]()
    var user: User!
    var setlist: Setlist!
    var groupKey: String?
    
    var pitchPlayer: PitchPlayer!
    var currentPitch: String?
    var pitchView: PitchView!
    var longPressRecognizer: UILongPressGestureRecognizer!
    
    var watchEvent: UInt?
    
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

    override func viewWillAppear(animated: Bool) {
        pitchPlayer.changeOctave()
        
        let songIdsRef = myRootRef.childByAppendingPath("groups").childByAppendingPath(groupKey).childByAppendingPath("setlists").childByAppendingPath(setlist.id).childByAppendingPath("songIds")
        
        // monitor list of song ids in the setlist
        watchEvent = songIdsRef.observeEventType(.Value, withBlock: {snapshot in
            var newSongs = [SongItem]()
            var newSongIds = [String]()
            // for each song id in the setlist, look up the song data and add it to the
            // tableview
            for item in snapshot.children {
                let songId = (item as! FDataSnapshot).value as! String
                newSongIds.append(songId)
                self.myRootRef.childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("songs").childByAppendingPath(songId).observeSingleEventOfType(.Value, withBlock: { songData in
                    
                    if songData.value is NSNull {
                        // TODO: clean out dead references
                    } else {
                        let songItem = SongItem(snapshot: songData as FDataSnapshot)
                        
                        newSongs.append(songItem)
                        self.songs = newSongs
                        self.tableView.reloadData()
                    }
                    
                })
                self.setlist.songIds = newSongIds
            }
        })
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = setlist.name
        
        // set up pitch gesture
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SetlistTableViewController.longPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.3
        self.view.addGestureRecognizer(longPressRecognizer)
        pitchPlayer = PitchPlayer()
        
        pitchView = PitchView(frame: self.view.frame)
        
        // play with mute switch on
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("audio error")
        }
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewDidDisappear(animated: Bool) {
        let songIdsRef = myRootRef.childByAppendingPath("groups").childByAppendingPath(groupKey).childByAppendingPath("setlists").childByAppendingPath(setlist.id).childByAppendingPath("songIds")
        if watchEvent != nil {
            songIdsRef.removeObserverWithHandle(watchEvent!)
        }
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
        let cell = tableView.dequeueReusableCellWithIdentifier("SongCell", forIndexPath: indexPath) as! SetlistSongTableViewCell
        
        let songItem = songs[indexPath.row]
        
        cell.titleLabel?.text = songItem.name
        cell.soloLabel?.text = songItem.soloist
        cell.keyLabel?.text = songItem.key
        cell.indexLabel?.text = String(indexPath.row + 1) // +1 accounts for 0 index
        
        return cell
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        if editing {
            self.view.removeGestureRecognizer(longPressRecognizer)
        } else {
            self.view.addGestureRecognizer(longPressRecognizer)
        }
        super.setEditing(editing, animated: animated)
    }

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            setlist.songIds.removeAtIndex(indexPath.row)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    // swipe actions for pitch and delete
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        // remove song swipe action
        let delete = UITableViewRowAction(style: .Destructive, title: "Remove") {action, index in
            self.setlist.songIds.removeAtIndex(index.row)
            let setlistRef = self.myRootRef.childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("setlists").childByAppendingPath(self.setlist.id)
            setlistRef.childByAppendingPath("songIds").setValue(self.setlist.songIds)
            self.tableView.reloadData()
        }
        
        return [delete]
    }

    
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
        
        var idsOfSongsInView = [String]()
        for song in songs {
            idsOfSongsInView.append(song.id)
        }
        
        let songIdToMove = idsOfSongsInView[fromIndexPath.row]
        idsOfSongsInView.removeAtIndex(fromIndexPath.row)
        idsOfSongsInView.insert(songIdToMove, atIndex: toIndexPath.row)
        
        setlist.songIds = idsOfSongsInView
        
        let setlistRef = myRootRef.childByAppendingPath("groups").childByAppendingPath(groupKey).childByAppendingPath("setlists").childByAppendingPath(setlist.id)
        setlistRef.childByAppendingPath("songIds").setValue(setlist.songIds)
        
    }
    
    func longPress(longPressRecognizer: UILongPressGestureRecognizer) {
        let touchPoint = longPressRecognizer.locationInView(self.view)

        if longPressRecognizer.state == .Began {
            if let indexPath = tableView.indexPathForRowAtPoint(touchPoint) {
                
                let pitchText = songs[indexPath.row].key
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
