//
//  LBNor.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 4 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBNor: LBGate {

    var inputs : CGFloat { return 2 }
    
    override init(withDefaultSize size: CGSize) {
        super.init(withDefaultSize: size)
        nativeBounds = CGRect(x: 0, y: 0, width: 129, height: 70)
        var pin1 = LBPinType(x: 0, y: 24); pin1.facing = .left; pin1.type = .input
        var pin2 = pin1; pin2.pos = CGPoint(x: 0, y: 48)
        var pin3 = LBPinType(x: 70, y: 34); pin3.facing = .right; pin3.type = .output
        pins = [pin1, pin2, pin3]
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func draw(_ scale: CGFloat) {
        let scaled = CGSize(width: bounds.width*scale, height: bounds.height*scale)
        let sbounds = CGRect(origin: bounds.origin, size: scaled)
        Gates.drawOrNorGate(frame: sbounds, highlight: highlighted, pinVisible: pinsVisible, inputs: inputs, invert: true)
    }
    
}

class LBNor3 : LBNor {
    
    override var inputs: CGFloat { return 3 }
    
}

class LBNor4 : LBNor {
    
    override var inputs: CGFloat { return 4 }
    
}
