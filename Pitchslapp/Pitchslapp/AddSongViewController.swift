//
//  AddSongViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 4/7/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import SwiftForms
import Firebase

class AddSongViewController: FormViewController {

    var groupKey: String!
    var myRootRef = Firebase(url:"https://popping-inferno-1963.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = .SingleLine
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.loadForm()
    }
    
    @IBAction func submitDidTouch(sender: AnyObject) {
        let formValues = self.form.formValues()
        var title = ""
        var key: String
        var soloist = "N/A"
        var tags = []
        
        if !(formValues.valueForKey("title") is NSNull) {
            title = formValues.valueForKey("title") as! String
        }
        
        if !(formValues.valueForKey("soloist") is NSNull) {
            soloist = formValues.valueForKey("soloist") as! String
        }
        
        key = formValues.valueForKey("key") as! String
        
        if !(formValues.valueForKey("tags") is NSNull) {
            tags = (formValues.valueForKey("tags") as! String).componentsSeparatedByString(", ")
        }
        
        let songItem = SongItem(name: title, key: key, soloist: soloist)
        let songItemRef = self.myRootRef.childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("songs").childByAutoId()
        songItemRef.setValue(songItem.toAnyObject())
        songItemRef.childByAppendingPath("tags").setValue(tags)
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelDidTouch(sender: AnyObject) {
        let alert = UIAlertController(title: "Don't save?", message: "Are you sure you don't want to save this song?", preferredStyle: .Alert)
        
        let continueAction = UIAlertAction(title: "Keep working", style: .Default) { (action: UIAlertAction!) -> Void in
            
        }
        
        let cancelAction = UIAlertAction(title: "Delete", style: .Destructive) { (action: UIAlertAction!) -> Void in
            self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(continueAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func loadForm() {
        let form = FormDescriptor(title: "Add a Song")
        
        let section1 = FormSectionDescriptor(headerTitle: "Information", footerTitle: nil)
        
        var row = FormRowDescriptor(tag: "title", rowType: .Name, title: "Title")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "e.g. I Want You Back", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section1.addRow(row)
        
        row = FormRowDescriptor(tag: "soloist", rowType: .Name, title: "Soloist(s)")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "e.g. Caroline", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section1.addRow(row)
        
        row = FormRowDescriptor(tag: "key", rowType: .Picker, title: "Key")
        row.configuration[FormRowDescriptor.Configuration.Options] = ["A", "A#", "Ab", "B", "Bb", "C", "C#", "D", "Db", "D#", "Eb", "E", "F", "F#", "G", "Gb", "G#"]
        row.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
            return value as! String
            } as TitleFormatterClosure
        row.value = "A"
        section1.addRow(row)
        
        let section2 = FormSectionDescriptor(headerTitle: "Separate tags using a comma", footerTitle: nil)
        
        row = FormRowDescriptor(tag: "tags", rowType: .Text, title: "Tags")
        row.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : "e.g. slow, choral, long", "textField.textAlignment" : NSTextAlignment.Right.rawValue]
        section2.addRow(row)

        let text = UITextField()
        text.autocapitalizationType = UITextAutocapitalizationType.None
        
        form.sections = [section1, section2]
        self.form = form
    }
    

}
