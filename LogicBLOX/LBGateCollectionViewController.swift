//
//  LBGateCollectionViewController.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 3 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

private let reuseIdentifier = "GateCell"

class LBGateCollectionViewController: UICollectionViewController {
    
    var selectedItem : Int = LBGateType.nand.rawValue
    var callback : (_ selected: LBGateType) -> () = { _ in }
    
    // MARK: Life cycle methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.scrollToItem(at: IndexPath(item: selectedItem, section: 0), at: UICollectionViewScrollPosition.centeredVertically, animated: false)
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
