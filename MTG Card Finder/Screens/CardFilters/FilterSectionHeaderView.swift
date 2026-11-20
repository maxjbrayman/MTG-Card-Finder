//
//  FilterSectionHeaderView.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/5/26.
//

import UIKit

class FilterSectionHeaderView: UIStackView {
    private let titleLabel = UILabel()
    private let secondaryLabel = UILabel()
    
    var titleText: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue?.uppercased() }
    }
    var secondaryText: String? {
        get { secondaryLabel.text }
        set { secondaryLabel.text = newValue }
    }
    
    init() {
        super.init(frame: .zero)
        configure()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        distribution = .equalSpacing
        
        addArrangedSubview(titleLabel)
        addArrangedSubview(secondaryLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .systemGray2
        
        secondaryLabel.translatesAutoresizingMaskIntoConstraints = false
        secondaryLabel.font = .systemFont(ofSize: 16)
        secondaryLabel.textColor = .systemGray2
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
