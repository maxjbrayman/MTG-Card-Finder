//
//  ListSectionView.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/9/26.
//

import UIKit

class ListSectionView: UIStackView {
    var sectionTitle: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue?.uppercased() }
    }
    
    private let titleLabel = UILabel()
    private let contentView = UIStackView()
    
    init() {
        super.init(frame: .zero)
        configureView()
        configureTitleLabel()
        configureContentView()
    }
    
    func addRow(_ view: UIView, with action: UIAction? = nil) {
        let wrapper = UIControl()
        if let action {
            wrapper.addAction(action, for: .touchUpInside)
            view.isUserInteractionEnabled = false
        }
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 16,
            leading: 16,
            bottom: 16,
            trailing: 16
        )
        wrapper.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor
                .constraint(equalTo: wrapper.layoutMarginsGuide.topAnchor),
            view.leadingAnchor
                .constraint(equalTo: wrapper.layoutMarginsGuide.leadingAnchor),
            view.trailingAnchor
                .constraint(equalTo: wrapper.layoutMarginsGuide.trailingAnchor),
            view.bottomAnchor
                .constraint(equalTo: wrapper.layoutMarginsGuide.bottomAnchor)
        ])
        
        if contentView.arrangedSubviews.count > 0 {
            let separator = UIView()
            wrapper.addSubview(separator)
            separator.translatesAutoresizingMaskIntoConstraints = false
            separator.backgroundColor = .separator
            NSLayoutConstraint.activate([
                separator.leadingAnchor
                    .constraint(equalTo: wrapper.leadingAnchor),
                separator.trailingAnchor
                    .constraint(equalTo: wrapper.trailingAnchor),
                separator.heightAnchor.constraint(equalToConstant: 1),
                separator.topAnchor.constraint(equalTo: wrapper.topAnchor)
            ])
        }
        
        contentView.addArrangedSubview(wrapper)
    }
    
    private func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        spacing = 4
    }
    
    private func configureTitleLabel() {
        addArrangedSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .systemGray2
    }
    
    private func configureContentView() {
        addArrangedSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 12
        contentView.axis = .vertical
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
