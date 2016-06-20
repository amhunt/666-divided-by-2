//
//  SettingsViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 3/31/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import Foundation
import Firebase
import ZAlertView

class SettingsViewController: UITableViewController {

    let ref = Firebase(url: "https://popping-inferno-1963.firebaseio.com")
    var user: User!
    
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    // footnotes easter egg
    @IBOutlet weak var highStakesButton: UIBarButtonItem!
    let footnotesKey = "-KHr-KSRB8Ey1B25fJ3V"
    
    // indices of tableview cells for selection
    let MANAGE_GROUP = 2
    let CHANGE_PASSWORD = 6
    let DELETE_ACCOUNT = 7
    
    @IBOutlet weak var manageMembershipCell: UITableViewCell!
    @IBOutlet weak var changeOctaveCell: UITableViewCell!
    var octaveStepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // footnotes easter egg
        if user.groupKey != footnotesKey {
            highStakesButton.enabled = false
            highStakesButton.title = ""
        }
        octaveStepper = UIStepper()
        octaveStepper.minimumValue = 3
        octaveStepper.maximumValue = 7
        octaveStepper.addTarget(self, action: #selector(SettingsViewController.stepperValueChanged(_:)), forControlEvents: .ValueChanged)
        changeOctaveCell.accessoryView = octaveStepper
        let defaults = NSUserDefaults.standardUserDefaults()
        octaveStepper.value = defaults.doubleForKey("Octave")
        octaveStepper.tintColor = UIColor.init(red: 107/255, green: 80/255, blue: 176/255, alpha: 1)
        
        changeOctaveCell.textLabel?.text = "Change pitch octave (" + String(Int(octaveStepper.value)) + ")"
    }
    
    func stepperValueChanged(sender: UIStepper) {
        changeOctaveCell.textLabel?.text = "Change pitch octave (" + String(Int(sender.value)) + ")"
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setDouble(sender.value, forKey: "Octave")
    }
    
    override func viewWillAppear(animated: Bool) {
        userEmailLabel.text = user.email
        userNameLabel.text = user.name
        
        
        ref.childByAppendingPath("groups").childByAppendingPath(user.groupKey).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
            self.manageMembershipCell.textLabel?.text = "Manage " + (snapshot.value["name"] as! String)
            
        })
        
        ref.observeAuthEventWithBlock { (authData) -> Void in
            if authData == nil {
                self.performSegueWithIdentifier("LogoutSegue", sender: nil)
            }
            
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.row == CHANGE_PASSWORD {
            self.changePassword()
        } else if indexPath.row == DELETE_ACCOUNT {
            self.deleteAccount()
        }
    }
    
    @IBAction func logoutDidTouch(sender: AnyObject) {
        
        let logoutAlert = ZAlertView(title: "Logout", message: "Are you sure you want to logout of your account?", isOkButtonLeft: true, okButtonText: "Cancel", cancelButtonText: "Logout",
            okButtonHandler: { alertview in
                alertview.dismiss()
            },
            cancelButtonHandler: { alertview in
                self.ref.unauth()
                alertview.dismiss()
        })
        
        logoutAlert.show()
    }
    
    
    func changePassword() {
        let passwordAlert = ZAlertView(title: "Change password", message: "Enter your current password first, then your new password.", isOkButtonLeft: false, okButtonText: "Change", cancelButtonText: "Cancel",
            okButtonHandler: { alertview in
                let oldPassword = alertview.getTextFieldWithIdentifier("oldPassword")?.text
                let newPassword = alertview.getTextFieldWithIdentifier("newPassword")?.text
                
                if oldPassword != "" && newPassword != "" {
                    self.ref.changePasswordForUser(self.user.email, fromOld: oldPassword!, toNew: newPassword!, withCompletionBlock: { error in
                        if error != nil {
                            alertview.dismiss()
                            let errorAlert = ZAlertView(title: "Incorrect Password", message: "We were unable to change your password. Please make sure you entered your current password correctly.", closeButtonText: "OK", closeButtonHandler: {alert in alert.dismiss()})
                            errorAlert.show()
                        } else {
                            alertview.dismiss()
                            let successAlert = ZAlertView(title: "Password changed", message: "You have successfully updated your password.", closeButtonText: "OK", closeButtonHandler: {alert in alert.dismiss()})
                            successAlert.show()
                        }
                    })
                }
                
               
            },
            cancelButtonHandler: { alertview in
                alertview.dismiss()
            })
        
        passwordAlert.addTextField("oldPassword", placeHolder: "Enter your current password", isSecured: true)
        passwordAlert.addTextField("newPassword", placeHolder: "Enter your new password", isSecured: true)
        passwordAlert.show()
    }
    
    func deleteAccount() {
        
        let confirmDeleteAlert = ZAlertView(title: "Confirm delete account", message: "Please enter your password to delete your account. You will not be able to undo this action.", isOkButtonLeft: true, okButtonText: "Cancel", cancelButtonText: "Delete",
              okButtonHandler: { alertview in
                alertview.dismiss()
            }, cancelButtonHandler: { alertview in
                
                let password = alertview.getTextFieldWithIdentifier("password")?.text
                
                if password != "" {
                    self.ref.removeUser(self.user.email, password: password!, withCompletionBlock: { error in
                        if error != nil {
                            print("handle error")
                        } else {
                            // delete user from database
                            self.ref.unauth()
                            self.ref.childByAppendingPath("users").childByAppendingPath(self.user.uid).removeValue()
                            self.ref.childByAppendingPath("groups").childByAppendingPath(self.user.groupKey).childByAppendingPath("members").childByAppendingPath(self.user.uid).removeValue()
                        }
                    })
                }
                
                alertview.dismiss()
        })
        
        confirmDeleteAlert.addTextField("password", placeHolder: "Enter your password", isSecured: true)
        
        let deleteAlert = ZAlertView(title: "Delete account", message: "Are you sure you want to delete your account? This action cannot be undone.", isOkButtonLeft: true, okButtonText: "Cancel", cancelButtonText: "Delete",
            okButtonHandler: { alertview in
                alertview.dismiss()
            }, cancelButtonHandler: { alertview in
                alertview.dismiss()
                confirmDeleteAlert.show()
        })
        
        deleteAlert.show()
        
    }
    
    
    @IBAction func backButtonDidTouch(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowMembers" {
            let destination = segue.destinationViewController as! GroupMembersTableViewController
            destination.groupKey = user.groupKey
        }
    }
    
}
