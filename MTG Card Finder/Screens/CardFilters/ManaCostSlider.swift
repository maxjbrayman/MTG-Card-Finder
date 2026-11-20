//
//  ManaCostSlider.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/6/26.
//

import UIKit
import RangeUISlider

class ManaCostSlider: MBRoundedCardView {
    private let slider = SheetFriendlyRangeSlider()
    let minValue: Int
    let maxValue: Int
    let initialRange: (Int, Int)
    var delegate: RangeUISliderDelegate? {
        didSet {
            slider.delegate = delegate
        }
    }
    
    init(minValue: Int = 0, maxValue: Int = 10, initialRange: (Int, Int)? = nil) {
        self.minValue = minValue
        self.maxValue = maxValue
        
        if let initialRange {
            self.initialRange = initialRange
        } else {
            self.initialRange = (minValue, maxValue)
        }
        
        super.init()
        configureSlider()
    }
    
    private func configureSlider() {
        slider.translatesAutoresizingMaskIntoConstraints = false
        addArrangedSubview(slider)
        
        slider.scaleMinValue = CGFloat(minValue)
        slider.scaleMaxValue = CGFloat(maxValue)
        slider.defaultValueLeftKnob = CGFloat(initialRange.0)
        slider.defaultValueRightKnob = CGFloat(initialRange.1)
        slider.stepIncrement = 1
        slider.rangeSelectedColor = .brandPrimary
        slider.rangeNotSelectedColor = .systemGray5
        slider.barCorners = 3
        slider.barHeight = 6
        
        slider.leftKnobColor = .systemBackground
        slider.leftKnobBorderColor = .systemGray4
        slider.leftKnobBorderWidth = 1
        slider.leftKnobWidth = 25
        slider.leftKnobHeight = 25
        slider.leftKnobCorners = 12.5
        
        slider.rightKnobColor = .systemBackground
        slider.rightKnobBorderColor = .systemGray4
        slider.rightKnobBorderWidth = 1
        slider.rightKnobWidth = 25
        slider.rightKnobHeight = 25
        slider.rightKnobCorners = 12.5
        
        NSLayoutConstraint.activate([
            slider.heightAnchor.constraint(equalToConstant: 25)
        ])
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
