//
//  UserCellDelagate.swift
//  Canvas
//
//  Created by Dylan Wight on 5/28/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation
protocol UserCellDelagate {
    func followAction(userCell: UserCell)
    func unfollowAction(userCell: UserCell)
}