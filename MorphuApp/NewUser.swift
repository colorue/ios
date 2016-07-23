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
    var userRef: FIRUser?
    
    var FacebookSignUp = false
    
    func toAnyObject()-> NSDictionary {
        let object: NSMutableDictionary = ["email": self.email ?? "",
                                           "username": self.username ?? "", "fullName": self.fullName ?? ""]
        
        if let phoneNumber = self.phoneNumber {
            object["phoneNumber"] = phoneNumber
        }
        
        if let FacebookID = self.FacebookID {
            object["FacebookID"] = FacebookID
        }
        
        return  object
    }
}
