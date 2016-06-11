//
//  NewUser.swift
//  Colorue
//
//  Created by Dylan Wight on 6/11/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class NewUser {
    var email: String?
    var password: String?
    var username: String?
    var fullName: String?
    var phoneNumber: String?
    
    
    func toAnyObject()-> NSDictionary {
        if let fullName = fullName {
            if let phoneNumber = phoneNumber {
                return ["email": self.email!,
                        "password": self.password!,
                        "username": self.username!,
                        "fullName": fullName,
                        "phoneNumber": phoneNumber]
                
            } else {
                return ["email": self.email!,
                        "password": self.password!,
                        "username": self.username!,
                        "fullName": fullName]
            }
        } else if let phoneNumber = phoneNumber {
            return ["email": self.email!,
                    "password": self.password!,
                    "username": self.username!,
                    "phoneNumber": phoneNumber]
        } else {
            return ["email": self.email!,
                    "password": self.password!,
                    "username": self.username!]
        }
    }
}
