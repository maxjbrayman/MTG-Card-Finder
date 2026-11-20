//
//  CardColorsFilterSection.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/6/26.
//

import UIKit

class CardColorsFilterSection: UIStackView {
    var selectedColors: [CardColor] {
        get { picker.selectedColors }
        set {
            picker.selectedColors = newValue
            render()
        }
    }
    var colorMatch: ColorMatch {
        get { ColorMatch.allCases[colorMatchControl.selectedSegmentIndex] }
        set {
            guard let index = ColorMatch.allCases.firstIndex(of: newValue) else { return }
            colorMatchControl.selectedSegmentIndex = index
            render()
        }
    }
    var monoOnly: Bool {
        get { monoOnlySwitch.isOn }
        set {
            monoOnlySwitch.setOn(newValue, animated: true)
            render()
        }
    }
    
    var onToggleColor: ((CardColor) -> Void)? {
        didSet {
            picker.onToggle = { [weak self] color in
                self?.onToggleColor?(color)
            }
        }
    }
    
    var onChangeColorMatch: ((ColorMatch) -> Void)? = nil
    var onToggleMonoOnly: ((Bool) -> Void)? = nil
    
    private let header = FilterSectionHeaderView()
    private let picker = CardColorsPicker()
    private let colorDetailsSection = MBRoundedCardView()
    private let colorMatchLabel = UILabel()
    private let colorMatchControl = UISegmentedControl(
        items: ColorMatch.allCases.map { $0.label }
    )
    private let monoOnlySection = UIStackView()
    private let monoOnlySectionLabel = UILabel()
    private let monoOnlySwitch = UISwitch()
    private let colorMatchMessageLabel = UILabel()
    
    private var colorMatchMessage: String {
        if !monoOnly && selectedColors.isEmpty {
            return "All cards."
        }
        
        if monoOnly {
            let colors = selectedColors.map { "only \($0.label)" }
            if colors.isEmpty {
                return "All mono-colored cards."
            }
            return "Cards that are \(colors.joined(separator: " or "))."
        }
        
        let colors = selectedColors.map { $0.label }
        switch colorMatch {
        case .includeAllColors:
            return "All cards that contain \(colors.joined(separator: " or "))."
        case .includeOnlySelected:
            return "All cards containing only \(colors.joined(separator: " or ")). Cards containing any other colors are excluded."
        case .exact:
            return "All cards containing exactly \(colors.joined(separator: " and "))."
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        configure()
        configureColorDetailsSection()
        configureColorMatchMessageLabel()
        render()
    }
    
    private func render() {
        header.secondaryText = selectedColors.isEmpty ? nil : "\(selectedColors.count) selected"
        colorMatchMessageLabel.text = colorMatchMessage
        colorMatchControl.isEnabled = !monoOnlySwitch.isOn
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        spacing = 6
        
        header.titleText = "Color"
        
        addArrangedSubview(header)
        addArrangedSubview(picker)
    }
    
    private func configureColorDetailsSection() {
        addArrangedSubview(colorDetailsSection)
        colorDetailsSection.axis = .vertical
        colorDetailsSection.alignment = .fill
        
        colorMatchLabel.text = "Match colors"
        colorMatchLabel.translatesAutoresizingMaskIntoConstraints = false
        colorDetailsSection.addArrangedSubview(colorMatchLabel)
        
        colorDetailsSection.addArrangedSubview(colorMatchControl)
        colorMatchControl.selectedSegmentIndex = 0
        colorMatchControl.translatesAutoresizingMaskIntoConstraints = false
        colorMatchControl
            .addTarget(
                self,
                
                action: #selector(didSelectColorMatch),
                for: .valueChanged
            )
        
        monoOnlySection.translatesAutoresizingMaskIntoConstraints = false
        monoOnlySection.distribution = .equalSpacing
        
        monoOnlySectionLabel.translatesAutoresizingMaskIntoConstraints = false
        monoOnlySectionLabel.text = "Mono-colored only"
        monoOnlySection.addArrangedSubview(monoOnlySectionLabel)
        
        monoOnlySwitch.translatesAutoresizingMaskIntoConstraints = false
        monoOnlySwitch
            .addTarget(
                self,
                action: #selector(didToggleMonoOnly),
                for: .valueChanged
            )
        monoOnlySection.addArrangedSubview(monoOnlySwitch)
        
        colorDetailsSection.addArrangedSubview(monoOnlySection)
    }
    
    private func configureColorMatchMessageLabel() {
        addArrangedSubview(colorMatchMessageLabel)
        colorMatchMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        colorMatchMessageLabel.text = colorMatchMessage
        colorMatchMessageLabel.textColor = .systemGray2
        colorMatchMessageLabel.numberOfLines = 0
    }

    @objc private func didSelectColorMatch(_ sender: UISegmentedControl) {
        onChangeColorMatch?(ColorMatch.allCases[sender.selectedSegmentIndex])
        render()
    }
    
    @objc private func didToggleMonoOnly(_ sender: UISwitch) {
        onToggleMonoOnly?(sender.isOn)
        render()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
