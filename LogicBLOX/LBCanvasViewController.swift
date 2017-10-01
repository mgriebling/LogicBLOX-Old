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
    @IBOutlet weak var lineButton: UIButton!
    @IBOutlet var deleteBarButton: UIBarButtonItem!
    @IBOutlet var filesBarButton: UIBarButtonItem!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet var playButton: UIBarButtonItem!
    @IBOutlet var stopButton: UIBarButtonItem!
    @IBOutlet weak var gatesItem: UIBarButtonItem!
    @IBOutlet weak var timeItem: UIBarButtonItem!
    
    var lastGateType : LBGateType = .nand
    var editingGates = true
    var simulating = false
    var editingLines = false
    var panGesture : UIPanGestureRecognizer!
    var menuGate : LBGate?
    var transitionManager = LBTransitionManager()
    
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
            
            // add my own pan gesture
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
//            canvasView.panGestureRecognizer.require(toFail: panGesture)
            canvasView.addGestureRecognizer(panGesture)
            panGesture.isEnabled = false
            
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
            navigationItem.setLeftBarButtonItems([filesBarButton, playButton], animated: true)
            playButton.isEnabled = true
            imageButton.setImage(UIImage(named: "Gate Icon 1"), for: .normal)
        }
        UIView.animate(withDuration: 0.5) {
            self.iconView.isHidden = !self.editingGates
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func toggleEdit(_ sender: Any) {
        editingGates = !editingGates
        updateState()
    }
    
    @IBAction func startSimulating(_ sender: Any) {
        navigationController?.isToolbarHidden = false
        navigationItem.setLeftBarButtonItems([filesBarButton, stopButton], animated: true)
        gatesItem.title = "Gates: \(gateView.gates.count)"
        timeItem.title = "Time: 25nS"
        simulating = true
        togglePanGesture(true)
    }
    
    @IBAction func stopSimulating(_ sender: Any) {
        navigationController?.isToolbarHidden = true
        navigationItem.setLeftBarButtonItems([filesBarButton, playButton], animated: true)
        simulating = false
    }
    
    @IBAction func toggleLine(_ sender: Any) {
        editingLines = !editingLines
        if editingLines {
            lineButton.setImage(UIImage(named: "Line Icon 2"), for: .normal)
        } else {
            lineButton.setImage(UIImage(named: "Line Icon 1"), for: .normal)
        }
        togglePanGesture(gateView.selected.count == 0)
    }
    
    @IBAction func deleteGates(_ sender: UIBarButtonItem) {
        if editingGates {
            gateView.deleteSelected(sender)
            deleteBarButton.isEnabled = false
        }
    }
    
    // MARK: - Support
    
    func togglePanGesture(_ enable: Bool) {
        panGesture.isEnabled = !enable
        canvasView.panGestureRecognizer.isEnabled = enable
    }
    
    @objc func doEditMenu() {
        print("Editing \(menuGate!)")
    }
    
    @objc func doDeleteMenu() {
        print("Deleting \(menuGate!)")
        self.gateView.deleteGate(menuGate!)
    }
    
    @objc func doCloneMenu() {
        self.gateView.cloneGate(menuGate!)
        print("Gates = \(self.gateView.gates)")
    }
    
    func clearPopupMenu() {
        let popupMenu = UIMenuController.shared
        if popupMenu.isMenuVisible {
            popupMenu.setMenuVisible(false, animated: true)
        }
        menuGate = nil
    }
    
    // MARK: - Gesture management
    
    @objc func didPress(_ sender: UILongPressGestureRecognizer) {
        gateView.moveSelected(sender)
    }
    
    @objc func didDoubleTap(_ sender: UITapGestureRecognizer) {
        if let gate = gateView.gateUnderPoint(sender.location(in: gateView)) {
            let popupMenu = UIMenuController.shared
            if popupMenu.isMenuVisible {
                clearPopupMenu()
            } else {
                gateView.becomeFirstResponder()  // required to show the menu
                popupMenu.setTargetRect(gate.bounds, in: gateView)
                let items = popupMenu.menuItems
                menuGate = gate
                if items == nil {
                    let edit = UIMenuItem(title: "Edit", action: #selector(doEditMenu))
                    let delete = UIMenuItem(title: "Delete", action: #selector(doDeleteMenu))
                    let clone = UIMenuItem(title: "Clone", action: #selector(doCloneMenu))
                    popupMenu.menuItems = [edit, delete, clone]
                    popupMenu.update()
                }
//                print(popupMenu.menuItems!)
                popupMenu.setMenuVisible(true, animated: true)
            }
            togglePanGesture(true)
        } else {
            clearPopupMenu()
        }
    }
    
    @objc func didTap (_ sender: UITapGestureRecognizer) {
        togglePanGesture(true)
        if editingLines {
            clearPopupMenu()
            gateView.insertLine(sender)
        } else if editingGates {
            clearPopupMenu()
            gateView.insertGate(lastGateType, withEvent: sender)
            deleteBarButton.isEnabled = gateView.selected.count > 0
            togglePanGesture(gateView.selected.count == 0)
        } else if simulating {
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
        } else {
            // edit objects
            didDoubleTap(sender)
            togglePanGesture(gateView.selected.count == 0)
        }
    }
    
    @objc func didPan(_ sender: UIPanGestureRecognizer) {
        let selected = gateView.selected
        if selected.count > 0 {
            gateView.moveSelected(sender)
            if sender.state == .ended {
                togglePanGesture(true)
            }
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
        } else if let button = sender as? UIBarButtonItem {
            contentController.popoverPresentationController?.barButtonItem = button
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let id = segue.identifier {
            switch id {
            case "Show Gates" :
                let vc = segue.destination as? LBGateViewController
                vc?.selectedItem = lastGateType.rawValue
                vc?.callback = { selected in
                    self.lastGateType = selected
                    self.gateView.insertGate(selected, withEvent: nil)
                }
            case "Show Designs":
                let vc = (segue.destination as! UINavigationController).viewControllers[0] as? LBDesignViewController
                segue.destination.transitioningDelegate = self.transitionManager
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
//        gateView.setNeedsDisplay()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let x = scrollView.contentOffset
//        print("Scrolled to = \(x)")
//        gateView.setNeedsDisplay()
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
