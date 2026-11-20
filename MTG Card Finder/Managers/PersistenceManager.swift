//
//  PersistenceManager.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/10/26.
//

import Foundation

enum PersistenceManager {
    static private let defaults = UserDefaults.standard
    
    enum Keys {
        static let favoriteCards = "favoriteCards"
    }
    
    static func getFavoriteCards() -> [Card] {
        let favorites: [Card] = (try? get(forKey: Keys.favoriteCards)) ?? []
        return favorites
    }
    
    static func addFavoriteCard(_ card: Card) throws {
        var favorites = getFavoriteCards()
        if favorites.contains(where: { $0.id == card.id }) { return }
        
        favorites.append(card)
        try save(favorites, forKey: Keys.favoriteCards)
    }
    
    static func removeFavoriteCard(_ card: Card) throws {
        let favorites = getFavoriteCards()
        let filtered = favorites.filter { $0.id != card.id }
        
        if filtered.count == favorites.count { return }
        
        try save(filtered, forKey: Keys.favoriteCards)
    }
    
    static private func get<T: Decodable>(forKey: String) throws -> T? {
        guard let data = defaults.data(forKey: forKey) else {
            return nil
        }
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
    
    static private func save(_ value: Encodable, forKey: String) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        defaults.set(data, forKey: forKey)
    }
    
    static private func delete(forKey: String) {
        defaults.removeObject(forKey: forKey)
    }
}
