//
//  SignupFormViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 5/12/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import Foundation
import Eureka
import Firebase
import SwiftSpinner
import ZAlertView

class SignupFormViewController: FormViewController {
    
    var ref = Firebase(url:"https://popping-inferno-1963.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NameRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 16.0)!
            cell.detailTextLabel?.font = UIFont(name: "Avenir-Medium", size: 16.0)!
        }
        
        EmailRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 16.0)!
            cell.detailTextLabel?.font = UIFont(name: "Avenir-Medium", size: 16.0)!
        }

        PasswordRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 16.0)!
            cell.detailTextLabel?.font = UIFont(name: "Avenir-Medium", size: 16.0)!
        }
        
        form
        +++ Section("User Information")
            <<< NameRow("firstname"){
                $0.title = "First Name"
        }
            <<< NameRow("lastname") {
                $0.title = "Last Name"
        }
        +++ Section("Login")
            <<< EmailRow("email") {
                $0.title = "Email"
                $0.placeholder = "pitch@example.com"
        }
            <<< PasswordRow("password") {
                $0.title = "Password"
        }
            <<< PasswordRow("confirmpassword") {
                $0.title = "Confirm Password"
        }
    }
    
    @IBAction func cancelDidTouch(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitDidTouch(sender: AnyObject) {
        let signupData = form.values()
        
        var name: String?
        var email: String?
        var password: String?
        var confirmPassword: String?
        
        if signupData["firstname"]! != nil && signupData["lastname"]! != nil {
            name = (signupData["firstname"] as! String) + " " + (signupData["lastname"] as! String)
        }
        
        if signupData["email"]! != nil {
            email = (signupData["email"] as! String)
        }
        
        if signupData["password"]! != nil {
            password = (signupData["password"] as! String)
        }
        
        if signupData["confirmpassword"]! != nil {
            confirmPassword = (signupData["confirmpassword"] as! String)
        }
        
        let signupErrorAlert = ZAlertView(title: "Oops!", message: "Please enter your first and last name in order to create your account.", closeButtonText: "OK", closeButtonHandler: {alertView in alertView.dismiss()})
        
        // didn't fill out name
        if name == nil {
            signupErrorAlert.alertTitle = "Missing Information"
            signupErrorAlert.message = "Please enter your first and last name in order to create your account."
            signupErrorAlert.show()
        }
        
        // passwords don't match
        if password != nil && confirmPassword != nil && password! != confirmPassword! {
            signupErrorAlert.alertTitle = "Passwords Don't Match"
            signupErrorAlert.message = "The passwords entered don't match. Try again."
            signupErrorAlert.show()
        }
        
        // hide keyboard
        view.endEditing(true)
        
        // ref.auth new user
        if name != nil && email != nil && password != nil && confirmPassword != nil {
            if password! == confirmPassword! {
            self.ref.createUser(email!, password: password!) { error, result in
                // error creating new user
                if (error != nil) {
                    if let errorCode = FAuthenticationError(rawValue: error.code) {
                        switch (errorCode) {
                        case .EmailTaken:
                            signupErrorAlert.alertTitle = "Email in Use"
                            signupErrorAlert.message = "The email address you entered is already in use. Please enter a different one to create your account."
                            signupErrorAlert.show()
                        case .InvalidEmail:
                            signupErrorAlert.alertTitle = "Invalid Email"
                            signupErrorAlert.message = "Please enter a valid email address (e.g., jon@example.com)."
                            signupErrorAlert.show()
                        default:
                            signupErrorAlert.message = "An error has occurred. Please check your internet connection and try creating your account again."
                            signupErrorAlert.show()
                        }
                    }
                }
                // successfully created new user
                else {
                    // add user to the database
                    let uid = result["uid"] as! String
                    let newUser = User(uid: uid, email: email!, group: "must_pick_group", name: name!, status: "pending")
                    self.ref.childByAppendingPath("users").childByAppendingPath(uid).setValue(newUser.toAnyObject())
                    // log user in
                    SwiftSpinner.show("Creating account")
                    self.ref.authUser(email!, password: password!, withCompletionBlock: {(error, auth) -> Void in
                        // segue to group picker view
                        SwiftSpinner.hide()
                        self.performSegueWithIdentifier("PickGroup", sender: nil)
                    })
                }
                
            }
            }
        }
    }
}
