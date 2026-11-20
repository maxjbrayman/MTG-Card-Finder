//
//  MainTabController.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 10/30/26.
//

import UIKit

enum AppTab: CaseIterable {
    case saved
    case search
    
    var tag: Int {
        switch self {
        case .saved:
            0
        case .search:
            1
        }
    }
    
    var title: String {
        switch self {
        case .saved:
            "My Cards"
        case .search:
            "Search"
        }
    }
    
    var icon: String {
        switch self {
        case .saved:
            "bookmark"
        case .search:
            "magnifyingglass"
        }
    }
}

class MainTabController: UITabBarController {
    let cardStore: CardStore
    
    init(cardStore: CardStore) {
        self.cardStore = cardStore
        super.init(nibName: nil, bundle: nil)
        
        self.tabBar.tintColor = .brandPrimary
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func createNavigationController(for tab: AppTab) -> UINavigationController {
        let vc = switch tab {
        case .saved:
            SavedCardsVC(cardStore: cardStore)
        case .search:
            CardsListVC(cardStore: cardStore)
        }
        
        let tabBarItem = UITabBarItem(
            title: nil,
            image: UIImage(systemName: tab.icon),
            tag: tab.tag
        )
        
        vc.tabBarItem = tabBarItem
        
        return UINavigationController(rootViewController: vc)
    }
    
    private func setupTabs() {
        self.viewControllers = AppTab.allCases.map {
            createNavigationController(for: $0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
