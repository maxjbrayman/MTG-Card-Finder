//
//  UIUtilities.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/4/26.
//

import UIKit

enum UIUtilities {
    static func makeGridFlowLayout(
        totalWidth: CGFloat,
        minCellWidth: CGFloat,
        height: CGFloat,
        edgeInsets: UIEdgeInsets? = nil,
        itemSpacing: CGFloat = 10,
        lineSpacing: CGFloat = 10
    ) -> UICollectionViewFlowLayout {
        
        let cellWidth = getCellWidth(
            totalWidth: totalWidth,
            minCellWidth: minCellWidth,
            edgeInsets: edgeInsets,
            itemSpacing: itemSpacing
        )
        
        return createFlowLayout(
            itemSize: CGSize(width: cellWidth, height: height),
            edgeInsets: edgeInsets,
            itemSpacing: itemSpacing,
            lineSpacing: lineSpacing
        )
    }
    
    static func makeGridFlowLayout(
        totalWidth: CGFloat,
        minCellWidth: CGFloat,
        heightMultiplier: CGFloat,
        edgeInsets: UIEdgeInsets? = nil,
        itemSpacing: CGFloat = 10,
        lineSpacing: CGFloat = 10
    ) -> UICollectionViewFlowLayout {
        
        let cellWidth = getCellWidth(
            totalWidth: totalWidth,
            minCellWidth: minCellWidth,
            edgeInsets: edgeInsets,
            itemSpacing: itemSpacing
        )
        let cellHeight = cellWidth * heightMultiplier
        
        return createFlowLayout(
            itemSize: CGSize(width: cellWidth, height: cellHeight),
            edgeInsets: edgeInsets,
            itemSpacing: itemSpacing,
            lineSpacing: lineSpacing
        )
    }
    
    static func getCellWidth(
        totalWidth: CGFloat,
        minCellWidth: CGFloat,
        edgeInsets: UIEdgeInsets? = nil,
        itemSpacing: CGFloat = 10
    ) -> CGFloat {
        let padding = edgeInsets == nil ? 0 : edgeInsets!.left + edgeInsets!.right
        let availableWidth = totalWidth - padding
        var maxColumns = max(1, floor(availableWidth / minCellWidth))
        var totalSpacing = itemSpacing * (maxColumns - 1)
        
        while (minCellWidth * maxColumns) + totalSpacing > availableWidth {
            if maxColumns == 1 { break }
            
            maxColumns -= 1
            totalSpacing = itemSpacing * (maxColumns - 1)
        }
        
        return floor((availableWidth - totalSpacing) / maxColumns)
    }
    
    private static func createFlowLayout(
        itemSize: CGSize,
        edgeInsets: UIEdgeInsets? = nil,
        itemSpacing: CGFloat,
        lineSpacing: CGFloat
    ) -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        if let edgeInsets { flowLayout.sectionInset = edgeInsets }
        flowLayout.itemSize = itemSize
        flowLayout.minimumInteritemSpacing = itemSpacing
        flowLayout.minimumLineSpacing = lineSpacing
                
        return flowLayout
    }
    
    static func debounce(
        delay: Duration,
        task: inout Task<Void, Never>?,
        action: @escaping @MainActor () -> Void
    ) {
        task?.cancel()
        task = Task { @MainActor in
            do {
                try await Task.sleep(for: delay)
                action()
            } catch {
                return
            }
        }
    }
}
