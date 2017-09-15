//
//  LBInput.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 5 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBButton: LBGate {
    
    var state : LogicState = .zero
    var name : String = "Input"
    
    override public var description: String {
        return "Input"
    }
    
    override func localInit() {
        super.localInit()
        nativeBounds = CGRect(x: 0, y: 0, width: 95, height: 69)
        let pin1 = LBPin(x: 95-LBPin.size, y: 34.5)
        pins = [pin1]
    }
    
    override func evaluate() -> LogicState {
        return state
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
        Gates.drawButton(frame: bounds, highlight: highlighted, pinVisible: outputPinVisible == 1, state: state, name: name)
    }
    
}
