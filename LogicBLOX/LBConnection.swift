//
//  LBConnection.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 4 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBConnection: LBGate {

    override init(withDefaultSize size: CGSize) {
        super.init(withDefaultSize: size)
        nativeBounds = CGRect(x: 0, y: 0, width: 88, height: 57)
        var pin1 = LBPinType(x: 0, y: 24); pin1.facing = .left; pin1.type = .input
        var pin2 = LBPinType(x: 70, y: 34); pin2.facing = .right; pin2.type = .output
        pins = [pin1, pin2]
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func draw(_ scale: CGFloat) {
        let scaled = CGSize(width: bounds.width*scale, height: bounds.height*scale)
        let sbounds = CGRect(origin: bounds.origin, size: scaled)
        Gates.drawConnection(frame: sbounds, highlight: highlighted)
    }
    
}
