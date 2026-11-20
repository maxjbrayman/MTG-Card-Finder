//
//  EmptySavedCards.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/2/26.
//

import UIKit

class EmptySavedCards: UIView {
    var onSearchTapped: (() -> Void)? {
        didSet {
            updateLayout()
        }
    }
    
    private var messageToBottom: NSLayoutConstraint!

    private let headerView = EmptyCardsHeaderView()
    private let headlineLabelView = UILabel()
    private let messageLabelView = UILabel()
    private let ctaButton = MBButton(
        label: "Search Cards",
        style: .primary
    )
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        configureHeaderView()
        configureHeadlineLabelView()
        configureMessageLabelView()
        configureCTAButton()
        
        updateLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateLayout() {
        let hideButton = onSearchTapped == nil
        
        ctaButton.isHidden = hideButton
        messageToBottom.isActive = hideButton
    }
    
    private func configureHeaderView() {
        addSubview(headerView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func configureHeadlineLabelView() {
        addSubview(headlineLabelView)
        headlineLabelView.translatesAutoresizingMaskIntoConstraints = false
        
        headlineLabelView.text = "No saved cards yet"
        headlineLabelView.font = UIFont.preferredFont(forTextStyle: .headline)
        headlineLabelView.adjustsFontSizeToFitWidth = true
        
        NSLayoutConstraint.activate([
            headlineLabelView.topAnchor
                .constraint(equalTo: headerView.bottomAnchor, constant: 16),
            headlineLabelView.centerXAnchor
                .constraint(equalTo: centerXAnchor)
        ])
    }
    
    private func configureMessageLabelView() {
        addSubview(messageLabelView)
        messageLabelView.translatesAutoresizingMaskIntoConstraints = false
        
        messageLabelView.text = "Cards you save show up here, sorted into creatures, instants, lands and more."
        messageLabelView.textAlignment = .center
        messageLabelView.numberOfLines = 0
        
        NSLayoutConstraint.activate([
            messageLabelView.topAnchor
                .constraint(equalTo: headlineLabelView.bottomAnchor, constant: 6),
            messageLabelView.leadingAnchor
                .constraint(equalTo: leadingAnchor, constant: 24),
            messageLabelView.trailingAnchor
                .constraint(equalTo: trailingAnchor, constant: -24),
        ])
    }
    
    private func configureCTAButton() {
        addSubview(ctaButton)
        
        ctaButton.addAction(UIAction { _ in
            self.onSearchTapped?()
        }, for: .touchUpInside)
        
        messageToBottom = messageLabelView.bottomAnchor.constraint(equalTo: bottomAnchor)
//        buttonToBottom = searchButton.bottomAnchor.constraint(equalTo: bottomAnchor)
        
        NSLayoutConstraint.activate(
            [
                ctaButton.topAnchor
                    .constraint(
                        equalTo: messageLabelView.bottomAnchor,
                        constant: 12
                    ),
                ctaButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                ctaButton.heightAnchor.constraint(equalToConstant: 50),
                ctaButton.widthAnchor.constraint(equalToConstant: 200),
                ctaButton.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
        )
    }
}

private class EmptyCardsHeaderView: UIView {
    private enum CardPosition {
        case left, center, right
    }
    
    private let centerCardView = MBBorderedView(
        borderWidth: 2,
        cornerRadius: 8
    )
    private let leftCardView = MBBorderedView(borderWidth: 2, cornerRadius: 8)
    private let rightCardView = MBBorderedView(borderWidth: 2, cornerRadius: 8)
    private let imageView = UIImageView()
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        configureCards()
        configureImageView()
    }
    
    private func configureCards() {
        positionCardView(leftCardView, position: .left)
        positionCardView(rightCardView, position: .right)
        positionCardView(centerCardView, position: .center)
    }
    
    private func configureImageView() {
        centerCardView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.image = UIImage(systemName: "bookmark")
        imageView.tintColor = .brandPrimary
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 30),
            imageView.heightAnchor.constraint(equalToConstant: 30),
            imageView.centerXAnchor
                .constraint(equalTo: centerCardView.centerXAnchor),
            imageView.centerYAnchor
                .constraint(equalTo: centerCardView.centerYAnchor)
        ])
    }
    
    private func positionCardView(_ view: UIView, position: CardPosition) {
        addSubview(view)
        let backgroundColor: UIColor = switch position {
        case .center:
                .brandPrimaryLite
        case .left, .right:
                .white
        }
        view.backgroundColor = backgroundColor
        
        let degrees: CGFloat = switch position {
        case .center: 0
        case .left: -15
        case .right: 15
        }
        let radians = degrees * .pi / 180
        view.transform = CGAffineTransform(rotationAngle: radians)
        
        let xOffset: CGFloat = switch position {
        case .center: 0
        case .left: -20
        case .right: 20
        }
        
        let yOffset: CGFloat = switch position {
        case .center: 0
        case .left, .right: 10
        }
        
        let height: CGFloat = switch position {
        case .center: 100
        case .left, .right: 90
        }
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor, constant: yOffset),
            view.centerXAnchor.constraint(equalTo: centerXAnchor, constant: xOffset),
            view.heightAnchor.constraint(equalToConstant: height),
            view.widthAnchor.constraint(equalToConstant: 70)
        ])
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

