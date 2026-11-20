//
//  CardPreviewCell.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/3/26.
//

import UIKit

class CardPreviewCell: UICollectionViewCell {
    let cardPreviewView = CardPreviewView()
    static let reuseId = "CardPreviewCellId"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(cardPreviewView)
        cardPreviewView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardPreviewView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardPreviewView.leadingAnchor
                .constraint(equalTo: contentView.leadingAnchor),
            cardPreviewView.trailingAnchor
                .constraint(equalTo: contentView.trailingAnchor),
            cardPreviewView.bottomAnchor
                .constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cardPreviewView.card = nil
    }
    
    func set(card: Card, isSaved: Bool = false) {
        cardPreviewView.card = card
        cardPreviewView.isSaved = isSaved
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
