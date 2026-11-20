//
//  CardRarityFilterSection.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/6/26.
//

import UIKit

class CardRarityFilterSection: UIStackView {
    var selectedRarities: [CardRarity] {
        get { picker.selectedRarities }
        set {
            picker.selectedRarities = newValue
            render()
        }
    }
    
    var onToggle: ((CardRarity) -> Void)? {
        didSet {
            picker.onToggle = { [weak self] rarity in
                self?.onToggle?(rarity)
            }
        }
    }
    
    private var header = FilterSectionHeaderView()
    private var picker = CardRarityPicker()
    
    init() {
        super.init(frame: .zero)
        
        configure()
        render()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        spacing = 6
        
        header.titleText = "Rarity"
        
        addArrangedSubview(header)
        addArrangedSubview(picker)
    }
    
    private func render() {
        picker.selectedRarities = selectedRarities
        header.secondaryText = selectedRarities.isEmpty ? nil : "\(selectedRarities.count) selected"
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
