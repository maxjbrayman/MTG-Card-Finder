//
//  CapsuleChip.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/13/26.
//

import UIKit

class CapsuleChip: UIButton {
    override var isSelected: Bool {
        didSet {
            render()
        }
    }
    
    init(label: String) {
        super.init(frame: .zero)
        configure(label: label)
        render()
    }
    
    private func render() {
        layer.borderColor = isSelected ? nil : UIColor.systemGray3.cgColor
        layer.borderWidth = isSelected ? 0 : 2
        tintColor = isSelected ? .brandPrimary : .systemBackground
    }
    
    private func configure(label: String) {
        translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.filled()
        config.cornerStyle = .capsule
        config.title = label
        configuration = config
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
