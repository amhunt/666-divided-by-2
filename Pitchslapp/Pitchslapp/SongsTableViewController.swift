//
//  SongsTableViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 3/29/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import Firebase
import Foundation

class SongsTableViewController: UITableViewController {
    var myRootRef = Firebase(url:"https://popping-inferno-1963.firebaseio.com")
    var songs = [SongItem]()
    var user: User!
    
    override func viewDidAppear(animated: Bool) {
        let songsRef = myRootRef.childByAppendingPath("groups").childByAppendingPath("-KE2t-HbseflgtLhuV8-").childByAppendingPath("songs")

        songsRef.observeEventType(.Value, withBlock: { snapshot in
            var newSongs = [SongItem]()
            
            for item in snapshot.children {
                let songItem = SongItem(snapshot: item as! FDataSnapshot)
                newSongs.append(songItem)
            }
            
            self.songs = newSongs
            self.songs.sortInPlace({$0.name < $1.name})
            self.tableView.reloadData()
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        
        myRootRef.observeAuthEventWithBlock { (authData) in
            if authData != nil {
                self.user = User(authData: authData)
            } else {
                self.performSegueWithIdentifier("LogoutSegue", sender: nil)
            }
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongCell") as! SongTableViewCell
        
        let songItem = songs[indexPath.row]
        
        cell.titleLabel?.text = songItem.name
        cell.soloLabel?.text = songItem.soloist
        cell.keyLabel?.text = songItem.key
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let songItem = songs[indexPath.row]
            songItem.ref?.removeValue()
            tableView.reloadData()
        }
    }
    
    @IBAction func addButtonDidTouch(sender: AnyObject) {
        let alert = UIAlertController(title: "Add a Song",
            message: "Enter information here",
            preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
            style: .Default) { (action: UIAlertAction!) -> Void in
                
                let nameField = alert.textFields![0] as UITextField
                let keyField = alert.textFields![1] as UITextField
                let soloField = alert.textFields![2] as UITextField
                let songItem = SongItem(name: nameField.text!, key: keyField.text!, soloist: soloField.text!)
                let songItemRef = self.myRootRef.childByAppendingPath("groups").childByAppendingPath("-KE2t-HbseflgtLhuV8-").childByAppendingPath("songs").childByAutoId()
                songItemRef.setValue(songItem.toAnyObject())
                self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Title"
        }
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Key"
        }
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField!) -> Void in
            textField.placeholder = "Soloist"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
            animated: true,
            completion: nil)
    }
    
    @IBAction func logoutButtonDidTouch(sender: AnyObject) {
        let alert = UIAlertController(title: "Logout?", message: "Confirm to logout of your account.", preferredStyle: .Alert)
        
        let logoutAction = UIAlertAction(title: "Logout", style: .Default) { (action: UIAlertAction!) -> Void in
                self.myRootRef.unauth()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
            style: .Default) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }

    
}
