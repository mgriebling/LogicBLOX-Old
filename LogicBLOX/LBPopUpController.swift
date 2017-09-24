//
//  LBPopUpController.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 23 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBPopUpController: UIViewController {
    
    var actions : [() -> ()] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func performAction(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        print("Selected segment \(index)")
        if index < actions.count {
            let action = actions[sender.selectedSegmentIndex]
            action()
        }
    }

}
