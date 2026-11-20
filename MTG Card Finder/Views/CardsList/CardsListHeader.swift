//
//  CardsListHeader.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/4/26.
//

import UIKit

protocol CardsListHeaderDelegate: UISearchTextFieldDelegate {
    func filtersButtonTapped()
    
    func searchTextDidChange(textField: UISearchTextField)
}

extension CardsListHeaderDelegate {
    func filtersButtonTapped() {}
    
    func searchTextDidChange(textField: UISearchTextField) {}
}

class CardsListHeader: UIStackView {
    private let padding: CGFloat
    private let searchField = UISearchTextField()
    private let filtersButton = UIButton()
    var delegate: CardsListHeaderDelegate? = nil {
        didSet {
            searchField.delegate = delegate
        }
    }
    
    init(padding: CGFloat = 0) {
        self.padding = padding
        super.init(frame: .zero)
        
        configureView()
        configureSearchField()
        configureFiltersButton()
    }
    
    private func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        spacing = 4
        isLayoutMarginsRelativeArrangement = true
        insetsLayoutMarginsFromSafeArea = false
        directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: padding, leading: padding, bottom: padding, trailing: padding
        )
    }
    
    private func configureSearchField() {
        addArrangedSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.backgroundColor = .systemGray5
        searchField.borderStyle = .none
        searchField.layer.cornerRadius = 8.0
        searchField.layer.masksToBounds = true
        searchField.returnKeyType = .go
        searchField.addTarget(self, action: #selector(handleChangeText), for: .editingChanged)
    }
    
    private func configureFiltersButton() {
        addArrangedSubview(filtersButton)
        filtersButton.translatesAutoresizingMaskIntoConstraints = false
        
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "slider.horizontal.3")
        config.baseForegroundColor = .brandPrimary
        config.baseForegroundColor = .brandPrimary
        config.background.backgroundColor = .systemGray5
        config.background.cornerRadius = 8
        config.cornerStyle = .fixed
        
        filtersButton.configuration = config
        filtersButton.addAction(UIAction { [weak self] _ in
            self?.delegate?.filtersButtonTapped()
        }, for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            filtersButton.widthAnchor
                .constraint(equalTo: filtersButton.heightAnchor)
        ])
    }
    
    @objc private func handleChangeText() {
        delegate?.searchTextDidChange(textField: searchField)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
