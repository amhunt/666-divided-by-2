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

class SongInfoViewController: UITableViewController, TagListViewDelegate {
    
    var song: SongItem!
    var groupKey: String!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var soloistLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    
    @IBOutlet weak var showPdfButton: UIButton!
    @IBOutlet weak var linkPdfButton: UIButton!
    
    @IBOutlet weak var tagListView: TagListView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tabBarController?.tabBar.hidden = false
        titleLabel.text = song.name
        soloistLabel.text = song.soloist
        keyLabel.text = song.key
        
        //configure tag list view
        tagListView.delegate = self
        tagListView.textFont = UIFont(name: "Avenir-Book", size: 16.0)!
        tagListView.marginX = 5.0
        tagListView.marginY = 5.0
        
        // display song's tags
        for tag in song.tags {
            tagListView.addTag(tag)
        }
        
        for tag in tagListView.tagViews {
            print((tag.titleLabel?.text)!)
        }
        
        //configure sheet music buttons
        if song.pdfUrl == nil {
            showPdfButton.enabled = false
            showPdfButton.backgroundColor = UIColor.lightGrayColor()
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
                let songItemRef = Firebase(url: "https://popping-inferno-1963.firebaseio.com").childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("songs").childByAppendingPath(self.song.id)
                songItemRef.setValue(self.song.toAnyObject())
            }
        })
    }
    
    // MARK: TagListViewDelegate
    
    func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) {
        let songItemRef = Firebase(url: "https://popping-inferno-1963.firebaseio.com").childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("songs").childByAppendingPath(self.song.id)
        sender.removeTagView(tagView)
        for i in 0 ..< self.song.tags.count {
            if (self.song.tags[i] == title) {
                self.song.tags.removeAtIndex(i)
            }
        }
        songItemRef.childByAppendingPath("tags").setValue(self.song.tags)
    }
    
    @IBAction func addTagDidTouch(sender: AnyObject) {
        let songItemRef = Firebase(url: "https://popping-inferno-1963.firebaseio.com").childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("songs").childByAppendingPath(self.song.id)
        
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
                songItemRef.childByAppendingPath("tags").setValue(self.song.tags)
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
