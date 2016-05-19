//
//  Thread.swift
//  Morphu
//
//  Created by Dylan Wight on 4/8/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class Chain {
    
    let chainId: String
    private var contentList = [Content]()
    private var nextUser = User()

    init (chainId: String) {
        self.chainId = chainId
    }
    
    convenience init() {
        self.init(chainId: "")
    }
    
    func setNextUser(nextUser: User) {
        self.nextUser = nextUser
    }
    
    func getNextUser() -> User {
        return self.nextUser
    }
    
    func userIsParticipant(user: User) -> Bool {
        for content in self.contentList {
            if content.getAuthor().userId ==  user.userId {
                return true
            }
        }
        return false
    }
    
    func prependContent(content: Content) {
        self.contentList.insert(content, atIndex: 0)
    }
    
    func appendContent(content: Content) {
        self.contentList.append(content)
    }
    
    func getLastContent() -> Content? {
        return contentList.last
    }
    
    func getAllContent() -> [Content] {
        return contentList
    }
}