//
//  MBButton.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/2/26.
//

import UIKit

enum MBButtonStyle {
    case primary
    case outline
    
    var backgroundColor: UIColor {
        switch self {
        case .primary:
                .brandPrimary
        case .outline:
                .white
        }
    }
    
    var foregroundColor: UIColor {
        switch self {
        case .primary:
                .white
        case .outline:
                .brandPrimary
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .primary:
            0
        case .outline:
            2
        }
    }
    
    var borderColor: UIColor? {
        switch self {
        case .primary:
            nil
        case .outline:
                .brandPrimary
        }
    }
}

class MBButton: UIButton {
    init(label: String, style: MBButtonStyle = .primary) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        setTitle(label, for: .normal)
        setTitleColor(style.foregroundColor, for: .normal)
        backgroundColor = style.backgroundColor
        
        layer.cornerRadius = 8
        layer.borderWidth = style.borderWidth
        layer.borderColor = style.borderColor?.cgColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
