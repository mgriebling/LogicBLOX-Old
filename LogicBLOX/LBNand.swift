//
//  LBNand.swift
//  LogicBLOX
//
//  Created by Michael Griebling on 25Sep2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

// MARK: -
// MARK: - Nand Gates

// Note: For some reason PropertyListEncoder() can't encode these gates when they are in a separate file ???
//       Smells like a bug.

class LBNand : LBGate {
    
    fileprivate var inputs : Int { return 2 }
    fileprivate var invert : Bool { return true }
    fileprivate let yoff : CGFloat = 10
    fileprivate let xoff : CGFloat = 4
    
    override public var description: String {
        let gate = invert ? "Nand" : "And"
        return "\(inputs)-Input " + gate
    }
    
    override func localInit() {
        super.localInit()
        nativeBounds = CGRect(x: 0, y: 0, width: 120, height: 60)
        
        let pin1 = LBPin(x: xoff, y: 10+yoff)
        let pin2 = LBPin(x: xoff, y: 34+yoff)
        let pin3 = LBPin(x: nativeBounds.width-xoff, y: 30+yoff-1); pin3.type = .output
        pins = [pin3, pin1, pin2]
    }
    
    override func draw(_ scale: CGFloat) {
        Gates.drawAndNandGate(frame: bounds, highlight: highlighted, inputs: CGFloat(inputs), joinedPin: joinedInputs, joinedOutputPin: joinedOutputs, inputPinVisible: inputPinVisible, outputPinVisible: outputPinVisible, invert: invert)
    }
    
    override func evaluate() -> LogicState {
        if pins.count < inputs+1 { return .U }
        let inputStates = pins.dropFirst().map { $0.state }
        var state = inputStates[0]
        for input in inputStates.dropFirst() {
            state = state & input            // And function
        }
        state = invert ? !state : state      // Nand if inverted
        pins[0].state = state
        return state
    }
    
}

class LBNand3 : LBNand {
    
    override fileprivate var inputs : Int { return 3 }
    
    override func localInit() {
        super.localInit()
        
        // replace last two pins with 3-input pins
        let pin1 = LBPin(x: xoff, y: 2+yoff)
        let pin2 = LBPin(x: xoff, y: 22+yoff)
        let pin3 = LBPin(x: xoff, y: 42+yoff)
        pins = pins.dropLast(2) + [pin1, pin2, pin3]
    }
    
}

class LBNand4 : LBNand {
    
    override fileprivate var inputs : Int { return 4 }
    
    override func localInit() {
        super.localInit()
        
        // replace last two pins with 3-input pins
        let pin1 = LBPin(x: xoff, y: 2+yoff)
        let pin2 = LBPin(x: xoff, y: 14+yoff)
        let pin3 = LBPin(x: xoff, y: 30+yoff)
        let pin4 = LBPin(x: xoff, y: 42+yoff)
        pins = pins.dropLast(2) + [pin1, pin2, pin3, pin4]
    }
    
}

// MARK: -
// MARK: - And Gates

class LBAnd: LBNand {
    
    override var invert: Bool { return false }
    
}

class LBAnd3 : LBNand3 {
    
    override var invert: Bool { return false }
    
}

class LBAnd4 : LBNand4 {
    
    override var invert: Bool { return false }
    
}

