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
    
    override public var description: String {
        return "Connection"
    }
    
    override func localInit() {
        super.localInit()
        pins = []  // these are initialized later
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
        path.move(to: bounds.offsetBy(dx: pin1.pos.x, dy: pin1.pos.y).origin)
        for pin in pins.dropFirst() {
            path.addLine(to: bounds.offsetBy(dx: pin.pos.x, dy: pin.pos.y).origin)
        }
        return path
    }
    
}
