//
//  LBBlock.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 4 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBBlock: LBGate {
    
    var name: String = "Block"

    override init(withDefaultSize size: CGSize) {
        super.init(withDefaultSize: size)
        nativeBounds = CGRect(x: 0, y: 0, width: 146, height: 141)
        var pin1 = LBPin(x: 0, y: 24); pin1.facing = .left; pin1.type = .input
        var pin2 = LBPin(x: 70, y: 34); pin2.facing = .right; pin2.type = .output
        pins = [pin1, pin2]
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func draw(_ scale: CGFloat) {
        let scaled = CGSize(width: bounds.width*scale, height: bounds.height*scale)
        let sbounds = CGRect(origin: bounds.origin, size: scaled)
        Gates.drawBlockGate(frame: sbounds, highlight: highlighted, pinVisible: pinsVisible, inputs: 1, name: name)
    }
    
}
