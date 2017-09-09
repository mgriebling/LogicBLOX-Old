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
    
    var gates = [LBGate]() {
        didSet { setNeedsDisplay() }
    }

    override func draw(_ rect: CGRect) {
        UIColor.white.setFill()
        UIRectFill(rect)
        
        print("Drawing gates in \(rect)")
        
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
    
    var initialDelta: CGPoint = CGPoint.zero
    var selected : LBGate? = nil
    
    func moveSelected(_ gesture: UIPanGestureRecognizer) {
        let position = gesture.location(in: self)
        if gesture.state == .began {
            selected = gateUnderPoint(position)
            if let selected = selected {
                if !selected.highlighted { toggleSelection(selected); setNeedsDisplay() }
                initialDelta.x = selected.bounds.origin.x - position.x
                initialDelta.y = selected.bounds.origin.y - position.y
            }
        } else if gesture.state == .changed {
            if let selected = selected {
                selected.bounds.origin = CGPoint(x: position.x + initialDelta.x, y: position.y + initialDelta.y)
                setNeedsDisplay()
            }
        } else if gesture.state == .ended {
            setNeedsDisplay()
        }
    }
    
    func clearSelected() {
        let selected = gates.filter { (gate) -> Bool in
            return gate.highlighted
        }
        for gate in selected {
            gate.highlighted = false
        }
        setNeedsDisplay()
    }
    
    func deleteSelected(_ sender: UIBarButtonItem) {
        let selected = gates.filter { (gate) -> Bool in
            return gate.highlighted
        }
        for delete in selected {
            if let index = gates.index(of: delete) {
                gates.remove(at: index)
                setNeedsDisplay()
            }
        }
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
