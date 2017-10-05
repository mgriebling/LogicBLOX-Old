//
//  Grid.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 2 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBGrid {
    
    var color : UIColor? = UIColor.lightGray
    var spacing : CGFloat = 4
    var isAlwaysShown : Bool = true
    var isConstraining : Bool = true
    var isUsable : Bool { return spacing > 0 }
    var canAlign : Bool { return isUsable }
    
    func constrainedPoint(_ point: CGPoint) -> CGPoint {
        var point = point
        if isUsable && isConstraining {
            point.x = floor(point.x / spacing + 0.5) * spacing
            point.y = floor(point.y / spacing + 0.5) * spacing
        }
        return point
    }
    
    func alignedRect(_ rect: CGRect) -> CGRect {
        var upperRight = CGPoint(x: rect.maxX, y: rect.maxY)
        var rect = rect
        rect.origin.x = floor(rect.origin.x / spacing + 0.5) * spacing
        rect.origin.y = floor(rect.origin.y / spacing + 0.5) * spacing
        upperRight.x = floor(upperRight.x / spacing + 0.5) * spacing
        upperRight.y = floor(upperRight.y / spacing + 0.5) * spacing
        rect.size.width = upperRight.x - rect.origin.x
        rect.size.height = upperRight.y - rect.origin.y
        return rect
    }
    
    func drawRect(_ rect: CGRect, inView view: UIView) {
        let spacing = self.spacing * 2  // visible spacing skips lines
        if isUsable && isAlwaysShown {
            let gridPath = UIBezierPath()
            let firstVerticalLineNumber = Int(ceil(rect.minX / spacing))
            let lastVerticalLineNumber = Int(floor(rect.maxX / spacing))
            for lineNumber in firstVerticalLineNumber...lastVerticalLineNumber {
                gridPath.move(to: CGPoint(x: CGFloat(lineNumber) * spacing, y: rect.minY))
                gridPath.addLine(to: CGPoint(x:CGFloat(lineNumber) * spacing, y: rect.maxY))
            }
            let firstHorizontalLineNumber = Int(ceil(rect.minX / spacing))
            let lastHorizontalLineNumber = Int(floor(rect.maxX / spacing))
            for lineNumber in firstHorizontalLineNumber...lastHorizontalLineNumber {
                gridPath.move(to: CGPoint(x: rect.minX, y: CGFloat(lineNumber) * spacing))
                gridPath.addLine(to: CGPoint(x: rect.maxX, y: CGFloat(lineNumber) * spacing))
            }
            
            // draw the grid as one-pixel-wide lines of a specific colour
            color?.set()
            gridPath.lineWidth = 0.5
            gridPath.stroke()
        }
    }
    
}
