//
//  Setlist.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 4/21/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import Foundation
import Firebase

struct Setlist {
    
    let id: String
    var date: NSDate
    var songIds: [String]
    var name: String
    
    init(snapshot: FDataSnapshot) {
        self.id = snapshot.key
        
        let dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.defaultTimeZone()
        dateFmt.dateFormat = "yyyy-MM-dd"
        self.date = dateFmt.dateFromString(snapshot.value["date"] as! String)!
        
        self.name = snapshot.value["name"] as! String
        
        if snapshot.hasChild("songIds") {
            self.songIds = snapshot.value["songIds"] as! [String]
        } else {
            self.songIds = []
        }
    }
    
}