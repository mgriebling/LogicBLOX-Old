//
//  LBOr.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 4 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBOr: LBGate {

    var inputs : CGFloat { return 2 }
    
    override init(withDefaultSize size: CGSize) {
        super.init(withDefaultSize: size)
        nativeBounds = CGRect(x: 0, y: 0, width: 135, height: 68)
        var pin1 = LBPinType(x: 0, y: 24); pin1.facing = .left; pin1.type = .input
        var pin2 = pin1; pin2.pos = CGPoint(x: 0, y: 48)
        var pin3 = LBPinType(x: 68, y: 34); pin3.facing = .right; pin3.type = .output
        pins = [pin1, pin2, pin3]
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func draw(_ scale: CGFloat) {
        let scaled = CGSize(width: bounds.width*scale, height: bounds.height*scale)
        let sbounds = CGRect(origin: bounds.origin, size: scaled)
        Gates.drawOrNorGate(frame: sbounds, highlight: highlighted, pinVisible: pinsVisible, inputs: inputs, invert: false)
    }
    
}

class LBOr3 : LBOr {
    
    override var inputs: CGFloat { return 3 }
    
}

class LBOr4 : LBOr {
    
    override var inputs: CGFloat { return 4 }
    
}
