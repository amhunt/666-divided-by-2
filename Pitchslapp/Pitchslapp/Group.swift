//
//  Group.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 3/31/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import Foundation
import Firebase

struct Group {
    let uid: String
    let groupName: String
    let schoolName: String
    let members: [String:String]
    
    // Initialize from Firebase
    init(snapshot: FDataSnapshot) {
        self.uid = snapshot.key
        self.groupName = snapshot.value["name"] as! String
        self.schoolName = snapshot.value["school"] as! String
        if snapshot.hasChild("members") {
            self.members = snapshot.value["members"] as! [String:String]
        } else {
            self.members = [:]
        }
    }
    
    // Initialize from arbitrary data
    init(uid: String, group: String, school: String) {
        self.uid = uid
        self.groupName = group
        self.schoolName = school
        self.members = [:]
    }
}