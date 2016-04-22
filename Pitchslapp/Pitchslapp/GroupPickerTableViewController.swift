//
//  GroupPickerTableViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 3/31/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class GroupPickerTableViewController: UITableViewController {

    var ref = Firebase(url:"https://popping-inferno-1963.firebaseio.com")
    var groups = [Group]()
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        let groupsRef = ref.childByAppendingPath("groups")
        
        groupsRef.observeEventType(.Value, withBlock: { snapshot in
            var newGroups = [Group]()
            
            for item in snapshot.children {
                let group = Group(snapshot: item as! FDataSnapshot)
                newGroups.append(group)
            }
            
            self.groups = newGroups
            self.groups.sortInPlace({$0.groupName < $1.groupName})
            self.tableView.reloadData()
            }, withCancelBlock: { error in
                print (error.description)
        })
        
        ref.observeAuthEventWithBlock { (authData) in
            if authData != nil {
                self.user = User(authData: authData)
            } else {
                self.performSegueWithIdentifier("LogoutSegue", sender: nil)
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GroupCell", forIndexPath: indexPath)

        let group = groups[indexPath.row]
        
        cell.textLabel?.text = group.groupName
        cell.detailTextLabel?.text = group.schoolName
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedGroup = groups[indexPath.row]
        user = User(uid: user.uid, email: user.email, group: selectedGroup.uid, name: user.name)
        ref.childByAppendingPath("users").childByAppendingPath(user.uid).setValue(user.toAnyObject())
        // TODO: add user id to list of users in group
        
    }

    @IBAction func addGroupDidTouch(sender: AnyObject) {
        let alert = UIAlertController(title: "Create a new group",
            message: "Enter information here",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction!) -> Void in
            let nameField = alert.textFields![0] as UITextField
            let schoolField = alert.textFields![1] as UITextField
            let newGroupRef = self.ref.childByAppendingPath("groups").childByAutoId()
            newGroupRef.setValue(["name":nameField.text!, "school":schoolField.text!])
            // create new group's members array, initializing it with the first member's info and status
            newGroupRef.childByAppendingPath("members").setValue([self.user.uid : "member"])
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Destructive) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Group Name"
        }
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            textField.placeholder = "School Name"
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ChoseExistingGroup" {
            let destination = segue.destinationViewController as! PendingGroupViewController
            destination.group = self.groups[(self.tableView.indexPathForSelectedRow?.row)!]
        }
        else if segue.identifier == "ChoseNewGroup" {
            
        }
    }


}
