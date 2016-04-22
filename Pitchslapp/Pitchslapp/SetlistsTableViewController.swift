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
        cell.dateLabel?.text = dateText
        
     // Configure the cell...
     
     return cell
     }
 
    
    
    @IBAction func addButtonDidTouch(sender: AnyObject) {
        let alert = UIAlertController(title: "Create a new setlist",
                                      message: "",
                                      preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .Default) { (action: UIAlertAction!) -> Void in
                                        let nameField = alert.textFields![0] as UITextField
                                        let newSetlistRef = self.ref.childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("setlists").childByAutoId()
                                        
                                        let date = NSDate()
                                        let dateFmt = NSDateFormatter()
                                        dateFmt.dateFormat = "YYYY-MM-dd"
                                        let currentDateText = dateFmt.stringFromDate(date)
                                        
                                        newSetlistRef.setValue(["name":nameField.text!, "date":currentDateText])
                                        // create new group's members array, initializing it with the first member's info and status
                                        newSetlistRef.childByAppendingPath("songIds").setValue([])
                                        self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .Destructive) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Setlist Name"
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        presentViewController(alert,
                              animated: true,
                              completion: nil)

    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let destination = segue.destinationViewController as! SetlistTableViewController
        destination.groupKey = self.groupKey
        
        let indexPath = self.tableView.indexPathForSelectedRow!
        destination.setlist = self.setlists[indexPath.row]
    }
    

}
