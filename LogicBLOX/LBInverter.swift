//
//  LBInverter.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 4 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBInverter: LBGate {
    
    var yoff : CGFloat { return 0 }
    var xoff : CGFloat { return 4 }
    
    public var invert : Bool { return true }
    
    override public var description: String {
        return invert ? "Inverter" : "Buffer"
    }
    
    override func localInit() {
        super.localInit()
        nativeBounds = CGRect(x: 0, y: 0, width: 102, height: 57)
        let xoff2 : CGFloat = invert ? 0 : 20   // account for inverter
        
        let pin1 = LBPin(x: xoff, y: 28+yoff)
        let pin2 = LBPin(x: nativeBounds.width-xoff-xoff2, y: 28+yoff); pin2.type = .output
        pins = [pin2, pin1]
    }
    
    override func draw(_ scale: CGFloat) {
        Gates.drawBufferInverterGate(frame: bounds, highlight: highlighted, inputPinVisible: CGFloat(inputPinVisible), outputPinVisible: outputPinVisible == 1, invert: invert)
    }
    
    override func evaluate() -> LogicState {
        var state = pins[1].state       // Buffer
        state = invert ? !state : state // Not if inverted
        pins[0].state = state
        return state
    }
    
}
