//
//  Proteus.swift
//  Proteus
//
//  Created by 玉垒浮云 on 27/9/24.
//

import UIKit

public final class Proteus: UIView {
    private var reusableCardCache: [String: [UIView]] = [:]
    
    let visibleRectExtension = 10.0
    
    let maxScale: CGFloat
    
    let inactiveCardAlpha: CGFloat
    
    var reloadData: (() -> Void)?
    
    var cardForIndex: ((Int) -> UIView?)?
    
    var cardsCount = 0
    
    let scrollView = UIScrollView()
    
    public var scrollDirection: ScrollDirection = .leftToRight {
        didSet {
            switch scrollDirection {
            case .rightToLeft:
                scrollView.transform = CGAffineTransformMakeRotation(.pi)
            case .bottomToTop:
                scrollView.transform = CGAffineTransform(scaleX: 1, y: -1)
            default:
                break
            }
        }
    }
    
    var resolvedCardSize: CGSize = .zero
    public var cardSize: CardSize = .init(width: .fractionalWidth(1), height: .fractionalHeight(1)) {
        didSet {
            resolvedCardSize = cardSize.resolvedSize(within: bounds.size)
        }
    }
    
    public var headMargin: CGFloat = 0
    
    public var tailMargin: CGFloat = 0
    
    public var lineSpacing: CGFloat = 0
    
    public init(maxScale: CGFloat, inactiveCardAlpha: CGFloat = 1) {
        self.maxScale = maxScale
        self.inactiveCardAlpha = inactiveCardAlpha
        super.init(frame: .zero)
        
        setupScrollView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = bounds
        reloadData?()
    }
    
    public func dequeueConfiguredReusableCard<Card, Item>(using registration: CardRegistration<Card, Item>, for index: Int, item: Item) -> Card where Card: UIView {
        let reuseIdentifier = String(describing: Card.self)
        if var cards = reusableCardCache[reuseIdentifier], let card = cards.popLast() as? Card {
            reusableCardCache[reuseIdentifier] = cards
            card.index = index
            registration.handler(card, index, item)
            return card
        } else {
            let card = Card()
            card.frame = CGRect(origin: .zero, size: resolvedCardSize)
            card.index = index
            switch scrollDirection {
            case .rightToLeft:
                card.transform = CGAffineTransformMakeRotation(.pi)
            case .bottomToTop:
                card.transform = CGAffineTransform(scaleX: 1, y: -1)
            default:
                break
            }
            
            registration.handler(card, index, item)
            return card
        }
    }
}

extension Proteus: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        func handler(index: Int) {
            let (originX, originY, scale) = calculateZoomTransformValues(for: index)
            let condition1 = scrollDirection.isHorizontal
                && ((originX > leadingPosition && originX <= leadingPosition + visibleRectExtension)
                || (originX < trailingPosition && originX >= trailingPosition - visibleRectExtension))
            let condition2 = !scrollDirection.isHorizontal
                && ((originY > leadingPosition && originY <= leadingPosition + visibleRectExtension)
                || (originY < trailingPosition && originY >= trailingPosition - visibleRectExtension))
            if condition1 || condition2 {
                if let card = cardForIndex?(index) {
                    card.transform = CGAffineTransform(scaleX: scale, y: scale)
                    card.center = CGPoint(x: originX + resolvedCardSize.width * scale * 0.5, y: originY + resolvedCardSize.height * scale * 0.5)
                    scrollView.addSubview(card)
                }
            }
        }
        
        let (extendedVisibleRect, leadingPosition, trailingPosition) = calculateExtendedVisibleRect()
        
        var records: [(Int, CGRect)] = []
        scrollView.subviews.forEach { card in
            let (originX, originY, scale) = calculateZoomTransformValues(for: card.index)
            card.transform = CGAffineTransform(scaleX: scale, y: scale)
            card.center = CGPoint(x: originX + resolvedCardSize.width * scale * 0.5, y: originY + resolvedCardSize.height * scale * 0.5)
            if CGRectIntersectsRect(extendedVisibleRect, card.frame) {
                records.append((card.index, card.frame))
            } else {
                let reuseIdentifier = String(describing: type(of: card))
                reusableCardCache[reuseIdentifier, default: []].append(card)
                card.removeFromSuperview()
            }
        }
        
        if records.isEmpty {
            handler(index: 0)
            if cardsCount > 0 {
                handler(index: cardsCount)
            }
        } else {
            records.sort { $0.0 < $1.0 }
            let firstRecord = records[0]
            var cardIndex = firstRecord.0
            var cardFrame = firstRecord.1
            var position = scrollDirection.isHorizontal ? cardFrame.minX : cardFrame.minY
            if cardIndex > 0 {
                if position - lineSpacing > leadingPosition {
                    addCardToScrollView(index: cardIndex - 1)
                }
            }
            
            if let lastRecord = records.last, lastRecord.0 + 1 < cardsCount {
                cardIndex = lastRecord.0
                cardFrame = lastRecord.1
                position = scrollDirection.isHorizontal ? cardFrame.maxX : cardFrame.maxY
                if position + lineSpacing < trailingPosition {
                    addCardToScrollView(index: cardIndex + 1)
                }
            }
        }
    }
}

extension Proteus {
    private func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        addSubview(scrollView)
    }
    
    private func calculateExtendedVisibleRect() -> (CGRect, CGFloat, CGFloat) {
        var extendedVisibleRect: CGRect, leadingPosition: CGFloat, trailingPosition: CGFloat
        if scrollDirection.isHorizontal {
            extendedVisibleRect = CGRect(x: scrollView.contentOffset.x - visibleRectExtension, y: 0, width: bounds.width + 2 * visibleRectExtension, height: bounds.height)
            leadingPosition = scrollView.contentOffset.x - visibleRectExtension
            trailingPosition = scrollView.contentOffset.x + bounds.width + visibleRectExtension
        } else {
            extendedVisibleRect = CGRect(x: 0, y: scrollView.contentOffset.y - visibleRectExtension, width: bounds.width, height: bounds.height + 2 * visibleRectExtension)
            leadingPosition = scrollView.contentOffset.y - visibleRectExtension
            trailingPosition = scrollView.contentOffset.y + bounds.height + visibleRectExtension
        }
        
        return (extendedVisibleRect, leadingPosition, trailingPosition)
    }
    
    private func addCardToScrollView(index: Int) {
        let (originX, originY, scale) = calculateZoomTransformValues(for: index)
        if let card = cardForIndex?(index) {
            card.transform = CGAffineTransform(scaleX: scale, y: scale)
            card.center = CGPoint(x: originX + resolvedCardSize.width * scale * 0.5, y: originY + resolvedCardSize.height * scale * 0.5)
            scrollView.addSubview(card)
        }
    }
    
    func calculateZoomTransformValues(for index: Int) -> (CGFloat, CGFloat, CGFloat) {
        let cardDimension = scrollDirection.isHorizontal ? resolvedCardSize.width : resolvedCardSize.height
        let containerDimension = scrollDirection.isHorizontal ? scrollView.bounds.width : scrollView.bounds.height
        let offset = scrollDirection.isHorizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y
        let cardDimensionWithSpacing = cardDimension + lineSpacing
        let baseOffset = headMargin + cardDimensionWithSpacing * CGFloat(index)
        
        let largestOffset = baseOffset + cardDimensionWithSpacing + cardDimension * maxScale * 0.5 - containerDimension * 0.5
        let middleOffset = baseOffset + cardDimension * maxScale * 0.5 - containerDimension * 0.5
        var smallestOffset = baseOffset + cardDimension * (maxScale - 1) - containerDimension * 0.5 - cardDimension * maxScale * 0.5 - lineSpacing
        let headCardSmallestOffset = headMargin - containerDimension * 0.5 - cardDimension * maxScale * 0.5 - lineSpacing
        if index == 0 { smallestOffset = headCardSmallestOffset }
        
        var scale: CGFloat = 1
        var originX: CGFloat = 0, originY: CGFloat = 0, a: CGFloat
        let b = cardDimension * 0.5
        let criticalDistance = b + b * maxScale + lineSpacing
        let screenCenterCoordinate = offset + containerDimension * 0.5
        if offset >= smallestOffset && offset <= middleOffset {
            a = baseOffset - cardDimensionWithSpacing + criticalDistance - screenCenterCoordinate
            scale = (criticalDistance * maxScale + a * (1 - maxScale) + b * (1 - maxScale * maxScale)) / (criticalDistance + b * (1 - maxScale))
            
            let prevCardScale = 1 + maxScale - scale
            originX = baseOffset - cardDimensionWithSpacing + cardDimension * prevCardScale + lineSpacing
        } else if offset > middleOffset && offset <= largestOffset {
            a = baseOffset - screenCenterCoordinate
            scale = (maxScale * criticalDistance - (1 - maxScale) * a) / (criticalDistance + (1 - maxScale) * b)
            originX = baseOffset
        } else if offset < smallestOffset {
            if offset < headCardSmallestOffset {
                originX = baseOffset
            } else {
                originX = baseOffset + cardDimension * (maxScale - 1)
            }
        } else {
            originX = baseOffset
        }
        
        if scrollDirection.isHorizontal {
            originY = (scrollView.bounds.height - resolvedCardSize.height * scale) * 0.5
        } else {
            originY = originX
            originX = (scrollView.bounds.width - resolvedCardSize.width * scale) * 0.5
        }
        
        return (originX, originY, scale)
    }
}

public extension Proteus {
    struct CardRegistration<Card, Item> where Card : UIView {

        public typealias Handler = (_ card: Card, _ index: Int, _ item: Item) -> Void
        
        fileprivate var handler: Handler

        public init(handler: @escaping CardRegistration<Card, Item>.Handler) {
            self.handler = handler
        }
    }
}

fileprivate extension UIView {
    private struct AssociatedKeys {
        static var index: UInt8 = 0
    }
    
    var index: Int {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.index) as? Int ?? 0
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.index, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

/*
import UIKit

public final class CardCarousel: CardCarouselInternalType, CardCarouselInterface {
    public let view: UIView
    
    public init() {
        self.view = CardCarouselView()
    }
    
    /**
     从重用池中获取一个已配置的可重用卡片视图，或者在必要时创建一个新的卡片视图。

     - Parameters:
       - registration: 一个包含卡片类型和配置处理器的注册对象。
       - index: 请求卡片的索引。
       - item: 与卡片关联的数据项。
     - Returns: 配置好的卡片视图。
    */
    public func dequeueConfiguredReusableCard<Card, Item>(
        using registration: CardRegistration<Card, Item>,
        for index: Int,
        item: Item
    ) -> Card where Card: UIView {
        guard let view = view as? CardCarouselView else { fatalError() }
        
        // 获取重用标识符
        let reuseIdentifier = String(describing: Card.self)
        // 尝试从重用池中获取一个可重用的卡片视图
        if var cards = view.reusableCardCache[reuseIdentifier], let card = cards.popLast() as? Card {
            // 更新重用池
            view.reusableCardCache[reuseIdentifier] = cards
            // 设置卡片的索引
            card._index = index
            // 使用配置处理器对卡片进行配置
            registration.handler(card, view.totalCardsCount == 0 ? index : index % view.totalCardsCount, item)
            // 返回配置好的卡片
            return card
        } else {
            // 如果重用池中没有可用的卡片，创建一个新的卡片视图
            let card = Card()
            // 设置卡片的初始 frame
            card.frame = CGRect(origin: .zero, size: view.actualCardSize)
            // 设置卡片的索引
            card._index = index
            // 使用配置处理器对卡片进行配置
            registration.handler(card, view.totalCardsCount == 0 ? index : index % view.totalCardsCount, item)
            // 返回配置好的卡片
            return card
        }
    }
}

public extension CardCarousel {
    /// CardRegistration 用于注册卡片视图和数据项的配置闭包。
    struct CardRegistration<Card, Item> where Card : UIView {

        public typealias Handler = (_ card: Card, _ index: Int, _ item: Item) -> Void
        
        fileprivate var handler: Handler

        public init(handler: @escaping CardRegistration<Card, Item>.Handler) {
            self.handler = handler
        }
    }
}
*/
