//
//  LBConnection.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 4 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

struct Connection : PropertyListReadable {
    
    weak var gate: LBGate!  // connection to parent
    var index: Int!         // index in parent's pins
    
    init(gate: LBGate, index: Int) {
        self.gate = gate
        self.index = index
    }
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let index = values["index"] as? Int, let gate = values["gate"] as? LBGate {
            self.index = index
            self.gate = gate
        } else {
            return nil
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        let representation: [String:AnyObject] = [
            "index":index as AnyObject,
            "gate":gate as AnyObject
        ]
        return representation as NSDictionary
    }
}

class LBConnection: LBGate {
    
    static let MatchSize : CGFloat = 10
    
    var cpins : [Connection] = []   // logical connections to gates
    
    var prevPoint : CGPoint {
        if let connection = cpins.last, let gate = connection.gate {
            let pos = gate.pins[connection.index!].pos
            return gate.bounds.offsetBy(dx: pos.x, dy: pos.y).origin
        }
        return CGPoint.zero
    }
    
    override public var description: String {
        return "Connection"
    }
    
    override init (withDefaultSize size: CGSize = CGSize.zero) {
        super.init()
    }
    
    required init? (coder decoder: NSCoder) {
        let cpinEncoding = decoder.decodeObject(forKey: "cPins") as? [AnyObject]
        cpins = extractValuesFromPropertyListArray(cpinEncoding)
        super.init()
    }
    
    override func encode(with encoder: NSCoder) {
        let cpinEncoding = pins.map{$0.propertyListRepresentation()}
        encoder.encode(cpinEncoding, forKey: "cPins")
        super.encode(with: encoder)
    }
    
    override func localInit() {
        super.localInit()
        pins = []  // these are initialized later
    }
    
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
    
    /// logical connection is made to the source gate
    func addPin(_ source: LBGate, index: Int) {
        cpins.append(Connection(gate: source, index: index))
        let pt = source.pins[index].pos
        if pins.count == 0 {
            bounds.origin = source.bounds.offsetBy(dx: pt.x, dy: pt.y).origin
            pins.append(LBPin(x: 0, y: 0))
        } else {
            let newPt = source.bounds.offsetBy(dx: pt.x, dy: pt.y).origin  // map point to view coordinates
            addPoint(newPt)
        }
    }
    
    /// drawing connection is added where position is in view coordinates
    func addPin(_ position: CGPoint) {
        // add a connection to ourselves
        cpins.append(Connection(gate: self, index: pins.count))
        addPoint(position)
    }
    
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
            let newPt = CGPoint(x: offset.x, y: y)                  // first move along x axis
            pins.append(LBPin(x: newPt.x, y: newPt.y))
            cpins.append(Connection(gate: self, index: pins.count)) // add another logical point
            x = offset.x; y = offset.y                              // add current point
        } else if dx > LBConnection.MatchSize {
            // use the new x and previous y values
            x = offset.x
        } else {
            // use the new y and previous x values
            y = offset.y
        }
        pins.append(LBPin(x: x, y: y))
    }
    
    var input : Connection! {
        // find the input connection and return it
        for connection in cpins {
            if let gate = connection.gate, let index = connection.index {
                let pin = gate.pins[index]
                if pin.type == .output && !(gate is LBConnection) {
                    return connection
                }
            }
        }
        return nil
    }
    
    var output : Connection! {
        // find the input connection and return it
        for connection in cpins {
            if let gate = connection.gate, let index = connection.index {
                let pin = gate.pins[index]
                if pin.type == .input && !(gate is LBConnection) {
                    return connection
                }
            }
        }
        return nil
    }
    
    override func evaluate() -> LogicState {
        if let output = self.output, let input = self.input {
            let state = input.gate.pins[input.index].state
            output.gate.pins[output.index].state = state
            print("Evaluating connection from \(input.gate) to \(output.gate) = \(state)")
            return state
        }
        return .U
    }
    
    func bezierShape() -> UIBezierPath {
        guard pins.count > 1 else { return UIBezierPath() }
        let path = UIBezierPath()
        let pin1 = pins[0]
        let org = bounds.origin
        path.move(to: CGPoint(x:org.x+pin1.pos.x, y: org.y+pin1.pos.y))
        for pin in pins.dropFirst() {
            path.addLine(to: CGPoint(x:org.x+pin.pos.x, y: org.y+pin.pos.y))
        }
        return path
    }
    
}

