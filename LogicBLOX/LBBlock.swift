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
    
    override func localInit() {
        super.localInit()
        nativeBounds = CGRect(x: 0, y: 0, width: 146, height: 141)
        var pin1 = LBPin(x: 0, y: 24); pin1.facing = .left; pin1.type = .input
        var pin2 = LBPin(x: 70, y: 34); pin2.facing = .right; pin2.type = .output
        pins = [pin1, pin2]
    }
    
    override func draw(_ scale: CGFloat) {
        Gates.drawBlockGate(frame: bounds, highlight: highlighted, pinVisible: pinsVisible, inputs: 1, name: name)
    }
    
}
