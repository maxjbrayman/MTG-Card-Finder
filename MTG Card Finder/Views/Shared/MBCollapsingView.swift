//
//  MBCollapsingView.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/11/26.
//

import UIKit

class MBCollapsingView: UIView {
    let collapsedHeight: CGFloat
    let edgeInsets: UIEdgeInsets
    var onAnimate: (() -> Void)?
    var titleText: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    private let headerViewControl = UIControl()
    private let headerViewStack = UIStackView()
    private let titleLabel = UILabel()
    private let chevronView = UIImageView()
    private let contentContainerView = UIView()
    var headerRight: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let headerRight { headerViewStack.addArrangedSubview(headerRight) }
        }
    }
    var isOpen = false {
        didSet { render() }
    }
    
    private lazy var collapsedConstraint = heightAnchor.constraint(equalToConstant: collapsedHeight)
    private lazy var expandedConstraint = contentContainerView.bottomAnchor.constraint(
        equalTo: bottomAnchor,
        constant: edgeInsets.bottom
    )
    
    init(
        collapsedHeight: CGFloat = 50,
        edgeInsets: UIEdgeInsets = UIEdgeInsets(
            top: 8,
            left: 8,
            bottom: -8,
            right: -8
        )
    ) {
        self.collapsedHeight = collapsedHeight
        self.edgeInsets = edgeInsets
        super.init(frame: .zero)
        
        configureView()
        configureHeader()
        configureContentContainerView()
    }
    
    func addContentView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            view.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor)
        ])
    }
    
    private func configureView () {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        layer.cornerRadius = 12
    }
    
    private func configureHeader() {
        addSubview(headerViewControl)
        headerViewControl.translatesAutoresizingMaskIntoConstraints = false
        headerViewControl.addAction(UIAction { [weak self] _ in
            self?.isOpen.toggle()
        }, for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            headerViewControl.topAnchor
                .constraint(equalTo: topAnchor),
            headerViewControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerViewControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerViewControl.heightAnchor.constraint(equalToConstant: collapsedHeight)
        ])
        
        headerViewStack.translatesAutoresizingMaskIntoConstraints = false
        headerViewStack.isUserInteractionEnabled = false
        headerViewStack.alignment = .center
        headerViewStack.spacing = 16
        headerViewControl.addSubview(headerViewStack)
        
        NSLayoutConstraint.activate(
            [
                headerViewStack.topAnchor
                    .constraint(
                        equalTo: headerViewControl.topAnchor,
                        constant: edgeInsets.top
                    ),
                headerViewStack.leadingAnchor
                    .constraint(
                        equalTo: headerViewControl.leadingAnchor,
                        constant: edgeInsets.left
                    ),
                headerViewStack.trailingAnchor
                    .constraint(
                        equalTo: headerViewControl.trailingAnchor,
                        constant: edgeInsets.right
                    ),
                headerViewStack.bottomAnchor
                    .constraint(
                        equalTo: headerViewControl.bottomAnchor,
                        constant: edgeInsets.bottom
                    )
            ]
        )
        
        headerViewStack.addArrangedSubview(chevronView)
        chevronView.frame.size = CGSize()
        let image = UIImage(
            systemName: "chevron.right",
            withConfiguration: UIImage
                .SymbolConfiguration(pointSize: 20, weight: .regular)
        )
        chevronView.image = image
        chevronView.tintColor = .brandPrimary
        chevronView.contentMode = .scaleAspectFit
        chevronView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        headerViewStack.addArrangedSubview(titleLabel)
        
    }
    
    private func configureContentContainerView() {
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentContainerView)
        
        NSLayoutConstraint.activate([
            contentContainerView.topAnchor.constraint(equalTo: headerViewControl.bottomAnchor,  constant: edgeInsets.top),
            contentContainerView.leadingAnchor.constraint(equalTo: leadingAnchor,  constant: edgeInsets.left),
            contentContainerView.trailingAnchor.constraint(equalTo: trailingAnchor,  constant: edgeInsets.right),
            collapsedConstraint
        ])
    }
    
    private func render() {
        superview?.layoutIfNeeded()
        
        if isOpen {
            collapsedConstraint.isActive = false
            expandedConstraint.isActive = true
        } else {
            expandedConstraint.isActive = false
            collapsedConstraint.isActive = true
        }
        
        let degrees: CGFloat = isOpen ? 90 : 0
        let angle = degrees * .pi / 180
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.superview?.layoutIfNeeded()
            self?.onAnimate?()
            self?.chevronView.transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
