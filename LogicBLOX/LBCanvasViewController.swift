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
    
    var initialDelta: CGPoint = CGPoint.zero
    var selected : LBGate? = nil
    
    func didPan(_ sender: UIPanGestureRecognizer) {
        let position = sender.location(in: gateView)
        if sender.state == .began {
            selected = gateView.gateUnderPoint(sender.location(in: gateView))
            if let selected = selected {
                if !selected.highlighted { gateView.toggleSelection(selected); gateView.setNeedsDisplay() }
                initialDelta.x = selected.bounds.origin.x - position.x
                initialDelta.y = selected.bounds.origin.y - position.y
            }
        } else if sender.state == .changed {
            if let selected = selected {
                selected.bounds.origin = CGPoint(x: position.x + initialDelta.x, y: position.y + initialDelta.y)
                gateView.setNeedsDisplay()
            }
        } else if sender.state == .ended {
            gateView.setNeedsDisplay()
        }
    }
    
    func didLongPress(_ sender: UILongPressGestureRecognizer) {
//        if sender.state == .began {
//            let position = sender.location(in: drawingView)
//            selected?.highlighted = false
//            selected = document?.data.highlightGateUnderPoint(position)
//            selected?.highlighted = true
//            drawingView.setNeedsDisplay()
//        } else if sender.state == .ended {
//            if let deleted = selected {
//                document?.data.removeGate(deleted)
//                selected = nil
//                drawingView.setNeedsDisplay()
//                saveDoc()
//            }
//        }
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
