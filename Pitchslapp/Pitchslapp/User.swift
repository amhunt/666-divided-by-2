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
    
    // Initialize from Firebase
    init(authData: FAuthData) {
        uid = authData.uid
        email = authData.providerData["email"] as! String
        groupKey = "will change"
    }
    
    init(snapshot: FDataSnapshot) {
        uid = snapshot.key
        email = snapshot.value["login"] as! String
        groupKey = snapshot.value["groupid"] as! String
    }
    
    // Initialize from arbitrary data
    init(uid: String, email: String, group: String) {
        self.uid = uid
        self.email = email
        self.groupKey = group
    }
    
    func toAnyObject() -> AnyObject {
        return [
            "email": self.email,
            "groupid": self.groupKey
        ]
    }
}