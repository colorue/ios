//
//  PushService.swift
//  Colorue
//
//  Created by Dylan Wight on 10/2/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Alamofire
import Firebase

struct PushService {
    let myRootRef = FIRDatabase.database().reference()

    func send(message: String, to user: User, badge: String = "+0") {
        myRootRef.child("airshipKey").observeSingleEvent(of: .value, with: { snapshot in

            guard snapshot.exists() else { return }
            let airshipKey = snapshot.value as! String
            
            let iosData: NSDictionary = ["alert": message]
            let notificationData: NSDictionary = ["ios": iosData]
            let namedUser: NSDictionary = ["named_user": user.userId]
            let parameters: [String : Any] = ["audience":namedUser, "notification":notificationData, "device_types":["ios"]]
            let headers: HTTPHeaders = ["Authorization" : airshipKey,
                                        "Accept" : "application/vnd.urbanairship+json; version=3",
                                        "Drawing-Type" : "application/json"]
            
            Alamofire.request("https://go.urbanairship.com/api/push", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
                debugPrint(response)
            }
        })
    }
}
