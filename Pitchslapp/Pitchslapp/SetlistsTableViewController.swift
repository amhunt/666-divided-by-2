//
//  SetlistsTableViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 4/22/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import ZAlertView

class SetlistsTableViewController: UITableViewController {
    
    var ref = Firebase(url:"https://popping-inferno-1963.firebaseio.com")
    var setlists = [Setlist]()
    var user: User!
    var groupKey: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        ref.observeAuthEventWithBlock { (authData) in
            if authData != nil {
                self.user = User(authData: authData)
                // get group key
                self.ref.childByAppendingPath("users").childByAppendingPath(self.user.uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
                    
                    if self.groupKey == nil {
                        self.groupKey = snapshot.value["groupid"] as? String
                    }
                    
                    let setlistsRef = self.ref.childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("setlists")
                    
                    setlistsRef.observeEventType(.Value, withBlock: { snapshot in
                        var newSetlists = [Setlist]()
                        
                        for item in snapshot.children {
                            var setlist = Setlist(snapshot: item as! FDataSnapshot)
                            if snapshot.hasChild("songIds") {
                                setlist.songIds = snapshot.valueForKey("songIds") as! [String]
                            }
                            newSetlists.append(setlist)
                        }
                        
                        self.setlists = newSetlists
                        self.setlists.sortInPlace({ $0.date.compare($1.date) == NSComparisonResult.OrderedDescending })
                        self.tableView.reloadData()
                        
                        }, withCancelBlock: { error in
                            print(error.description)
                    })
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return setlists.count
    }
    
    
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SetlistCell", forIndexPath: indexPath) as! SetlistTableViewCell
        let setlist = setlists[indexPath.row]
        
        let dateFmt = NSDateFormatter()
        dateFmt.dateFormat = "MM/dd/YYYY"
        let dateText = dateFmt.stringFromDate(setlist.date)
        
        cell.nameLabel?.text = setlist.name
        cell.dateLabel?.text = "Created " + dateText
        
     return cell
     }
 
    
    
    @IBAction func addButtonDidTouch(sender: AnyObject) {
        let newSetlistAlert = ZAlertView(title: "Create a New Setlist", message: "Enter a name for the new setlist.", isOkButtonLeft: false, okButtonText: "Create", cancelButtonText: "Cancel",
            okButtonHandler: {alert in
                let setlistTitle = alert.getTextFieldWithIdentifier("setlisttitle")?.text
                if setlistTitle! != "" {
                    let newSetlistRef = self.ref.childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("setlists").childByAutoId()
                    
                    let date = NSDate()
                    let dateFmt = NSDateFormatter()
                    dateFmt.dateFormat = "YYYY-MM-dd"
                    let currentDateText = dateFmt.stringFromDate(date)
                    
                    newSetlistRef.setValue(["name":setlistTitle!, "date":currentDateText])
                    // create new group's members array, initializing it with the first member's info and status
                    newSetlistRef.childByAppendingPath("songIds").setValue([])
                    self.tableView.reloadData()
                }
                alert.dismiss()
            },
            cancelButtonHandler: {alert in alert.dismiss()})
        
        newSetlistAlert.addTextField("setlisttitle", placeHolder: "Setlist title")
        newSetlistAlert.getTextFieldWithIdentifier("setlisttitle")?.autocapitalizationType = .Words
        newSetlistAlert.getTextFieldWithIdentifier("setlisttitle")?.autocorrectionType = .No
        
        newSetlistAlert.show()
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let setlist = self.setlists[indexPath.row]
        let delete = UITableViewRowAction(style: .Destructive, title: "Delete") {action, index in
            let deleteAlert = ZAlertView(title: "Delete", message: "Are you sure you want to delete " + setlist.name + "?", isOkButtonLeft: true, okButtonText: "Cancel", cancelButtonText: "Delete",
                okButtonHandler: {alert in
                    self.tableView.editing = false
                    alert.dismiss()
                }, cancelButtonHandler: {alert in
                    self.tableView.editing = false
                    self.ref.childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("setlists").childByAppendingPath(setlist.id).removeValue()
                    self.tableView.reloadData()
                    alert.dismiss()
            })
            
            deleteAlert.show()
            
        }
        return [delete]
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "ShowSetlist") {
            let destination = segue.destinationViewController as! SetlistTableViewController
            destination.groupKey = self.groupKey
            
            let indexPath = self.tableView.indexPathForSelectedRow!
            destination.setlist = self.setlists[indexPath.row]
        }
    }
    

}
