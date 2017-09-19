//
//  LBIndicator.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 5 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBIndicator: LBGate {
    
    var name: String = "LED1"
    
    let yoff : CGFloat = 0
    
    override public var description: String {
        return "Indicator"
    }
    
    override func localInit() {
        super.localInit()
        nativeBounds = CGRect(x: 0, y: 0, width: 57, height: 35)
        let pin1 = LBPin(x: LBPin.size/2, y: 17.5+yoff); pin1.facing = .left; pin1.type = .input
        pins = [pin1]
    }
    
    override func draw(_ scale: CGFloat) {
        let pin1 = pins.first!
        let state : CGFloat = pin1.state.isOne ? 1 : 0
        Gates.drawIndicator(frame: bounds, highlight: highlighted, state: state, inputPinVisible: CGFloat(inputPinVisible))
    }
    
}
