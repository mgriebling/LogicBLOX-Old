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
    @IBOutlet var deleteBarButton: UIBarButtonItem!
    @IBOutlet var filesBarButton: UIBarButtonItem!
    @IBOutlet weak var iconView: UIView!
    
    var lastGateType : LBGateType = .nand
    var editingGates = true
    var panGesture : UIPanGestureRecognizer!
    
    @IBOutlet var canvasView: LBZoomingCanvasView! {
        didSet {
            canvasView.minimumZoomScale = 0.25
            canvasView.maximumZoomScale = 6
            canvasView.zoomScale = 1
            canvasView.delegate = self
            canvasView.addSubview(gateView)
            canvasView.contentSize = gateView.frame.size
            
            // long press gesture for selecting objects and moving objects
            let pressGesture = UILongPressGestureRecognizer(target: self, action: #selector(didPress(_:)))
            canvasView.addGestureRecognizer(pressGesture)
            
            // double-tap to edit object
            let doubleTap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap(_:)))
            doubleTap.numberOfTapsRequired = 2
            canvasView.addGestureRecognizer(doubleTap)
            
            // tap gesture for selecting and creating objects .
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
            tapGesture.numberOfTapsRequired = 1
            canvasView.addGestureRecognizer(tapGesture)
        }
    }
    
    private var _gateView : LBGateView?
    var gateView : LBGateView! {
        if _gateView == nil {
            _gateView = LBGateView(frame: CGRect(x: 0, y: 0, width: 2000, height: 2000))
            _gateView?.contentMode = .redraw
            _gateView?.contentScaleFactor = 1
        }
        return _gateView
    }
    
    // MARK: - Document methods
    
    var document : LBDocument?
    
    func loadInitialDoc() {
        // reopen an existing document -- if possible
        let doc : LBDocument
        if let design = Designs.list.first {
            doc = loadDocAtURL(design)
        } else {
            // create a new document
            doc = Designs.addNewDesign()
            gateView.gates = []
            title = doc.fileURL.deletingPathExtension().lastPathComponent
        }
        document = doc
    }
    
    func loadDocAtURL(_ fileURL : URL) -> LBDocument {
        let doc = LBDocument(fileURL: fileURL)
        doc.open { (success) in
            if !success {
                NSLog("Failed to open a file at %@", [fileURL])
                self.gateView.gates = []
                return
            }
            self.gateView.gates = doc.gates
            self.title = doc.fileURL.deletingPathExtension().lastPathComponent
            doc.close(completionHandler: nil)
        }
        return doc
    }
    
    func saveActiveDoc() {
        guard let doc = document else { return }
        doc.gates = gateView.gates
        doc.save(to: doc.fileURL, for: .forOverwriting, completionHandler: { (success) in
            if !success {
                NSLog("Failed to save file to %@", [doc.fileURL])
                return
            }
        })
    }
    
    
    // MARK: - Support methods
    
//    func setButtonImage() {
//        let image : UIImage
//        if lastGateType == .line {
//            image = Gates.imageOfConnection(highlight: true).imageByBestFitForSize(imageButton.bounds.size)!
//        } else {
//            let gate = LBGateType.classForGate(lastGateType)
//            gate.highlighted = true
//            gate.inputPinVisible = 0
//            gate.outputPinVisible = 0
//            gate.defaultBounds()
//            image = gate.getImageOfObject(gate.bounds, scale: 1).imageByBestFitForSize(imageButton.bounds.size)!
//        }
//        imageButton.setImage(image, for: .normal)
//    }

    // MARK: - Viewcontroller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateState()
        loadInitialDoc()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveActiveDoc()
    }
    
    // MARK: - Bar button actions
    
    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        editingGates = false
        updateState()
        gateView.clearSelected()
        saveActiveDoc()
    }
    
    func updateState() {
        if editingGates {
            deleteBarButton.isEnabled = gateView.selected.count > 0
            navigationItem.setLeftBarButtonItems([deleteBarButton], animated: true)
            imageButton.setImage(UIImage(named: "Gate Icon 2"), for: .normal)
        } else {
            gateView.clearSelected()
            saveActiveDoc()
            navigationItem.setLeftBarButtonItems([filesBarButton], animated: true)
            imageButton.setImage(UIImage(named: "Gate Icon 1"), for: .normal)
        }
        UIView.animate(withDuration: 0.5) {
            self.iconView.isHidden = !self.editingGates
        }
    }
    
    @IBAction func toggleEdit(_ sender: Any) {
        editingGates = !editingGates
        updateState()
    }
    
    @IBAction func deleteGates(_ sender: UIBarButtonItem) {
        if editingGates {
            gateView.deleteSelected(sender)
            deleteBarButton.isEnabled = false
        }
    }
    
    // MARK: - Gesture management
    
    func didPress(_ sender: UILongPressGestureRecognizer) {
        gateView.moveSelected(sender)
    }
    
    func didDoubleTap(_ sender: UITapGestureRecognizer) {
        if let gate = gateView.gateUnderPoint(sender.location(in: gateView)) {
            print("Double tapped gate \(gate)")
            performSegue(withIdentifier: "Show Menu", sender: gate)
        }
    }
    
    func didTap (_ sender: UITapGestureRecognizer) {
        if editingGates {
            gateView.insertGate(lastGateType, withEvent: sender)
            deleteBarButton.isEnabled = gateView.selected.count > 0
        } else {
            // running simulation
            if let button = gateView.gateUnderPoint(sender.location(in: gateView)) as? LBButton {
                button.toggleState()
//                print("gates = \(gateView.gates)")
                
                // clear all connected gate input pins so drive signals on shorted inputs propagate properly
                NSLog("Started clearing inputs")
                for gate in gateView.gates {
                    if let connection = gate as? LBConnection {
                        for pin in connection.outputs {
                            pin.state = .U
                        }
                    }
                }
                
//                NSLog("First evaluation pass...")
                for gate in gateView.gates {
                    // simplistic evaluation of values
                    _ = gate.evaluate()
                }
//                NSLog("Second evaluation pass...")
                for gate in gateView.gates {
                    // do it twice to catch any changes
                    _ = gate.evaluate()
                }
                NSLog("Finished")
                gateView.setNeedsDisplay()
            }
        }
    }
    
    func didPan(_ sender: UIPanGestureRecognizer) {
        if editingGates {
            gateView.moveSelected(sender)
        }
    }

    // MARK: - Navigation
    
    @IBAction func exitFromPopup(segue: UIStoryboardSegue) {
        // Dummy exit from popup window
    }
    
    func preparePopover(_ contentController: UIViewController, sender: Any?, delegate: UIPopoverPresentationControllerDelegate?) {
        contentController.modalPresentationStyle = .popover
        contentController.popoverPresentationController?.delegate = delegate
        
        if let view = sender as? UIView {
            contentController.popoverPresentationController?.sourceView = view
            contentController.popoverPresentationController?.sourceRect = view.bounds
        } else {
            contentController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let id = segue.identifier {
            switch id {
            case "Show Menu" :
                preparePopover(segue.destination, sender: sender, delegate: self)
            case "Show Gates" :
                let vc = segue.destination as? LBGateCollectionViewController
                vc?.selectedItem = lastGateType.rawValue
                vc?.callback = { selected in
                    self.lastGateType = selected
                    self.gateView.insertGate(selected, withEvent: nil)
//                    self.setButtonImage()
                }
            case "Show Designs":
                let vc = (segue.destination as! UINavigationController).viewControllers[0] as? LBDesignTableViewController
                preparePopover(segue.destination, sender: sender, delegate: self)
                vc?.selectedItem = Designs.list.index(of: document!.fileURL) ?? 0
                vc?.callback = { selected in
                    let url = Designs.list[selected]
                    if url != self.document!.fileURL {
                        self.saveActiveDoc()
                        self.document = self.loadDocAtURL(url)
                    }
                    
                    // update the title in case an existing design is renamed
                    self.title = url.deletingPathExtension().lastPathComponent
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
//        let x = scrollView.contentSize
//        gateView.contentScaleFactor = scrollView.zoomScale
//        print("Zoom scale = \(scrollView.zoomScale), size = \(x)")
        gateView.setNeedsDisplay()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let x = scrollView.contentOffset
//        print("Scrolled to = \(x)")
        gateView.setNeedsDisplay()
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        return false
    }
    
}

extension LBCanvasViewController : UIPopoverPresentationControllerDelegate {
    
    // Just so the iPhone shows pop-overs too
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
    
}
