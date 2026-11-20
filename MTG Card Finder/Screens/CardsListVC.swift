//
//  CardsListVC.swift
//  MTG Card Finder
//
//  Created by Max Brayman on 11/2/26.
//

import UIKit

class CardsListVC: UIViewController {
    
    nonisolated enum Section: Hashable {
        case main
    }
    
    let cardStore: CardStore
    private let header = CardsListHeader(padding: 4)
    private let refreshControl = UIRefreshControl()
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Card>!
    private var prevY: CGFloat = 0
    private var translateY: CGFloat = 0
    
    private let padding: CGFloat = 12
    private let cardSpacing: CGFloat = 8
    private let cardLineSpacing: CGFloat = 8
    private let minCardWidth: CGFloat = 120
    private let cardHeightMultiplier: CGFloat = 1 / Card.imageAspectRatio
    private let headerHeight: CGFloat = 60
    private let paginateScrollBuffer: CGFloat = 400
    private var searchFieldTask: Task<Void, Never>? = nil
    
    private var renderedSavedIds: Set<String> = []
    private var favoriteCards: [Card]
    private var favoriteCardsById: [ String : Card ] {
        favoriteCards.reduce(into: [ String : Card ]()) { dict, card in
            dict[card.id] = card
        }
    }
    private var isPaginating: Bool {
        switch cardStore.state {
        case .paginating: true
            
        default: false
        }
    }
    
    init(cardStore: CardStore) {
        self.cardStore = cardStore
        favoriteCards = PersistenceManager.getFavoriteCards()
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        configureCollectionView()
        configureHeaderView()
        configureDataSource()
        configureRefreshControl()
        
        loadCards()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favoriteCards = PersistenceManager.getFavoriteCards()
        render(state: cardStore.state)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func updateProperties() {
        super.updateProperties()
        render(state: cardStore.state)
        
        let savedIds = cardStore.savedCards.reduce(into: Set<String>()) { $0.insert($1.id) }
        let changedIds = savedIds.symmetricDifference(renderedSavedIds)
        renderedSavedIds = savedIds

        guard !changedIds.isEmpty else { return }
        var snapshot = dataSource.snapshot()
        let changedCards = snapshot.itemIdentifiers.filter { changedIds.contains($0.id) }
        snapshot.reconfigureItems(changedCards)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func render(state: LoadState<[Card]>) {
        var cards: [Card]
        var hideList: Bool
        var unavailableConfig: UIContentUnavailableConfiguration? = nil
        
        switch state {
        case .idle:
            cards = []
            hideList = true
            unavailableConfig = .empty()
        case .loading:
            cards = []
            hideList = true
            unavailableConfig = .loading()
        case .success(let newCards):
            cards = newCards
            hideList = false
        case .error(let message, let prevCards):
            cards = prevCards ?? []
            hideList = prevCards == nil
            if prevCards == nil {
                unavailableConfig = errorConfiguration(message: message)
            } else {
                showErrorAlert(message: message)
            }
        case .refreshing(let prevCards):
            cards = prevCards ?? []
            hideList = prevCards == nil
        case .paginating(let prevCards):
            cards = prevCards
            hideList = false
        }
        
        updateData(cards)
        updateVisibleFooters()
        collectionView.isHidden = hideList
        contentUnavailableConfiguration = unavailableConfig
    }
    
    private func configureHeaderView() {
        view.addSubview(header)
        header.backgroundColor = .systemBackground
        header.delegate = self
        
        NSLayoutConstraint.activate([
            header.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            header.heightAnchor.constraint(equalToConstant: headerHeight),
            header.leadingAnchor
                .constraint(equalTo: view.leadingAnchor, constant: 12),
            header.trailingAnchor
                .constraint(equalTo: view.trailingAnchor, constant: -12)
        ])
        
        let statusBarCoverView = UIView()
        view.addSubview(statusBarCoverView)
        statusBarCoverView.translatesAutoresizingMaskIntoConstraints = false
        statusBarCoverView.backgroundColor = .systemBackground
        
        NSLayoutConstraint.activate([
            statusBarCoverView.topAnchor.constraint(equalTo: view.topAnchor),
            statusBarCoverView.leadingAnchor
                .constraint(equalTo: view.leadingAnchor),
            statusBarCoverView.trailingAnchor
                .constraint(equalTo: view.trailingAnchor),
            statusBarCoverView.bottomAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
    }
    
    private func configureCollectionView() {
        let layout = UIUtilities.makeGridFlowLayout(
            totalWidth: view.bounds.width,
            minCellWidth: minCardWidth,
            heightMultiplier: cardHeightMultiplier,
            edgeInsets: UIEdgeInsets(
                top: 0,
                left: padding,
                bottom: padding,
                right: padding
            ),
            itemSpacing: cardSpacing,
            lineSpacing: cardLineSpacing
        )
        layout.footerReferenceSize = CGSize(width: view.bounds.width, height: 50)
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: layout
        )
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .interactive
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor
                .constraint(equalTo: view.trailingAnchor)
        ])
        
        collectionView
            .register(
                CardPreviewCell.self,
                forCellWithReuseIdentifier: CardPreviewCell.reuseId
            )
        
        collectionView
            .register(
                PaginationFooterView.self,
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                withReuseIdentifier: PaginationFooterView.reuseIdentifier
            )
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Card>(
            collectionView: collectionView
        ) { [weak self] (collectionView, indexPath, card) in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: CardPreviewCell.reuseId,
                for: indexPath
            ) as! CardPreviewCell
            
            let isSaved = self?.favoriteCardsById[card.id] != nil
            cell.set(card: card, isSaved: isSaved)
            return cell
        }
        
        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionFooter else { return nil }
            let footer = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: PaginationFooterView.reuseIdentifier,
                for: indexPath
            ) as! PaginationFooterView
            
            if case .paginating = self?.cardStore.state {
                footer.isVisible = true
            } else {
                footer.isVisible = false
            }

            return footer
        }
    }
    
    private func configureRefreshControl() {
        collectionView.alwaysBounceVertical = true
        refreshControl.tintColor = .brandPrimary
        refreshControl
            .addTarget(
                self,
                action: #selector(handleRefresh),
                for: .valueChanged
            )
        collectionView.contentInset.top = headerHeight
        collectionView.verticalScrollIndicatorInsets.top = headerHeight
        collectionView.refreshControl = refreshControl
    }
    
    private func updateData(_ cards: [Card]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Card>()
        snapshot.appendSections([.main])
        snapshot.appendItems(cards)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    private func updateVisibleFooters() {
        for case let footer as PaginationFooterView in
            collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter) {
            footer.isVisible = isPaginating
        }
    }
    
    private func loadCards() {
        Task {
            await cardStore.loadCards()
        }
    }
    
    private func loadMoreCards() {
        Task {
            await cardStore.fetchNextPage()
        }
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "Something went wrong",
            message: message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default) { [weak self] _ in
            self?.cardStore.clearError()
        })
            
        present(alert, animated: true)
    }
    
    private func errorConfiguration(message: String) -> UIContentUnavailableConfiguration {
        var config = UIContentUnavailableConfiguration.empty()
        config.image = UIImage(systemName: "exclamationmark.triangle")
        config.text = "Couldn't Load Cards"

        var button = UIButton.Configuration.filled()
        button.title = "Try Again"
        button.image = UIImage(systemName: "arrow.clockwise")
        button.imagePadding = 10
        button.cornerStyle = .medium
        button.baseBackgroundColor = .brandPrimary
        button.baseForegroundColor = .brandPrimaryLite
        button.preferredSymbolConfigurationForImage =
            UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        config.button = button
        config.buttonProperties.primaryAction = UIAction { [weak self] _ in
            Task {
                await self?.cardStore.loadCards()
            }
        }

        return config
    }
    
    @objc private func handleRefresh() {
        Task {
            await cardStore.refresh()
            refreshControl.endRefreshing()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CardsListVC: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        if offset < 0 || offset > scrollView.contentSize.height - scrollView.frame.height { return }
        
        let isAtBottom = offset + scrollView.frame.height > scrollView.contentSize.height - paginateScrollBuffer
        let isScrollingDown = offset > prevY
        if isAtBottom && isScrollingDown { loadMoreCards() }
        
        let delta = offset - prevY
        prevY += delta
        translateY = max(0, min(translateY + delta, headerHeight))
        header.transform = CGAffineTransform(translationX: 0, y: -translateY)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let card = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let vc = CardDetailsVC(card: card, cardStore: cardStore)
        vc.title = card.name
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension CardsListVC: CardsListHeaderDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func filtersButtonTapped() {
        let vc = CardsFiltersVC(filters: cardStore.filters)
        vc.delegate = self
        let nc = UINavigationController(rootViewController: vc)
        
        present(nc, animated: true)
    }
    
    func searchTextDidChange(textField: UISearchTextField) {
        AsyncUtilities
            .debounce(
                delay: .milliseconds(300),
                task: &searchFieldTask
            ) { [weak self] in
                self?.cardStore.updateFilters {
                    $0.text = textField.text
                }
            }
    }
}

extension CardsListVC: CardsFiltersVCDelegate {
    func didApplyFilters(filters: SearchCardsFilters) {
        cardStore.updateFilters {
            let text = $0.text
            $0 = filters
            $0.text = text
        }
    }
}

private class PaginationFooterView: UICollectionReusableView {
    private let label = UILabel()
    private let indicator = UIActivityIndicatorView()
    static let reuseIdentifier = "footerLabelId"
    var isVisible: Bool {
        get { indicator.isAnimating }
        set {
            newValue ? indicator.startAnimating() : indicator.stopAnimating()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        isVisible = false
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
