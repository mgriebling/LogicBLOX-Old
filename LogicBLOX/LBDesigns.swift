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
    static let DEFPREFIX = "unnamed"
    
    static var list : [URL] = {
        if let urls = try? FileManager.default.contentsOfDirectory(at: localRoot!, includingPropertiesForKeys: nil, options: .skipsHiddenFiles) {
            return urls
        }
        return [getDocURL(getDocFilename(DEFPREFIX, unique: true))]
    }()
    
    static var localRoot : URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first
    }
    
    static func getDocURL(_ filename: String) -> URL {
        return localRoot!.appendingPathComponent(filename, isDirectory: false)
    }
    
    static func docNameExistsInObjects(_ docName: String) -> Bool {
        let url = getDocURL(docName)
        let found = list.contains(url)
        return found
    }
    
    static func prefixExistsInObjects(_ prefix: String) -> Bool {
        let docName = getDocFilename(prefix, unique: false)
        return docNameExistsInObjects(docName)
    }
    
    static func addNewDesign(_ prefix: String = DEFPREFIX) -> LBDocument {
        // create a new document
        let fileURL = getDocURL(getDocFilename(prefix, unique: true))
        
        let doc = LBDocument(fileURL: fileURL)
        doc.save(to: fileURL, for: .forCreating) { (success) in
            if !success {
                NSLog("Failed to create a file at %@", [fileURL])
                return
            }
        }
        list.insert(fileURL, at: 0)
        return doc
    }
    
    static func renameDesign(_ existingPrefix: String, to newPrefix: String) {
        let fileURL = getDocURL(getDocFilename(existingPrefix, unique: false))
        let newURL = getDocURL(getDocFilename(newPrefix, unique: false))
        if list.contains(fileURL) && !list.contains(newURL) {
            do {
                // rename the external file
                try FileManager.default.moveItem(at: fileURL, to: newURL)
                
                // do the same for our internal link
                let index = list.index(of: fileURL)!
                list[index] = newURL
            } catch let error as NSError {
                print(error)
            }
        }
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
