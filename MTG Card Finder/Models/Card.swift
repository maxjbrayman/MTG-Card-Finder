//
//  Card.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/3/26.
//

import Foundation

struct CardImageURIs: Codable {
    let png: String
}

struct CardPurchaseURIs: Codable {
    let tcgplayer: String?
    let cardmarket: String?
    let cardhoarder: String?
}

struct CardFace: Codable {
    let cmc: Int?
    let colors: [String]?
    let imageUris: CardImageURIs?
    let manaCost: String?
    let name: String
    let oracleText: String?
    let power: String?
    let toughness: String?
    let typeLine: String?
}

nonisolated struct Card: Codable, Hashable {
    let id: String
    let name: String
    let releasedAt: String
    let imageUris: CardImageURIs?
    let manaCost: String?
    let cmc: Int?
    let colors: [String]? // mana cost colors
    let colorIdentity: [String] // includes colors in card details
    let setName: String
    let rarity: String
    let typeLine: String?
    let power: String?
    let toughness: String?
    let oracleText: String?
    let purchaseUris: CardPurchaseURIs?
    let cardFaces: [CardFace]?
    
    var firstFace: CardFace? { cardFaces?.first }
    
    var displayCmc: Int { cmc ?? firstFace?.cmc ?? 0 }
    var displayColors: [String]? { colors ?? firstFace?.colors }
    var displayImageUris: CardImageURIs? { imageUris ?? firstFace?.imageUris }
    var displayManaCost: String? { manaCost ?? firstFace?.manaCost }
    var displayOracleText: String? { oracleText ?? firstFace?.oracleText }
    var displayPower: String? { power ?? firstFace?.power }
    var displayToughness: String? { toughness ?? firstFace?.toughness }
    var displayTypeLine: String? { typeLine ?? firstFace?.typeLine }
    
    var isDoubleSided: Bool {
        cardFaces != nil && imageUris == nil
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var releaseDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.date(from: releasedAt)
    }
    
    var releaseDateFormatted: String? {
        releaseDate?.formatted(.dateTime.month().day().year())
    }
}

extension Card {
    static let imageAspectRatio: CGFloat = 745 / 1040
}
