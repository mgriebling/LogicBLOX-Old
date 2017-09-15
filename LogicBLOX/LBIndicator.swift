//
//  LBIndicator.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 5 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBIndicator: LBGate {
    
    var name: String = "LED1"
    
    override public var description: String {
        return "Indicator"
    }
    
    override func localInit() {
        super.localInit()
        nativeBounds = CGRect(x: 0, y: 0, width: 94, height: 73)
        var pin1 = LBPin(x: LBPin.size, y: 36.5); pin1.facing = .left; pin1.type = .input
        pins = [pin1]
    }
    
    override func draw(_ scale: CGFloat) {
        let pin1 = pins.first!
        Gates.drawIndicator(frame: bounds, highlight: highlighted, pinVisible: inputPinVisible == 1, state: CGFloat(pin1.state.rawValue), name: name)
    }
    
}
