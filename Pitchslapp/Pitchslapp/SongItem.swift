//
//  SongItem.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 3/29/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import Foundation
import Firebase

struct SongItem {
    
    let name: String!
    let id: String!
    let key: String!
    let soloist: String!
    var pdfUrl: String?
    var tags: [String]
    let ref: Firebase?
    
    // Initialize from arbitrary data
    init(name: String, id: String = "", key: String, soloist: String) {
        self.id = id
        self.name = name
        self.key = key
        self.soloist = soloist
        self.tags = []
        self.pdfUrl = nil
        self.ref = nil
    }
    
    init(snapshot: FDataSnapshot) {
        id = snapshot.key
        name = snapshot.value["name"] as! String
        soloist = snapshot.value["solo"] as! String
        key = snapshot.value["key"] as! String
        if snapshot.hasChild("pdfUrl") {
            pdfUrl = snapshot.value["pdfUrl"] as! String
        }
        if snapshot.hasChild("tags") {
            tags = snapshot.value["tags"] as! [String]
        } else {
            tags = []
        }
        ref = snapshot.ref
    }
    
    func toAnyObject() -> AnyObject {
        var songObject = [
            "name": name,
            "key": key,
            "solo": soloist
        ]
        if (pdfUrl != nil) {
            songObject.updateValue(pdfUrl!, forKey: "pdfUrl")
        }
//        if (tags.count > 0) {
//            songObject.updateValue(tags, forKey: "tags")
//        }

        return songObject
    }
    
}