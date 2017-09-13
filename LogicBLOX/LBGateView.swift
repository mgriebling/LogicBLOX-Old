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
        
//        print("Drawing gates in \(rect)")
        
        // draw the grid
        grid.drawRect(rect, inView: self)
        
        // draw the gates
        let gc = UIGraphicsGetCurrentContext()
        for gate in gates {
            let drawingBounds = gate.bounds
            if rect.intersects(drawingBounds) {
                gc?.saveGState()
                gc?.clip(to: rect)
                gate.draw(1)
                gc?.restoreGState()
            }
        }
    }
    
    func toggleSelection (_ gate : LBGate) {
        gate.highlighted = !gate.highlighted
        setNeedsDisplay()
    }
    
    func insertGate (_ gateID: LBGateType, withEvent event: UITapGestureRecognizer?) {
        var gateOrigin : CGPoint
        if event != nil {
            gateOrigin = event!.location(in: self)
        } else {
            gateOrigin = CGPoint(x: 10, y: 10)
        }
        gateOrigin = grid.constrainedPoint(gateOrigin)
        
        if let gate = gateUnderPoint(gateOrigin) {
            if gateID == .line {
                createLine(fromGate: gate, withGesture: event!)
            } else {
                toggleSelection(gate)
            }
        } else if gateID != .line {
            let gate = LBGateType.classForGate(gateID)
            gate.defaultBounds()
            gate.bounds = CGRect(origin: gateOrigin, size: gate.bounds.size)
            gate.highlighted = true
            
            gates.append(gate)
            creatingGate?.highlighted = false
            creatingGate = gate
        }
        setNeedsDisplay()
    }
    
    private var initialDelta: CGPoint = CGPoint.zero

    var selected : [LBGate] { return gates.filter { $0.highlighted } }
    
    func moveSelected(_ gesture: UIPanGestureRecognizer) {
        let position = gesture.location(in: self)
        if gesture.state == .began {
            if let gate = gateUnderPoint(position) {
                if !gate.highlighted { toggleSelection(gate); setNeedsDisplay() }
            }
            initialDelta = position
        } else if gesture.state == .changed {
            let move = CGPoint(x: position.x - initialDelta.x, y: position.y - initialDelta.y)
            initialDelta = position
            LBGate.translateGates(selected, byX: move.x, y: move.y)
            setNeedsDisplay()
        } else if gesture.state == .ended {
            setNeedsDisplay()
        }
    }

    func createLine(fromGate gate: LBGate, withGesture gesture: UITapGestureRecognizer) {
        gate.pinsVisible = true
        gate.highlighted = true
        if editingGate == nil {
            editingGate = gate
            sourcePin = gate.getClosestPinIndex(location)
        } else {
            if let destPin = gate.getClosestPinIndex(location) {
                joinGates(sourceGate!, atPin:sourcePin, to: gate, atPin:destPin)
                editingGate = nil
            } else {
                // add a pin to the active line
                editingGate?.pins.append(<#T##newElement: LBPin##LBPin#>)
            }
        }
    }
    
    func joinGates (_ source: LBGate, atPin spin: Int?, to destination: LBGate, atPin dpin: Int?) {
        // draw a connection between these gates
        if let spin = spin, let dpin = dpin {
            let connection = LBConnection()
            let spt  = source.pins[spin].pos
            let spta = CGPoint(x: spt.x+source.bounds.origin.x, y: spt.y+source.bounds.origin.y)
            let ept  = destination.pins[dpin].pos
            let epta = CGPoint(x: ept.x+destination.bounds.origin.x, y: ept.y+destination.bounds.origin.y)
            let mid = CGPoint(x: epta.x, y: spta.y)
            
            connection.pins[0].pos = spta
            connection.pins[1].pos = mid
            connection.pins[2].pos = epta
            connection.highlighted = true
            gates.append(connection)
            source.highlighted = false
            source.pinsVisible = false
            destination.highlighted = false
            destination.pinsVisible = false
            setNeedsDisplay()
        }
    }
    
    func clearSelected() {
        for gate in selected {
            gate.highlighted = false
            gate.pinsVisible = false
        }
        setNeedsDisplay()
    }
    
    func deleteSelected(_ sender: UIBarButtonItem) {
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
