//
//  CardsFiltersVC.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/5/26.
//

import UIKit
import RangeUISlider

private enum FilterSection {
    case colors, type, manaCost, rarity
}

protocol CardsFiltersVCDelegate {
    func didApplyFilters(filters: SearchCardsFilters)
    
    func didCancelFilters()
}

extension CardsFiltersVCDelegate {
    func didCancelFilters() {}
}

class CardsFiltersVC: UIViewController {
    var delegate: CardsFiltersVCDelegate?
    private let leftBarButton = UIBarButtonItem()
    private let rightBarButton = UIBarButtonItem()
    private let scrollView = ControlFriendlyScrollView<UIControl>()
    private let contentView = UIStackView()
    private let applyButton = MBButton(label: "Apply filters")
    
    private let colorsFilterSection: CardColorsFilterSection!
    private let cardTypesFilterSection: CardTypesFilterSection!
    private let cardRarityFilterSection: CardRarityFilterSection!
    private let manaCostFilterSection: ManaCostSliderSection!
    private let sortSection = CardSortSection()
    
    private var localFilters = SearchCardsFilters() {
        didSet {
            colorsFilterSection.selectedColors = localFilters.colors
            cardTypesFilterSection.selectedTypes = localFilters.cardTypes
            cardRarityFilterSection.selectedRarities = localFilters.rarities
        }
    }
    
    init(filters: SearchCardsFilters = SearchCardsFilters()) {
        self.localFilters = filters
        colorsFilterSection = CardColorsFilterSection()
        cardTypesFilterSection = CardTypesFilterSection()
        cardRarityFilterSection = CardRarityFilterSection()
        manaCostFilterSection = ManaCostSliderSection(initialRange: (
            filters.minManaCost ?? 0,
            filters.maxManaCost ?? 10
        ))
        super.init(nibName: nil, bundle: nil)
        
        configureFilters()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray6
        configureNavBar()
        configureApplyButton()
        configureScrollView()
        configureContentView()
    }
    
    private func toggleColor(_ color: CardColor) {
        let filtered = localFilters.colors.filter {
            $0 != color
        }
        if filtered.count == localFilters.colors.count {
            localFilters.colors.append(color)
        } else {
            localFilters.colors = filtered
        }
    }
    
    private func toggleMonoOnly(_ isOn: Bool) {
        localFilters.monoOnly = isOn
    }
    
    private func updateColorMatch(_ match: ColorMatch) {
        localFilters.colorMatch = match
    }
    
    private func toggleCardType(_ cardType: CardType) {
        let filtered = localFilters.cardTypes.filter {
            $0 != cardType
        }
        if filtered.count == localFilters.cardTypes.count {
            localFilters.cardTypes.append(cardType)
        } else {
            localFilters.cardTypes = filtered
        }
    }
    
    private func toggleRarity(_ rarity: CardRarity) {
        let filtered = localFilters.rarities.filter {
            $0 != rarity
        }
        if filtered.count == localFilters.rarities.count {
            localFilters.rarities.append(rarity)
        } else {
            localFilters.rarities = filtered
        }
    }
    
    private func updateSort(sort: CardSort, direction: SortDirection) {
        localFilters.sort = sort
        localFilters.sortDirection = direction
    }
    
    private func configureNavBar() {
        title = "Filters"
        
        leftBarButton.title = "Cancel"
        leftBarButton.style = .plain
        leftBarButton.target = self
        leftBarButton.action = #selector(cancel)
        leftBarButton.hidesSharedBackground = true
        leftBarButton.tintColor = .brandPrimary
        
        let leftButtonAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular)
        ]
        leftBarButton.setTitleTextAttributes(leftButtonAttributes, for: .normal)
        leftBarButton
            .setTitleTextAttributes(leftButtonAttributes, for: .highlighted)
        navigationItem.leftBarButtonItem = leftBarButton
        
        
        rightBarButton.title = "Done"
        rightBarButton.style = .plain
        rightBarButton.target = self
        rightBarButton.action = #selector(applyFilters)
        rightBarButton.hidesSharedBackground = true
        rightBarButton.tintColor = .brandPrimary
        
        let rightButtonAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        rightBarButton.setTitleTextAttributes(rightButtonAttributes, for: .normal)
        rightBarButton.setTitleTextAttributes(rightButtonAttributes, for: .highlighted)
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func configureApplyButton() {
        view.addSubview(applyButton)
        applyButton.addAction(UIAction { [weak self] _ in
            self?.applyFilters()
        }, for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            applyButton.bottomAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            applyButton.leadingAnchor
                .constraint(equalTo: view.leadingAnchor, constant: 12),
            applyButton.trailingAnchor
                .constraint(equalTo: view.trailingAnchor, constant: -12),
            applyButton.heightAnchor.constraint(equalToConstant: 54)
        ])
    }
    
    private func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
                
        NSLayoutConstraint.activate([
            scrollView.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor
                .constraint(equalTo: applyButton.topAnchor, constant: -12)
        ])
    }
    
    private func configureContentView() {
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.axis = .vertical
        contentView.isLayoutMarginsRelativeArrangement = true
        contentView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: 12,
            leading: 12,
            bottom: 12,
            trailing: 12
        )
        contentView.spacing = 20
        
        NSLayoutConstraint.activate(
            [
                contentView.topAnchor
                    .constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
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
        
        sortSection.onChangeSort = {
            [weak self] in self?.updateSort(sort: $0, direction: $1)
        }
        contentView.addArrangedSubview(sortSection)
        
        colorsFilterSection.onToggleColor = {
            [weak self] in self?.toggleColor($0)
        }
        colorsFilterSection.onToggleMonoOnly = {
            [weak self] in self?.toggleMonoOnly($0)
        }
        colorsFilterSection.onChangeColorMatch = {
            [weak self] in self?.updateColorMatch($0)
        }
        contentView.addArrangedSubview(colorsFilterSection)
        
        
        cardTypesFilterSection.onToggle = {
            [weak self] in self?.toggleCardType($0)
        }
        contentView.addArrangedSubview(cardTypesFilterSection)
        
        
        manaCostFilterSection.delegate = self
        contentView.addArrangedSubview(manaCostFilterSection)
        
        
        cardRarityFilterSection.onToggle = {
            [weak self] in self?.toggleRarity($0)
        }
        contentView.addArrangedSubview(cardRarityFilterSection)
    }
    
    private func configureFilters() {
        sortSection.sortOption = localFilters.sort
        sortSection.sortDirection = localFilters.sortDirection
        
        colorsFilterSection.selectedColors = localFilters.colors
        colorsFilterSection.colorMatch = localFilters.colorMatch
        colorsFilterSection.monoOnly = localFilters.monoOnly
        
        cardTypesFilterSection.selectedTypes = localFilters.cardTypes
        
        cardRarityFilterSection.selectedRarities = localFilters.rarities
    }
    
    @objc private func applyFilters() {
        delegate?.didApplyFilters(filters: localFilters)
        dismiss(animated: true)
    }
    
    @objc private func cancel() {
        delegate?.didCancelFilters()
        dismiss(animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CardsFiltersVC: RangeUISliderDelegate {
    func rangeChangeFinished(
        event: RangeUISliderChangeFinishedEvent
    ) {
        
    }

    func rangeIsChanging(event: RangeUISliderChangeEvent) {
        localFilters.minManaCost = Int(event.minValueSelected)
        localFilters.maxManaCost = Int(event.maxValueSelected)
    }
    
}
