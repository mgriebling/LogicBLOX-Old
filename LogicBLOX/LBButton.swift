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
    
    override init(withDefaultSize size: CGSize) {
        super.init(withDefaultSize: size)
        nativeBounds = CGRect(x: 0, y: 0, width: 95, height: 69)
        var pin1 = LBPinType(x: 86-LBPinType.size, y: 30.5); pin1.facing = .right; pin1.type = .output
        pins = [pin1]
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
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
        let scaled = CGSize(width: bounds.width*scale, height: bounds.height*scale)
        let sbounds = CGRect(origin: bounds.origin, size: scaled)
        let state : CGFloat = self.state == .one ? 1 : 0
        Gates.drawButton(frame: sbounds, highlight: highlighted, pinVisible: pinsVisible, state: state, name: name)
    }
    
}
