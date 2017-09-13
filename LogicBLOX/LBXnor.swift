//
//  LBXnor.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 4 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBXnor: LBGate {
    
    let yoff : CGFloat = 10
    let xoff : CGFloat = 4
    
    var inputs : CGFloat { return 2 }
    public var invert : Bool { return true }
    
    override public var description: String {
        let gate = invert ? "Xnor" : "Xor"
        return "\(Int(inputs))-Input " + gate
    }
    
    override func localInit() {
        super.localInit()
        nativeBounds = CGRect(x: 0, y: 0, width: 143, height: 67)
        
        let pin1 = LBPin(x: xoff, y: 9+yoff)
        let pin2 = LBPin(x: xoff, y: 39+yoff)
        let pin3 = LBPin(x: nativeBounds.width-xoff, y: 34+yoff-1) // output pin is shared
        pins = [pin3, pin1, pin2]
    }
    
    override func draw(_ scale: CGFloat) {
        Gates.drawXorXnorGate(frame: bounds, highlight: highlighted, pinVisible: pinsVisible, inputs: inputs, invert: true)
    }
    
}

class LBXnor3 : LBXnor {
    
    override var inputs: CGFloat { return 3 }
    
    override func localInit() {
        super.localInit()
        
        // replace last two pins with 3-input pins
        let pin1 = LBPin(x: xoff, y: 8+yoff)
        let pin2 = LBPin(x: xoff, y: 27+yoff)
        let pin3 = LBPin(x: xoff, y: 47+yoff)
        pins = pins.dropLast(2) + [pin1, pin2, pin3]
    }
}

class LBXnor4 : LBXnor {
    
    override var inputs: CGFloat { return 4 }

    override func localInit() {
        super.localInit()
        
        // replace last two pins with 3-input pins
        let pin1 = LBPin(x: xoff, y: 8+yoff)
        let pin2 = LBPin(x: xoff, y: 21+yoff)
        let pin3 = LBPin(x: xoff, y: 34+yoff)
        let pin4 = LBPin(x: xoff, y: 47+yoff)
        pins = pins.dropLast(2) + [pin1, pin2, pin3, pin4]
    }
}
