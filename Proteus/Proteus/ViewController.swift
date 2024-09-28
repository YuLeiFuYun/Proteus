//
//  ViewController.swift
//  Proteus
//
//  Created by 玉垒浮云 on 27/9/24.
//

import UIKit

class ViewController: UIViewController {
    
    let proteus = Proteus()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        example1()
    }

    func example1() {
        proteus.itemSize = .init(width: .absolute(150), height: .absolute(120))
        proteus.headMargin = view.bounds.width * 0.5 - 75 * 1.4
        proteus.tailMargin = proteus.headMargin
        proteus.lineSpacing = 10
        proteus.view.backgroundColor = .systemRed
        view.addSubview(proteus.view)
        
        proteus.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            proteus.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            proteus.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            proteus.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            proteus.view.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        proteus.items = [.systemBlue, .systemCyan, .systemGray, .systemTeal, .systemGreen, .systemBrown]
    }
}

