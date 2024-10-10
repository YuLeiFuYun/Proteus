//
//  ProteusDefinitions.swift
//  Proteus
//
//  Created by 玉垒浮云 on 27/9/24.
//

import UIKit

public extension Proteus {
    struct CardDimension {
        enum Option {
            case fractionalWidth(CGFloat, padding: CGFloat)
            case fractionalHeight(CGFloat, padding: CGFloat)
            case absolute(CGFloat)
        }
        
        var option: Option
        
        init(option: Option) {
            self.option = option
        }
        
        public static func fractionalWidth(_ fractionalWidth: CGFloat, padding: CGFloat = 0) -> CardDimension {
            CardDimension(option: .fractionalWidth(fractionalWidth, padding: padding))
        }

        public static func fractionalHeight(_ fractionalHeight: CGFloat, padding: CGFloat = 0) -> CardDimension {
            CardDimension(option: .fractionalHeight(fractionalHeight, padding: padding))
        }

        public static func absolute(_ absoluteDimension: CGFloat) -> CardDimension {
            CardDimension(option: .absolute(absoluteDimension))
        }
    }

    struct CardSize {
        public var width: CardDimension
        public var height: CardDimension
        
        public init(width: CardDimension = .fractionalWidth(1), height: CardDimension = .fractionalHeight(1)) {
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

    enum ScrollDirection: Int {
        case leftToRight = 1
        case rightToLeft = 2
        case topToBottom = 3
        case bottomToTop = 4
        
        var isHorizontal: Bool {
            return self == .leftToRight || self == .rightToLeft
        }
    }
}

