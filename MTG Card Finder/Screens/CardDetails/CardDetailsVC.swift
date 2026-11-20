//
//  CardDetailsVC.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/6/26.
//

import UIKit
import SafariServices

class CardDetailsVC: UIViewController {
    let card: Card
    let cardStore: CardStore
    private let scrollView = ControlFriendlyScrollView<UIControl>()
    private let contentView = UIStackView()
    private let imageView = UIImageView()
    private let headerView = UIStackView()
    private let headerBackButton = UIButton()
    private let headerImagePlaceholderView = UIView()
    private let headerTitleView = UILabel()
    private let headerSaveButton = UIButton()
    private let detailsHeaderView: CardDetailsHeader!
    private let cardBodySection: CardBodyView!
    private let cardInfoSection: CardInfoSection!
    private let cardPurchaseURIsSection: CardPurchaseURIsSection!
    
    private let headerInset: CGFloat = 8
    private let imageViewPadding: CGFloat = 20
    private let headerImageWidth: CGFloat = 50
    
    init(card: Card, cardStore: CardStore) {
        self.card = card
        self.cardStore = cardStore
        detailsHeaderView = CardDetailsHeader(card: card)
        cardBodySection = CardBodyView(card: card)
        cardInfoSection = CardInfoSection(card: card)
        cardPurchaseURIsSection = CardPurchaseURIsSection(
            purchaseURIs: card.purchaseUris
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .systemGray5
        
        configureHeader()
        configureScrollView()
        configureContentView()
        configureImageView()
        
        render()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let newInset = imageView.frame.height
        guard scrollView.contentInset.top != newInset else { return }
        
        let wasAtTop = scrollView.contentOffset.y <= -scrollView.adjustedContentInset.top
        
        scrollView.contentInset.top = newInset
        
        if wasAtTop {
            scrollView.contentOffset.y = -scrollView.adjustedContentInset.top
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func render() {
        let isSaved = cardStore.isSaved(card)
        headerSaveButton.configuration?.image = UIImage(
            systemName: isSaved ? "bookmark.fill" : "bookmark"
        )?
            .withTintColor(.brandPrimary, renderingMode: .alwaysOriginal)
    }
    
    private func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor
                .constraint(equalTo: headerView.bottomAnchor),
            scrollView.leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureContentView() {
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = .vertical
        contentView.spacing = 12
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 0,
            leading: 12,
            bottom: 12,
            trailing: 12
        )
        
        NSLayoutConstraint.activate(
            [
                contentView.topAnchor
                    .constraint(
                        equalTo: scrollView.contentLayoutGuide.topAnchor,
                        constant: 12
                    ),
                contentView.widthAnchor
                    .constraint(
                        equalTo: scrollView.frameLayoutGuide.widthAnchor
                    ),
                contentView.bottomAnchor
                    .constraint(
                        equalTo: scrollView.contentLayoutGuide.bottomAnchor
                    ),
            ]
        )
        
        contentView.addArrangedSubview(detailsHeaderView)
        contentView.addArrangedSubview(cardBodySection)
        contentView.addArrangedSubview(cardInfoSection)
        
        cardPurchaseURIsSection.onTapURI = onTapPurchaseLink(_:)
        contentView.addArrangedSubview(cardPurchaseURIsSection)

    }
    
    private func configureImageView() {
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let width = view.bounds.width - (imageViewPadding * 2)
        let height = width / Card.imageAspectRatio
        
        Task {
            let image = await ImageManager.shared.loadImage(from: card.imageUris?.png)
            imageView.image = image
        }
        
        NSLayoutConstraint.activate(
            [
                imageView.topAnchor
                    .constraint(equalTo: headerView.bottomAnchor),
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageView.widthAnchor.constraint(equalToConstant: width),
                imageView.heightAnchor.constraint(equalToConstant: height)
            ]
        )
    }
    
    private func configureHeader() {
        view.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.axis = .horizontal
        headerView.alignment = .center
        headerView.distribution = .fill
        headerView.backgroundColor = view.backgroundColor
        headerView.isLayoutMarginsRelativeArrangement = true
        headerView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: headerInset,
            leading: headerInset,
            bottom: headerInset,
            trailing: headerInset
        )
        
        headerBackButton.translatesAutoresizingMaskIntoConstraints = false
        var backButtonConfig = UIButton.Configuration.glass()
        backButtonConfig.image = UIImage(systemName: "chevron.left")
        headerBackButton.configuration = backButtonConfig
        headerBackButton.addAction(UIAction { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }, for: .touchUpInside)
        headerBackButton.setContentHuggingPriority(.required, for: .horizontal)
        headerBackButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        headerView.addArrangedSubview(headerBackButton)
        
        headerImagePlaceholderView.translatesAutoresizingMaskIntoConstraints = false
        headerView.addArrangedSubview(headerImagePlaceholderView)
        
        NSLayoutConstraint.activate([
            headerImagePlaceholderView.widthAnchor
                .constraint(equalToConstant: headerImageWidth)
        ])
        
        headerTitleView.text = card.name
        headerTitleView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        headerTitleView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        headerTitleView.font = .preferredFont(forTextStyle: .headline)
        headerTitleView.adjustsFontForContentSizeCategory = true
        
        headerView.addArrangedSubview(headerTitleView)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        headerSaveButton.translatesAutoresizingMaskIntoConstraints = false
        let saveButtonConfig = UIButton.Configuration.glass()
        headerSaveButton.configuration = saveButtonConfig
        headerSaveButton.addAction(UIAction { [weak self] _ in
            self?.onTapSave()
        }, for: .touchUpInside)
        headerSaveButton.setContentHuggingPriority(.required, for: .horizontal)
        headerSaveButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        headerView.addArrangedSubview(headerSaveButton)
    }
    
    private func onTapPurchaseLink(_ url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    private func onTapSave() {
        let isSaved = cardStore.isSaved(card)
        do {
            if isSaved {
                try cardStore.removeCard(card)
            } else {
                try cardStore.saveCard(card)
            }
            
            render()
        } catch {
            let message = isSaved ?
            "We were unable to remove this card from your favorites." :
            "We were unable to add this card to your favorites."
            let alert = UIAlertController(
                title: "Something went wrong",
                message: message,
                preferredStyle: .alert
            )
            
            present(alert, animated: true)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CardDetailsVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentSize.height > 0 else { return }
        
        imageView.transform = .identity
        
        let scrollY = scrollView.contentInset.top + scrollView.contentOffset.y
        let imageViewHeight = imageView.bounds.height
        let imageViewWidth = imageView.bounds.width
        let imageViewCenterX = imageView.bounds.midX
        let imageViewCenterY = imageView.bounds.midY
        
        let finalX = headerImagePlaceholderView.convert(
            .zero,
            to: headerView
        ).x + (headerImageWidth / 4)
                
        let cardInitialX = imageView.convert(.zero, to: view).x
        let deltaX = finalX - cardInitialX
        let anchorX = deltaX / imageViewWidth
        
        let cardFinalHeight = headerView.bounds.height - (headerInset * 2)
        let minImageScale = cardFinalHeight / imageViewHeight
        
        let imageScale = MathUtils.clamp(MathUtils.interpolate(
            value: scrollY,
            from: (0, imageViewHeight),
            to: (1, minImageScale)
        ), min: minImageScale, max: 1)
        
        let anchorPoint = CGPoint(x: anchorX, y: 0)
        let pivotX = imageViewWidth * anchorPoint.x
        let pivotY = imageViewHeight * anchorPoint.y
        let dx = pivotX - imageViewCenterX
        let dy = pivotY - imageViewCenterY
        let translateY = MathUtils.interpolate(
            value: imageScale,
            from: (minImageScale, 1),
            to: (-cardFinalHeight - headerInset, 0)
        )
        var transform = CGAffineTransform(translationX: dx, y: dy + translateY)
        transform = transform.scaledBy(x: imageScale, y: imageScale)
        
        transform = transform.translatedBy(x: -dx, y: -dy)
        
        imageView.transform = transform
        
        let titleOpacity = MathUtils.interpolate(
            value: imageScale,
            from: (minImageScale, minImageScale + 0.1),
            to: (1, 0)
        )
        headerTitleView.layer.opacity = Float(titleOpacity)
        
    }
}
