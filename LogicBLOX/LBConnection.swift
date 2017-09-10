//
//  LBConnection.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 4 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBConnection: LBGate {

    override init(withDefaultSize size : CGSize = CGSize(width: 88, height: 57)) {
        super.init(withDefaultSize: size)
        nativeBounds = CGRect(origin: CGPoint.zero, size: size)
        var pin1 = LBPin(x: 0, y: 0); pin1.facing = .left; pin1.type = .input
        var pin2 = LBPin(x: 50, y: 0); pin2.facing = .right; pin2.type = .output
        pins = [pin1, pin2]
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func draw(_ scale: CGFloat) {
        // draw a connection between pin1 and pin2
        let path = UIBezierPath()
        let pin1 = pins[0]
        let pin2 = pins[1]
        path.move(to: pin1.pos)
        path.addLine(to: pin2.pos)
        path.lineWidth = 2.5
        if highlighted {
            UIColor.red.setStroke()
        } else {
            UIColor.black.setStroke()
        }
        path.stroke()
    }
    
}
