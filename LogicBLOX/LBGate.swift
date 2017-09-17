//
//  LBGate.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 16 Jan 2016.
//  Copyright © 2016 Solinst Canada. All rights reserved.
//

import UIKit

enum PinType: Int {
    case input, output, bidirectional, tristate, openCollector
}

enum Orientation: Int {
    case top, bottom, left, right
}

class LBPin : NSObject, NSCoding {
    
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
    
    init(x: CGFloat, y:CGFloat) {
        pos.x = x
        pos.y = y
    }
    
    required init? (coder decoder: NSCoder) {
        let _ = decoder.decodeCInt(forKey: LBPin.kVersionKey)
        pos = decoder.decodeCGPoint(forKey: LBPin.kPosition)
        type = PinType(rawValue: decoder.decodeInteger(forKey: LBPin.kType)) ?? .input
        facing = Orientation(rawValue: decoder.decodeInteger(forKey: LBPin.kFacing)) ?? .left
        highlighted = decoder.decodeBool(forKey: LBPin.kHighlighted)
        super.init()
    }
    
    func encode(with encoder: NSCoder) {
        encoder.encodeCInt(1, forKey: LBPin.kVersionKey)
        encoder.encode(pos, forKey: LBPin.kPosition)
        encoder.encode(type.rawValue, forKey: LBPin.kType)
        encoder.encode(facing.rawValue, forKey: LBPin.kFacing)
        encoder.encode(highlighted, forKey: LBGate.kHighlighted)
    }
    
}

//extension LBPin: PropertyListReadable {
//    
//    init?(propertyListRepresentation: NSDictionary?) {
//        guard let values = propertyListRepresentation else { return nil }
//        if let posx = values["posx"] as? CGFloat,
//           let posy = values["posy"] as? CGFloat,
//           let rawtype = values["type"] as? Int,
//           let rawfacing = values["facing"] as? Int,
//           let rawstate = values["state"] as? Int {
//            pos.x = posx; pos.y = posy
//            type = PinType(rawValue: rawtype) ?? .input
//            facing = Orientation(rawValue: rawfacing) ?? .left
//            state = LogicState(rawValue: rawstate) ?? .U
//        } else {
//            return nil
//        }
//    }
//    
//    func propertyListRepresentation() -> NSDictionary {
//        let representation: [String:AnyObject] = [
//            "posx":pos.x as AnyObject,
//            "posy":pos.y as AnyObject,
//            "type":type.rawValue as AnyObject,
//            "facing":facing.rawValue as AnyObject,
//            "state": state.rawValue as AnyObject
//        ]
//        return representation as NSDictionary
//    }
//}

extension CGPoint {
    
    func distanceTo(_ point: CGPoint) -> CGFloat {
        return pow(x - point.x, 2) + pow(y - point.y, 2)
    }
    
}

/// The mother of all gates: basic gate object with default properties & methods.

class LBGate : NSObject, NSCoding {
    
    static let kVersionKey  = "Version"
    static let kNativeRect  = "NativeRect"
    static let kPosition    = "Position"
    static let kRect        = "Rect"
    static let kHighlighted = "Highlighted"
    static let kPins        = "Pins"
    
    var pins: [LBPin] = []
    var bounds: CGRect
    
    var highlighted = false
    var outputPinVisible = 0
    var inputPinVisible = 0
    
    var nativeBounds: CGRect
    
    override public var description: String { return "Gate" }
    
    // MARK: - Life cycle
    
    init (withDefaultSize size: CGSize = CGSize.zero) {
        nativeBounds = CGRect(origin: CGPoint.zero, size: size)
        bounds = nativeBounds
        super.init()
        localInit()
    }
    
    required init? (coder decoder: NSCoder) {
        let _ = decoder.decodeCInt(forKey: LBGate.kVersionKey)
        nativeBounds = decoder.decodeCGRect(forKey: LBGate.kNativeRect)
        bounds = decoder.decodeCGRect(forKey: LBGate.kRect)
        highlighted = decoder.decodeBool(forKey: LBGate.kHighlighted)
        pins = decoder.decodeObject(forKey: LBGate.kPins) as! [LBPin]
        super.init()
    }
    
    func encode(with encoder: NSCoder) {
        encoder.encodeCInt(1, forKey: LBGate.kVersionKey)
        encoder.encode(nativeBounds, forKey: LBGate.kNativeRect)
        encoder.encode(bounds, forKey: LBGate.kRect)
        encoder.encode(highlighted, forKey: LBGate.kHighlighted)
        encoder.encode(pins, forKey: LBGate.kPins)
    }
    
    // MARK: - Object Methods
    
    func localInit() {
        // override to set up pins and nativeBounds
    }
    
    func isInBounds (_ point: CGPoint) -> Bool {
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
        _ = evaluate()  // evaluate states before drawing
    }
    
    func evaluate () -> LogicState {
        return .U
    }
    
    func getImageOfObject (_ rect: CGRect, scale: CGFloat) -> UIImage {
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
