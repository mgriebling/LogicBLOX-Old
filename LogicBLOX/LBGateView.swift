//
//  GateView.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 2 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBGateView: UIView {
    
    var grid = LBGrid()
    
    var creatingGate : LBGate?
    var editingGate : LBGate?
    
    var gates = [LBGate]()

    override func draw(_ rect: CGRect) {
        UIColor.white.setFill()
        UIRectFill(rect)
        
        // draw the grid
        grid.drawRect(rect, inView: self)
        
        // draw the gates
        let gc = UIGraphicsGetCurrentContext()
        for gate in gates {
            let drawingBounds = gate.bounds
            if rect.intersects(drawingBounds) {
                let drawSelectionPins = true
                
                gc?.saveGState()
                gc?.clip(to: drawingBounds)
                gate.draw(1)
                if drawSelectionPins { gate.drawPins(1) }
                gc?.restoreGState()
            }
        }
    }
    
    func toggleSelection (_ gate : LBGate) {
        gate.highlighted = !gate.highlighted
        setNeedsDisplay()
    }
    
    func insertGate (_ gateID: LBGateType, withEvent event: UIGestureRecognizer?) {
        var gateOrigin : CGPoint
        if let event = event {
            gateOrigin = event.location(in: self)
        } else {
            gateOrigin = CGPoint(x: 10, y: 10)
        }
        gateOrigin = grid.constrainedPoint(gateOrigin)
        
        let gate = LBGateType.classForGate(gateID)
        gate.defaultBounds()
        gate.bounds = CGRect(origin: gateOrigin, size: gate.bounds.size)
        gate.highlighted = true
        
        gates.append(gate)
        if creatingGate != nil {
            creatingGate?.highlighted = false
        }
        creatingGate = gate
        setNeedsDisplay()
    }
    
    func moveSelected(_ gesture: UIPanGestureRecognizer) {
        
    }
    
    func gateUnderPoint(_ point: CGPoint) -> LBGate? {
        for gate in gates {
            if gate.bounds.contains(point) {
                return gate
            }
        }
        return nil
    }

}
