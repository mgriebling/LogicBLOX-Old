//
//  LBInput.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 5 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBButton: LBGate {
    
    var state = LogicState.zero
    var name : String = "Input"
    
    let yoff : CGFloat = 0
    
    override public var description: String {
        return "Button"
    }
    
    override func localInit() {
        super.localInit()
        nativeBounds = CGRect(x: 0, y: 0, width: 52, height: 32)
        let pin1 = LBPin(x: nativeBounds.width-LBPin.size, y: 16+yoff); pin1.type = .output
        pins = [pin1]
    }
    
    override func evaluate() -> LogicState {
        pins[0].state = self.state
        return self.state
    }
    
    func toggleState() {
        if state == .zero {
            state = .one
        } else {
            state = .zero
        }
    }
    
    override func draw(_ scale: CGFloat) {
        let state : CGFloat = self.state == .one ? 1 : 0
        Gates.drawButtonR(frame: bounds, highlight: highlighted, state: state, joinedOutputPin: 0, outputPinVisible: CGFloat(outputPinVisible))
    }
    
}
