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
    
    var inputs : Int { return 2 }
    public var invert : Bool { return true }
    
    override public var description: String {
        let gate = invert ? "Nand" : "And"
        return "\(inputs)-Input " + gate
    }

    override func localInit() {
        super.localInit()
        nativeBounds = CGRect(x: 0, y: 0, width: 134, height: 68)
        
        let pin1 = LBPin(x: xoff, y: 9+yoff)
        let pin2 = LBPin(x: xoff, y: 39+yoff)
        var pin3 = LBPin(x: nativeBounds.width-xoff, y: 25+yoff-1); pin3.type = .output
        pins = [pin3, pin1, pin2]
    }
    
    override func draw(_ scale: CGFloat) {
        Gates.drawAndNandGate(frame: bounds, highlight: highlighted, pinVisible: outputPinVisible == 1, inputs: CGFloat(inputs), inputPinVisible: CGFloat(inputPinVisible), invert: invert)
    }
    
    override func evaluate() -> LogicState {
        if pins.count < self.inputs+1 { return .U }
        var out = pins[0]
        let inputStates = pins.dropFirst().map { $0.state }
        var state = inputStates[0]
        for input in inputStates.dropFirst() {
            state = state & input            // And function
        }
        out.state = invert ? !state : state  // Nand if inverted
        return out.state
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
    
    override var inputs: Int { return 3 }
    
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
    
    override var inputs: Int { return 4 }
    
}
