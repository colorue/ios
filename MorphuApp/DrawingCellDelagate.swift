//
//  DrawingCellDelagate.swift
//  Morphu
//
//  Created by Dylan Wight on 5/23/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation
protocol DrawingCellDelagate {
    func like(drawingCell: DrawingCell) -> ()
    func unlike(drawingCell: DrawingCell) -> ()
    func upload(drawingCell: DrawingCell) -> ()
    func viewLikes(drawingCell: DrawingCell) -> ()
    func viewComments(drawingCell: DrawingCell) -> ()
    func refresh()
    
}