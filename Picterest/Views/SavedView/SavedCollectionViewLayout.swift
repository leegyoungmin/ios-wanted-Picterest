//
//  SavedCollectionViewLayout.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/28.
//

import UIKit

protocol SaveCollectionViewDelegate: AnyObject {
    func collectionView(
        _ collectionView: UICollectionView,
        heightForPhotoAtIndexPath: IndexPath
    ) -> CGFloat
}

class SavedCollectionViewLayout: UICollectionViewLayout {
    weak var delegate: SaveCollectionViewDelegate?
    private let cellPadding: CGFloat = 10
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    private var contentHeight: CGFloat = 0
    
    var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard let collectionView = collectionView else {
            return
        }
        
        let width = contentWidth
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            let height = delegate?.collectionView(
                collectionView,
                heightForPhotoAtIndexPath: indexPath
            ) ?? 0
            let frame = CGRect(x: 0, y: contentHeight, width: width, height: height)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            cache.append(attribute)
            contentHeight += CGFloat(height)
        }
        
    }
    
    override func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        for attribute in cache {
            if attribute.frame.intersects(rect) {
                visibleLayoutAttributes.append(attribute)
            }
        }
        
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
