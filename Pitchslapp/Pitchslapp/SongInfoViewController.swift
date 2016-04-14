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
import ActionSheetPicker_3_0

class SongInfoViewController: UITableViewController, TagListViewDelegate {
    
    var song: SongItem!
    var groupKey: String!
    var player: AVAudioPlayer!
    
    let pitchDict = ["A":"A", "A#":"Bb", "Ab":"Ab", "B":"B", "Bb":"Bb",
        "C":"C", "C#":"C#", "D":"D", "Db":"C#", "D#":"Eb", "Eb":"Eb", "E":"EHigh",
        "F":"F", "F#":"F#", "G":"G", "Gb":"F#", "G#":"Ab"
    ]
    
    let infoOrder = ["title", "solo", "key"]

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var soloistLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    
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
        }
    }
    
    // MARK: - Refresh functions (for view and Firebase)
    
    func refreshLabels() -> Void {
        titleLabel.text = song.name
        soloistLabel.text = song.soloist
        keyLabel.text = song.key
    }
    
    func updateSongInFirebase() -> Void {
        let songItemRef = Firebase(url: "https://popping-inferno-1963.firebaseio.com").childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("songs").childByAppendingPath(self.song.id)
        songItemRef.setValue(self.song.toAnyObject())
        songItemRef.childByAppendingPath("tags").setValue(self.song.tags)
    }
    
    // MARK: - Play pitch
    
    @IBAction func playPitchDidTouch(sender: AnyObject) {
        let pitchText = song.key as String
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
    
    // MARK: - Edit song information
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .Normal, title: "Edit") {action, index in
            // display an action with text box to edit information
            var alertTitle: String
            var alertMessage: String
            
            switch self.infoOrder[index.row] {
            case "title":
                alertTitle = "Edit title"
                alertMessage = "Enter a new title for your song."
            case "solo":
                alertTitle = "Edit soloist"
                alertMessage = "Enter a new soloist for your song."
            default:
                alertTitle = "ERROR"
                alertMessage = "ERROR"
            }
            
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .Alert)
            
            alert.addTextFieldWithConfigurationHandler {
                (textField: UITextField!) -> Void in
                if self.infoOrder[index.row] == "title" {
                    textField.text = self.song.name
                } else if self.infoOrder[index.row] == "solo" {
                    textField.text = self.song.soloist
                    textField.autocapitalizationType = UITextAutocapitalizationType.Words
                }
            }
            
            let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
                let editedField = alert.textFields![0] as UITextField
                // update song item
                if editedField.text != "" {
                    if self.infoOrder[index.row] == "title" {
                        self.song.name = editedField.text
                    } else if self.infoOrder[index.row] == "solo" {
                        self.song.soloist = editedField.text
                    }
                    self.refreshLabels()
                    // update firebase
                    self.updateSongInFirebase()
                    self.tableView.editing = false
                }
                
            }
            let cancelAction = UIAlertAction(title: "Cancel",
               style: .Destructive) { (action: UIAlertAction!) -> Void in
            }
            alert.addAction(cancelAction)
            alert.addAction(saveAction)
            
            if self.infoOrder[index.row] == "title" || self.infoOrder[index.row] == "solo" {
                self.presentViewController(alert,
                                      animated: true,
                                      completion: nil)
                self.tableView.editing = false
            }
            
            // change key (pitch)
            
            else if self.infoOrder[index.row] == "key" {
                let keys = ["A", "A#", "Ab", "B", "Bb", "C", "C#", "D", "Db", "D#", "Eb", "E", "F", "F#", "G", "Gb", "G#"]
                ActionSheetStringPicker.showPickerWithTitle("Change key", rows: keys, initialSelection: keys.indexOf(self.song.key)!,
                       doneBlock: {picker, selectedIndex, value in
                        self.song.key = keys[selectedIndex]
                        self.refreshLabels()
                        self.updateSongInFirebase()
                        self.tableView.editing = false
                    },
                       cancelBlock: {ActionMultipleStringCancelBlock in
                        self.tableView.editing = false
                        return
                    },
                       origin: self.view)
            }
        }
        editAction.backgroundColor = UIColor.init(red: 107/255, green: 80/255, blue: 176/255, alpha: 1)
        return [editAction]
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Dropbox file chooser
    
    // given a DB preview url, change dl=0 to dl=1 (making it a direct link)
    func convertToDirectLink(url: String) -> String {
        let count = url.characters.count
        return (url as NSString).substringToIndex(count-1) + "1"
    }
    
    @IBAction func dbChooser(sender: AnyObject) {
        DBChooser.defaultChooser().openChooserForLinkType(DBChooserLinkTypePreview, fromViewController: self, completion: { (results: [AnyObject]!) -> Void in
            if results == nil {
                print("user cancelled")
            } else {
                self.showPdfButton.enabled = true
                self.showPdfButton.backgroundColor = UIColor.init(red: 107/255, green: 80/255, blue: 176/255, alpha: 1)
                let pdfUrl = (results[0].link as NSURL).absoluteString
                self.song.pdfUrl = self.convertToDirectLink(pdfUrl)
                self.updateSongInFirebase()
            }
        })
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
        
        let alert = UIAlertController(title: "Add a tag",
            message: "",
            preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Tag"
        }
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
            let tagField = alert.textFields![0] as UITextField
            if (tagField.text!) != "" {
                self.tagListView.addTag(tagField.text!)
                self.song.tags.append(tagField.text!)
                self.updateSongInFirebase()
            }
            
        }
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Destructive) { (action: UIAlertAction!) -> Void in
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        presentViewController(alert,
           animated: true,
           completion: nil)
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
    }
 

}
