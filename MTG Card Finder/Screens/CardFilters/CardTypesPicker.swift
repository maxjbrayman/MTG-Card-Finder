//
//  CardTypesPicker.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/6/26.
//

import UIKit

class CardTypesPicker: WrappingHStack {
    var selectedTypes: [CardType] = [] {
        didSet {
            render()
        }
    }
    var onToggle: ((CardType) -> Void)?
    private var capsules: [ CardType : CapsuleChip ] = [:]
    
    init() {
        super.init()
        
        configure()
        render()
    }
    
    private func configure() {
        CardType.allCases.forEach { cardType in
            let chip = CapsuleChip(label: cardType.label)
            chip.addAction(UIAction { [weak self] _ in
                self?.onToggle?(cardType)
            }, for: .touchUpInside)
            capsules[cardType] = chip
            addSubview(chip)
        }
    }
    
    private func render() {
        capsules.forEach { (cardType, button) in
            button.isSelected = selectedTypes.contains(cardType)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
