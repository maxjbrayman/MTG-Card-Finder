//
//  SearchCardsDTO.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/3/26.
//

import Foundation

struct SearchCardsDTO: Codable {
    let totalCards: Int
    let hasMore: Bool
    let nextPage: String?
    let data: [Card]
    
    var nextPageQueryString: String? {
        if let parts = nextPage?.removingPercentEncoding?.split(
            separator: "?"
        ) {
            return String(parts[1])
        }
        
        return nil
    }
}
