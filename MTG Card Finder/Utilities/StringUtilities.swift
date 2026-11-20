//
//  StringUtilities.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/9/26.
//

enum StringUtilities {
    static func hasExactly(_ letters: String, in symbol: String) -> Bool {
        let found = symbol.lowercased().filter(\.isLetter).sorted()
        return found == letters.lowercased().sorted()
    }
}
