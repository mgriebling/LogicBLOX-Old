//
//  LBGateCollectionViewController.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 3 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

private let reuseIdentifier = "GateCell"

public enum LBGateType : Int {
    case line = 0, button, indicator,
    or, or3, or4,
    nor, nor3, nor4,
    and, and3, and4,
    nand, nand3, nand4,
    xor, xor3, xor4,
    xnor, xnor3, xnor4,
    buffer,
    inverter,
    block,

    MAX // last item indicator
    
    static func classForGate(_ gate: LBGateType) -> LBGate {
        switch gate {
        case .or:       return LBOr()
        case .or3:      return LBOr3()
        case .or4:      return LBOr4()
        case .nor:      return LBNor()
        case .nor3:     return LBNor3()
        case .nor4:     return LBNor4()
        case .xor:      return LBXor()
        case .xor3:     return LBXor3()
        case .xor4:     return LBXor4()
        case .xnor:     return LBXnor()
        case .xnor3:    return LBXnor3()
        case .xnor4:    return LBXnor4()
        case .and:      return LBAnd()
        case .and3:     return LBAnd3()
        case .and4:     return LBAnd4()
        case .nand:     return LBNand()
        case .nand3:    return LBNand3()
        case .nand4:    return LBNand4()
        case .inverter: return LBInverter()
        case .buffer:   return LBBuffer()
        case .block:    return LBBlock()
        case .line:     return LBConnection()
        case .indicator: return LBIndicator()
        case .button:   return LBButton()
        default: break
        }
        return LBNand()
    }
}

class LBGateCollectionViewController: UICollectionViewController {
    
    var selectedItem : Int = LBGateType.nand.rawValue
    var callback : (_ selected: LBGateType) -> () = { _ in }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        callback(LBGateType(rawValue: selectedItem)!)
//    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LBGateType.MAX.rawValue
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        // Get the gate
        let kind = LBGateType(rawValue: indexPath.item)!
        let gate = LBGateType.classForGate(kind)
        gate.defaultBounds()
        gate.highlighted = indexPath.item == selectedItem
        gate.inputPinVisible = 0
        gate.outputPinVisible = 0
    
        // Configure the cell
        let image = cell.viewWithTag(10) as? UIImageView
        if kind == .line {
            image?.image  = Gates.imageOfConnection(highlight: indexPath.item == selectedItem)
        } else {
            image?.image = gate.getImageOfObject(gate.bounds, scale: 1)
        }
        let label = cell.viewWithTag(20) as? UILabel
        label?.text = gate.description
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem = indexPath.item
        callback(LBGateType(rawValue: selectedItem)!)
        collectionView.reloadData()
    }


}
