//
//  CardRarityPicker.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/6/26.
//

import UIKit

class CardRarityPicker: WrappingHStack {
    var selectedRarities: [CardRarity] {
        didSet {
            render()
        }
    }
    var onToggle: ((CardRarity) -> Void)?
    private var capsules: [ CardRarity : CapsuleChip ] = [:]
    
    init(selectedRarities: [CardRarity] = []) {
        self.selectedRarities = selectedRarities
        super.init()
        
        configure()
        render()
    }
    
    private func configure() {
        CardRarity.allCases.forEach { rarity in
            let chip = CapsuleChip(label: rarity.label)
            chip.setTitle(rarity.label, for: .normal)
            chip.addAction(UIAction { [weak self] _ in
                self?.onToggle?(rarity)
            }, for: .touchUpInside)
            capsules[rarity] = chip
            addSubview(chip)
        }
    }
    
    private func render() {
        capsules.forEach { (rarity, button) in
            button.isSelected = selectedRarities.contains(rarity)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
