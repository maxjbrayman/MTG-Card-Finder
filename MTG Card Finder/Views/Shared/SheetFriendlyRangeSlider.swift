//
//  SheetFriendlyRangeSlider.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/10/26.
//

import UIKit
import RangeUISlider

class SheetFriendlyRangeSlider: RangeUISlider {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UIPanGestureRecognizer && gestureRecognizer.view !== self {
            return false
        }
        return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
}
