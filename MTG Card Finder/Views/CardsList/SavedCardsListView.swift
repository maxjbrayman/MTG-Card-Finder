//
//  SavedCardsListView.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/11/26.
//

import UIKit

class SavedCardsListView: ControlFriendlyScrollView<UIControl> {
    private let contentView = UIStackView()
    var cards: [Card] = [] {
        didSet {
            render()
        }
    }
    var onTapCard: ((Card) -> Void)?
    private let scrollContentPadding: CGFloat = 12
    
    private var cardSections: [(key: String, value: [Card])] {
        var sections: [ String : [Card] ] = [:]
        
        cards.forEach { card in
            let cardType = CardType.getType(from: card.displayTypeLine)
            let sectionLabel = cardType?.label ?? "Other"
            sections[sectionLabel, default: []].append(card)
        }
        
        return sections.sorted { $0.key > $1.key }
    }
    
    init() {
        super.init(frame: .zero)
        
        configureScrollView()
        configureContentView()
    }
    
    private func configureScrollView() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func configureContentView() {
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = .vertical
        contentView.spacing = 16
        
        NSLayoutConstraint.activate(
            [
                contentView.topAnchor
                    .constraint(
                        equalTo: contentLayoutGuide.topAnchor,
                        constant: scrollContentPadding
                    ),
                contentView.leadingAnchor
                    .constraint(
                        equalTo: contentLayoutGuide.leadingAnchor,
                        constant: scrollContentPadding
                    ),
                contentView.trailingAnchor
                    .constraint(
                        equalTo: contentLayoutGuide.trailingAnchor,
                        constant: -scrollContentPadding
                    ),
                contentView.bottomAnchor
                    .constraint(
                        equalTo: contentLayoutGuide.bottomAnchor,
                        constant: -scrollContentPadding
                    ),
                contentView.widthAnchor
                    .constraint(
                        equalTo: frameLayoutGuide.widthAnchor,
                        constant: -scrollContentPadding * 2
                    )
            ]
        )
    }
    
    private func render() {
        contentView.subviews.forEach {
            $0.removeFromSuperview()
        }
        
        cardSections.forEach { (sectionTitle, sectionCards) in
            
            let collapsingView = MBCollapsingView()
            collapsingView.translatesAutoresizingMaskIntoConstraints = false
            collapsingView.titleText = sectionTitle
            collapsingView.backgroundColor = .secondarySystemBackground
            collapsingView.onAnimate = { [weak self] in
                self?.superview?.layoutIfNeeded()
            }
            
            let headerRightView = UIView()
            headerRightView.translatesAutoresizingMaskIntoConstraints = false
            headerRightView.layer.cornerRadius = 15
            headerRightView.backgroundColor = .brandPrimary
            collapsingView.headerRight = headerRightView
            
            NSLayoutConstraint.activate([
                headerRightView.widthAnchor.constraint(equalToConstant: 30),
                headerRightView.heightAnchor.constraint(equalToConstant: 30)
            ])
            
            let headerRightLabel = UILabel()
            headerRightLabel.translatesAutoresizingMaskIntoConstraints = false
            headerRightLabel.text = "\(sectionCards.count)"
            headerRightLabel.textColor = .brandPrimaryLite
            headerRightLabel.adjustsFontSizeToFitWidth = true
            headerRightView.addSubview(headerRightLabel)
            
            NSLayoutConstraint.activate(
                [
                    headerRightLabel.centerXAnchor
                        .constraint(equalTo: headerRightView.centerXAnchor),
                    headerRightLabel.centerYAnchor
                        .constraint(equalTo: headerRightView.centerYAnchor)
                ]
            )
            
            let gridView = SavedCardsGridView(minCardWidth: 100)
            gridView.translatesAutoresizingMaskIntoConstraints = false
            gridView.onTapCard = onTapCard
            gridView.cards = sectionCards
            
            collapsingView.addContentView(gridView)
            
            contentView.addArrangedSubview(collapsingView)
            
            NSLayoutConstraint.activate([
                collapsingView.leadingAnchor
                    .constraint(equalTo: contentView.leadingAnchor),
                collapsingView.trailingAnchor
                    .constraint(equalTo: contentView.trailingAnchor)
            ])
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
