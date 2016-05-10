//
//  PitchesTableViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 5/3/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation

class PitchesTableViewController: UITableViewController {

    var player: AVAudioPlayer!
    
    let pitches = ["E (low)", "F", "F#/Gb", "G", "G#/Ab", "A", "A#/Bb", "B", "C", "C#/Db", "D", "D#/Eb", "E (high)"]
    
    let pitchDict = ["E (low)":"ELow", "F":"F", "F#/Gb":"F#", "G":"G", "G#/Ab":"Ab", "A":"A", "A#/Bb":"Bb", "B":"B", "C":"C", "C#/Db":"C#", "D":"D", "D#/Eb":"Eb", "E (high)":"EHigh"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // play with mute switch on
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("audio error")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        return pitches.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PitchCell", forIndexPath: indexPath) as! PitchTableViewCell

        // Configure the cell...
        cell.pitchLabel?.text = pitches[indexPath.row]

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let pitchText = pitches[indexPath.row]
        let path = NSBundle.mainBundle().pathForResource(self.pitchDict[pitchText], ofType:"mp3", inDirectory: "Pitches")!
        let url = NSURL(fileURLWithPath: path)
        let stopAlert = UIAlertController(title: "Playing: " + pitchText, message: "Make sure your volume switch is on!", preferredStyle: .Alert)
        let stopAction = UIAlertAction(title: "Stop", style: .Destructive) { (action: UIAlertAction!) -> Void in
            if self.player != nil {
                self.player.stop()
                self.player = nil
            }
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
        tableView.cellForRowAtIndexPath(indexPath)?.selected = false
    }


}
