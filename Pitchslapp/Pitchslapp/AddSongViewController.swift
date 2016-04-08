//
//  AddSongViewController.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 4/7/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import UIKit
import SwiftForms

class AddSongViewController: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    private func loadForm() {
        let form = FormDescriptor(title: "Add a Song")
        
        let section1 = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)
        
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
        
        form.sections = [section1]
        self.form = form
    }
    

}
