//
//  LBConnection.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 4 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBConnection: LBGate {
    
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
    
    override func evaluate() -> LogicState {
        let state = pins[0].state
        var last = pins.last!
        last.state = state
        print("Evaluating connection = \(state)")
        return state
    }
    
    func bezierShape() -> UIBezierPath {
        guard pins.count > 1 else { return UIBezierPath() }
        let path = UIBezierPath()
        let pin1 = pins[0]
        let org = bounds.origin
        path.move(to: CGPoint(x:org.x+pin1.pos.x, y: org.y+pin1.pos.y))
        for pin in pins.dropFirst() {
            path.addLine(to: CGPoint(x:org.x+pin.pos.x, y: org.y+pin.pos.y))
        }
        return path
    }
    
}
