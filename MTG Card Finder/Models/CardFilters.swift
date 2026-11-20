//
//  CardFilters.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/5/26.
//

import UIKit

enum CardColor: String, CaseIterable {
    case red = "R"
    case blue = "U"
    case green = "G"
    case white = "W"
    case black = "B"
    case colorless = "C"
    
    var queryParamValue: String {
        self.rawValue.lowercased()
    }
    
    var label: String {
        switch self {
        case .red:
            "Red"
        case .blue:
            "Blue"
        case .green:
            "Green"
        case .white:
            "White"
        case .black:
            "Black"
        case .colorless:
            "Colorless"
        }
    }
    
    var color: UIColor {
        switch self {
        case .red:
                .redMana
        case .blue:
                .blueMana
        case .green:
                .greenMana
        case .white:
                .whiteMana
        case .black:
                .blackMana
        case .colorless:
                .colorlessMana
        }
    }
    
    var imageName: String? {
        ManaSymbols.imageDict[rawValue]
    }
}

enum CardType: CaseIterable {
    case creature, instant, sorcery, land, artifact, enchantment, planeswalker, battle
    
    var queryParamValue: String {
        switch self {
        case .creature:
            "creature"
        case .instant:
            "instant"
        case .sorcery:
            "sorcery"
        case .land:
            "land"
        case .artifact:
            "artifact"
        case .enchantment:
            "enchantment"
        case .planeswalker:
            "planeswalker"
        case .battle:
            "battle"
        }
    }
    
    var label: String {
        switch self {
        case .creature:
            "Creature"
        case .instant:
            "Instant"
        case .sorcery:
            "Sorcery"
        case .land:
            "Land"
        case .artifact:
            "Artifact"
        case .enchantment:
            "Enchantment"
        case .planeswalker:
            "Planeswalker"
        case .battle:
            "Battle"
        }
    }
    
    static func getType(from string: String?) -> CardType? {
        guard let string else { return nil }
        return allCases
            .first(where: { string.lowercased().contains($0.queryParamValue) })
    }
}

enum CardRarity: CaseIterable {
    case common, uncommon, rare, mythic
    
    var queryParamValue: String {
        switch self {
        case .common:
            "common"
        case .uncommon:
            "uncommon"
        case .rare:
            "rare"
        case .mythic:
            "mythic"
        }
    }
    
    var label: String {
        switch self {
        case .common:
            "Common"
        case .uncommon:
            "Uncommon"
        case .rare:
            "Rare"
        case .mythic:
            "Mythic"
        }
    }
    
    var color: UIColor {
        switch self {
        case .common:
                .commonCard
        case .uncommon:
                .uncommonCard
        case .rare:
                .rareCard
        case .mythic:
                .mythicCard
        }
    }
}

enum CardSort: CaseIterable {
    case manaCost
    case rarity
    case name
    case releaseYear
    case set
    case price
    
    var label: String {
        switch self {
        case .manaCost:
            "Mana cost"
        case .rarity:
            "Rarity"
        case .name:
            "Name"
        case .releaseYear:
            "Release year"
        case .set:
            "Set"
        case .price:
            "Price"
        }
    }
    
    var queryParamValue: String {
        switch self {
        case .manaCost:
            "cmc"
        case .rarity:
            "rarity"
        case .name:
            "name"
        case .releaseYear:
            "released"
        case .set:
            "set"
        case .price:
            "usd"
        }
    }
    
    func directionLabel(for direction: SortDirection) -> String {
        switch self {
        case .manaCost:
            direction == .ascending ? "Low to high" : "High to low"
        case .rarity:
            direction == .ascending ? "Common first" : "Mythic first"
        case .name:
            direction == .ascending ? "A to Z" : "Z to A"
        case .releaseYear:
            direction == .ascending ? "Oldest first" : "Newest first"
        case .set:
            direction == .ascending ? "Ascending" : "Descending"
        case .price:
            direction == .ascending ? "Low to high" : "High to low"
        }
    }
}

enum SortDirection: CaseIterable {
    case ascending
    case descending
    
    var queryParamValue: String {
        switch self {
        case .ascending:
            "asc"
        case .descending:
            "desc"
        }
    }
}

enum ColorMatch: CaseIterable {
    case includeAllColors
    case includeOnlySelected
    case exact
    
    var label: String {
        switch self {
        case .includeAllColors:
            "All colors"
        case .includeOnlySelected:
            "Selected only"
        case .exact:
            "Exact match"
        }
    }
}

struct SearchCardsFilters: Hashable {
    var colors: [CardColor] = []
    var colorMatch: ColorMatch = .includeAllColors
    var monoOnly = false
    var minManaCost: Int?
    var maxManaCost: Int?
    var text: String?
    var cardTypes: [CardType] = []
    var rarities: [CardRarity] = []
    var sort: CardSort = .name
    var sortDirection: SortDirection = .ascending
    
    static func == (lhs: SearchCardsFilters, rhs: SearchCardsFilters) -> Bool {
        lhs.minManaCost == rhs.minManaCost &&
        lhs.maxManaCost == rhs.maxManaCost &&
        lhs.text == rhs.text &&
        lhs.sort == rhs.sort &&
        lhs.sortDirection == rhs.sortDirection &&
        lhs.colorMatch == rhs.colorMatch &&
        lhs.monoOnly == rhs.monoOnly &&
        Set(lhs.colors) == Set(rhs.colors) &&
        Set(lhs.cardTypes) == Set(rhs.cardTypes) &&
        Set(lhs.rarities) == Set(rhs.rarities)
    }
    
    static var defaultFilters = SearchCardsFilters(
        minManaCost: 0,
        sort: .name,
        sortDirection: .ascending
    )
}
