//
//  CardDetailsHeader.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/9/26.
//

import UIKit

class CardDetailsHeader: UIStackView {
    let card: Card
    private let titleLabel = UILabel()
    private let manaCostView: ManaCostView!
    private let titleAndManaStack = UIStackView()
    private let cardTypeLabel = UILabel()
    private let titleAndManaView = UIView()
    
    
    init(card: Card) {
        self.card = card
        self.manaCostView = ManaCostView(manaCost: card.displayManaCost)
        super.init(frame: .zero)
        
        configureView()
        configureTitleAndManaStack()
        configureCardTypeLabel()
    }
    
    private func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        spacing = 4
        alignment = .fill
    }
    
    private func configureTitleAndManaStack() {
        addArrangedSubview(titleAndManaStack)
        titleAndManaStack.translatesAutoresizingMaskIntoConstraints = false
        titleAndManaStack.axis = .horizontal
        titleAndManaStack.distribution = .fill
        titleAndManaStack.spacing = 8
        
        titleAndManaStack.addArrangedSubview(titleLabel)
        titleAndManaStack.addArrangedSubview(manaCostView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = card.name
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.numberOfLines = 2
        titleLabel.minimumScaleFactor = 0.6
        titleLabel.adjustsFontSizeToFitWidth = true
        
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        manaCostView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        manaCostView.widthAnchor.constraint(lessThanOrEqualTo: titleAndManaStack.widthAnchor, multiplier: 0.5).isActive = true
        manaCostView.widthAnchor
            .constraint(
                greaterThanOrEqualTo: titleAndManaStack.widthAnchor,
                multiplier: 0.25
            ).isActive = true
    }
    
    private func configureCardTypeLabel() {
        addArrangedSubview(cardTypeLabel)
        cardTypeLabel.translatesAutoresizingMaskIntoConstraints = false
        cardTypeLabel.text = card.displayTypeLine
        cardTypeLabel.numberOfLines = 2
        cardTypeLabel.minimumScaleFactor = 0.6
        cardTypeLabel.adjustsFontSizeToFitWidth = true
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class ManaCostView: WrappingHStack {
    let manaCost: String?
    
    private var manaSections: [String] {
        guard let sections = manaCost?.split(separator: "//") else {
            return []
        }
        
        return sections.map { String($0) }
        
    }
    
    init(manaCost: String?) {
        self.manaCost = manaCost
        super.init(alignment: .trailing)
        
        configureView()
    }
    
    private func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        itemSpacing = 4
        rowSpacing = 4
        
        var index: Int = 0
        var forceWrapIndices = Set<Int>()
        manaSections.forEach { section in
            let manaSymbols = section.matches(of: /\{([^}]*)\}/).map { String($0.1) }
            guard !manaSymbols.isEmpty else { return }
            
            if index > 0 { forceWrapIndices.insert(index) }

            manaSymbols.forEach { symbol in
                if let imageName = ManaSymbols.imageDict[symbol] {
                    let imageView = UIImageView()
                    imageView.frame.size = CGSize(width: 20, height: 20)
                    addSubview(imageView)
                    imageView.image = UIImage(named: imageName)
                    imageView.contentMode = .scaleAspectFit
                }
                index += 1
            }
        }
        self.forceWrapIndices = forceWrapIndices
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
