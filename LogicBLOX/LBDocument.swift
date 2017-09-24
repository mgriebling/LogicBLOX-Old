//
//  LBDocument.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 6 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBDocument: UIDocument {
    
    // MARK: - Data storage
    
    var gates : [LBGate] = []
    
    // MARK: - Document loading override
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let data = contents as? Data {
            let unarchiver = NSKeyedUnarchiver(forReadingWith: data)
            if let gates = unarchiver.decodeObject(forKey: "LBGates") as? [LBGate] {
                self.gates = gates
            } else {
                self.gates = []
            }
        }
    }
    
    // MARK: - Document saving override
    
    override func contents(forType typeName: String) throws -> Any {
        let archiver = NSKeyedArchiver()
        archiver.encode(gates, forKey: "LBGates")
        archiver.finishEncoding()
        return archiver.encodedData
    }

}
