//
//  LBGateLayout.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 4 Oct 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

protocol GateLayoutDelegate : class {
    func collectionView(_ collectionView: UICollectionView, heightForGateAtIndexPath indexPath: IndexPath, usingWidth width: CGFloat) -> CGFloat
}

class LBGateLayout: UICollectionViewLayout {
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    var numberOfColumns = 1 { didSet { cache = [] } }
    fileprivate var cellPadding : CGFloat = 2
    fileprivate var contentHeight : CGFloat = 0
    fileprivate var contentWidth : CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    weak var delegate : GateLayoutDelegate!
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let bounds = collectionView!.bounds
        guard newBounds.width != bounds.width || newBounds.height != bounds.height else { return false }
        cache = []
        numberOfColumns = Int(newBounds.width / 95)
        print("Bounds = \(newBounds), columns = \(numberOfColumns)")
        return true
    }
    
    override func prepare() {
        guard cache.isEmpty == true, let collectionView = collectionView else { return }
        
        print("Preparing with columns = \(numberOfColumns)")
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        contentHeight = 0
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let gateHeight = delegate.collectionView(collectionView, heightForGateAtIndexPath: indexPath, usingWidth: columnWidth)
            let height = cellPadding * 2 + gateHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            column = column+1 > (numberOfColumns - 1) ? 0 : (column + 1)
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }

}
