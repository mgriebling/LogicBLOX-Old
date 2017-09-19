//
//  LBConnection.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 4 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBConnection: LBGate {
    
    static let MatchSize : CGFloat = 10
    
    static let kInputs      = "Inputs"
    static let kOutputs     = "Outputs"
    static let kConnections = "Connections"
    
    // MARK: - Internal state
    
    /// Output pins from other gates
    var inputs = [LBPin]()
    
    // Input pins from other gates
    var outputs = [LBPin]()
    
    // wired connections relative to our origin
    var connections = [CGPoint]()
    
    override public var description: String {
        return "Connection"
    }
    
    // MARK: - Support
    
    var prevPoint : CGPoint {
        let pindex = max(0, connections.count-1)
        let pos = connections[pindex]
        return bounds.offsetBy(dx: pos.x, dy: pos.y).origin
    }
    
    // MARK: - Life cycle
    
    override init (withDefaultSize size: CGSize = CGSize.zero) {
        super.init()
    }
    
    required init? (coder decoder: NSCoder) {
        super.init(coder: decoder)
        inputs = decoder.decodeObject(forKey: LBConnection.kInputs) as! [LBPin]
        outputs = decoder.decodeObject(forKey: LBConnection.kOutputs) as! [LBPin]
        connections = decoder.decodeObject(forKey: LBConnection.kConnections) as! [CGPoint]
    }
    
    override func encode(with encoder: NSCoder) {
        super.encode(with: encoder)
        encoder.encode(inputs, forKey: LBConnection.kInputs)
        encoder.encode(outputs, forKey: LBConnection.kOutputs)
        encoder.encode(connections, forKey: LBConnection.kConnections)
    }
    
    deinit {
        // need to release all the pins since we don't own most of them
        inputs = []; outputs = []
    }
    
    // MARK: - Drawing
    
    override func draw(_ scale: CGFloat) {
        // draw a connection joining all the pins
        let path = bezierShape()
        path.lineWidth = 2.5
        if highlighted {
            Gates.highlightColour.setStroke()
        } else {
            Gates.baseColor.setStroke()
        }
        path.stroke()
    }
    
    func bezierShape() -> UIBezierPath {
        guard connections.count > 1 else { return UIBezierPath() }
        let path = UIBezierPath()
        let pin1 = connections[0]
        let org = bounds.origin
        path.move(to: CGPoint(x:org.x+pin1.x, y: org.y+pin1.y))
        for pin in connections.dropFirst() {
            path.addLine(to: CGPoint(x:org.x+pin.x, y: org.y+pin.y))
        }
        return path
    }
    
    // MARK: - Editing
    
    func addPin(_ pin: LBPin) {
        if pin.type == .input {
            // we drive gate inputs so they are outputs here
            outputs.append(pin)
        } else if pin.type == .output {
            // we take gate outputs as inputs here
            inputs.append(pin)
        } else {
            print("Erroneous pin entry!")
        }
    }
    
    /// logical connection is made to the source gate
    func addGatePin(_ source: LBGate, index: Int) {
        let pin = source.pins[index]
        addPin(pin)  // our connections to other gates
        if connections.count == 0 {
            bounds.origin = source.bounds.offsetBy(dx: pin.pos.x, dy: pin.pos.y).origin
            connections.append(CGPoint.zero)
        } else {
            let newPt = source.bounds.offsetBy(dx: pin.pos.x, dy: pin.pos.y).origin  // map point to view coordinates
            addPoint(newPt)
        }
    }
    
    /// drawing connection is added where position is in view coordinates
    func addPoint(_ point: CGPoint) {
        // convert to view coordinates relative to path start
        let offset = CGPoint(x: point.x-bounds.origin.x, y: point.y-bounds.origin.y) // get pt relative to path start
        
        // check along which axis the connection is extending
        let prev = prevPoint
        let dx = abs(offset.x)
        let dy = abs(offset.y)
        var x = prev.x-bounds.origin.x
        var y = prev.y-bounds.origin.y
        if dx > LBConnection.MatchSize && dy > LBConnection.MatchSize {
            // need to generate an intermediate point
            connections.append(CGPoint(x: offset.x, y: y))  // first move along x axis
            x = offset.x; y = offset.y                      // add current point
        } else if dx > LBConnection.MatchSize {
            // use the new x and previous y values
            x = offset.x
        } else {
            // use the new y and previous x values
            y = offset.y
        }
        connections.append(CGPoint(x: x, y: y))
    }
    
    /// Override since connection bounds are rather tricky
    override func contains(_ point: CGPoint) -> Bool {
        let buffer = LBConnection.MatchSize // distance from the line that is still considered a match
        var pta = bounds.offsetBy(dx: 0, dy: 0).origin   // first pt starts at origin
        for pt in connections.dropFirst() {
            let ptb = bounds.offsetBy(dx: pt.x, dy: pt.y).origin
            let topLeft = CGPoint(x: min(pta.x, ptb.x), y: min(pta.y, ptb.y))
            let bottomRight = CGPoint(x: max(pta.x, ptb.x), y: max(pta.y, ptb.y))
            let box = CGRect(x: topLeft.x-buffer, y: topLeft.y-buffer,
                             width: bottomRight.x-topLeft.x+2*buffer, height: bottomRight.y-topLeft.y+2*buffer)
            if box.contains(point) {
                return true
            }
            
            // move on to the next line segment
            pta = ptb
        }
        return false
    }
    
    // MARK: - Logic evaluation
    
    override func evaluate() -> LogicState {
        let state = LogicState.resolve(inputs.map { $0.state })  // combine all inputs -- more than one implies a bus
        for pin in outputs {                                     // drive all the outputs
            pin.state = state
        }
        print("Evaluating connection from \(inputs) to \(outputs) = \(state)")
        return state
    }
    
}

