//
//  Wall.swift
//  Canvas
//
//  Created by Dylan Wight on 5/29/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

import Foundation

class Wall {
    private var drawings = [Drawing]()
    
    private var oldestTimeLoaded: Double = -99999999999999
    private var newestTimeLoaded: Double = 0
    
    var delagate: APIDelagate?
    
    func getDrawings() -> [Drawing] {
        return self.drawings
    }
    
    func addDrawing(drawing: Drawing, new: Bool) {
        if self.drawings.count == 0 {
            self.drawings.append(drawing)
            self.oldestTimeLoaded = drawing.timeStamp
            self.newestTimeLoaded = drawing.timeStamp
            self.delagate?.refresh()
        } else if drawing.timeStamp > self.oldestTimeLoaded {
            self.oldestTimeLoaded = drawing.timeStamp
            self.drawings.append(drawing)
        } else if drawing.timeStamp < self.newestTimeLoaded {
            self.newestTimeLoaded = drawing.timeStamp
            self.drawings.insert(drawing, atIndex: 0)
        } else {
            if new {
                var i = 0
                for drawing_ in self.drawings {
                    if drawing_.timeStamp > drawing.timeStamp {
                        self.drawings.insert(drawing, atIndex: i)
                        return
                    }
                    i += 1
                }
            }
        }
    }
    
    func removeDrawing(drawingId: String) {
        var i = 0
        for drawing in self.drawings {
            if drawing.getDrawingId() == drawingId {
                self.drawings.removeAtIndex(i)
                return
            }
            i += 1
        }
    }
    
    func removeAll() {
        self.drawings.removeAll()
    }
}
