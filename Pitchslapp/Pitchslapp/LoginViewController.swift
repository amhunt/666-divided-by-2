//
//  LoginViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 3/31/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import SwiftSpinner
import ZAlertView

class LoginViewController: UIViewController {
    
    let ref = Firebase(url: "https://popping-inferno-1963.firebaseio.com")
    
    var groupKey: String?
    
    var newName: String?
    
    var authEvent: UInt?

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
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

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.autocorrectionType = UITextAutocorrectionType.No
        
        authEvent = ref.observeAuthEventWithBlock { (authData) -> Void in
            if authData != nil {
               self.checkIfUserExists(authData)
            }
        }
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        if authEvent != nil {
            ref.removeAuthEventObserverWithHandle(authEvent!)
        }
    }
    
    @IBAction func forgotPasswordDidTouch(sender: AnyObject) {
        let resetAlert = ZAlertView(title: "Reset Password",
                                    message: "Enter the email address you used to sign up for Pitchslapp. You will receive an email with a temporary password.",
                                    isOkButtonLeft: false,
                                    okButtonText: "Reset", cancelButtonText: "Cancel",
                                    okButtonHandler: {alertview in
                                        let email = alertview.getTextFieldWithIdentifier("email")?.text
                                        self.resetPassword(email!)
                                        alertview.dismiss()
                                        
            },
                                    cancelButtonHandler: {alertview in alertview.dismiss()})
        
        resetAlert.addTextField("email", placeHolder: "Enter your email address")
        
        resetAlert.show()
        
    }
    
    func resetPassword(email: String) {
        ref.resetPasswordForUser(email, withCompletionBlock: {error in
            
            if error != nil {
                let errorAlert = ZAlertView(title: "We couldn't find your account", message: "We are unable to locate an account with the email address you gave. Please double-check and try again.", closeButtonText: "OK", closeButtonHandler: {alert in alert.dismiss()})
                errorAlert.show()
            } else {
                let errorAlert = ZAlertView(title: "Your password has been reset", message: "Check your email for a temporary password. You have 24 hours to login before it resets again!", closeButtonText: "OK", closeButtonHandler: {alert in alert.dismiss()})
                errorAlert.show()
            }
        
        })
    }
    
    @IBAction func loginDidTouch(sender: AnyObject) {
        SwiftSpinner.show("Logging in")
        self.dismissKeyboard()
        ref.authUser(emailTextField.text, password: passwordTextField.text,
            withCompletionBlock: { (error, auth) in
                SwiftSpinner.hide()
                if (error != nil) {
                    self.handleLoginErrors(error)
                }
        })
    }
    
    func handleLoginErrors(error: NSError) {
         let loginErrorAlert = ZAlertView(title: "Oops!", message: "Please enter your first and last name in order to create your account.", closeButtonText: "OK", closeButtonHandler: {alertView in alertView.dismiss()})
        
        if let errorCode = FAuthenticationError(rawValue: error.code) {
            switch (errorCode) {
            case .UserDoesNotExist:
                loginErrorAlert.alertTitle = "Invalid Email"
                loginErrorAlert.message = "There is no user associated with the email address you entered. Please check your spelling and try again!"
                loginErrorAlert.show()
            case .InvalidPassword:
                loginErrorAlert.alertTitle = "Invalid Password"
                loginErrorAlert.message = "The password you entered is incorrect. Please try again, or tap \"I Forgot My Password\" below."
                loginErrorAlert.show()
            case .InvalidEmail:
                loginErrorAlert.alertTitle = "No Information Entered"
                loginErrorAlert.message = "To login, please enter your account email and password."
                loginErrorAlert.show()
            case .NetworkError:
                loginErrorAlert.alertTitle = "Trouble Connecting"
                loginErrorAlert.message = "Pitchslapp is unable to connect to the internet. Please check your connection and try again."
                loginErrorAlert.show()
            default:
                print(error)
                loginErrorAlert.message = "An unknown error has occured. Please check your internet connection and try again."
                loginErrorAlert.show()

            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Pending" {
            let destination = segue.destinationViewController as! PendingGroupViewController
            destination.groupKey = groupKey!
        }
    }
    
}
