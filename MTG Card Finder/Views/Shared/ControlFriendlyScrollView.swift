//
//  ControlFriendlyScrollView.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/10/26.
//

import UIKit

class ControlFriendlyScrollView<T: UIView>: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is T { return true }
        return super.touchesShouldCancel(in: view)
    }
}
