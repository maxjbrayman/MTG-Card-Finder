//
//  CardPreviewView.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/11/26.
//

import UIKit

class CardPreviewView: UIView {
    let imageView = UIImageView()
    private let placeholderView = CardPlaceholderView()
    private let savedIndicator = UIView()
    var card: Card? = nil {
        didSet { render() }
    }
    var isSaved = false {
        didSet { savedIndicator.isHidden = !isSaved }
    }
    var imageLoadTask: Task<Void, Never>? = nil
    var currentURL: String? = nil
    
    init() {
        super.init(frame: .zero)
        configurePlaceholderView()
        configureImageView()
        configureSavedIndicator()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func render() {
        placeholderView.card = card
        imageView.image = nil
        imageLoadTask?.cancel()
        
        guard let card else {
            savedIndicator.isHidden = true
            currentURL = nil
            return
        }
        
        savedIndicator.isHidden = !isSaved
        let url = card.imageUris?.png
        currentURL = url
        imageLoadTask = Task { [weak self] in
            guard let url,
                  let self,
                  let image = await ImageManager.shared.loadImage(from: url) else { return }
            
            guard !Task.isCancelled, self.currentURL == url else { return }
            
            placeholderView.card = nil
            self.imageView.image = image
        }
    }
    
    private func configureImageView() {
        addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor
                .constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor
                .constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func configurePlaceholderView() {
        addSubview(placeholderView)
        
        NSLayoutConstraint.activate([
            placeholderView.topAnchor
                .constraint(equalTo: topAnchor),
            placeholderView.bottomAnchor
                .constraint(equalTo: bottomAnchor),
            placeholderView.leadingAnchor
                .constraint(equalTo: leadingAnchor),
            placeholderView.trailingAnchor
                .constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func configureSavedIndicator() {
        addSubview(savedIndicator)
        
        let bookmarkImage = UIImage(systemName: "bookmark.fill")?
            .withTintColor(.brandPrimary, renderingMode: .alwaysOriginal)
        let bookmarkImageView = UIImageView(image: bookmarkImage)
        bookmarkImageView.translatesAutoresizingMaskIntoConstraints = false
        savedIndicator.addSubview(bookmarkImageView)
        
        savedIndicator.translatesAutoresizingMaskIntoConstraints = false
        savedIndicator.backgroundColor = .systemBackground
        
        savedIndicator.layer.cornerRadius = 12.5
        savedIndicator.layer.shadowColor = UIColor.black.cgColor
        savedIndicator.layer.shadowOpacity = 0.4
        savedIndicator.layer.shadowRadius = 4
        savedIndicator.layer.shadowOffset = CGSize(width: 2, height: 4)
        
        NSLayoutConstraint.activate([
            savedIndicator.leadingAnchor
                .constraint(equalTo: leadingAnchor, constant: 8),
            savedIndicator.bottomAnchor
                .constraint(equalTo: bottomAnchor, constant: -8),
            savedIndicator.widthAnchor.constraint(equalToConstant: 25),
            savedIndicator.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        NSLayoutConstraint.activate(
            [
                bookmarkImageView.leadingAnchor
                    .constraint(
                        equalTo: savedIndicator.leadingAnchor,
                        constant: 4
                    ),
                bookmarkImageView.trailingAnchor
                    .constraint(
                        equalTo: savedIndicator.trailingAnchor,
                        constant: -4
                    ),
                bookmarkImageView.topAnchor
                    .constraint(
                        equalTo: savedIndicator.topAnchor,
                        constant: 4
                    ),
                bookmarkImageView.bottomAnchor
                    .constraint(
                        equalTo: savedIndicator.bottomAnchor,
                        constant: -4
                    ),
            ]
        )
    }
}

private class CardPlaceholderView: UIView {
    private let titleLabel = UILabel()
    private let imageOverlay = UIView()
    var card: Card? {
        didSet {
            if let card {
                if let firstColor = card.colors?.first,
                   let cardColor = CardColor(rawValue: firstColor) {
                    backgroundColor = cardColor.color
                } else { backgroundColor = CardColor.colorless.color }
                
                titleLabel.text = card.name
            }
        }
    }
    
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        configureView()
        configureLabel()
        configureImageOverlay()
    }
    
    private func configureView() {
        layer.cornerRadius = 4
        layer.borderWidth = 2
        layer.borderColor = UIColor.black.cgColor
    }
    
    private func configureLabel() {
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.6
        titleLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            titleLabel.widthAnchor
                .constraint(equalTo: widthAnchor, multiplier: 0.9),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }

    private func configureImageOverlay() {
        addSubview(imageOverlay)
        imageOverlay.translatesAutoresizingMaskIntoConstraints = false
        imageOverlay.backgroundColor = .white.withAlphaComponent(0.2)
        imageOverlay.layer.cornerRadius = 4
        
        NSLayoutConstraint.activate([
            imageOverlay.topAnchor
                .constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            imageOverlay.leadingAnchor
                .constraint(equalTo: titleLabel.leadingAnchor),
            imageOverlay.trailingAnchor
                .constraint(equalTo: titleLabel.trailingAnchor),
            imageOverlay.heightAnchor
                .constraint(equalTo: heightAnchor, multiplier: 0.4)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
