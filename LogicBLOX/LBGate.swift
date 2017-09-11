//
//  LBGate.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 16 Jan 2016.
//  Copyright © 2016 Solinst Canada. All rights reserved.
//

import UIKit

enum LogicState: Int {
    case zero, one, pullUp, pullDown, highZ, undefined
}

enum PinType: Int {
    case input, output, bidirectional, tristate, openCollector
}

enum Orientation: Int {
    case top, bottom, left, right
}

struct LBPin {
    
    static let size: CGFloat = 6      // pin size to use as an offset
    var pos: CGPoint = CGPoint.zero
    var type: PinType = .input
    var facing: Orientation = .left
    var state: LogicState = .undefined
    var highlighted: Bool = false
    
    init(x: CGFloat, y:CGFloat) {
        pos.x = x
        pos.y = y
    }
    
    func draw(_ scale: CGFloat, pos: CGPoint) {
//        let path = UIBezierPath()
//        let ssize = scale * LBPin.size
//        path.move(to: CGPoint(x: pos.x-ssize, y: pos.y-ssize))
//        path.addLine(to: CGPoint(x: pos.x+ssize, y: pos.y-ssize))
//        path.addLine(to: CGPoint(x: pos.x+ssize, y: pos.y+ssize))
//        path.addLine(to: CGPoint(x: pos.x-ssize, y: pos.y+ssize))
//        path.addLine(to: CGPoint(x: pos.x-ssize, y: pos.y-ssize))
//        path.stroke()
    }
}

extension LBPin: PropertyListReadable {
    
    init?(propertyListRepresentation: NSDictionary?) {
        guard let values = propertyListRepresentation else { return nil }
        if let posx = values["posx"] as? CGFloat,
           let posy = values["posy"] as? CGFloat,
           let rawtype = values["type"] as? Int,
           let rawfacing = values["facing"] as? Int,
           let rawstate = values["state"] as? Int {
            pos.x = posx; pos.y = posy
            type = PinType(rawValue: rawtype) ?? .input
            facing = Orientation(rawValue: rawfacing) ?? .left
            state = LogicState(rawValue: rawstate) ?? .undefined
        } else {
            return nil
        }
    }
    
    func propertyListRepresentation() -> NSDictionary {
        let representation: [String:AnyObject] = [
            "posx":pos.x as AnyObject,
            "posy":pos.y as AnyObject,
            "type":type.rawValue as AnyObject,
            "facing":facing.rawValue as AnyObject,
            "state": state.rawValue as AnyObject
        ]
        return representation as NSDictionary
    }
}

extension CGPoint {
    
    func distanceTo(_ point: CGPoint) -> CGFloat {
        return pow(x - point.x, 2) + pow(y - point.y, 2)
    }
    
}

/// The mother of all gates: basic gate object with default properties & methods.

class LBGate : NSObject, NSCoding {
    
    static let kVersionKey  = "Version"
    static let kNativeRect  = "NativeRect"
    let kPosition    = "Position"
    let kRect        = "Rect"
    let kHighlighted = "Highlighted"
    let kPins        = "Pins"
    
    var pins: [LBPin] = []
    var bounds: CGRect
    
    var highlighted: Bool = false
    var pinsVisible: Bool = false
    
    var nativeBounds: CGRect
    
    // MARK: - Life cycle
    
    init (withDefaultSize size: CGSize) {
        nativeBounds = CGRect(origin: CGPoint.zero, size: size)
        bounds = nativeBounds
        super.init()
        localInit()
    }
    
    required init? (coder decoder: NSCoder) {
        let _ = decoder.decodeCInt(forKey: LBGate.kVersionKey)
        let nBounds = decoder.decodeCGRect(forKey: LBGate.kNativeRect)
        nativeBounds = nBounds
        bounds = decoder.decodeCGRect(forKey: kRect)
        highlighted = decoder.decodeBool(forKey: kHighlighted)
        let pinEncoding = decoder.decodeObject(forKey: kPins) as? [AnyObject]
        pins = extractValuesFromPropertyListArray(pinEncoding)
        super.init()
    }
    
    func encode(with encoder: NSCoder) {
        encoder.encodeCInt(1, forKey: LBGate.kVersionKey)
        encoder.encode(nativeBounds, forKey: LBGate.kNativeRect)
        encoder.encode(bounds, forKey: kRect)
        encoder.encode(highlighted, forKey: kHighlighted)
        let pinEncoding = pins.map{$0.propertyListRepresentation()}
        encoder.encode(pinEncoding, forKey: kPins)
    }
    
    // MARK: - Object Methods
    
    func localInit() {
        // override to set up pins and nativeBounds
    }
    
    final func isInBounds (_ point: CGPoint) -> Bool {
        return bounds.contains(point)
    }
    
    final func getClosestPinIndex (_ point: CGPoint) -> Int? {
        if !isInBounds(point) { return nil }
        var distance = CGFloat.infinity
        var index : Int?
        for (pos, pin) in pins.enumerated() {
            let pinPoint = CGPoint(x: pin.pos.x+bounds.origin.x, y: pin.pos.y+bounds.origin.y)
            let range = pinPoint.distanceTo(point)
            if range < distance {
                distance = range
                index = pos
            }
        }
        return index
    }
    
    final func defaultBounds () {
        bounds = nativeBounds
    }
    
    func draw (_ scale: CGFloat) {
//        if highlighted {
//            LBGate.highlightColour.setStroke()
//        } else {
//            UIColor.black.setStroke()
//        }
    }
    
//    final func drawPins (_ scale: CGFloat) {
//        if !highlighted { return }
//        pinsVisible = true
//    }
    
    func evaluate () -> LogicState {
        return .undefined
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
