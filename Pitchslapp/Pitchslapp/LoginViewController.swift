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

class LoginViewController: UIViewController {
    
    let ref = Firebase(url: "https://popping-inferno-1963.firebaseio.com")

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    func checkIfUserExists(authData: FAuthData) -> Void {
        let usersRef = ref.childByAppendingPath("users")
        usersRef.childByAppendingPath(authData.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if snapshot.value["login"] != nil {
                self.performSegueWithIdentifier("LoginSegue", sender: nil)
            } else {
                let email = authData.providerData["email"] as! String
                self.ref.childByAppendingPath("users").childByAppendingPath(authData.uid).setValue(["login":email])
                self.performSegueWithIdentifier("PickGroup", sender: nil)
            }
        })
        emailTextField.autocorrectionType = UITextAutocorrectionType.No
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        ref.observeAuthEventWithBlock { (authData) -> Void in
            if authData != nil {
               self.checkIfUserExists(authData)
            }
        }
    }
    
    
    @IBAction func loginDidTouch(sender: AnyObject) {
        ref.authUser(emailTextField.text, password: passwordTextField.text,
            withCompletionBlock: { (error, auth) in
                
        })
    }
    
    @IBAction func signupDidTouch(sender: AnyObject) {
        let alert = UIAlertController(title: "Register",
            message: "Enter your email and create a new password",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Create",
            style: .Default) { (action: UIAlertAction!) -> Void in
                
                let emailField = alert.textFields![0]
                let passwordField = alert.textFields![1]
                
                self.emailTextField.text = emailField.text
                
                self.ref.createUser(emailField.text, password: passwordField.text) { (error: NSError!) in
                    if error == nil {
                        self.ref.authUser(emailField.text, password: passwordField.text,
                            withCompletionBlock: { (error, auth) -> Void in
                        })
                    }
                }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textEmail) -> Void in
            if self.emailTextField.text != "" {
                textEmail.text = self.emailTextField.text
            } else {
                textEmail.placeholder = "Enter your email"
            }
            
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textPassword) -> Void in
            textPassword.secureTextEntry = true
            if self.passwordTextField.text != "" {
                textPassword.text = self.passwordTextField.text
            } else {
                textPassword.placeholder = "Choose a password"
            }
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
        
    }
    
}
