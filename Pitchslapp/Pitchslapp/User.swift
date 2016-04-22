//
//  User.swift
//  Pitchslapp
//
//  Created by Zachary Stecker on 3/31/16.
//  Copyright © 2016 Social Coderz. All rights reserved.
//

import Foundation
import Firebase

struct User {
    let uid: String
    let email: String
    var groupKey: String
    var name: String
    
    // Initialize from Firebase
    init(authData: FAuthData) {
        uid = authData.uid
        email = authData.providerData["email"] as! String
        name = "will change"
        groupKey = "will change"
    }
    
    init(snapshot: FDataSnapshot) {
        uid = snapshot.key
        email = snapshot.value["login"] as! String
        groupKey = snapshot.value["groupid"] as! String
        name = snapshot.value["name"] as! String
    }
    
    // Initialize from arbitrary data
    init(uid: String, email: String, group: String, name: String) {
        self.uid = uid
        self.email = email
        self.groupKey = group
        self.name = name
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "email": self.email,
            "groupid": self.groupKey,
            "name": self.name
        ]
    }
}