//
//  MBBorderedView.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/2/26.
//

import UIKit

class MBBorderedView: UIView {
    init(
        borderWidth: CGFloat,
        borderColor: CGColor = UIColor.brandPrimary.cgColor,
        cornerRadius: CGFloat = 0
    ) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor
        layer.cornerRadius = cornerRadius
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
