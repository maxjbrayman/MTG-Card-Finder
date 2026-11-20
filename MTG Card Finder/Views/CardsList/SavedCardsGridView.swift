//
//  SavedCardsGridView.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/11/26.
//

import UIKit

class SavedCardsGridView: WrappingHStack {
    var cards: [Card] = [] {
        didSet { updateCards() }
    }
    private(set) var minCardWidth: CGFloat
    private let wrap = WrappingHStack()
    var onTapCard: ((Card) -> Void)?
    
    init(minCardWidth: CGFloat = 120) {
        self.minCardWidth = minCardWidth
        super.init()
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0 else { return }
        
        let cellWidth = UIUtilities.getCellWidth(
            totalWidth: bounds.width,
            minCellWidth: minCardWidth,
            itemSpacing: itemSpacing
        )
        let cellSize = CGSize(
            width: cellWidth,
            height: cellWidth / Card.imageAspectRatio
        )
        
        var changed = false
        for view in subviews where view.frame.size != cellSize {
            view.frame.size = cellSize
            changed = true
        }
        
        if changed {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    
    private func updateCards() {
        subviews.forEach { $0.removeFromSuperview() }
        cards.forEach { card in
            let cell = CardPreviewView()
            cell.card = card
            cell.isSaved = true
            let control = UIControl()
            control.translatesAutoresizingMaskIntoConstraints = false
            control.addAction(UIAction {[weak self] _ in
                self?.onTapCard?(card)
            }, for: .touchUpInside)
            cell.addSubview(control)
            NSLayoutConstraint.activate([
                control.topAnchor.constraint(equalTo: cell.topAnchor),
                control.leadingAnchor.constraint(equalTo: cell.leadingAnchor),
                control.trailingAnchor.constraint(equalTo: cell.trailingAnchor),
                control.bottomAnchor.constraint(equalTo: cell.bottomAnchor)
            ])
            addSubview(cell)
        }
        setNeedsLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
