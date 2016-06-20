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
import ZAlertView

class PitchesTableViewController: UITableViewController {
    
    var pitchPlayer: PitchPlayer!
    var currentPitch: String?
    var pitchView: PitchView!
    
    let pitches = ["C (low)", "C#/Db", "D", "D#/Eb", "E", "F", "F#/Gb", "G", "G#/Ab", "A", "A#/Bb", "B", "C (high)"]
    
    let pitchDict = ["E":"E", "F":"F", "F#/Gb":"F#", "G":"G", "G#/Ab":"Ab", "A":"A", "A#/Bb":"Bb", "B":"B", "C (low)":"CLow", "C#/Db":"C#", "D":"D", "D#/Eb":"Eb", "C (high)":"CHigh"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(PitchesTableViewController.longPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.2
        self.view.addGestureRecognizer(longPressRecognizer)
        
        // play with mute switch on
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("audio error")
        }
        
        pitchPlayer = PitchPlayer()
    }
    
    override func viewWillAppear(animated: Bool) {
        pitchPlayer.changeOctave()
    }
    
    func longPress(longPressRecognizer: UILongPressGestureRecognizer) {
        let touchPoint = longPressRecognizer.locationInView(self.view)

        if longPressRecognizer.state == .Began {
            if let indexPath = tableView.indexPathForRowAtPoint(touchPoint) {
                let pitchText = pitches[indexPath.row]
                currentPitch = self.pitchDict[pitchText]!
                pitchPlayer.play(self.pitchDict[pitchText]!)
                
                pitchView = PitchView(frame: self.view.frame)
                pitchView.showInView(self.tabBarController?.view, withMessage: pitchText, animated: true)
                
                tableView.cellForRowAtIndexPath(indexPath)?.selected = true
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

  
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pitches.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PitchCell", forIndexPath: indexPath) as! PitchTableViewCell
        cell.pitchLabel?.text = pitches[indexPath.row]
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

}
