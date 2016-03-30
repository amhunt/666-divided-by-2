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
    let ref: Firebase?
    
    // Initialize from arbitrary data
    init(name: String, id: String = "", key: String, soloist: String) {
        self.id = id
        self.name = name
        self.key = key
        self.soloist = soloist
        self.ref = nil
    }
    
    init(snapshot: FDataSnapshot) {
        id = snapshot.key
        name = snapshot.value["name"] as! String
        soloist = snapshot.value["solo"] as! String
        key = snapshot.value["key"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "name": name,
            "key": key,
            "solo": soloist
        ]
    }
    
}