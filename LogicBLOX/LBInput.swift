//
//  LBInput.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 27 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBInput: LBGate {
    
    var name = "Input"
    
    override public var description: String {
        return "Input Pin"
    }
    
    override func localInit() {
        super.localInit()
        nativeBounds = CGRect(x: 0, y: 0, width: 135, height: 30)
        
        let pin1 = LBPin(x: bounds.width-LBPin.size, y: 15); pin1.type = .output
        pins = [pin1]
    }
    
    override func draw(_ scale: CGFloat) {
        Gates.drawInput(frame: bounds, name: name)
    }
    
    override func evaluate() -> LogicState {
        return .U
    }
    
}

