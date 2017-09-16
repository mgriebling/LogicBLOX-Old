//
//  LBInverter.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 4 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBInverter: LBGate {
    
    let yoff : CGFloat = 10
    let xoff : CGFloat = 4
    
    public var invert : Bool { return true }
    
    override public var description: String {
        return invert ? "Inverter" : "Buffer"
    }
    
    override func localInit() {
        super.localInit()
        nativeBounds = CGRect(x: 0, y: 0, width: 102, height: 57)
        
        let pin1 = LBPin(x: xoff, y: 28+yoff)
        var pin2 = LBPin(x: nativeBounds.width-xoff, y: 28+yoff-1); pin2.type = .output
        pins = [pin1, pin2]
    }
    
    override func draw(_ scale: CGFloat) {
        Gates.drawBufferInverterGate(frame: bounds, highlight: highlighted, inputPinVisible: CGFloat(inputPinVisible), outputPinVisible: outputPinVisible == 1, invert: invert)
    }
    
}
