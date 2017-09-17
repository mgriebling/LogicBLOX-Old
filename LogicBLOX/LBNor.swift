//
//  LBNor.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 4 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBNor: LBGate {

    let yoff : CGFloat = 11
    let xoff : CGFloat = 4
    
    var inputs : Int { return 2 }
    public var invert : Bool { return true }
    
    override public var description: String {
        let gate = invert ? "Nor" : "Or"
        return "\(inputs)-Input " + gate
    }
    
    override func localInit() {
        super.localInit()
        nativeBounds = CGRect(x: 0, y: 0, width: 135, height: 67)
        let xoff2 : CGFloat = invert ? 2 : 20   // account for inverter
        
        let pin1 = LBPin(x: xoff, y: 9+yoff)
        let pin2 = LBPin(x: xoff, y: 39+yoff)
        let pin3 = LBPin(x: nativeBounds.width-xoff-xoff2, y: 34-1); pin3.type = .output
        pins = [pin3, pin1, pin2]
    }
    
    override func draw(_ scale: CGFloat) {
        Gates.drawOrNorGate(frame: bounds, highlight: highlighted, inputs: CGFloat(inputs), inputPinVisible: CGFloat(inputPinVisible), outputPinVisible: outputPinVisible == 1, invert: invert)
    }
    
    override func evaluate() -> LogicState {
        if pins.count < self.inputs+1 { return .U }
        let inputStates = pins.dropFirst().map { $0.state }
        var state = inputStates[0]
        for input in inputStates.dropFirst() {
            state = state | input            // Or function
        }
        state = invert ? !state : state      // Nor if inverted
        pins[0].state = state
        return state
    }
    
}

class LBNor3 : LBNor {
    
    override var inputs: Int { return 3 }
    
    override func localInit() {
        super.localInit()
        
        // replace last two pins with 3-input pins
        let pin1 = LBPin(x: xoff, y: 8+yoff)
        let pin2 = LBPin(x: xoff, y: 27+yoff)
        let pin3 = LBPin(x: xoff, y: 47+yoff)
        pins = pins.dropLast(2) + [pin1, pin2, pin3]
    }

}

class LBNor4 : LBNor {
    
    override var inputs: Int { return 4 }
    
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
