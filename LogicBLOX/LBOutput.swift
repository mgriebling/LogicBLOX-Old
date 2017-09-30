//
//  LBOutput.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 27 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBOutput: LBGate {
    
    var name = "Output"
    
    override public var description: String {
        return "Output Pin"
    }
    
    override func localInit() {
        super.localInit()
        nativeBounds = CGRect(x: 0, y: 0, width: 112, height: 30)
        
        let pin1 = LBPin(x: 5, y: 15)
        pins = [pin1]
    }
    
    override func draw(_ scale: CGFloat) {
        Gates.drawOutput(frame: bounds, highlight: highlighted, joinedPin: joinedInputs, inputPinVisible: inputPinVisible, name: name)
    }
    
    override func evaluate() -> LogicState {
        return .U
    }
    
}
