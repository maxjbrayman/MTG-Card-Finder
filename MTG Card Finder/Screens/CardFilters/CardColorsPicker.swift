//
//  CardColorsPicker.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/6/26.
//

import UIKit

class CardColorsPicker: MBRoundedCardView {
    var selectedColors: [CardColor] {
        didSet {
            render()
        }
    }
    var onToggle: ((CardColor) -> Void)?
    private var badges: [CardColor : ColorBadgeControl] = [:]
    
    init(selectedColors: [CardColor] = [], onToggle: ((CardColor) -> Void)? = nil) {
        self.selectedColors = selectedColors
        self.onToggle = onToggle
        super.init()
        
        configure()
    }
    
    private func render() {
        badges.forEach { (color, badge) in
            badge.isSelected = selectedColors.contains(color)
        }
    }
    
    private func configure() {
        CardColor.allCases.forEach {color in
            let badge = ColorBadgeControl(color: color)
            badge.addAction(UIAction { [weak self] _ in
                self?.onToggle?(color)
            }, for: .touchUpInside)
            
            badges[color] = badge
            addArrangedSubview(badge)
        }
    }
    
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class ColorBadgeControl: UIControl {
    private let color: CardColor
    private let innerImageView = UIImageView()
    private let padding: CGFloat = 6
    private let borderWidth: CGFloat = 2.5
    override var isSelected: Bool {
        didSet {
            layer.borderWidth = isSelected ? borderWidth : 0
        }
    }
    
    init(color: CardColor) {
        self.color = color
        super.init(frame: .zero)
        
        configure()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.width / 2
        innerImageView.layer.cornerRadius = (bounds.width - (padding * 2)) / 2
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .systemBackground
        layer.borderWidth = isSelected ? borderWidth : 0
        layer.borderColor = UIColor.brandPrimary.cgColor.copy(alpha: 1)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalTo: widthAnchor)
        ])
        
        addSubview(innerImageView)
        innerImageView.translatesAutoresizingMaskIntoConstraints = false
        innerImageView.backgroundColor = color.color
        innerImageView.isUserInteractionEnabled = false
        if let imageName = color.imageName {
            innerImageView.image = UIImage(named: imageName)
        }
        innerImageView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            innerImageView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            innerImageView.leadingAnchor
                .constraint(equalTo: leadingAnchor, constant: padding),
            innerImageView.trailingAnchor
                .constraint(equalTo: trailingAnchor, constant: -padding),
            innerImageView.bottomAnchor
                .constraint(equalTo: bottomAnchor, constant: -padding),
        ])
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
