//
//  SongInfoViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 3/31/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import Firebase
import DBChooser
import TagListView
import AVFoundation
import ZAlertView
import NVActivityIndicatorView

class SongInfoViewController: UITableViewController, TagListViewDelegate {
    
    var song: SongItem!
    var groupKey: String!
    var player: AVAudioPlayer!
    
    var pitchPlayer: PitchPlayer!
    var currentPitch: String?
    var pitchView: PitchView!
    var activityView: NVActivityIndicatorView!
    
    var songRefEvent: UInt?
    
    let pitchDict = ["A":"A", "A#":"Bb", "Ab":"Ab", "B":"B", "Bb":"Bb",
        "C":"C", "C#":"C#", "D":"D", "Db":"C#", "D#":"Eb", "Eb":"Eb", "E":"E",
        "F":"F", "F#":"F#", "G":"G", "Gb":"F#", "G#":"Ab"
    ]
    
    let infoOrder = ["title", "solo", "key"]

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var soloistLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var keyCell: UITableViewCell!
    
    @IBOutlet weak var showPdfButton: UIButton!
    @IBOutlet weak var linkPdfButton: UIButton!
    
    @IBOutlet weak var tagListView: TagListView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.hidden = false
        refreshLabels()
        
        //configure tag list view
        tagListView.delegate = self
        tagListView.textFont = UIFont(name: "Avenir-Book", size: 16.0)!
        tagListView.marginX = 5.0
        tagListView.marginY = 5.0
        
        // display song's tags
        for tag in song.tags {
            tagListView.addTag(tag)
        }
        
        //configure sheet music buttons
        if song.pdfUrl == nil {
            showPdfButton.enabled = false
            showPdfButton.backgroundColor = UIColor.lightGrayColor()
            showPdfButton.setTitle("Tap Edit to link sheet music", forState: .Normal)
        }
        
        // configure circle buttons
        keyLabel.layer.cornerRadius = keyLabel.frame.size.width / 2
        keyLabel.layer.masksToBounds = true
        
        // set up pitch gesture
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(SongInfoViewController.longPress(_:)))
        longPressRecognizer.minimumPressDuration = 0.1
        self.keyLabel.addGestureRecognizer(longPressRecognizer)
        pitchPlayer = PitchPlayer()
        
        let activityFrame = keyCell.convertRect(keyLabel.frame, toView: self.view)
        
        activityView = NVActivityIndicatorView(frame: activityFrame, type: .BallScaleRipple)
        
        // play with mute switch on
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print("audio error")
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        // update song from db
        let songItemRef = Firebase(url: "https://popping-inferno-1963.firebaseio.com").childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("songs").childByAppendingPath(self.song.id)
        songRefEvent = songItemRef.observeEventType(.Value, withBlock: {snapshot in
            self.song = SongItem(snapshot: snapshot)
            self.refreshLabels()
        })
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        let songItemRef = Firebase(url: "https://popping-inferno-1963.firebaseio.com").childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("songs").childByAppendingPath(self.song.id)
        if songRefEvent != nil {
            songItemRef.removeObserverWithHandle(songRefEvent!)
        }
    }
    
    // MARK: - Refresh functions (for view and Firebase)
    
    func refreshLabels() -> Void {
        titleLabel.text = song.name
        soloistLabel.text = song.soloist
        keyLabel.text = song.key
        
        if song.pdfUrl != nil {
            self.showPdfButton.enabled = true
            self.showPdfButton.backgroundColor = UIColor.init(red: 107/255, green: 80/255, blue: 176/255, alpha: 1)
            self.showPdfButton.setTitle("🎹 Show sheet music", forState: .Normal)
        }
        
        tagListView.removeAllTags()
        for tag in song.tags {
            tagListView.addTag(tag)
        }
    }
    
    func updateSongInFirebase() -> Void {
        let songItemRef = Firebase(url: "https://popping-inferno-1963.firebaseio.com").childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("songs").childByAppendingPath(self.song.id)
        songItemRef.setValue(self.song.toAnyObject())
        songItemRef.childByAppendingPath("tags").setValue(self.song.tags)
    }
    
    // MARK: - Play pitch
    
    func longPress(longPressRecognizer: UILongPressGestureRecognizer) {
        
        if longPressRecognizer.state == .Began {
            let pitchText = song.key
            currentPitch = self.pitchDict[pitchText]!
            pitchPlayer.play(self.pitchDict[pitchText]!)
            
            let activityFrame = keyCell.convertRect(keyLabel.frame, toView: self.view)
            activityView.frame = activityFrame
            self.view.addSubview(activityView)
            activityView.startAnimation()
        }
        
        if longPressRecognizer.state == .Ended {
            if currentPitch != nil {
                pitchPlayer.stop(currentPitch!)
                activityView.removeFromSuperview()
                activityView.stopAnimation()
            }
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    // MARK: TagListViewDelegate
    
    func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) {
        sender.removeTagView(tagView)
        for i in 0 ..< self.song.tags.count {
            if (self.song.tags[i] == title) {
                self.song.tags.removeAtIndex(i)
                break
            }
        }
        self.updateSongInFirebase()
    }
    
    @IBAction func addTagDidTouch(sender: AnyObject) {
        
        let addTagAlert = ZAlertView(title: "Add a Tag", message: "", isOkButtonLeft: false, okButtonText: "Save", cancelButtonText: "Cancel",
            okButtonHandler: {alert in
                let newTag = alert.getTextFieldWithIdentifier("newtag")?.text
                if newTag != "" {
                    self.tagListView.addTag(newTag!)
                    self.song.tags.append(newTag!)
                    self.updateSongInFirebase()
                }
                alert.dismiss()
            },
            cancelButtonHandler: {alert in alert.dismiss()})
        
        addTagAlert.addTextField("newtag", placeHolder: "")
        addTagAlert.getTextFieldWithIdentifier("newtag")?.autocapitalizationType = .None
        
        addTagAlert.show()
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowPDF" {
            let destination = segue.destinationViewController as! PDFViewController
            if song.pdfUrl != nil {
                destination.pdfUrlString = song.pdfUrl
            }
        }
        if segue.identifier == "EditSong" {
            let destinationNav = segue.destinationViewController as! UINavigationController
            let destinatinon = destinationNav.topViewController as! AddSongFormViewController
            destinatinon.song = self.song
            destinatinon.groupKey = self.groupKey
        }
    }
 

}
