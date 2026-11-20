//
//  CardUtilities.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/16/26.
//

import Foundation
import UIKit

enum CardUtilities {
    static func getManaCostAttributedText(for text: String?, fontSize: CGFloat = 18) -> NSMutableAttributedString? {
        guard let text else { return nil }
        
        let attributedText = NSMutableAttributedString(string: text)
        let symbolRanges = getManaSymbolRanges(for: text)
        symbolRanges.reversed().forEach { range in
            let nsText = text as NSString
            let symbol = nsText.substring(with: range)
                .replacingOccurrences(of: "{", with: "")
                .replacingOccurrences(of: "}", with: "")
            guard let imageName = ManaSymbols.imageDict[symbol],
                  let image = UIImage(named: imageName) else { return }
            
            let attachment = NSTextAttachment()
            attachment.image = image
            
            let imageHeight = fontSize
            let aspectRatio = image.size.width / image.size.height
            let targetWidth = imageHeight * aspectRatio
            
            attachment.bounds = CGRect(x: 0, y: -4, width: targetWidth, height: imageHeight)
            
            let imageString = NSAttributedString(attachment: attachment)
            attributedText.replaceCharacters(in: range, with: imageString)
        }
        
        return attributedText
    }
    
    static private func getManaSymbolRanges(for text: String) -> [NSRange] {
        let ranges = text.matches(of: /\{[^{}]+\}/).map(\.range)
        return ranges.map { range in
            NSRange(range, in: text)
        }
    }
}

