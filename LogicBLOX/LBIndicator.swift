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
    
    override init(withDefaultSize size: CGSize) {
        super.init(withDefaultSize: size)
        nativeBounds = CGRect(x: 0, y: 0, width: 94, height: 73)
        var pin1 = LBPin(x: 0, y: 24); pin1.facing = .left; pin1.type = .input
        pins = [pin1]
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func draw(_ scale: CGFloat) {
        let scaled = CGSize(width: bounds.width*scale, height: bounds.height*scale)
        let sbounds = CGRect(origin: bounds.origin, size: scaled)
        Gates.drawIndicator(frame: sbounds, highlight: highlighted, pinVisible: pinsVisible, state: 0, name: name)
    }
    
}
