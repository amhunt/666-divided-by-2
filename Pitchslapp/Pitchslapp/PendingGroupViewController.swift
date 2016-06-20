//
//  PendingGroupViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 4/14/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import Firebase
import ZAlertView

class PendingGroupViewController: UITableViewController {

    @IBOutlet weak var groupNameLabel: UILabel!
    var groupKey: String!
    var user: User!
    var status: String!
    var authEvent: UInt?
    @IBOutlet weak var topLineLabel: UILabel!
    @IBOutlet weak var bottomLineLabel1: UILabel!
    @IBOutlet weak var bottomLineLabel2: UILabel!
    
    let ref = Firebase(url: "https://popping-inferno-1963.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        status = "pending"
        
        ref.childByAppendingPath("groups").childByAppendingPath(self.groupKey).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            self.groupNameLabel.text = (snapshot.value["name"] as! String)
        })
        
       authEvent = ref.observeAuthEventWithBlock { (authData) in
            if authData != nil {
                let user = User(authData: authData)
                self.ref.childByAppendingPath("users").childByAppendingPath(user.uid).observeEventType(.Value, withBlock: {snapshot in
                    
                    self.user = User(snapshot: snapshot)
                    
                    self.status = snapshot.value["status"] as! String
                    
                    if self.status == "member" {
                        self.performSegueWithIdentifier("MemberApproved", sender: nil)
                    }
                    
                    if self.status == "hosed" {
                        self.hoseUser()
                    }
                    
                })
            } else {
                self.performSegueWithIdentifier("LogoutSegue", sender: nil)
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if authEvent != nil {
            ref.removeAuthEventObserverWithHandle(authEvent!)
            print("removed auth event")
        }
    }
    
    @IBAction func logoutDidTouch(sender: AnyObject) {
        let logoutAlert = ZAlertView(title: "Logout", message: "Are you sure you want to logout of your account?", isOkButtonLeft: true, okButtonText: "Cancel", cancelButtonText: "Logout", okButtonHandler: { alertview in alertview.dismiss()},
            cancelButtonHandler: { alertview in
                                        self.ref.unauth()
                                        alertview.dismiss()
                                })
        
        logoutAlert.show()
    }
    
    @IBAction func changeGroupDidTouch(sender: AnyObject) {
        ref.childByAppendingPath("groups").childByAppendingPath(groupKey).childByAppendingPath("members").childByAppendingPath(user.uid).removeValue()
        
        user = User(uid: user.uid, email: user.email, group: "must_pick_group", name: user.name, status: "pending")
        ref.childByAppendingPath("users").childByAppendingPath(user.uid).setValue(user.toAnyObject())
        
        self.performSegueWithIdentifier("ChooseNewGroup", sender: nil)
    }
    
    func hoseUser() {
        topLineLabel.text = "Your request to join"
        bottomLineLabel1.text = "has been denied. You can either"
        bottomLineLabel2.text = "request to join another group or logout."
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
