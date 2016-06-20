//
//  GroupMembersTableViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 5/12/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import Firebase
import ZAlertView

class GroupMembersTableViewController: UITableViewController {

    var ref = Firebase(url:"https://popping-inferno-1963.firebaseio.com")
    var members = [User]()
    var pendingMembers = [User]()
    var groupKey: String?
    let headerTitles = ["Approval Required", "Members"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let memberIdsRef = ref.childByAppendingPath("groups").childByAppendingPath(groupKey).childByAppendingPath("members")
        
        memberIdsRef.observeEventType(.Value, withBlock: {snapshot in
            var newMembers = [User]()
            var newPendingMembers = [User]()
            
            // get ids of users
            for item in snapshot.children {
                let memberId = (item as! FDataSnapshot).key as String
                // get user data for each id
                self.ref.childByAppendingPath("users").childByAppendingPath(memberId).observeSingleEventOfType(.Value, withBlock: {userData in
                    
                    if userData.value is NSNull {
                        
                    } else {
                        let member = User(snapshot: userData as FDataSnapshot)
                        if member.status == "member" {
                            newMembers.append(member)
                        } else if member.status == "pending" {
                            newPendingMembers.append(member)
                        }
                        self.members = newMembers
                        self.pendingMembers = newPendingMembers
                        self.members.sortInPlace({$0.name.lowercaseString < $1.name.lowercaseString})
                        self.pendingMembers.sortInPlace({$0.name.lowercaseString < $1.name.lowercaseString})
                        self.tableView.reloadData()
                    }

                })
            }
            
        })

    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return headerTitles.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return pendingMembers.count
        } else {
            return members.count
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if pendingMembers.count == 0 {
            if section == 0 {
                return nil
            } else {
                return headerTitles[1]
            }
        }
        
        return headerTitles[section]
    }
    
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header:UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        
        header.textLabel?.font = UIFont(name: "Avenir-Heavy", size: 16.0)!
        header.textLabel?.frame = header.frame
        
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath)
        
        var userItem: User
        
        if indexPath.section == 0 {
            userItem = pendingMembers[indexPath.row]
            cell.detailTextLabel?.text = "Pending"
            cell.detailTextLabel?.textColor = UIColor.redColor()
        } else {
            userItem = members[indexPath.row]
            cell.detailTextLabel?.text = "Member"
            cell.detailTextLabel?.textColor = UIColor.lightGrayColor()
        }
        
        cell.textLabel?.text = userItem.name

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var selectedUser: User
        
        if indexPath.section == 0 {
            selectedUser = pendingMembers[indexPath.row]
        } else {
            selectedUser = members[indexPath.row]
        }
        
        let approveAlert = ZAlertView(title: "Approve a New Member", message: "Do you want to allow " + selectedUser.name + " to view and edit your group's repertoire?", alertType: .MultipleChoice)
        
        approveAlert.addButton("Approve", hexColor: "#479673", hexTitleColor: "#FFFFFF", touchHandler: {alert in
            // add member to group: update user info
            self.ref.childByAppendingPath("users").childByAppendingPath(selectedUser.uid).childByAppendingPath("status").setValue("member")
            // add member to group: update group info
            self.ref.childByAppendingPath("groups").childByAppendingPath(self.groupKey!).childByAppendingPath("members").childByAppendingPath(selectedUser.uid).setValue("member")
            alert.dismiss()
        })
        
        approveAlert.addButton("Deny", hexColor: "#bf3646", hexTitleColor: "#FFFFFF", touchHandler: {alert in
            self.ref.childByAppendingPath("users").childByAppendingPath(selectedUser.uid).childByAppendingPath("status").setValue("hosed")
            self.ref.childByAppendingPath("groups").childByAppendingPath(self.groupKey!).childByAppendingPath("members").childByAppendingPath(selectedUser.uid).removeValue()
            alert.dismiss()
        })
        
        approveAlert.addButton("Cancel", hexColor: "#949494", hexTitleColor: "#FFFFFF", touchHandler: {alert in alert.dismiss()})

        if selectedUser.status == "pending" {
            approveAlert.show()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    

}
