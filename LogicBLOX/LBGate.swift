//
//  LBGate.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 16 Jan 2016.
//  Copyright © 2016 Solinst Canada. All rights reserved.
//

import UIKit

enum PinType: Int, Codable {
    case input, output, bidirectional, tristate, openCollector
}

enum Orientation: Int, Codable {
    case top, bottom, left, right
}

// MARK: -
// MARK: - LBGateType

public enum LBGateType : Int, Codable {
    case line = 0, button, indicator,
    or, or3, or4,
    nor, nor3, nor4,
    and, and3, and4,
    nand, nand3, nand4,
    xor, xor3, xor4,
    xnor, xnor3, xnor4,
    buffer,
    inverter,
    block,
    
    MAX // last item indicator
    
    static func classForGate(_ gate: LBGateType) -> LBGate {
        switch gate {
        case .or:       return LBOr(kind: gate)
        case .or3:      return LBOr3(kind: gate)
        case .or4:      return LBOr4(kind: gate)
        case .nor:      return LBNor(kind: gate)
        case .nor3:     return LBNor3(kind: gate)
        case .nor4:     return LBNor4(kind: gate)
        case .xor:      return LBXor(kind: gate)
        case .xor3:     return LBXor3(kind: gate)
        case .xor4:     return LBXor4(kind: gate)
        case .xnor:     return LBXnor(kind: gate)
        case .xnor3:    return LBXnor3(kind: gate)
        case .xnor4:    return LBXnor4(kind: gate)
        case .and:      return LBAnd(kind: gate)
        case .and3:     return LBAnd3(kind: gate)
        case .and4:     return LBAnd4(kind: gate)
        case .nand:     return LBNand(kind: gate)
        case .nand3:    return LBNand3(kind: gate)
        case .nand4:    return LBNand4(kind: gate)
        case .inverter: return LBInverter(kind: gate)
        case .buffer:   return LBBuffer(kind: gate)
        case .block:    return LBBlock(kind: gate)
        case .line:     return LBConnection(kind: gate)
        case .indicator: return LBIndicator(kind: gate)
        case .button:   return LBButton(kind: gate)
        default: break
        }
        return LBNand(kind: gate)
    }
}

// MARK: -
// MARK: - LBPin

public class LBPin : NSObject, NSCoding {
    
    static let kVersionKey  = "Version"
    static let kType        = "Type"
    static let kFacing      = "Facing"
    static let kPosition    = "Position"
    static let kHighlighted = "Highlighted"
    
    static let size: CGFloat = 6      // pin size to use as an offset
    
    var pos: CGPoint = CGPoint.zero
    var type: PinType = .input
    var facing: Orientation = .left
    var state: LogicState = .U
    var highlighted: Bool = false
    
    public init(x: CGFloat, y:CGFloat) {
        pos.x = x
        pos.y = y
    }
    
    public required init? (coder decoder: NSCoder) {
        let _ = decoder.decodeCInt(forKey: LBPin.kVersionKey)
        pos = decoder.decodeCGPoint(forKey: LBPin.kPosition)
        type = PinType(rawValue: decoder.decodeInteger(forKey: LBPin.kType)) ?? .input
        facing = Orientation(rawValue: decoder.decodeInteger(forKey: LBPin.kFacing)) ?? .left
        highlighted = decoder.decodeBool(forKey: LBPin.kHighlighted)
        super.init()
    }
    
    public func encode(with encoder: NSCoder) {
        encoder.encodeCInt(1, forKey: LBPin.kVersionKey)
        encoder.encode(pos, forKey: LBPin.kPosition)
        encoder.encode(type.rawValue, forKey: LBPin.kType)
        encoder.encode(facing.rawValue, forKey: LBPin.kFacing)
        encoder.encode(highlighted, forKey: LBGate.kHighlighted)
    }
    
}

// MARK: -
// MARK: - CGPoint

extension CGPoint {
    
    func distanceTo(_ point: CGPoint) -> CGFloat {
        return pow(x - point.x, 2) + pow(y - point.y, 2)
    }
    
}

// MARK: -
// MARK: - LBGateType
/// The mother of all gates: basic gate object with default properties & methods.

class LBGate : NSObject, NSCoding {
    
    static let kVersionKey  = "Version"
    static let kNativeRect  = "NativeRect"
    static let kPosition    = "Position"
    static let kRect        = "Rect"
    static let kHighlighted = "Highlighted"
    static let kPins        = "Pins"
    static let kKind        = "Kind"
    
    var pins: [LBPin] = []
    var bounds: CGRect
    var kind: LBGateType
    
    var highlighted = false
    var outputPinVisible : CGFloat = 0
    var inputPinVisible : CGFloat = 0
    
    var joinedInputs : CGFloat = 0
    var joinedOutputs : CGFloat = 0
    
    var nativeBounds: CGRect
    
    override public var description: String { return "Gate" }
    
    // MARK: - Life cycle
    
    init (kind: LBGateType, withDefaultSize size: CGSize = CGSize.zero) {
        nativeBounds = CGRect(origin: CGPoint.zero, size: size)
        bounds = nativeBounds
        self.kind = kind
        super.init()
        localInit()
    }
    
    required init? (coder decoder: NSCoder) {
        let _ = decoder.decodeCInt(forKey: LBGate.kVersionKey)
        kind = LBGateType(rawValue: decoder.decodeInteger(forKey: LBGate.kKind)) ?? .nand
        nativeBounds = decoder.decodeCGRect(forKey: LBGate.kNativeRect)
        bounds = decoder.decodeCGRect(forKey: LBGate.kRect)
        highlighted = decoder.decodeBool(forKey: LBGate.kHighlighted)
        pins = decoder.decodeObject(forKey: LBGate.kPins) as! [LBPin]
        super.init()
    }
    
    func encode(with encoder: NSCoder) {
        encoder.encodeCInt(1, forKey: LBGate.kVersionKey)
        encoder.encode(kind.rawValue, forKey: LBGate.kKind)
        encoder.encode(nativeBounds, forKey: LBGate.kNativeRect)
        encoder.encode(bounds, forKey: LBGate.kRect)
        encoder.encode(highlighted, forKey: LBGate.kHighlighted)
        encoder.encode(pins, forKey: LBGate.kPins)
    }
    
    // MARK: - Object Methods

    func localInit() {
        // override to set up pins and nativeBounds
    }

    func contains (_ point: CGPoint) -> Bool {
        return bounds.contains(point)
    }

    final func getClosestPinIndex (_ point: CGPoint) -> Int {
//        if !isInBounds(point) { return nil }
        var distance = CGFloat.infinity
        var fpin = 0
        for (index, pin) in pins.enumerated() {
            let pinPoint = CGPoint(x: pin.pos.x+bounds.origin.x, y: pin.pos.y+bounds.origin.y)
            let range = pinPoint.distanceTo(point)
            if range < distance {
                distance = range
                fpin = index
            }
        }
        return fpin
    }

    final func defaultBounds () {
        bounds = nativeBounds
    }

    func draw (_ scale: CGFloat) {
        // override to do the drawing
    }

    func evaluate () -> LogicState {
        return .U
    }

    final func getImageOfObject (_ rect: CGRect, scale: CGFloat) -> UIImage {
        if rect == CGRect.zero { return UIImage() }
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        draw(scale)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

}

extension LBGate  {
    
    // MARK: - Aggregrate convenience methods
    
    static func translateGates(_ gates: [LBGate], byX deltaX: CGFloat, y deltaY: CGFloat) {
        for gate in gates {
            gate.bounds = gate.bounds.offsetBy(dx: deltaX, dy: deltaY)
        }
    }
    
    static func boundsOfGates(_ gates: [LBGate]) -> CGRect {
        if var bounds = gates.first?.bounds {
            for gate in gates.dropFirst() {
                bounds = bounds.union(gate.bounds)
            }
            return bounds
        }
        return CGRect.zero
    }

}

// MARK: -
// MARK: - Nand Gates

// Note: For some reason PropertyListEncoder() can't encode these gates when they are in a separate file ???
//       Smells like a bug.

class LBNand : LBGate {

    fileprivate var inputs : Int { return 2 }
    fileprivate var invert : Bool { return true }
    fileprivate let yoff : CGFloat = 10
    fileprivate let xoff : CGFloat = 4

    override public var description: String {
        let gate = invert ? "Nand" : "And"
        return "\(inputs)-Input " + gate
    }

    override func localInit() {
        super.localInit()
        nativeBounds = CGRect(x: 0, y: 0, width: 134, height: 68)

        let pin1 = LBPin(x: xoff, y: 9+yoff)
        let pin2 = LBPin(x: xoff, y: 39+yoff)
        let pin3 = LBPin(x: nativeBounds.width-xoff, y: 25+yoff-1); pin3.type = .output
        pins = [pin3, pin1, pin2]
    }

    override func draw(_ scale: CGFloat) {
        Gates.drawAndNandGate(frame: bounds, highlight: highlighted, inputs: CGFloat(inputs), joinedPin: joinedInputs, joinedOutputPin: joinedOutputs, inputPinVisible: inputPinVisible, outputPinVisible: outputPinVisible, invert: invert)
    }

    override func evaluate() -> LogicState {
        if pins.count < inputs+1 { return .U }
        let inputStates = pins.dropFirst().map { $0.state }
        var state = inputStates[0]
        for input in inputStates.dropFirst() {
            state = state & input            // And function
        }
        state = invert ? !state : state      // Nand if inverted
        pins[0].state = state
        return state
    }

}

class LBNand3 : LBNand {
    
    override fileprivate var inputs : Int { return 3 }

    override func localInit() {
        super.localInit()

        // replace last two pins with 3-input pins
        let pin1 = LBPin(x: xoff, y: 4+yoff)
        let pin2 = LBPin(x: xoff, y: 23+yoff)
        let pin3 = LBPin(x: xoff, y: 43+yoff)
        pins = pins.dropLast(2) + [pin1, pin2, pin3]
    }

}

class LBNand4 : LBNand {

    override fileprivate var inputs : Int { return 4 }

    override func localInit() {
        super.localInit()

        // replace last two pins with 3-input pins
        let pin1 = LBPin(x: xoff, y: 4+yoff)
        let pin2 = LBPin(x: xoff, y: 17+yoff)
        let pin3 = LBPin(x: xoff, y: 30+yoff)
        let pin4 = LBPin(x: xoff, y: 43+yoff)
        pins = pins.dropLast(2) + [pin1, pin2, pin3, pin4]
    }

}

// MARK: -
// MARK: - And Gates

class LBAnd: LBNand {

    override var invert: Bool { return false }

}

class LBAnd3 : LBNand3 {

    override var invert: Bool { return false }

}

class LBAnd4 : LBNand4 {

    override var invert: Bool { return false }

}


