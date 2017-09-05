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

    MAX
    
    static func classForGate(_ gate: LBGateType) -> LBGate {
        switch gate {
        case .or:       return LBOr(withDefaultSize: CGSize.zero)
        case .or3:      return LBOr3(withDefaultSize: CGSize.zero)
        case .or4:      return LBOr4(withDefaultSize: CGSize.zero)
        case .nor:      return LBNor(withDefaultSize: CGSize.zero)
        case .nor3:     return LBNor3(withDefaultSize: CGSize.zero)
        case .nor4:     return LBNor4(withDefaultSize: CGSize.zero)
        case .xor:      return LBXor(withDefaultSize: CGSize.zero)
        case .xor3:     return LBXor3(withDefaultSize: CGSize.zero)
        case .xor4:     return LBXor4(withDefaultSize: CGSize.zero)
        case .xnor:     return LBXnor(withDefaultSize: CGSize.zero)
        case .xnor3:    return LBXnor3(withDefaultSize: CGSize.zero)
        case .xnor4:    return LBXnor4(withDefaultSize: CGSize.zero)
        case .and:      return LBAnd(withDefaultSize: CGSize.zero)
        case .and3:     return LBAnd3(withDefaultSize: CGSize.zero)
        case .and4:     return LBAnd4(withDefaultSize: CGSize.zero)
        case .nand:     return LBNand(withDefaultSize: CGSize.zero)
        case .nand3:    return LBNand3(withDefaultSize: CGSize.zero)
        case .nand4:    return LBNand4(withDefaultSize: CGSize.zero)
        case .inverter: return LBInverter(withDefaultSize: CGSize.zero)
        case .buffer:   return LBBuffer(withDefaultSize: CGSize.zero)
        case .block:    return LBBlock(withDefaultSize: CGSize.zero)
        case .line:     return LBConnection(withDefaultSize: CGSize.zero)
        case .indicator: return LBIndicator(withDefaultSize: CGSize.zero)
        case .button:   return LBButton(withDefaultSize: CGSize.zero)
        default: break
        }
        return LBNand(withDefaultSize: CGSize.zero)
    }
}

class LBGateCollectionViewController: UICollectionViewController {
    
    var selectedItem : Int = LBGateType.nand.rawValue
    var callback : (_ selected: LBGateType) -> () = { _ in }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        callback(LBGateType(rawValue: selectedItem)!)
    }

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
    
        // Configure the cell
        let image = cell.viewWithTag(10) as? UIImageView
        image?.image = gate.getImageOfObject(gate.bounds, scale: 1)
        let label = cell.viewWithTag(20) as? UILabel
        label?.text = kind == .line ? "Connection" : "\(kind) Gate"
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedItem = indexPath.item
        collectionView.reloadData()
    }

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
