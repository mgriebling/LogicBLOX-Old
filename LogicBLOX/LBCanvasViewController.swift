//
//  CanvasViewController.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 2 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBCanvasViewController: UIViewController {
    
    @IBOutlet weak var imageButton: UIButton!
    @IBOutlet var imageBarButton: UIBarButtonItem!
    @IBOutlet var doneBarButton: UIBarButtonItem!
    @IBOutlet var editBarButton: UIBarButtonItem!
    
    var lastGateType : LBGateType = .nand
    var editingGates = false {
        didSet {
            switchPanRecognizers()
        }
    }
    var panGesture : UIPanGestureRecognizer!
    
    @IBOutlet var canvasView: LBZoomingCanvasView! {
        didSet {
            canvasView.minimumZoomScale = 0.25
            canvasView.maximumZoomScale = 6
            canvasView.zoomScale = 1
            canvasView.delegate = self
            canvasView.addSubview(gateView)
            canvasView.contentSize = gateView.frame.size
            
            // install our own pan gesture recognizer -- later
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
            panGesture.minimumNumberOfTouches = 1
            panGesture.maximumNumberOfTouches = 1
            
            // tap gesture for selecting and creating objects
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.numberOfTouchesRequired = 1
            canvasView.addGestureRecognizer(tapGesture)
            
            // tap gesture for selecting and creating objects
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
            longPressGesture.numberOfTapsRequired = 0
            longPressGesture.numberOfTouchesRequired = 1
            longPressGesture.minimumPressDuration = 1
            longPressGesture.allowableMovement = 10
            canvasView.addGestureRecognizer(longPressGesture)
        }
    }
    
    private var _gateView : LBGateView?
    var gateView : LBGateView! {
        if _gateView == nil {
            _gateView = LBGateView(frame: CGRect(x: 0, y: 0, width: 1000, height: 1000))
            _gateView?.contentMode = .redraw
            _gateView?.contentScaleFactor = 1
        }
        return _gateView
    }
    
    // MARK: - Document methods
    
    let LBEXTENSION = "BLOX"
    
    var document : LBDocument? {
        // create a new document
        let fileURL = getDocURL(getDocFilename("Gates", unique: true))
        NSLog("Want to create a file at %@", [fileURL])
        
        let doc = LBDocument(fileURL: fileURL)
        doc.save(to: fileURL, for: .forCreating) { (success) in
            if !success {
                NSLog("Failed to create a file at %@", [fileURL])
                return
            }
            
            NSLog("File created at %@", [fileURL])
//            let fileURL = doc.fileURL
//            let state = doc.documentState
//            let version = NSFileVersion.currentVersionOfItem(at: fileURL)
        }
        return doc
    }
    
    var designs : [URL] {
        if let urls = try? FileManager.default.contentsOfDirectory(at: localRoot!, includingPropertiesForKeys: nil, options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles) {
            return urls
        }
        return [getDocURL(getDocFilename("unnamed", unique: true))]
    }
    
    var localRoot : URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths.first
    }
    
    func getDocURL(_ filename: String) -> URL {
        return localRoot!.appendingPathComponent(filename, isDirectory: false)
    }
    
    func docNameExistsInObjects(_ docName: String) -> Bool {
        let fileManager = FileManager.default
        let docName = getDocURL(docName).absoluteString
        return fileManager.fileExists(atPath: docName)
    }
    
    func getDocFilename (_ prefix: String, unique: Bool) -> String {
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
    
    func loadDocAtURL(_ fileURL : URL) {
        let doc = LBDocument(fileURL: fileURL)
        doc.open { (success) in
            if !success {
                NSLog("Failed to open a file at %@", [fileURL])
                return
            }
        }
    }
    
    
    // MARK: - Support methods
    
    /// We switch between the built-in and our pan gesture recognizer.  Our pan is used during edit mode
    /// to move gates around.
    func switchPanRecognizers() {
        let panGR = canvasView.panGestureRecognizer
        if editingGates {
            panGR.minimumNumberOfTouches = 2
            panGR.maximumNumberOfTouches = 2
            canvasView.addGestureRecognizer(panGesture)
        } else {
            panGR.minimumNumberOfTouches = 1
            panGR.maximumNumberOfTouches = 1
            canvasView.removeGestureRecognizer(panGesture)
        }
    }
    
    func imageForGate(_ gateID: LBGateType) -> UIImage {
        let gate = LBGateType.classForGate(gateID)
        gate.defaultBounds()
        gate.highlighted = true
        return gate.getImageOfObject(gate.bounds, scale: 1)
    }
    
    func setButtonImage() {
        let image = imageForGate(lastGateType).imageByBestFitForSize(imageButton.bounds.size)
        imageButton.setImage(image, for: .normal)
    }

    // MARK: - Viewcontroller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonImage()
        gateView.gates = document?.gates ?? []
        self.title = document?.fileURL.deletingPathExtension().lastPathComponent
    }
    
    // MARK: - Bar button actions
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        editingGates = false
        self.navigationItem.setRightBarButtonItems([editBarButton], animated: true)
    }
    
    @IBAction func toggleEdit(_ sender: UIBarButtonItem) {
        editingGates = true
        self.navigationItem.setRightBarButtonItems([doneBarButton, imageBarButton], animated: true)
    }
    
    // MARK: - Gesture management
    
    func didTap (_ sender: UITapGestureRecognizer) {
        if editingGates {
            if let gate = gateView.gateUnderPoint(sender.location(in: gateView)) {
                gateView.toggleSelection(gate)
            } else {
                gateView.insertGate(lastGateType, withEvent: sender)
            }
        } else {
            // running simulation
            if let button = gateView.gateUnderPoint(sender.location(in: gateView)) as? LBButton {
                button.toggleState()
                gateView.setNeedsDisplay()
            }
        }
    }
    
    func didPan(_ sender: UIPanGestureRecognizer) {
        if editingGates {
            gateView.moveSelected(sender)
        }
    }
    
    func didLongPress(_ sender: UILongPressGestureRecognizer) {
        if editingGates {
            gateView.deleteSelected(sender)
        }
    }

    // MARK: - Navigation
    
    @IBAction func exitFromPopup(segue: UIStoryboardSegue) {
        // Dummy exit from popup window
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let id = segue.identifier {
            switch id {
            case "Show Gates" :
                let vc = (segue.destination as! UINavigationController).viewControllers[0] as? LBGateCollectionViewController
                vc?.selectedItem = lastGateType.rawValue
                vc?.callback = { selected in
                    self.lastGateType = selected
                    self.setButtonImage()
                }
            case "Show Designs":
                let vc = (segue.destination as! UINavigationController).viewControllers[0] as? LBDesignTableViewController
                vc?.designs = designs
                vc?.selectedItem = 0
                vc?.callback = { selected in
                    print("Selected design \(self.designs[selected])")
                    self.title = self.designs[selected].deletingPathExtension().lastPathComponent
                }
            default: break
            }
        }
    }

}

extension LBCanvasViewController : UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return gateView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        gateView.contentScaleFactor = scrollView.zoomScale
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    
}
