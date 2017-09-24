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
    
    private var creatingGate : LBGate?
    private var editingGate : LBGate?
    
    var gates = [LBGate]() {
        didSet { setNeedsDisplay() }
    }

    override func draw(_ rect: CGRect) {
        UIColor.white.setFill()
        UIRectFill(rect)
        
        print("Drawing gates : \(gates)")
        
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
        var gateOrigin = event?.location(in: self) ?? CGPoint(x: 100, y: 100)
        
        if let gate = gateUnderPoint(gateOrigin) {
            if gateID == .line {
                gate.inputPinVisible = 0
                gate.outputPinVisible = 0
                if creatingGate == nil {
                    // create a line starting from this gate
                    editingGate = gate
                    gate.highlighted = true
                    
                    // create the initial connection
                    let connection = LBConnection(kind: .line)
                    let sourcePin = gate.getClosestPinIndex(gateOrigin)
                    if gate.pins[sourcePin].type == .output { gate.outputPinVisible = 1 }
                    else { gate.inputPinVisible = CGFloat(max(1, sourcePin)) }  // max in case of single pins
                    print("Pin = \(sourcePin)")
                    connection.addGatePin(gate, index: sourcePin)
                    connection.highlighted = true
                    gates.append(connection)
                    creatingGate = connection
                } else {
                    // finish the connection to this destination gate
                    let destinationPin = gate.getClosestPinIndex(gateOrigin)
                    let connection = creatingGate as! LBConnection
                    connection.addGatePin(gate, index: destinationPin)
                    editingGate?.highlighted = false
                    editingGate?.inputPinVisible = 0
                    editingGate?.outputPinVisible = 0
                    creatingGate = nil
                    gate.highlighted = false
                }
            } else {
                toggleSelection(gate)
            }
        } else if gateID == .line && creatingGate != nil {
            // add a point to the line
            let connection = creatingGate as! LBConnection
            connection.addPoint(gateOrigin)
        } else {
            gateOrigin = grid.constrainedPoint(gateOrigin)
            let gate = LBGateType.classForGate(gateID)
            gate.defaultBounds()
            gate.bounds = CGRect(origin: gateOrigin, size: gate.bounds.size)
            gate.highlighted = true
            
            gates.append(gate)
            editingGate?.highlighted = false
            editingGate = gate
        }
        setNeedsDisplay()
    }
    
    private var initialDelta: CGPoint = CGPoint.zero

    var selected : [LBGate] { return gates.filter { $0.highlighted } }
    
    func moveSelected(_ gesture: UIGestureRecognizer) {
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
            clearSelected()
            setNeedsDisplay()
        }
    }
    
    func clearSelected() {
        for gate in selected {
            gate.highlighted = false
            gate.inputPinVisible = 0
            gate.outputPinVisible = 0
        }
        setNeedsDisplay()
    }
    
    func deleteGate (_ gate: LBGate) {
        if let index = gates.index(where: { $0 === gate }) {
            gates.remove(at: index)
            setNeedsDisplay()
        }
    }
    
    func cloneGate (_ gate: LBGate) {
        let newGate = LBGateType.classForGate(gate.kind)
        newGate.bounds = gate.bounds.offsetBy(dx: 10, dy: 10)
        print("Cloned gate : \(newGate)")
        gates.append(newGate)
        setNeedsDisplay()
    }
    
    func deleteSelected(_ sender: UIBarButtonItem) {
        for delete in selected {
            deleteGate(delete)
        }
    }
    
    func gateUnderPoint(_ point: CGPoint) -> LBGate? {
        for gate in gates {
            if gate.contains(point) {
                return gate
            }
        }
        return nil
    }

}
