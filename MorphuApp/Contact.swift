//
//  Contact.swift
//  Colorue
//
//  Created by Dylan Wight on 6/18/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class Contact {
    
    let api = API.sharedInstance
    
    let name: String
    private var phoneNumbers = [String]()
    private var user: User?
    
    init(name: String) {
        self.name = name
    }
    
    func addPhoneNumber(number: String) {
        let stringArray = number.componentsSeparatedByCharactersInSet(
            NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        
        if stringArray.joinWithSeparator("").characters.count == 10 {
            let phone = "+1" + stringArray.joinWithSeparator("")
            self.phoneNumbers.append(phone)
            api.checkNumber(phone, callback: self.linkUser)
        } else if stringArray.joinWithSeparator("").characters.count == 11 {
            let phone = "+" + stringArray.joinWithSeparator("")
            self.phoneNumbers.append(phone)
        }
    }
    
    private func linkUser(user: User) {
        self.user = user
    }
    
    func getPhoneNumbers() -> [String] {
        return self.phoneNumbers
    }
    
    func hasNumber() -> Bool {
        return !self.phoneNumbers.isEmpty
    }
    
    func getUser() -> User? {
        return self.user
    }
}