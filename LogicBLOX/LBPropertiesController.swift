//
//  LBPropertiesController.swift
//  LogicBLOX
//
//  Created by Michael Griebling on 4Oct2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBPropertiesController: UITableViewController {
    
    @IBOutlet weak var facingControl: UISegmentedControl!
    @IBOutlet weak var inputsSlider: UISlider!
    @IBOutlet weak var inputsText: UITextField!
    @IBOutlet weak var widthSlider: UISlider!
    @IBOutlet weak var widthText: UITextField!
    
    weak var gate : LBGate? { didSet { configure() } }
    var invertedController : LBSwitchViewController?
    var states : [Bool] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configure()
    }
    
    func configure() {
        if let gate = gate {
            widthSlider?.value = Float(gate.bounds.width)
            widthText?.text = "\(Int(gate.bounds.width))"
            let inputs : Int
            switch gate.kind {
            case .and, .nor, .or, .nand, .xor, .xnor : inputs = 2
            case .and3, .nor3, .or3, .nand3, .xor3, .xnor3 : inputs = 3
            case .and4, .nor4, .or4, .nand4, .xor4, .xnor4 : inputs = 4
            default: inputs = 0
            }
            states = [Bool](repeating: false, count:inputs)
            if let active = invertedController?.states {
                // refresh states
                if active.count >= inputs {
                    states[0..<inputs] = active[0..<inputs]
                } else {
                    states[0..<inputs] = active[0..<inputs]
                }
            }
            print("Setting input to \(inputs)")


            inputsSlider?.value = Float(inputs)
            inputsText?.text = "\(inputs)"
            invertedController?.states = states
            self.title = "\(gate.description) Properties"
        }
    }

    // MARK: - Table view data source
    
    @IBAction func inputNumberChanged(_ sender: UISlider) {
        configure()
    }
    
    @IBAction func widthChanged(_ sender: UISlider) {
        configure()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "Switch Embed" {
            if let vc = segue.destination as? LBSwitchViewController {
                vc.states = states
                invertedController = vc
            }
        }
    }

}
