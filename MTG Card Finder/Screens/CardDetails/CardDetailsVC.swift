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
    private let imageContainerView = UIView()
    private let frontsideImageView = UIImageView()
    private let backsideImageView = UIImageView()
    private let headerView = UIStackView()
    private let headerBackButton = UIButton()
    private let headerImagePlaceholderView = UIView()
    private let headerTitleView = UILabel()
    private let headerSaveButton = UIButton()
    private let flipCardButton = UIButton()
    private let detailsHeaderView: CardDetailsHeader!
    private let cardBodySection = CardBodyView()
    private let cardInfoSection: CardInfoSection!
    private let cardPurchaseURIsSection: CardPurchaseURIsSection!
    
    private let headerInset: CGFloat = 8
    private let imageViewPadding: CGFloat = 20
    private let headerImageWidth: CGFloat = 50
    
    private var primaryImageUri: String? {
        card.displayImageUris?.png
    }
    private var secondaryImageUri: String? {
        guard card.isDoubleSided else { return nil }
        
        return card.cardFaces?.last?.imageUris?.png
    }
    private var isCardFlipped = false {
        didSet { flipCard() }
    }
    private var hideFlipButton = false {
        didSet { updateFlipButton() }
    }
    
    init(card: Card, cardStore: CardStore) {
        self.card = card
        self.cardStore = cardStore
        detailsHeaderView = CardDetailsHeader(card: card)
        cardBodySection.bodyText = card.displayOracleText
        cardBodySection.powerText = card.displayPower
        cardBodySection.toughnessText = card.displayToughness
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
        configureImageContainerView()
        configureFrontsideImageView()
        configureBacksideImageView()
        configureFlipCardButton()
        
        render()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let imageViewHeight = imageContainerView.frame.height
        let flipButtonHeight = flipCardButton.frame.height
        
        let newInset = imageViewHeight + flipButtonHeight + 16
        
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
    
    private func configureImageContainerView() {
        view.addSubview(imageContainerView)
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        imageContainerView.isUserInteractionEnabled = false
        
        let width = view.bounds.width - (imageViewPadding * 2)
        let height = width / Card.imageAspectRatio
        
        NSLayoutConstraint.activate(
            [
                imageContainerView.topAnchor
                    .constraint(equalTo: headerView.bottomAnchor),
                imageContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageContainerView.widthAnchor.constraint(equalToConstant: width),
                imageContainerView.heightAnchor
                    .constraint(equalToConstant: height)
            ]
        )
    }
    
    private func configureFrontsideImageView() {
        imageContainerView.addSubview(frontsideImageView)
        frontsideImageView.translatesAutoresizingMaskIntoConstraints = false
        
        Task {
            let image = await ImageManager.shared.loadImage(
                from: primaryImageUri
            )
            frontsideImageView.image = image
        }
        
        NSLayoutConstraint.activate(
            [
                frontsideImageView.topAnchor
                    .constraint(equalTo: imageContainerView.topAnchor),
                frontsideImageView.centerXAnchor
                    .constraint(equalTo: imageContainerView.centerXAnchor),
                frontsideImageView.widthAnchor
                    .constraint(equalTo: imageContainerView.widthAnchor),
                frontsideImageView.heightAnchor
                    .constraint(equalTo: imageContainerView.heightAnchor)
            ]
        )
    }
    
    private func configureBacksideImageView() {
        imageContainerView.addSubview(backsideImageView)
        backsideImageView.translatesAutoresizingMaskIntoConstraints = false
        backsideImageView.isHidden = true
        
        Task {
            let image = await ImageManager.shared.loadImage(
                from: secondaryImageUri
            )
            backsideImageView.image = image
        }
        
        NSLayoutConstraint.activate(
            [
                backsideImageView.topAnchor
                    .constraint(equalTo: imageContainerView.topAnchor),
                backsideImageView.centerXAnchor
                    .constraint(equalTo: imageContainerView.centerXAnchor),
                backsideImageView.widthAnchor
                    .constraint(equalTo: imageContainerView.widthAnchor),
                backsideImageView.heightAnchor
                    .constraint(equalTo: imageContainerView.heightAnchor)
            ]
        )
    }
    
    private func configureFlipCardButton() {
        if card.isDoubleSided {
            flipCardButton.translatesAutoresizingMaskIntoConstraints = false
            var buttonConfig = UIButton.Configuration.glass()
            buttonConfig.title = "Flip"
            buttonConfig.contentInsets = NSDirectionalEdgeInsets(
                top: 12,
                leading: 12,
                bottom: 12,
                trailing: 12
            )
            flipCardButton.configuration = buttonConfig
            flipCardButton.addAction(
                UIAction { [weak self] _ in
                    self?.isCardFlipped.toggle()
                },
                for: .touchUpInside)
            
            view.addSubview(flipCardButton)
            NSLayoutConstraint.activate([
                flipCardButton.topAnchor
                    .constraint(equalTo: frontsideImageView.bottomAnchor, constant: 16),
                flipCardButton.centerXAnchor
                    .constraint(equalTo: frontsideImageView.centerXAnchor)
            ])
        }
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
    
    private func flipCard() {
        if isCardFlipped {
            let face = card.cardFaces?.last
            let text = face?.oracleText
            let power = face?.power
            let toughness = face?.toughness
            
            cardBodySection.bodyText = text
            cardBodySection.powerText = power
            cardBodySection.toughnessText = toughness
        } else {
            cardBodySection.bodyText = card.displayOracleText
            cardBodySection.powerText = card.displayPower
            cardBodySection.toughnessText = card.displayToughness
        }
        
        let transitionOptions: UIView.AnimationOptions = isCardFlipped
            ? [.transitionFlipFromRight, .showHideTransitionViews]
            : [.transitionFlipFromLeft, .showHideTransitionViews]
        
        UIView
            .transition(
                with: imageContainerView,
                duration: 0.6,
                options: transitionOptions
            ) {
                frontsideImageView.isHidden = isCardFlipped
                backsideImageView.isHidden = !isCardFlipped
            }
    }
    
    private func updateFlipButton() {
        UIView.animate(withDuration: 0.3) {
            flipCardButton.isEnabled = !hideFlipButton
            flipCardButton.layer.opacity = hideFlipButton ? 0 : 1
        }
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
        
        imageContainerView.transform = .identity
        
        let scrollY = scrollView.contentInset.top + scrollView.contentOffset.y
        hideFlipButton = scrollY > 0
        
        let imageViewHeight = imageContainerView.bounds.height
        let imageViewWidth = imageContainerView.bounds.width
        let imageViewCenterX = imageContainerView.bounds.midX
        let imageViewCenterY = imageContainerView.bounds.midY
        
        let finalX = headerImagePlaceholderView.convert(
            .zero,
            to: headerView
        ).x + (headerImageWidth / 4)
        
        let cardInitialX = imageContainerView.convert(.zero, to: view).x
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
        
        imageContainerView.transform = transform
        
        let titleOpacity = MathUtils.interpolate(
            value: imageScale,
            from: (minImageScale, minImageScale + 0.1),
            to: (1, 0)
        )
        headerTitleView.layer.opacity = Float(titleOpacity)
        
    }
}
