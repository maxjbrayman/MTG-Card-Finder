//
//  CardInfoSection.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/9/26.
//

import UIKit

class CardInfoSection: ListSectionView {
    let card: Card
    private var rows: [(String, UILabel)] {
        var r: [(String, UILabel)] = []
        let cardColors = card.colorIdentity.compactMap { CardColor(rawValue: $0) }
        let cardColorsLabelText = cardColors.isEmpty ?
            "Colorless" :
            cardColors.map { $0.label }.joined(separator: ", ")
        let cardColorsLabel = UILabel()
        cardColorsLabel.text = cardColorsLabelText
        r.append(("Colors", cardColorsLabel))
        
        var manaCostParts: [String] = []
        if let manaCost = card.manaCost, !manaCost.isEmpty {
            manaCostParts.append(manaCost)
        }
        manaCostParts.append("\(card.cmc)")
        let manaCostPartsLabel = UILabel()
        manaCostPartsLabel.attributedText = CardUtilities
            .getManaCostAttributedText(for: manaCostParts.joined(separator: " · "))
        r.append(("Mana cost", manaCostPartsLabel))
        
        if !card.typeLine.isEmpty {
            let typeLineLabel = UILabel()
            typeLineLabel.text = card.typeLine
            r.append(("Card type", typeLineLabel))
        }
        
        if !card.rarity.isEmpty {
            let rarityLabel = UILabel()
            rarityLabel.text = card.rarity.capitalized
            r.append(("Rarity", rarityLabel))
        }
        
        if !card.setName.isEmpty {
            let setLabel = UILabel()
            setLabel.text = card.setName
            r.append(("Set", setLabel))
        }
        
        if let releaseDate = card.releaseDate {
            let year = Calendar.current.component(.year, from: releaseDate)
            let yearLabel = UILabel()
            yearLabel.text = "\(year)"
            r.append(("Released", yearLabel))
        }
        
        return r
    }
    
    init(card: Card) {
        self.card = card
        super.init()
        
        configure()
    }
    
    private func configure() {
        sectionTitle = "Details"
        rows.forEach { (key, valueLabel) in
            let rowView = UIStackView()
            rowView.translatesAutoresizingMaskIntoConstraints = false
            rowView.distribution = .equalSpacing
            rowView.spacing = 8
            
            let keyLabel = UILabel()
            keyLabel.translatesAutoresizingMaskIntoConstraints = false
            keyLabel.text = key
            keyLabel
                .setContentCompressionResistancePriority(
                    .required,
                    for: .horizontal
                )
            
            valueLabel.translatesAutoresizingMaskIntoConstraints = false
            valueLabel.textColor = .systemGray2
            valueLabel.numberOfLines = 1
            valueLabel.minimumScaleFactor = 0.7
            valueLabel.adjustsFontSizeToFitWidth = true
            
            rowView.addArrangedSubview(keyLabel)
            rowView.addArrangedSubview(valueLabel)
            
            addRow(rowView)
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


