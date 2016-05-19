//
//  User.swift
//  Morphu
//
//  Created by Dylan Wight on 4/21/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import UIKit
class User {
    
    let userId: String
    let username: String
    let email: String
    var profileImage: UIImage  //make getter and setter
    
    init(userId: String = "", email: String = "", username: String = "", profileImage: UIImage = UIImage()) {
        self.userId = userId
        self.username = username
        self.email = email
        self.profileImage = profileImage
    }
}