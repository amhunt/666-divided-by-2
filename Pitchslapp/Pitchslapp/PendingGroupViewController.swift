//
//  PendingGroupViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 4/14/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit

class PendingGroupViewController: UITableViewController {

    @IBOutlet weak var groupNameLabel: UILabel!
    var group: Group!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
