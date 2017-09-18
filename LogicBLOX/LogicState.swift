//
//  LogicState.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 16 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import Foundation

/// Based on IEEE 1164.
enum LogicState: Int {
    
    case U, // Uninitialized state used as a default value
         X, // Forcing unknown for bus contentions, error conditions, etc.
         𝟶, // Forcing zero or driven to GND
         𝟷, // Forcing one or driven to VCC
         Z, // High impedance for 3-state buffer outputs
         W, // Weak unknown for bus terminators
         L, // Weak zero for pull-down resistors
         H, // Weak one for pull-up resistors
         一 // Don't care used for synthesis and advanced modelling
    
    var isOne : Bool { return self == LogicState.𝟷 }
    
    // convenient shortcuts for common symbols
    static let zero = LogicState.𝟶
    static let one  = LogicState.𝟷
    static let dontCare = LogicState.一
    
    // Truth table for "not" function
    static let Not : [LogicState] =
      //---------------------------------
      //  U  X  0  𝟷  Z  W  L  H 一      Input
      //---------------------------------
        [ U, X, 𝟷, 𝟶, X, X, 𝟷, 𝟶, X ] // Output
    //
    static prefix func ! (arg: LogicState) -> LogicState {
        return LogicState.Not[arg.rawValue]
    }
    
    // Truth table for "xor" function
    static let Xor : [[LogicState]] = [
      //--------------------------------- Input
      //  U  X  0  1  Z  W  L  H 一        A/B
      //---------------------------------
        [ U, U, U, U, U, U, U, U, U ], // | U |
        [ U, X, X, X, X, X, X, X, X ], // | X |
        [ U, X, 𝟶, 𝟷, X, X, 𝟶, 𝟷, X ], // | 0 |
        [ U, X, 𝟷, 𝟶, X, X, 𝟷, 𝟶, X ], // | 1 |
        [ U, X, X, X, X, X, X, X, X ], // | Z |
        [ U, X, X, X, X, X, X, X, X ], // | W |
        [ U, X, 𝟶, 𝟷, X, X, 𝟶, 𝟷, X ], // | L |
        [ U, X, 𝟷, 𝟶, X, X, 𝟷, 𝟶, X ], // | H |
        [ U, X, X, X, X, X, X, X, X ]  // | - |
    ]
    static func ^ (lhs: LogicState, rhs: LogicState) -> LogicState {
        return LogicState.Xor[lhs.rawValue][rhs.rawValue]
    }
    
    // Truth table for "or" function
    static let Or : [[LogicState]] = [
      //--------------------------------- Input
      //  U  X  0  1  Z  W  L  H 一        A/B
      //---------------------------------
        [ U, U, U, 𝟷, U, U, U, 𝟷, U ], // | U |
        [ U, X, X, 𝟷, X, X, X, 𝟷, X ], // | X |
        [ U, X, 𝟶, 𝟷, X, X, 𝟶, 𝟷, X ], // | 0 |
        [ 𝟷, 𝟷, 𝟷, 𝟷, 𝟷, 𝟷, 𝟷, 𝟷, 𝟷 ], // | 1 |
        [ U, X, X, 𝟷, X, X, X, 𝟷, X ], // | Z |
        [ U, X, X, 𝟷, X, X, X, 𝟷, X ], // | W |
        [ U, X, 𝟶, 𝟷, X, X, 𝟶, 𝟷, X ], // | L |
        [ 𝟷, 𝟷, 𝟷, 𝟷, 𝟷, 𝟷, 𝟷, 𝟷, 𝟷 ], // | H |
        [ U, X, X, 𝟷, X, X, X, 𝟷, X ]  // | - |
    ]
    static func | (lhs: LogicState, rhs: LogicState) -> LogicState {
        return LogicState.Or[lhs.rawValue][rhs.rawValue]
    }
    
    // Truth table for "and" function
    static let And : [[LogicState]] = [
      //--------------------------------- Input
      //  U  X  0  1  Z  W  L  H 一        A/B
      //---------------------------------
        [ U, U, 𝟶, U, U, U, 𝟶, U, U ], // | U |
        [ U, X, 𝟶, X, X, X, 𝟶, X, X ], // | X |
        [ 𝟶, 𝟶, 𝟶, 𝟶, 𝟶, 𝟶, 𝟶, 𝟶, 𝟶 ], // | 0 |
        [ U, X, 𝟶, 𝟷, X, X, 𝟶, 𝟷, X ], // | 1 |
        [ U, X, 𝟶, X, X, X, 𝟶, X, X ], // | Z |
        [ U, X, 𝟶, X, X, X, 𝟶, X, X ], // | W |
        [ 𝟶, 𝟶, 𝟶, 𝟶, 𝟶, 𝟶, 𝟶, 𝟶, 𝟶 ], // | L |
        [ U, X, 𝟶, 𝟷, X, X, 𝟶, 𝟷, X ], // | H |
        [ U, X, 𝟶, X, X, X, 𝟶, X, X ]  // | - |
    ]
    static func & (lhs: LogicState, rhs: LogicState) -> LogicState {
        return LogicState.And[lhs.rawValue][rhs.rawValue]
    }
    
    static let Resolution : [[LogicState]] = [
      //--------------------------------- Input
      //  U  X  0  1  Z  W  L  H 一        A/B
      //---------------------------------
        [ U, U, U, U, U, U, U, U, U ], // | U |
        [ U, X, X, X, X, X, X, X, X ], // | X |
        [ U, X, 𝟶, X, 𝟶, 𝟶, 𝟶, 𝟶, X ], // | 0 |
        [ U, X, X, 𝟷, 𝟷, 𝟷, 𝟷, 𝟷, X ], // | 1 |
        [ U, X, 𝟶, 𝟷, Z, W, L, H, X ], // | Z |
        [ U, X, 𝟶, 𝟷, W, W, W, W, X ], // | W |
        [ U, X, 𝟶, 𝟷, L, W, L, W, X ], // | L |
        [ U, X, 𝟶, 𝟷, H, W, W, H, X ], // | H |
        [ U, X, X, X, X, X, X, X, X ]  // | - |
    ]
    // resolves tristate and open-collector bus states where
    // multiple outputs are connected together
    static func resolve (_ value: [LogicState]) -> LogicState {
        if value.count == 1 { return value.first! }
        var result = LogicState.Z
        for x in value {
            result =  LogicState.Resolution[result.rawValue][x.rawValue]
        }
        return result
    }
}

/// Bus-based logic evaluation functions

func ^ (lhs: [LogicState], rhs: [LogicState]) -> [LogicState] {
    assert(lhs.count == rhs.count, "Logic busses must be the same size!")
    var result = lhs
    for (index, lvalue) in lhs.enumerated() {
        let rvalue = rhs[index]
        result[index] = lvalue ^ rvalue
    }
    return result
}

func & (lhs: [LogicState], rhs: [LogicState]) -> [LogicState] {
    assert(lhs.count == rhs.count, "Logic busses must be the same size!")
    var result = lhs
    for (index, lvalue) in lhs.enumerated() {
        let rvalue = rhs[index]
        result[index] = lvalue & rvalue
    }
    return result
}

func | (lhs: [LogicState], rhs: [LogicState]) -> [LogicState] {
    assert(lhs.count == rhs.count, "Logic busses must be the same size!")
    var result = lhs
    for (index, lvalue) in lhs.enumerated() {
        let rvalue = rhs[index]
        result[index] = lvalue | rvalue
    }
    return result
}

prefix func ! (lhs: [LogicState]) -> [LogicState] {
    var result = lhs
    for (index, lvalue) in lhs.enumerated() {
        result[index] = !lvalue
    }
    return result
}
