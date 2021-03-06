//
//  PendingGroupViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 4/14/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import Firebase

class PendingGroupViewController: UITableViewController {

    @IBOutlet weak var groupNameLabel: UILabel!
    var groupKey: String!
    
    var status: String!
    
    let ref = Firebase(url: "https://popping-inferno-1963.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        status = "pending"
        
        ref.childByAppendingPath("groups").childByAppendingPath(self.groupKey).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            self.groupNameLabel.text = (snapshot.value["name"] as! String)
        })
        
        ref.observeAuthEventWithBlock { (authData) in
            if authData != nil {
                let user = User(authData: authData)
                self.ref.childByAppendingPath("users").childByAppendingPath(user.uid).observeEventType(.Value, withBlock: {snapshot in
                    self.status = snapshot.value["status"] as! String
                    
                    if self.status == "member" {
                        self.performSegueWithIdentifier("MemberApproved", sender: nil)
                    }
                    
                })
            }
        }

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
