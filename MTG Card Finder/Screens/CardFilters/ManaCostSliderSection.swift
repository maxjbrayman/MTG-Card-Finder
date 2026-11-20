//
//  ManaCostSliderSection.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/6/26.
//

import UIKit
import RangeUISlider

class ManaCostSliderSection: UIStackView {
    static let defaultMin: Int = 0
    static let defaultMax: Int = 10

    var delegate: RangeUISliderDelegate?
    private let header = FilterSectionHeaderView()
    private let slider: ManaCostSlider!
    
    init(initialRange: (Int, Int)? = nil) {
        let range = initialRange ?? (
            ManaCostSliderSection.defaultMin,
            ManaCostSliderSection.defaultMax
        )
        
        slider = ManaCostSlider(
            minValue: ManaCostSliderSection.defaultMin,
            maxValue: ManaCostSliderSection.defaultMax,
            initialRange: range
        )
        
        super.init(frame: .zero)
        configure()
        render(minValue: CGFloat(range.0), maxValue: CGFloat(range.1))
    }
    
    private func render(minValue: CGFloat, maxValue: CGFloat) {
        let minText = getManaCostText(for: minValue)
        let maxText = getManaCostText(for: maxValue)
        header.secondaryText = minValue == maxValue ? "\(maxText)" : "\(minText) - \(maxText)"
    }
    
    private func configure() {
        slider.delegate = self
        translatesAutoresizingMaskIntoConstraints = false
        axis = .vertical
        spacing = 6
        
        header.titleText = "Mana cost"
        
        addArrangedSubview(header)
        addArrangedSubview(slider)
    }
    
    private func getManaCostText(for float: CGFloat) -> String {
        let intValue = Int(round(float))
        return getManaCostText(for: intValue)
    }
    
    private func getManaCostText(for int: Int) -> String {
        int == slider.maxValue ? "\(int)+" : "\(int)"
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension ManaCostSliderSection: RangeUISliderDelegate {
    func rangeChangeFinished(
        event: RangeUISliderChangeFinishedEvent
    ) {
        
    }
    
    func rangeIsChanging(event: RangeUISliderChangeEvent) {
        render(
            minValue: event.minValueSelected,
            maxValue: event.maxValueSelected
        )
        delegate?.rangeIsChanging?(event: event)
    }
}
