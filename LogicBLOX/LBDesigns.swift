//
//  LBDesigns.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 7 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import Foundation

struct Designs {
    
    static let LBEXTENSION = "BLOX"
    
    static var list : [URL] {
        if let urls = try? FileManager.default.contentsOfDirectory(at: localRoot!, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
            return urls
        }
        return [getDocURL(getDocFilename("unnamed", unique: true))]
    }
    
    static var localRoot : URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first
    }
    
    static func getDocURL(_ filename: String) -> URL {
        return localRoot!.appendingPathComponent(filename, isDirectory: false)
    }
    
    static func docNameExistsInObjects(_ docName: String) -> Bool {
        let fileManager = FileManager.default
        let docName = getDocURL(docName).absoluteString
        return fileManager.fileExists(atPath: docName)
    }
    
    static func getDocFilename (_ prefix: String, unique: Bool) -> String {
        var docCount : Int = 0
        var newDocName = ""
        
        var done = false
        var first = true
        while !done {
            if first {
                first = false
                newDocName = prefix + "." + LBEXTENSION
            } else {
                newDocName = prefix + " \(docCount)." + LBEXTENSION
            }
            
            // look for an existing document with the same name
            var nameExists = false
            if unique {
                nameExists = docNameExistsInObjects(newDocName)
            }
            if !nameExists {
                done = true
            } else {
                docCount += 1
            }
        }
        return newDocName
    }
    
}
