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

class SongInfoViewController: UITableViewController {
    
    var song: SongItem!
    var groupKey: String!
    

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var soloistLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    
    @IBOutlet weak var showPdfButton: UIButton!
    @IBOutlet weak var linkPdfButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tabBarController?.tabBar.hidden = false
        titleLabel.text = song.name
        soloistLabel.text = song.soloist
        keyLabel.text = song.key
        
        //configure buttons
        if song.pdfUrl == nil {
            showPdfButton.enabled = false
            showPdfButton.backgroundColor = UIColor.lightGrayColor()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func linkToDB(sender: AnyObject) {
//        Dropbox.authorizeFromController(self)
    }

    @IBAction func dbChooser(sender: AnyObject) {
        DBChooser.defaultChooser().openChooserForLinkType(DBChooserLinkTypeDirect, fromViewController: self, completion: { (results: [AnyObject]!) -> Void in
            if results == nil {
                print("user cancelled")
            } else {
                self.showPdfButton.enabled = true
                self.showPdfButton.backgroundColor = UIColor.init(red: 107/255, green: 80/255, blue: 176/255, alpha: 1)
                self.song.pdfUrl = (results[0].link as NSURL).absoluteString
                let songItemRef = Firebase(url: "https://popping-inferno-1963.firebaseio.com").childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("songs").childByAppendingPath(self.song.id)
                songItemRef.setValue(self.song.toAnyObject())
            }
        })
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
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
