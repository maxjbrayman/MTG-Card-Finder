//
//  WrappingHStack.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/6/26.
//

import UIKit

private struct Row {
    var indices: [Int]
}

enum WrappingAlignment {
    case leading, trailing, center
}

class WrappingHStack: UIView {
    var itemSpacing: CGFloat {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    var rowSpacing: CGFloat { didSet { setNeedsLayout() } }
    var forceWrapIndices: Set<Int> = Set() {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }
    private var alignment: WrappingAlignment

    private var contentHeight: CGFloat = 0

    init(
        itemSpacing: CGFloat = 4,
        rowSpacing: CGFloat = 4,
        alignment: WrappingAlignment = .leading,
    ) {
        self.itemSpacing = itemSpacing
        self.rowSpacing = rowSpacing
        self.alignment = alignment
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // Natural width = everything on one row; height = whatever the last layout produced
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: contentHeight)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    
        var rows = [[UIView]]()
        var currentRow = [UIView]()
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0

        for (index, view) in subviews.enumerated() {
            var size = measuredSize(of: view)
            size.width = min(size.width, bounds.width) // don't let one item exceed the row

            if x > 0 && (
                x + size.width > bounds.width || forceWrapIndices.contains(index)
            ) {
                x = 0
                y += rowHeight + rowSpacing
                rowHeight = 0
                rows.append(currentRow)
                currentRow = []
            }
            view.frame = CGRect(origin: CGPoint(x: x, y: y), size: size)
            x += size.width + itemSpacing
            rowHeight = max(rowHeight, size.height)
            currentRow.append(view)
        }
        
        if !currentRow.isEmpty { rows.append(currentRow) }

        let newHeight = subviews.isEmpty ? 0 : y + rowHeight
        if newHeight != contentHeight {
            contentHeight = newHeight
            invalidateIntrinsicContentSize()
        }
        
        if alignment == .leading { return }
        
        rows.forEach { row in
            guard let lastView = row.last else { return }
            
            let remainingSpace = bounds.width - lastView.frame.maxX
            let dx = alignment == .trailing ? remainingSpace : remainingSpace / 2
            row.forEach { view in
                view.frame = CGRect(
                    x: view.frame.minX + dx,
                    y: view.frame.minY,
                    width: view.frame.width,
                    height: view.frame.height
                )
            }
        }
    }

    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    override func willRemoveSubview(_ subview: UIView) {
        super.willRemoveSubview(subview)
        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }
    
    private func measuredSize(of view: UIView) -> CGSize {
        // Respect an explicit frame size if the caller set one
        if view.bounds.size != .zero {
            return view.bounds.size
        }
        // Otherwise ask the view for its natural size (labels, buttons, etc.)
        return view.sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
    }
}
