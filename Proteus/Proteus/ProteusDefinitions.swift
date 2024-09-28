//
//  ProteusDefinitions.swift
//  Proteus
//
//  Created by 玉垒浮云 on 27/9/24.
//

import UIKit

public extension Proteus {
    struct ItemDimension {
        enum Option {
            case fractionalWidth(CGFloat, padding: CGFloat)
            case fractionalHeight(CGFloat, padding: CGFloat)
            case absolute(CGFloat)
        }
        
        var option: Option
        
        init(option: Option) {
            self.option = option
        }
        
        public static func fractionalWidth(_ fractionalWidth: CGFloat, padding: CGFloat = 0) -> ItemDimension {
            ItemDimension(option: .fractionalWidth(fractionalWidth, padding: padding))
        }

        public static func fractionalHeight(_ fractionalHeight: CGFloat, padding: CGFloat = 0) -> ItemDimension {
            ItemDimension(option: .fractionalHeight(fractionalHeight, padding: padding))
        }

        public static func absolute(_ absoluteDimension: CGFloat) -> ItemDimension {
            ItemDimension(option: .absolute(absoluteDimension))
        }
    }

    struct ItemSize {
        public var width: ItemDimension
        public var height: ItemDimension
        
        public init(width: ItemDimension = .fractionalWidth(1), height: ItemDimension = .fractionalHeight(1)) {
            self.width = width
            self.height = height
        }
        
        func resolvedSize(within containerSize: CGSize) -> CGSize {
            var resolvedWidth: CGFloat
            var resolvedHeight: CGFloat
            
            switch width.option {
            case let .fractionalWidth(ratio, padding):
                resolvedWidth = (containerSize.width - 2 * padding) * ratio
            case let .fractionalHeight(ratio, padding):
                resolvedWidth = (containerSize.height - 2 * padding) * ratio
            case let .absolute(value):
                resolvedWidth = value
            }
            
            switch height.option {
            case let .fractionalWidth(ratio, padding):
                resolvedHeight = (containerSize.width - 2 * padding) * ratio
            case let .fractionalHeight(ratio, padding):
                resolvedHeight = (containerSize.height - 2 * padding) * ratio
            case let .absolute(value):
                resolvedHeight = value
            }
            
            return CGSize(width: resolvedWidth, height: resolvedHeight)
        }
    }
    
    struct ItemTransform {
        enum Option {
            case none
            case zoom(maxScale: CGFloat, anchorPoint: CGPoint, inactiveItemAlpha: CGFloat)
            case custom((_ attributes: UICollectionViewLayoutAttributes) -> Void)
        }
        
        var option: Option
        
        init(option: Option) {
            self.option = option
        }
        
        public static let none = ItemTransform(option: .none)
        
        public static let defaultZoom = ItemTransform(option: .zoom(maxScale: 1.4, anchorPoint: .init(x: 0.5, y: 0.5), inactiveItemAlpha: 1))
        
        public static func zoom(maxScale: CGFloat, anchorPoint: CGPoint = .init(x: 0.5, y: 0.5), inactiveItemAlpha: CGFloat = 1) -> ItemTransform {
            .init(option: .zoom(maxScale: maxScale, anchorPoint: anchorPoint, inactiveItemAlpha: inactiveItemAlpha))
        }
        
        public static func custom(_ transform: @escaping (_ attributes: UICollectionViewLayoutAttributes) -> Void) -> ItemTransform {
            .init(option: .custom(transform))
        }
    }
}
