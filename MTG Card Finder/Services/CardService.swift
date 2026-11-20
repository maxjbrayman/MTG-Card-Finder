//
//  CardService.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/3/26.
//

import Foundation

protocol CardServiceImplementation {
    func searchCards(filters: SearchCardsFilters, invalidateCache: Bool) async throws -> SearchCardsDTO
}

class CardService: CardServiceImplementation {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func searchCards(filters: SearchCardsFilters, invalidateCache: Bool = false) async throws -> SearchCardsDTO {
        try await client.get(
            endpoint: "/cards/search",
            queryParams: createSearchQueryParams(from: filters),
            headers: ["Content-Type" : "application/json"],
            cachePolicy: invalidateCache ? .reloadIgnoringLocalCacheData : nil
        )
    }
    
    func loadNextPage(queryString: String) async throws -> SearchCardsDTO {
        try await client
            .get(endpoint: "/cards/search?\(queryString)", headers: ["Content-Type" : "application/json"])
    }
    
    private func createSearchQueryParams(from filters: SearchCardsFilters) -> [String:String] {
        var searchParams = [String]()
        let rarityValues = filters.rarities.map { "r:\($0.queryParamValue)" }
        let cardTypeValues = filters.cardTypes.map { "t:\($0.queryParamValue)" }
        
        if !filters.colors.isEmpty {
            var colorParam: String
            if filters.monoOnly {
                let segments = filters.colors.map { "id=\($0.queryParamValue)" }
                colorParam = "(\(segments.joined(separator: " or ")))"
            } else if filters.colorMatch == .includeAllColors {
                let segments = filters.colors.map { "id:\($0.queryParamValue)" }
                colorParam = "(\(segments.joined(separator: " or ")))"
            } else if filters.colorMatch == .exact {
                colorParam = "id=\(filters.colors.map { $0.queryParamValue }.joined(separator: ""))"
            } else {
                let segments = filters.colors.map { "id:\($0.queryParamValue)" }
                colorParam = "(\(segments.joined(separator: " or "))) id<=\(filters.colors.map { $0.queryParamValue }.joined(separator: ""))"
            }
            
            if !filters.colors.contains(.colorless) {
                colorParam += " -id:c"
            }
            
            searchParams.append(colorParam)
        }

        
        
        if !rarityValues.isEmpty {
            searchParams.append("(\(rarityValues.joined(separator: " or ")))")
        }
        
        if !cardTypeValues.isEmpty {
            searchParams.append("(\(cardTypeValues.joined(separator: " or ")))")
        }
        
        if let minManaCost = filters.minManaCost, minManaCost >= 0 {
            searchParams.append("mv>=\(minManaCost)")
        }
        
        if let maxManaCost = filters.maxManaCost {
            searchParams.append("mv<=\(maxManaCost)")
        }
        
        if let trimmedText = filters.text?.trimmingCharacters(
            in: .whitespacesAndNewlines
        ) {
            searchParams.append(trimmedText)
        }
                
        return [
            "q" : searchParams.joined(separator: " "),
            "order" : filters.sort.queryParamValue,
            "dir" : filters.sortDirection.queryParamValue
        ]
    }
}
