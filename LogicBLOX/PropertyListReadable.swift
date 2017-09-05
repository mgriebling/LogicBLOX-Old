//
//  PropertyListReadable.swift
//  LogicBLOX
//
//  Created by Michael Griebling on 26Jan2016.
//  Copyright © 2016 Solinst Canada. All rights reserved.
//

import Foundation

protocol PropertyListReadable {
    
    // This protocol allows structs to be reencoded as a dictionary for saving via NSCoding
    // \e propertyListRepresentation must encode your struct as a dictionary and
    // \e init reverses this process.  A helper function \e extractValuesFromPropertyListArray
    // helps to create an array of structs from an array of objects.  Finally, you can use
    // a map method of your array like \e yourArray.map{$0.propertyListRepresentation()} to
    // create an object of your array of structs for saving.
    //
    // For example:
    //
    //    struct Coordinate {
    //        let x:Double
    //        let y:Double
    //        let z:Double
    //
    //        init(_ x: Double, _ y: Double, _ z: Double) {
    //            self.x = x
    //            self.y = y
    //            self.z = z
    //        }
    //    }
    //    extension Coordinate: PropertyListReadable {
    //        func propertyListRepresentation() -> NSDictionary {
    //            let representation:[String:AnyObject] = ["x":self.x, "y":self.y, "z":self.z]
    //            return representation
    //        }
    //
    //        init?(propertyListRepresentation:NSDictionary?) {
    //            guard let values = propertyListRepresentation else {return nil}
    //            if let xCoordinate = values["x"] as? Double,
    //                yCoordinate = values["y"] as? Double,
    //                zCoordinate = values["z"] as? Double {
    //                    self.x = xCoordinate
    //                    self.y = yCoordinate
    //                    self.z = zCoordinate
    //            } else {
    //                return nil
    //            }
    //        }
    //    }
    
    func propertyListRepresentation() -> NSDictionary
    init?(propertyListRepresentation: NSDictionary?)
    
}

func extractValuesFromPropertyListArray<T:PropertyListReadable>(_ propertyListArray:[AnyObject]?) -> [T] {
    guard let encodedArray = propertyListArray else { return [] }
    return encodedArray.map{ $0 as? NSDictionary }.flatMap{ T(propertyListRepresentation:$0) }
}
