//
//  SavedCardsVC.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/2/26.
//

import UIKit

class SavedCardsVC: UIViewController {
    private let cardStore: CardStore
    private let emptyResults = EmptySavedCards()
    private let resultsView = SavedCardsListView()
    
    private let padding: CGFloat = 12
    private let cardSpacing: CGFloat = 8
    private let cardLineSpacing: CGFloat = 8
    private let minCardWidth: CGFloat = 120
    private let cardHeightMultiplier: CGFloat = 1 / Card.imageAspectRatio
    
    init(cardStore: CardStore) {
        self.cardStore = cardStore
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureEmptyResults()
        configureResultsView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "Saved"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func updateProperties() {
        if cardStore.savedCards.isEmpty {
            resultsView.isHidden = true
            emptyResults.isHidden = false
        } else {
            emptyResults.isHidden = true
            resultsView.isHidden = false
            resultsView.cards = cardStore.savedCards
        }
    }
    
    private func configureEmptyResults() {
        view.addSubview(emptyResults)
        
        emptyResults.onSearchTapped = { [weak self] in
            self?.tabBarController?.selectedIndex = AppTab.search.tag
        }
        
        NSLayoutConstraint.activate([
            emptyResults.centerYAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyResults.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyResults.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureResultsView() {
        view.addSubview(resultsView)
        
        resultsView.translatesAutoresizingMaskIntoConstraints = false
        resultsView.onTapCard = onTapCard(_:)
        
        NSLayoutConstraint.activate([
            resultsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            resultsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            resultsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            resultsView.bottomAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func onTapCard(_ card: Card) {
        let vc = CardDetailsVC(card: card, cardStore: cardStore)
        navigationController?.pushViewController(vc, animated: true)
    }
}
