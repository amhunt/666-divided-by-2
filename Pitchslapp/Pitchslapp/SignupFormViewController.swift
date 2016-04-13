//
//  SignupFormViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 3/31/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import Foundation
import SwiftForms
import UIKit
import Firebase

class SignupFormViewController: FormViewController {
    
    var ref = Firebase(url:"https://popping-inferno-1963.firebaseio.com")

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadForm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .Plain, target: self, action: Selector("submit:"))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(SignupFormViewController.cancel(_:)))
        
    }
    
    func cancel(_: UIBarButtonItem!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    
    private func loadForm() {
        let form = FormDescriptor(title: "Signup")
        
        let section1 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        
        var row: FormRowDescriptor! = FormRowDescriptor(tag: "email", rowType: .Email, title: "Email")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "john@gmail.com", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section1.addRow(row)
        row = FormRowDescriptor(tag: "password", rowType: .Password, title: "Password")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "Enter password", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section1.addRow(row)
        
        
        let section2 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        
        row = FormRowDescriptor(tag: "group", rowType: .MultipleSelector, title: "Group")
        row.configuration[FormRowDescriptor.Configuration.Options] = [0, 1, 2, 3, 4]
        row.configuration[FormRowDescriptor.Configuration.AllowsMultipleSelection] = true
        row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            switch( value ) {
            case 0:
                return "Restaurant"
            case 1:
                return "Pub"
            case 2:
                return "Shop"
            case 3:
                return "Hotel"
            case 4:
                return "Camping"
            default:
                return nil
            }
            } as TitleFormatterClosure
        section2.addRow(row)
        
        
        form.sections = [section1]
        
        self.form = form
        
    }
    
    
    
}
