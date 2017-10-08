//
//  LBBlock.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 4 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBBlock: LBGate {
    
    var name: String = "Custom"
    
    override func localInit() {
        super.localInit()
        inputs = 1
        nativeBounds = CGRect(x: 0, y: 0, width: 127, height: 121)
        let pin1 = LBPin(x: 0, y: 24); pin1.facing = .left; pin1.type = .input
        let pin2 = LBPin(x: 70, y: 34); pin2.facing = .right; pin2.type = .output
        pins = [pin1, pin2]
    }
    
    override public var description: String {
        return "Block"
    }
    
    override func draw(_ scale: CGFloat) {
        Gates.drawBlockGate(frame: bounds, highlight: highlighted, inputs: CGFloat(inputs), outputs: 1, joinedPin: joinedInputs, joinedOutputPin: joinedOutputs, inputPinVisible: inputPinVisible, outputPinVisible: outputPinVisible, name: name)
    }
    
}
