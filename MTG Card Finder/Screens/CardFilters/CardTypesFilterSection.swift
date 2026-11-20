//
//  CardTypesFilterSection.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/6/26.
//

import UIKit

class CardTypesFilterSection: UIStackView {
    var selectedTypes: [CardType] {
        didSet {
            render()
        }
    }
    
    var onToggle: ((CardType) -> Void)? {
        didSet {
            picker.onToggle = { [weak self] cardType in
                self?.onToggle?(cardType)
            }
        }
    }
    
    private var header = FilterSectionHeaderView()
    private var picker = CardTypesPicker()
    
    init(selectedTypes: [CardType] = []) {
        self.selectedTypes = selectedTypes
        super.init(frame: .zero)
        
        configure()
        render()
    }
    
    private func render() {
        picker.selectedTypes = selectedTypes
        header.secondaryText = selectedTypes.isEmpty ? nil : "\(selectedTypes.count) selected"
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        spacing = 6
        
        header.titleText = "Type"
        
        addArrangedSubview(header)
        addArrangedSubview(picker)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

