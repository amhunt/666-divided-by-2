//
//  LaunchScreenViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 5/25/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import Firebase
import NVActivityIndicatorView

class LaunchScreenViewController: UIViewController {
    
    var authEvent: UInt?
    let ref = Firebase(url: "https://popping-inferno-1963.firebaseio.com")
    
    var groupKey: String?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func checkIfUserExists(authData: FAuthData) -> Void {
        let usersRef = ref.childByAppendingPath("users")
        usersRef.childByAppendingPath(authData.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
            // user is new
            if snapshot.value is NSNull {
                
            }
            // user still needs to pick a group
            else if snapshot.value["groupid"] as! String == "must_pick_group" {
                self.performSegueWithIdentifier("PickGroup", sender: nil)
            }
            // user's status is still pending
            else if snapshot.value["status"] as! String == "pending" ||  snapshot.value["status"] as! String == "hosed" {
                self.groupKey = (snapshot.value["groupid"] as! String)
                self.performSegueWithIdentifier("Pending", sender: nil)
            }
            // user exists and is approved
            else {
                self.performSegueWithIdentifier("LoginSegue", sender: nil)
            }
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
                
        authEvent = ref.observeAuthEventWithBlock { (authData) -> Void in
            if authData != nil {
                self.checkIfUserExists(authData)
            } else {
                self.performSegueWithIdentifier("NeedToLogin", sender: nil)
            }
            
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(animated: Bool) {
        if authEvent != nil {
            ref.removeAuthEventObserverWithHandle(authEvent!)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
//        loadingView.startAnimation()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Pending" {
            let destination = segue.destinationViewController as! PendingGroupViewController
            destination.groupKey = groupKey!
        }
    }
    

}
