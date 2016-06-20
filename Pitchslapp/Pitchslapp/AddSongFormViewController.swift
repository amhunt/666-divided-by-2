//
//  AddSongFormViewController.swift
//  
//
//  Created by Zachary Stecker on 5/12/16.
//
//

import Foundation
import Eureka
import Firebase
import DBChooser

public class DropboxCell: Cell<String>, CellType {
    
    required public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    @IBOutlet weak var dropboxButton: UIButton!
    
    public override func setup() {
        row.title = nil
        super.setup()
        selectionStyle = .Default

    }
    
    public override func didSelect() {
        DBChooser.defaultChooser().openChooserForLinkType(DBChooserLinkTypePreview, fromViewController: AddSongFormViewController(), completion: { (results: [AnyObject]!) -> Void in
            if results == nil {
                print("user cancelled")
                self.selected = false
            } else {
                let pdfUrl = (results[0].link as NSURL).absoluteString
                let fileName = (results[0].name as String)
                self.row.value = self.convertToDirectLink(pdfUrl)
                self.textLabel?.text = fileName
                self.textLabel?.textColor = UIColor.blackColor()
                self.selected = false
            }
        })
    }
    
    public override func update() {
        row.title = nil
        super.update()
        if row.value == "!!none!!" {
            self.textLabel?.text = "🔗 Tap to link sheet music"
        } else {
            self.textLabel?.text = "✅ Sheet music linked. Tap to change"
        }
        self.accessoryType = .DisclosureIndicator
    }
    
    func convertToDirectLink(url: String) -> String {
        let count = url.characters.count
        return (url as NSString).substringToIndex(count-1) + "1"
    }
    
}

public final class DropboxRow: Row<String, DropboxCell>, RowType {
    
    required public init(tag: String?) {
        super.init(tag: tag)
        displayValueFor = nil
        cellProvider = CellProvider<DropboxCell>(nibName: "DropboxCell")
    }
}


class AddSongFormViewController : FormViewController {
    
    var groupKey: String!
    var ref = Firebase(url:"https://popping-inferno-1963.firebaseio.com")
    var song: SongItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editingSong = (song != nil)
        
        if editingSong {
            self.navigationItem.title = "Edit Song"
        }
        
        NameRow.defaultCellUpdate = { cell, row in
            cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 16.0)!
            cell.detailTextLabel?.font = UIFont(name: "Avenir-Medium", size: 16.0)!
        }
        
        form
            +++ Section("Song Title and Soloists")
                <<< NameRow("title"){
                        $0.title = "Song Title"
                        $0.placeholder = "e.g. I Want You Back"
                        if editingSong {
                            $0.baseValue = song!.name
                        }
                    }
                <<< NameRow("soloist") {
                        $0.title = "Soloist(s)"
                        $0.placeholder = "e.g. Caroline"
                        if editingSong {
                            $0.baseValue = song!.soloist
                        }
                    }
            +++ Section("Starting Pitch")
                <<< PickerRow<String>("pitch") { (row : PickerRow<String>) -> Void in
                        row.options = ["A", "A#", "Ab", "B", "Bb", "C", "C#", "D", "Db", "D#", "Eb", "E", "F", "F#", "G", "Gb", "G#"]
                        row.value = row.options[0]
                        if editingSong {
                            row.value = row.options[row.options.indexOf(song!.key)!]
                        }
                    }
            
            +++ Section("Sheet Music")
                <<< DropboxRow("url") {
                    $0.value = "!!none!!"
                    if editingSong {
                        if song!.pdfUrl != nil {
                            $0.value = song!.pdfUrl!
                        }
                    }
                }
            
            +++ Section("Tags (Separate using commas)")
                <<< TextAreaRow("tags") {
                    $0.placeholder = "e.g. pumpup, fast, crowd pleaser"
                    if editingSong {
                        var tagString = ""
                        if song!.tags.count > 0 {
                            for index in 0...(song!.tags.count - 1) {
                                if index < (song!.tags.count - 1) {
                                    tagString = tagString + song!.tags[index] + ", "
                                } else {
                                    tagString = tagString + song!.tags[index]
                                }
                            }
                            $0.baseValue = tagString
                        }
                    }
                }
        
    }
    
    @IBAction func cancelDidTouch(sender: AnyObject) {
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveDidTouch(sender: AnyObject) {
        let formValues = form.values()
        
        var title = ""
        var key: String
        var soloist = "N/A"
        var tags = []
        var url: String?
        
        if formValues["title"]! != nil {
            title = formValues["title"] as! String
        }
        
        if formValues["soloist"]! != nil {
            soloist = formValues["soloist"] as! String
        }
        
        if formValues["pitch"]! != nil {
            key = formValues["pitch"] as! String
        } else {
            key = "A"
        }
        
        if formValues["tags"]! != nil {
            tags = (formValues["tags"] as! String).componentsSeparatedByString(", ")
        }
        
        var songItem: SongItem
        
        if formValues["url"]! != nil && (formValues["url"] as! String) != "!!none!!" {
            url = (formValues["url"] as! String)
            songItem = SongItem(name: title, key: key, soloist: soloist, url: url!)
        } else {
            songItem = SongItem(name: title, key: key, soloist: soloist)
        }
        
        if self.song == nil {
            let songItemRef = self.ref.childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("songs").childByAutoId()
            songItemRef.setValue(songItem.toAnyObject())
            songItemRef.childByAppendingPath("tags").setValue(tags)
        } else {
            let songId = self.song!.id
            let editSongItemRef = self.ref.childByAppendingPath("groups").childByAppendingPath(self.groupKey).childByAppendingPath("songs").childByAppendingPath(songId)
            self.song!.name = title
            self.song!.key = key
            self.song!.soloist = soloist
            if url != nil {
                self.song!.pdfUrl = url!
            }
            editSongItemRef.setValue(self.song!.toAnyObject())
            editSongItemRef.childByAppendingPath("tags").setValue(tags)
        }
        
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
