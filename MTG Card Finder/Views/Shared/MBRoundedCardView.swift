//
//  MBRoundedCardView.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/13/26.
//

import UIKit

class MBRoundedCardView: UIStackView {
    init() {
        super.init(frame: .zero)
        
        configure()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        alignment = .center
        distribution = .fillEqually
        spacing = 8
        layer.cornerRadius = 12
        backgroundColor = .systemBackground
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        isLayoutMarginsRelativeArrangement = true
        directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 8,
            leading: 8,
            bottom: 8,
            trailing: 8
        )
    }
    
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
