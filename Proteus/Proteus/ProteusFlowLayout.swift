//
//  ProteusFlowLayout.swift
//  Proteus
//
//  Created by 玉垒浮云 on 27/9/24.
//

import UIKit

final class ProteusFlowLayout: UICollectionViewFlowLayout {
    var itemTransform: Proteus.ItemTransform = .defaultZoom
    
    var lineSpacing: CGFloat = 0
    
    var headMargin: CGFloat = 0
    
    override init() {
        super.init()
        
        scrollDirection = .horizontal
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ProteusFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if case .none = itemTransform.option {
            return super.shouldInvalidateLayout(forBoundsChange: newBounds)
        } else {
            return true
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if case .none = itemTransform.option { return super.layoutAttributesForElements(in: rect) }
        
        let attributesArray = NSArray(array: super.layoutAttributesForElements(in: rect)!, copyItems: true) as! [UICollectionViewLayoutAttributes]
        for attributes in attributesArray {
            switch itemTransform.option {
            case .zoom:
                applyZoomTransform(to: attributes)
            case let .custom(transform):
                transform(attributes)
            default:
                break
            }
        }
        
        return attributesArray
    }
}

private extension ProteusFlowLayout {
    func applyZoomTransform(to attributes: UICollectionViewLayoutAttributes) {
        guard case let .zoom(maxScale, anchorPoint, inactiveItemAlpha) = itemTransform.option else { return }
        
        let index = attributes.indexPath.row
        let itemWidth = itemSize.width
        let containerWidth = collectionView!.bounds.width
        let offset = collectionView!.contentOffset.x
        let largestOffset = headMargin + (itemWidth + lineSpacing) * CGFloat(index + 1) + itemWidth * maxScale * 0.5 - containerWidth * 0.5
        let middleOffset = headMargin + (itemWidth + lineSpacing) * CGFloat(index) + itemWidth * maxScale * 0.5 - containerWidth * 0.5
        var smallestOffset = headMargin + (itemWidth + lineSpacing) * CGFloat(index) + itemWidth * (maxScale - 1) - containerWidth * 0.5 - itemWidth * maxScale * 0.5 - lineSpacing
        let headItemSmallestOffset = headMargin - containerWidth * 0.5 - itemWidth * maxScale * 0.5 - lineSpacing
        if index == 0 {
            smallestOffset = headItemSmallestOffset
        }
        
        var a: CGFloat
        let b = itemSize.width * 0.5
        let criticalDistance = b + b * maxScale + lineSpacing
        let screenCenterX = offset + containerWidth * 0.5
        var scale: CGFloat = 1
        var originX: CGFloat, originY: CGFloat
        if offset >= smallestOffset && offset <= middleOffset {
            a = headMargin + (itemSize.width + lineSpacing) * CGFloat(attributes.indexPath.row - 1) + criticalDistance - screenCenterX
            scale = (criticalDistance * maxScale + a * (1 - maxScale) + b * (1 - maxScale * maxScale)) / (criticalDistance + b * (1 - maxScale))
            let prevItemScale = 1 + maxScale - scale
            originX = headMargin + (itemSize.width + lineSpacing) * CGFloat(index - 1) + itemSize.width * prevItemScale + lineSpacing
        } else if offset > middleOffset && offset <= largestOffset {
            a = headMargin + (itemSize.width + lineSpacing) * CGFloat(index) - screenCenterX
            scale = (maxScale * criticalDistance - (1 - maxScale) * a) / (criticalDistance + (1 - maxScale) * b)
            originX = headMargin + (itemSize.width + lineSpacing) * CGFloat(index)
        } else if offset < smallestOffset {
            if offset < headItemSmallestOffset {
                originX = headMargin + (itemSize.width + lineSpacing) * CGFloat(index)
            } else {
                originX = headMargin + (itemSize.width + lineSpacing) * CGFloat(index) + itemWidth * (maxScale - 1)
            }
        } else {
            originX = headMargin + (itemSize.width + lineSpacing) * CGFloat(index)
        }
        
        originY = (collectionView!.bounds.height - itemSize.height * scale) * 0.5
        attributes.frame = CGRect(x: originX, y: originY, width: itemSize.width * scale, height: itemSize.height * scale)
        let distance = originX + itemSize.width * scale * 0.5 - containerWidth * 0.5 - offset
        attributes.zIndex = Int.max - 1 - Int(abs(distance))
        print(attributes.indexPath.row, attributes.frame, scale, distance)
    }
}
