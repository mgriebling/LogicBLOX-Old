//
//  LBNand.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 3 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBNand: LBGate {
    
    let yoff : CGFloat = 10
    let xoff : CGFloat = 4
    
    var inputs : CGFloat { return 2 }

    override init(withDefaultSize size: CGSize) {
        super.init(withDefaultSize: size)
        nativeBounds = CGRect(x: 0, y: 0, width: 134, height: 68)

        let pin1 = LBPin(x: xoff, y: 9+yoff)
        let pin2 = LBPin(x: xoff, y: 39+yoff)
        let pin3 = LBPin(x: nativeBounds.width-xoff, y: 25+yoff-1)
        pins = [pin3, pin1, pin2]
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func draw(_ scale: CGFloat) {
        Gates.drawAndNandGate(frame: bounds, highlight: highlighted, pinVisible: highlighted, inputs: inputs, invert: true)
    }
    
}

class LBNand3 : LBNand {
    
    
    
    override var inputs: CGFloat { return 3 }
    
}

class LBNand4 : LBNand {
    
    override var inputs: CGFloat { return 4 }
    
}
