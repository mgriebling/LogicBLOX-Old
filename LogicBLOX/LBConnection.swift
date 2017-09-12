//
//  LBConnection.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 4 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBConnection: LBGate {
    
    override var pins: [LBPin] {
        didSet {
            let path = bezierShape()
            path.lineWidth = 10   // bigger to detect touches
            bounds = path.bounds
        }
    }
    
    override func localInit() {
        super.localInit()
        let pin1 = LBPin(x: 0, y: 0)
        pins = [pin1, pin1, pin1]  // these are initialized later
    }
    
    override func draw(_ scale: CGFloat) {
        // draw a connection joining all the pins
        let path = bezierShape()
        path.lineWidth = 2.5
        if highlighted {
            Gates.highlightColour.setStroke()
        } else {
            Gates.baseColor.setStroke()
        }
        path.stroke()
    }
    
    func bezierShape() -> UIBezierPath {
        let path = UIBezierPath()
        let pin1 = pins[0]
        path.move(to: pin1.pos)
        for pin in pins.dropFirst() {
            path.addLine(to: pin.pos)
        }
        return path
    }
    
}
