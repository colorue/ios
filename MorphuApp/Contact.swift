//
//  Contact.swift
//  Colorue
//
//  Created by Dylan Wight on 6/18/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

enum phoneType: String {
    case Mobile = "_$!<Mobile>!$_"
    case Home = "_$!<Home>!$_"
    case Work = "_$!<Work>!$_"
    case Main = "_$!<Main>!$_"
    case Iphone = "iPhone"
    case Blank = ""
}

class Contact {
    
    let api = API.sharedInstance
    
    let name: String
    fileprivate var iPhoneNumber: String?
    fileprivate var mobileNumber: String?
    fileprivate var mainNumber: String?
    fileprivate var homeNumber: String?
    fileprivate var workNumber: String?
    fileprivate var blankNumber: String?
    
//    private var user: User?
    
    init(name: String) {
        self.name = name
    }
    
    func addPhoneNumber(_ number: String, type: phoneType) {
        let stringArray = number.components(
            separatedBy: CharacterSet.decimalDigits.inverted)
        
        if stringArray.joined(separator: "").characters.count == 10 {
            let phone = "+1" + stringArray.joined(separator: "")
            self.setPhoneNumber(number, type: type)
            api.checkNumber(phone)
        } else if stringArray.joined(separator: "").characters.count == 11 {
            let phone = "+" + stringArray.joined(separator: "")
            self.setPhoneNumber(number, type: type)
            api.checkNumber(phone)

        }
    }
    
    fileprivate func setPhoneNumber(_ number: String, type: phoneType) {
        switch (type) {
        case .Mobile:
            self.mobileNumber = number
        case .Home:
            self.homeNumber = number
        case .Work:
            self.workNumber = number
        case .Main:
            self.mainNumber = number
        case .Iphone:
            self.iPhoneNumber = number
        case .Blank:
            self.blankNumber = number
        }
    }
    
//    private func linkUser(user: User) {
//        self.user = user
//    }
    
    func getPhoneNumber() -> String? {
        // phone type Priority
        if let iPhoneNumber = self.iPhoneNumber {
            return iPhoneNumber
        } else if let mobileNumber = self.mobileNumber {
            return mobileNumber
        } else if let mainNumber = self.mainNumber {
            return mainNumber
        } else if let blankNumber = self.blankNumber {
            return blankNumber
        } else if let homeNumber = self.homeNumber {
            return homeNumber
        } else if let workNumber = self.workNumber {
            return workNumber
        } else {
            return nil
        }
    }
    
//    func getUser() -> User? {
//        return self.user
//    }
}

extension Contact: Hashable {
    var hashValue: Int {
        return getPhoneNumber()?.hashValue ?? 0.hashValue
    }
}

// MARK: Equatable
func == (lhs: Contact, rhs: Contact) -> Bool {
    return lhs.getPhoneNumber() == lhs.getPhoneNumber()
}
