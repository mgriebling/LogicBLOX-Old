//
//  LBNand.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 3 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBNand: LBGate {
    
    var inputs : CGFloat { return 2 }

    override init(withDefaultSize size: CGSize) {
        super.init(withDefaultSize: size)
        nativeBounds = CGRect(x: 0, y: 0, width: 134, height: 68)
        var pin1 = LBPin(x: 0, y: 20); pin1.facing = .left; pin1.type = .input
        var pin2 = pin1; pin2.pos = CGPoint(x: 0, y: 50)
        var pin3 = LBPin(x: 118, y: 34); pin3.facing = .right; pin3.type = .output
        pins = [pin1, pin2, pin3]
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func draw(_ scale: CGFloat) {
        let scaled = CGSize(width: bounds.width*scale, height: bounds.height*scale)
        let origin = bounds.origin // CGPoint(x: bounds.origin.x*scale, y: bounds.origin.y*scale)
        let sbounds = CGRect(origin: origin, size: scaled)
        Gates.drawAndNandGate(frame: sbounds, highlight: highlighted, pinVisible: pinsVisible, inputs: inputs, invert: true)
    }
    
}

class LBNand3 : LBNand {
    
    override var inputs: CGFloat { return 3 }
    
}

class LBNand4 : LBNand {
    
    override var inputs: CGFloat { return 4 }
    
}
