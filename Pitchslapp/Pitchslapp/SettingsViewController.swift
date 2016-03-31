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

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ref.observeAuthEventWithBlock { (authData) -> Void in
            if authData != nil {
                self.performSegueWithIdentifier("LogoutSegue", sender: nil)
            }
            
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
            ref.unauth()
            print("unauthenticated")
    }
    
    
}
