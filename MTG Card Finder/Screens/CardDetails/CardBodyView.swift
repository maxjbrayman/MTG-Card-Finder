//
//  CardBodyView.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/9/26.
//

import UIKit

class CardBodyView: ListSectionView {
    let card: Card
    private let contentView = UIView()
    private let textBodyLabel = UILabel()
    private let powerAndToughnessView = UIView()
    private let powerAndToughnessLabel = UILabel()
    
    init(card: Card) {
        self.card = card
        super.init()
        
        configure()
        configurePowerAndToughness()
        configureTextBodyLabel()
    }
    
    private func configure() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addRow(contentView)
    }
    
    private func configureTextBodyLabel() {
        textBodyLabel.translatesAutoresizingMaskIntoConstraints = false
        let attributedText = CardUtilities.getManaCostAttributedText(for: card.oracleText)
        isHidden = attributedText == nil
        textBodyLabel.attributedText = attributedText
        textBodyLabel.numberOfLines = 0
        
        contentView.addSubview(textBodyLabel)
        NSLayoutConstraint.activate([
            textBodyLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            textBodyLabel.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor),
            textBodyLabel.trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor),
            textBodyLabel.bottomAnchor
                .constraint(equalTo: powerAndToughnessView.topAnchor),
        ])
    }
    
    private func configurePowerAndToughness() {
        powerAndToughnessView.translatesAutoresizingMaskIntoConstraints = false
        powerAndToughnessView.backgroundColor = .systemGray5
        powerAndToughnessView.layer.cornerRadius = 8
        
        contentView.addSubview(powerAndToughnessView)
        
        NSLayoutConstraint.activate(
            [
                powerAndToughnessView.trailingAnchor
                    .constraint(
                        equalTo: contentView.trailingAnchor
                    ),
                powerAndToughnessView.bottomAnchor
                    .constraint(
                        equalTo: contentView.bottomAnchor
                    )
            ]
        )
        
        guard let power = card.power, let toughness = card.toughness else { return }
        powerAndToughnessView.addSubview(powerAndToughnessLabel)
        powerAndToughnessLabel.translatesAutoresizingMaskIntoConstraints = false
        powerAndToughnessLabel.text = "\(power) / \(toughness)"
        
        NSLayoutConstraint.activate([
            powerAndToughnessLabel.topAnchor
                .constraint(equalTo: powerAndToughnessView.topAnchor, constant: 4),
            powerAndToughnessLabel.leadingAnchor
                .constraint(equalTo: powerAndToughnessView.leadingAnchor, constant: 8),
            powerAndToughnessLabel.trailingAnchor
                .constraint(equalTo: powerAndToughnessView.trailingAnchor, constant: -8),
            powerAndToughnessLabel.bottomAnchor
                .constraint(equalTo: powerAndToughnessView.bottomAnchor, constant: -4),
        ])
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
