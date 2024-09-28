//
//  Proteus.swift
//  Proteus
//
//  Created by 玉垒浮云 on 27/9/24.
//

import UIKit

public final class Proteus: NSObject {
    var itemSize: ItemSize = .init(width: .fractionalWidth(1), height: .fractionalHeight(1)) {
        didSet {
            if let flowLayout = view.collectionViewLayout as? ProteusFlowLayout {
                flowLayout.itemSize = itemSize.resolvedSize(within: view.bounds.size)
            }
        }
    }
    
    var headMargin: CGFloat = 0 {
        didSet {
            if let flowLayout = view.collectionViewLayout as? ProteusFlowLayout {
                flowLayout.headMargin = headMargin
            }
        }
    }
    
    var tailMargin: CGFloat = 0
    
    var lineSpacing: CGFloat = 0 {
        didSet {
            if let flowLayout = view.collectionViewLayout as? ProteusFlowLayout {
                flowLayout.lineSpacing = lineSpacing
            }
        }
    }
    
    var items: [UIColor] = [] {
        didSet {
            guard items != oldValue else { return }
            view.reloadData()
        }
    }
    
    var itemTransform: Proteus.ItemTransform = .defaultZoom {
        didSet {
            if let flowLayout = view.collectionViewLayout as? ProteusFlowLayout {
                flowLayout.itemTransform = itemTransform
            }
        }
    }
    
    var view: UICollectionView!
    
    public override init() {
        super.init()
        
        view = makeCollectionView()
    }
}

extension Proteus: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.contentView.backgroundColor = items[indexPath.row]
        return cell
    }
}

extension Proteus: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .init(top: 0, left: headMargin, bottom: 0, right: tailMargin)
    }
}

private extension Proteus {
    func makeCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: .init(), collectionViewLayout: ProteusFlowLayout())
//        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
//        collectionView.decelerationRate = .init(rawValue: decelerationRate)
        collectionView.semanticContentAttribute = .forceLeftToRight
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }
}
