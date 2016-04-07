//
//  SongInfoViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 3/31/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import Firebase
import SwiftyDropbox

class SongInfoViewController: UITableViewController {
    
    var song: SongItem!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var soloistLabel: UILabel!
    @IBOutlet weak var keyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.tabBarController?.tabBar.hidden = false
        titleLabel.text = song.name
        soloistLabel.text = song.soloist
        keyLabel.text = song.key
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func linkToDB(sender: AnyObject) {
        Dropbox.authorizeFromController(self)
    }

    @IBAction func dbChooser(sender: AnyObject) {
        DBChooser.defaultChooser().openChooserForLinkType(DBChooserLinkTypePreview, fromViewController: self, completion: { (results: [AnyObject]!) -> Void in
            if results == nil {
                print("user cancelled")
            } else {
                print(results.description)
            }
        })
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
