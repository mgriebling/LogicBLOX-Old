//
//  LBDocument.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 6 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

public class LBDocument: UIDocument {
    
    // MARK: - Data storage
    
    var gates : [LBGate] = []
    
    // MARK: - Document loading override
    
    public override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let data = contents as? Data {
            let unarchiver = PropertyListDecoder()
            if let gates = try? unarchiver.decode([LBGate].self, from: data) {
                self.gates = gates
            } else {
                self.gates = []
            }
        }
    }
    
    // MARK: - Document saving override
    
    public override func contents(forType typeName: String) throws -> Any {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(gates)
            return data
        } catch let error {
            print(error)
            return Data()
        }
    }

}
