//
//  CardSortSection.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/13/26.
//

import UIKit

class CardSortSection: UIStackView {
    var sortOption: CardSort = .name {
        didSet {
            updateControlSegments()
            updateChips()
        }
    }
    var sortDirection: SortDirection {
        get { SortDirection.allCases[directionControl.selectedSegmentIndex] }
        set {
            guard let index = SortDirection.allCases.firstIndex(of: newValue) else { return }
            directionControl.selectedSegmentIndex = index
            updateHeader()
        }
    }
    var onChangeSort: ((CardSort, SortDirection) -> Void)?
    
    private let headerView = FilterSectionHeaderView()
    private let chipsView = WrappingHStack()
    private var chips: [ CardSort : CapsuleChip ] = [:]
    private let directionControl = UISegmentedControl()
    
    init() {
        super.init(frame: .zero)
        
        configureView()
        configureHeaderView()
        configureChipsView()
        configureDirectionControl()
    }
    
    private func updateChips() {
        chips.forEach { (sort, chip) in
            chip.isSelected = sort == sortOption
        }
    }
    
    private func updateControlSegments() {
        directionControl.removeAllSegments()
        let segments = SortDirection.allCases.map {
            sortOption.directionLabel(for: $0)
        }
        segments.enumerated().forEach { index, title in
            directionControl
                .insertSegment(withTitle: title, at: index, animated: false)
        }
        directionControl.selectedSegmentIndex = 0
        updateHeader()
    }
    
    private func updateHeader() {
        headerView.secondaryText = "\(sortOption.label) · \(sortOption.directionLabel(for: sortDirection))"
    }
    
    private func configureView() {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        spacing = 8
    }
    
    private func configureHeaderView() {
        addArrangedSubview(headerView)
        headerView.titleText = "Sort by"
    }
    
    private func configureChipsView() {
        addArrangedSubview(chipsView)
        chipsView.translatesAutoresizingMaskIntoConstraints = false
        CardSort.allCases.forEach { sort in
            let chip = CapsuleChip(label: sort.label)
            chip.isSelected = sort == sortOption
            chip.addAction(UIAction { [weak self] _ in
                guard let self else { return }
                self.sortOption = sort
                self.onChangeSort?(sort, .ascending)
            }, for: .touchUpInside)
            chips[sort] = chip
            chipsView.addSubview(chip)
        }
    }
    
    private func configureDirectionControl() {
        addArrangedSubview(directionControl)
        directionControl.translatesAutoresizingMaskIntoConstraints = false
        directionControl
            .addTarget(
                self,
                action: #selector(directionChanged),
                for: .valueChanged
            )
        updateControlSegments()
    }
    
    @objc private func directionChanged(_ sender: UISegmentedControl) {
        onChangeSort?(sortOption, sortDirection)
        updateHeader()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
