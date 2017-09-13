//
//  LBNand.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 3 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBNand: LBGate {
    
    let yoff : CGFloat = 10
    let xoff : CGFloat = 4
    
    var inputs : CGFloat { return 2 }
    public var invert : Bool { return true }
    
    override public var description: String {
        let gate = invert ? "Nand" : "And"
        return "\(Int(inputs))-Input " + gate
    }

    override func localInit() {
        super.localInit()
        nativeBounds = CGRect(x: 0, y: 0, width: 134, height: 68)
        
        let pin1 = LBPin(x: xoff, y: 9+yoff)
        let pin2 = LBPin(x: xoff, y: 39+yoff)
        let pin3 = LBPin(x: nativeBounds.width-xoff, y: 25+yoff-1) // output pin is shared
        pins = [pin3, pin1, pin2]
    }
    
    override func draw(_ scale: CGFloat) {
        Gates.drawAndNandGate(frame: bounds, highlight: highlighted, pinVisible: pinsVisible, inputs: inputs, invert: invert)
    }
    
}

class LBNand3 : LBNand {
    
    override func localInit() {
        super.localInit()
        
        // replace last two pins with 3-input pins
        let pin1 = LBPin(x: xoff, y: 4+yoff)
        let pin2 = LBPin(x: xoff, y: 23+yoff)
        let pin3 = LBPin(x: xoff, y: 43+yoff)
        pins = pins.dropLast(2) + [pin1, pin2, pin3]
    }
    
    override var inputs: CGFloat { return 3 }
    
}

class LBNand4 : LBNand {
    
    override func localInit() {
        super.localInit()
        
        // replace last two pins with 3-input pins
        let pin1 = LBPin(x: xoff, y: 4+yoff)
        let pin2 = LBPin(x: xoff, y: 17+yoff)
        let pin3 = LBPin(x: xoff, y: 30+yoff)
        let pin4 = LBPin(x: xoff, y: 43+yoff)
        pins = pins.dropLast(2) + [pin1, pin2, pin3, pin4]
    }
    
    override var inputs: CGFloat { return 4 }
    
}
