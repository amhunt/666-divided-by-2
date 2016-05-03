//
//  SettingsViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 3/31/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import Foundation
import Firebase

class SettingsViewController: UITableViewController {

    let ref = Firebase(url: "https://popping-inferno-1963.firebaseio.com")
    var user: User!
    
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userEmailLabel.text = user.email
        userNameLabel.text = user.name
        
        
        ref.childByAppendingPath("groups").childByAppendingPath(user.groupKey).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            self.groupNameLabel.text = snapshot.value["name"] as! String
            
        })
        
        ref.observeAuthEventWithBlock { (authData) -> Void in
            if authData == nil {
                self.performSegueWithIdentifier("LogoutSegue", sender: nil)
            }
            
        }
    }
    
    @IBAction func switchGroupsDidTouch(sender: AnyObject) {
    }
    
    @IBAction func manageMembershipDidTouch(sender: AnyObject) {
    }
    
    @IBAction func logoutDidTouch(sender: AnyObject) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout of your account?", preferredStyle: .Alert)
        
        let logoutAction = UIAlertAction(title: "Logout", style: .Destructive) { (action: UIAlertAction!) -> Void in
            self.ref.unauth()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .Default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func backButtonDidTouch(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
