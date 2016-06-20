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
import ZAlertView

extension GroupPickerTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension GroupPickerTableViewController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
}

class GroupPickerTableViewController: UITableViewController {

    var ref = Firebase(url:"https://popping-inferno-1963.firebaseio.com")
    var groups = [Group]()
    var user: User!
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredGroups = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.barTintColor = UIColor.init(red: 107/255, green: 80/255, blue: 176/255, alpha: 1)
        searchController.searchBar.tintColor = UIColor.whiteColor()
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
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
                self.ref.childByAppendingPath("users").childByAppendingPath(authData.uid).observeSingleEventOfType(.Value, withBlock: {
                    snapshot in
                    self.user = User(snapshot: snapshot)
                })
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
        if searchController.active && searchController.searchBar.text != "" {
            return filteredGroups.count
        }
        return groups.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GroupCell", forIndexPath: indexPath)

        let group: Group
        
        if searchController.active && searchController.searchBar.text != "" {
            group = filteredGroups[indexPath.row]
        } else {
            group = groups[indexPath.row]
        }
        
        cell.textLabel?.text = group.groupName
        cell.detailTextLabel?.text = group.schoolName
        
        return cell
    }
    
    // user chose a group
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedGroup: Group
            
        if searchController.active && searchController.searchBar.text != "" {
            selectedGroup = filteredGroups[indexPath.row]
        } else {
            selectedGroup = groups[indexPath.row]
        }
        
        user = User(uid: user.uid, email: user.email, group: selectedGroup.uid, name: user.name, status: "pending")
        
        // add user to database with groupid and pending flag
        ref.childByAppendingPath("users").childByAppendingPath(user.uid).setValue(user.toAnyObject())
        
        // add user to list of members for the group
        ref.childByAppendingPath("groups").childByAppendingPath(selectedGroup.uid).childByAppendingPath("members").childByAppendingPath(user.uid).setValue("pending")
        
    }

    @IBAction func addGroupDidTouch(sender: AnyObject) {
        
        let newGroupAlert = ZAlertView(title: "Create a New Group", message: "Enter the name of your group and an easy identifier, such as your school or city, for other members to find you.", isOkButtonLeft: false, okButtonText: "Save", cancelButtonText: "Cancel",
            okButtonHandler: {alert in
                let groupName = alert.getTextFieldWithIdentifier("groupname")?.text
                let schoolName = alert.getTextFieldWithIdentifier("schoolname")?.text
                if groupName! != "" && schoolName! != "" {
                    let newGroupRef = self.ref.childByAppendingPath("groups").childByAutoId()
                    newGroupRef.setValue(["name":groupName!, "school":schoolName!])
                    
                    // create new group's members array, initializing it with the first member's info and status
                    newGroupRef.childByAppendingPath("members").setValue([self.user.uid : "member"])
                    
                    // add user to database
                    self.user = User(uid: self.user.uid, email: self.user.email, group: newGroupRef.key, name: self.user.name, status: "member")
                    self.ref.childByAppendingPath("users").childByAppendingPath(self.user.uid).setValue(self.user.toAnyObject())
                    
                    self.performSegueWithIdentifier("ChoseNewGroup", sender: nil)
                    
                    alert.dismiss()
                }
            },
            cancelButtonHandler: {alert in alert.dismiss()})
        
        newGroupAlert.addTextField("groupname", placeHolder: "Group name (e.g., The Footnotes)")
        newGroupAlert.addTextField("schoolname", placeHolder: "Identifier (e.g., Princeton University)")
        newGroupAlert.getTextFieldWithIdentifier("groupname")?.autocapitalizationType = .Words
        newGroupAlert.getTextFieldWithIdentifier("groupname")?.autocorrectionType = .No
        newGroupAlert.getTextFieldWithIdentifier("schoolname")?.autocapitalizationType = .Words
        newGroupAlert.getTextFieldWithIdentifier("schoolname")?.autocorrectionType = .No
        
        newGroupAlert.show()
    }
    
    @IBAction func cancelDidTouch(sender: AnyObject) {

        let alert = UIAlertController(title: "Are you sure you don't want to make an account?",
                                      message: "If you select Quit, your new account will be deleted. Tap Cancel to continue joining a group.",
                                      preferredStyle: .Alert)
        
        let quitAction = UIAlertAction(title: "Quit", style: .Destructive) { (action: UIAlertAction!) -> Void in
            self.ref.childByAppendingPath("users").childByAppendingPath(self.user.uid).removeValue()
            self.ref.unauth()
            // need to delete actual user, not just ref
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .Default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addAction(cancelAction)
        alert.addAction(quitAction)
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    // update view based on search
    func filterContentForSearchText(searchText: String) {
        filteredGroups = groups.filter { group in
            return group.groupName.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ChoseExistingGroup" {
            let destination = segue.destinationViewController as! PendingGroupViewController
            
            if searchController.active && searchController.searchBar.text != "" {
                destination.groupKey = self.filteredGroups[(self.tableView.indexPathForSelectedRow?.row)!].uid
            } else {
                destination.groupKey = self.groups[(self.tableView.indexPathForSelectedRow?.row)!].uid
            }
        }
    }


}
