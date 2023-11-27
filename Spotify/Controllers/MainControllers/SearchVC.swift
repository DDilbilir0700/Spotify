//
//  SearchVC.swift

//
//  Created by Deniz Dilbilir on 21/11/2023.
//

import UIKit
import SafariServices

class SearchVC: UIViewController {
    
    private let searchVC: UISearchController = {
        let controller = UISearchController(searchResultsController: ResultsVC())
        controller.searchBar.placeholder = "Type anything you want to listen to."
        controller.searchBar.searchBarStyle = .minimal
        controller.definesPresentationContext = true
        controller.searchBar.searchTextField.backgroundColor = .white
        return controller
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8)
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(160)), subitem: item, count: 2)
            group.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
            
            return NSCollectionLayoutSection(group: group)
        }
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private var categories = [Items]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
    
    private func setupUI() {
        let myColor = UIColor(hex: "#121212")
        view.backgroundColor = myColor
        
        searchVC.searchResultsUpdater = self
        searchVC.searchBar.delegate = self
        navigationItem.searchController = searchVC
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = myColor
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.cellIdentifier)
        
        view.addSubview(collectionView)
    }
    
    private func fetchData() {
        APIManager.shared.getCategoriesForSearchVC { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let categories):
                    self?.categories = categories
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

extension SearchVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        // Handle search results update
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let resultsVC = searchVC.searchResultsController as? ResultsVC, let result = searchBar.text,
              !result.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        resultsVC.delegate = self
        
        APIManager.shared.search(with: result) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let results):
                    resultsVC.update(with: results)
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension SearchVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.cellIdentifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        let category = categories[indexPath.row]
        cell.configuration(with: CategoryCollectionViewCellVM(categoryName: category.name, categoryCoverUrl: URL(string: category.icons.first?.url ?? "")))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.selectionVibration()
        let category = categories[indexPath.row]
        let vc = CategoryVC(category: category)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SearchVC: ResultsVCDelegate {
    func didTapResult(_ result: SearchBarResults) {
        configureNavigationBarAndTabBarColors()
        
        switch result {
        case .artist(model: let model):
            openSafariViewController(with: model.external_urls["spotify"])
        case .track(model: let model):
            PlayPresent.shared.startPlaying(from: self, track: model)
        case .playlist(model: let model):
            let vc = PlaylistVC(playlist: model)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .album(model: let model):
            let vc = AlbumVC(album: model)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func configureNavigationBarAndTabBarColors() {
        let myColor = UIColor(hex: "#121212")
        navigationController?.navigationBar.barTintColor = myColor
        tabBarController?.tabBar.barTintColor = myColor
    }
    
    private func openSafariViewController(with urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            return
        }
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
}
