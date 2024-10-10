//
//  ProteusFlowLayout.swift
//  Proteus
//
//  Created by 玉垒浮云 on 27/9/24.
//

import UIKit

public class ProteusDataSource<Item> {
    public typealias CardProvider = (_ proteus: Proteus, _ index: Int, _ item: Item) -> UIView
    
    weak var proteus: Proteus?
    
    private var items: [Item] = []
    
    var cardProvider: CardProvider
    
    public init(proteus: Proteus, cardProvider: @escaping CardProvider) {
        self.proteus = proteus
        self.cardProvider = cardProvider
        
        self.proteus?.reloadData = { [weak self] in
            guard let self else { return }
            appendItems(items)
        }
        
        self.proteus?.cardForIndex = { [weak self] index in
            guard let self, index <= items.count - 1 else { return nil }
            return cardProvider(proteus, index, items[index])
        }
    }
    
    public func appendItems(_ items: [Item]) {
        self.items = items
        self.proteus?.cardsCount = items.count
        proteus?.scrollView.subviews.forEach { $0.removeFromSuperview() }
        guard let proteus, proteus.bounds.width > 0 || proteus.bounds.height > 0, !items.isEmpty else { return }
        
        let containerDimension = proteus.scrollDirection.isHorizontal ? proteus.bounds.width : proteus.bounds.height
        let cardDimension = proteus.scrollDirection.isHorizontal ? proteus.resolvedCardSize.width : proteus.resolvedCardSize.height
        let cardDimensionWithSpacing = cardDimension + proteus.lineSpacing
        let baseOffset = proteus.headMargin + cardDimensionWithSpacing * CGFloat(items.count)
        var contentDimension: CGFloat, scale: CGFloat = 1
        if baseOffset + cardDimension * proteus.maxScale * 0.5 <= containerDimension * 0.5 {
            addCardsToScrollView(range: 0..<items.count)
            contentDimension = baseOffset + proteus.tailMargin - proteus.lineSpacing
        } else if baseOffset + cardDimension * (proteus.maxScale - 1) - proteus.lineSpacing < containerDimension + cardDimension * proteus.maxScale * 0.5 {
            scale = addCardsToScrollView(range: 0..<items.count)
            contentDimension = baseOffset + proteus.tailMargin + cardDimension * (scale - 1) - proteus.lineSpacing
        } else {
            let base = containerDimension + proteus.visibleRectExtension - proteus.headMargin - cardDimension * (proteus.maxScale - 1)
            let count = max(Int(min(ceil(base / cardDimensionWithSpacing), CGFloat(items.count))), 1)
            addCardsToScrollView(range: 0..<count)
            contentDimension = baseOffset + cardDimension * (proteus.maxScale - 1) + proteus.tailMargin - proteus.lineSpacing
        }
        
        updateScrollViewContentSize(contentDimension: contentDimension)
    }
}

private extension ProteusDataSource {
    // 添加卡片到滚动视图
    @discardableResult
    func addCardsToScrollView(range: CountableRange<Int>) -> CGFloat {
        var originX: CGFloat, originY: CGFloat, scale: CGFloat = 1.0
        for index in range {
            let card = cardProvider(proteus!, index, items[index])
            (originX, originY, scale) = proteus!.calculateZoomTransformValues(for: index)
            card.transform = CGAffineTransform(scaleX: scale, y: scale)
            card.center = CGPoint(x: originX + proteus!.resolvedCardSize.width * scale * 0.5,
                                  y: originY + proteus!.resolvedCardSize.height * scale * 0.5)
            proteus!.scrollView.addSubview(card)
        }
        return scale
    }
    
    func updateScrollViewContentSize(contentDimension: CGFloat) {
        if proteus!.scrollDirection.isHorizontal {
            proteus!.scrollView.contentSize = CGSize(width: contentDimension, height: proteus!.bounds.height)
        } else {
            proteus!.scrollView.contentSize = CGSize(width: proteus!.bounds.width, height: contentDimension)
        }
    }
}
