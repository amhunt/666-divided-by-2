//
//  GroupMembersTableViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 5/12/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import Firebase

class GroupMembersTableViewController: UITableViewController {

    var ref = Firebase(url:"https://popping-inferno-1963.firebaseio.com")
    var members = [User]()
    var groupKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let memberIdsRef = ref.childByAppendingPath("groups").childByAppendingPath(groupKey).childByAppendingPath("members")
        
        memberIdsRef.observeEventType(.Value, withBlock: {snapshot in
            var newMembers = [User]()
            
            for item in snapshot.children {
                let memberId = (item as! FDataSnapshot).key as String
                self.ref.childByAppendingPath("users").childByAppendingPath(memberId).observeSingleEventOfType(.Value, withBlock: {userData in
                    
                    if userData.value is NSNull {
                        
                    } else {
                        let member = User(snapshot: userData as FDataSnapshot)
                        newMembers.append(member)
                        self.members = newMembers
                        self.tableView.reloadData()
                    }
                    
                    
                })
            }
            
        })

    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("UserCell", forIndexPath: indexPath)
        
        let userItem = members[indexPath.row]
        
        cell.textLabel?.text = userItem.name
        
        if userItem.status == "member" {
            cell.detailTextLabel?.text = "Member"
        } else if userItem.status == "pending" {
            cell.detailTextLabel?.text = "Pending"
            cell.detailTextLabel?.textColor = UIColor.redColor()
        }

        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedUser = members[indexPath.row]
        
        let approveMember = UIAlertController(title: "Approve a new member", message: "Do you want to allow " + selectedUser.name + " to view and edit your group's repertoire?", preferredStyle: .Alert)
        let approveAction = UIAlertAction(title: "Approve", style: .Default) { (action: UIAlertAction!) -> Void in
            // add member to group: update user info
            self.ref.childByAppendingPath("users").childByAppendingPath(selectedUser.uid).childByAppendingPath("status").setValue("member")
            // add member to group: update group info
            self.ref.childByAppendingPath("groups").childByAppendingPath(self.groupKey!).childByAppendingPath("members").childByAppendingPath(selectedUser.uid).setValue("member")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction!) -> Void in
        }
        
        approveMember.addAction(cancelAction)
        approveMember.addAction(approveAction)
        if selectedUser.status == "pending" {
            self.presentViewController(approveMember, animated: true, completion: nil)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
