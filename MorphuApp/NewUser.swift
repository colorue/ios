//
//  NewUser.swift
//  Colorue
//
//  Created by Dylan Wight on 6/11/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation
import Firebase

class NewUser {
    var userId: String?
    var email: String?
    var password: String?
    var username: String?
    var fullName: String?
    var phoneNumber: String?
    var FacebookID: String?
    var userRer: FIRUser?
    
    var FacebookSignUp = false
    
    func toAnyObject()-> NSDictionary {
        return ["email": self.email!,
                "username": self.username!,
                "fullName": self.fullName!,
                "phoneNumber": self.phoneNumber!]
    }
}
