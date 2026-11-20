//
//  CardStore.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/3/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class CardStore {
    private(set) var state: LoadState<[Card]> = .idle
    private(set) var filters = SearchCardsFilters.defaultFilters
    private(set) var nextPage: String?
    private let service: CardService
    private(set) var savedCards: [Card] = []
    var savedById: [ String : Card ] {
        savedCards.reduce(into: [ String : Card ]()) {
            $0[$1.id] = $1
        }
    }
    private var paginateTask: Task<Void, Never>?
    
    init(service: CardService) {
        self.service = service
        self.savedCards = PersistenceManager.getFavoriteCards()
    }
    
    func updateFilters(_ change: (inout SearchCardsFilters) -> Void) {
        var newFilters = filters
        change(&newFilters)
        guard newFilters != filters else { return }
        filters = newFilters
        Task { await loadCards() }
        
    }
    
    func loadCards() async {
        nextPage = nil
        do {
            state = .loading
            let response = try await service.searchCards(filters: filters)
            state = .success(response.data)
            nextPage = response.nextPageQueryString
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func refresh() async {
        switch state {
        case .success(let cards):
            state = .refreshing(cards)
            do {
                let response = try await service.searchCards(
                    filters: filters,
                    invalidateCache: true
                )
                state = .success(response.data)
                nextPage = response.nextPageQueryString
            } catch {
                state = .error("Unable to refresh cards.", cards)
            }
            
        default: break
        }
    }
    
    func fetchNextPage() async {
        guard let nextPage, paginateTask == nil else { return }
        
        switch state {
        case .success(let prevCards):
            paginateTask = Task {
                state = .paginating(prevCards)
                do {
                    let response = try await service.loadNextPage(queryString: nextPage)
                    state = .success(prevCards + response.data)
                    self.nextPage = response.nextPageQueryString
                } catch {
//                    self.nextPage = nil
                    state = .success(prevCards)
                    try? await Task.sleep(for: .seconds(5))
                }
                
                paginateTask = nil
            }
            
        default: break
            
        }
    }
    
    func clearError() {
        if case let .error(_, prevData) = state {
            if let prevData {
                state = .success(prevData)
            } else {
                state = .idle
            }
        }
    }
    
    func isSaved(_ card: Card) -> Bool {
        savedById[card.id] != nil
    }
    
    func saveCard(_ card: Card) throws {
        try PersistenceManager.addFavoriteCard(card)
        savedCards = PersistenceManager.getFavoriteCards()
    }
    
    func removeCard(_ card: Card) throws {
        try PersistenceManager.removeFavoriteCard(card)
        savedCards = PersistenceManager.getFavoriteCards()
    }
}
