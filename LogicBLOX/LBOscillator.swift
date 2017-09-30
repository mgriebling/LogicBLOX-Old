//
//  LBOscillator.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 30 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBOscillator: LBGate {
    
    var state = LogicState.zero
    
    var onTime = 2      // number of cycles in On state
    var offTime = 2     // number of cycles in Off state
    var counter = 0
    
    let yoff : CGFloat = 0
    
    override public var description: String {
        return "Oscillator"
    }
    
    override func localInit() {
        super.localInit()
        nativeBounds = CGRect(x: 0, y: 0, width: 51, height: 32)
        let pin1 = LBPin(x: nativeBounds.width-LBPin.size, y: 16+yoff); pin1.type = .output
        pins = [pin1]
    }
    
    override func evaluate() -> LogicState {
        pins[0].state = self.state
        return self.state
    }
    
    func updateState() {
        if state == .zero {
            if counter > 0 {
                counter -= 1
            } else {
                counter = onTime
                state = .one
            }
        } else {
            if counter > 0 {
                counter -= 1
            } else {
                counter = offTime
                state = .zero
            }
        }
    }
    
    override func draw(_ scale: CGFloat) {
        Gates.drawOscillator(frame: bounds, highlight: highlighted, joinedOutputPin: joinedOutputs, outputPinVisible: outputPinVisible)
    }
    
}

