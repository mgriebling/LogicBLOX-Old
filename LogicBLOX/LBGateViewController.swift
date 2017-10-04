//
//  LBGateCollectionViewController.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 3 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

private let reuseIdentifier = "GateCell"

class LBGateViewController: UICollectionViewController {
    
    var selectedItem : Int = LBGateType.nand.rawValue
    var callback : (_ selected: LBGateType) -> () = { _ in }
    
    // MARK: Life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = collectionViewLayout as? LBGateLayout {
            layout.delegate = self
        }
    }
    
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
        image?.image = gate.getImageOfObject(gate.bounds, scale: 1)
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

extension LBGateViewController : GateLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, heightForGateAtIndexPath indexPath: IndexPath, usingWidth width: CGFloat) -> CGFloat {
        let labelHeight : CGFloat = 12
        let minimumHeight : CGFloat = 40
        let kind = LBGateType(rawValue: indexPath.item)!
        let gate = LBGateType.classForGate(kind)
        gate.defaultBounds()
        let image = gate.getImageOfObject(gate.bounds, scale: 1)
        
        // scale the height based on the actual column width to maintain the aspect ratio
        let scale = min(1, width / image.size.width)
        return max(minimumHeight, image.size.height * scale) + labelHeight
    }
    
}
