//
//  CardPurchaseURIsView.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/10/26.
//

import UIKit

class CardPurchaseURIsSection: ListSectionView {
    let purchaseURIs: CardPurchaseURIs?
    var onTapURI: ((URL) -> Void)? = nil
    
    private var rows: [(String, URL)] {
        var r: [(String, URL)] = []
                
        guard let purchaseURIs else { return r }
        if let tcgplayer = purchaseURIs.tcgplayer, let url = URL(
            string: tcgplayer
        ) { r.append(("TCGPlayer", url)) }
        if let cardmarket = purchaseURIs.cardmarket, let url = URL(
            string: cardmarket
        ) { r.append(("Cardmarket", url)) }
        if let cardhoarder = purchaseURIs.cardhoarder, let url = URL(
            string: cardhoarder
        ) { r.append(("Cardhoarder", url)) }
                
        return r
    }
    
    init(purchaseURIs: CardPurchaseURIs?) {
        self.purchaseURIs = purchaseURIs
        super.init()
        
        configure()
    }
    
    private func configure() {
        guard !rows.isEmpty else { return }
        
        sectionTitle = "Buy this card"
        
        rows.forEach { (retailer, url) in
            let rowView = UIStackView()
            rowView.translatesAutoresizingMaskIntoConstraints = false
            rowView.distribution = .equalSpacing
            rowView.spacing = 8
            
            let keyLabel = UILabel()
            keyLabel.translatesAutoresizingMaskIntoConstraints = false
            keyLabel.text = retailer
            keyLabel.setContentCompressionResistancePriority(
                    .required,
                    for: .horizontal
            )
            keyLabel.textColor = .brandPrimary
            
            let iconView = UIImageView()
            iconView.image = UIImage(systemName: "link")?
                .withTintColor(.brandPrimary, renderingMode: .alwaysOriginal)
            
            rowView.addArrangedSubview(keyLabel)
            rowView.addArrangedSubview(iconView)
            
            addRow(rowView, with: UIAction { [weak self] _ in self?.onTapURI?(url) })
        }
        
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
