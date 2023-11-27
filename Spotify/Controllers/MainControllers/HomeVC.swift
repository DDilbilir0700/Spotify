//
//  HomeVC.swift
//
//  Created by Deniz Dilbilir on 21/11/2023.
//

import UIKit

enum HomeSection {
    case newReleases(viewModels: [NewReleasesCellVM])
    case featuredPlaylists(viewModels: [FeaturedPlaylistCellVM])
    case recommendedTracks(viewModels: [RecommendedTracksCellVM])
    
    var title: String {
        switch self {
        case .newReleases:
            return "New released albums for you"
        case .featuredPlaylists:
            return "Your top mixes"
        case .recommendedTracks:
           return "Recommended for today"
        }
    }
}


class HomeVC: UIViewController {
    
    
    private var albums: [Album] = []
    private var playlists: [Playlist] = []
    private var tracks: [Tracks] = []
    
    
    private var collectionView: UICollectionView?
    
    private var homeSections = [HomeSection]()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("HomeVC - viewDidLoad")

        self.title = ""
        self.navigationItem.title = ""
       
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear.badge"), style: .done, target: self, action: #selector(touchSettings))
        let spinner = createSpinner()
        collectionViewConfiguration()
        view.addSubview(spinner)
        fetchData()
        addTapGesture()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let collectionView = collectionView {
            collectionView.frame = view.bounds
        }
    }
        private func addTapGesture() {
            let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didPress(_:)))
            collectionView?.isUserInteractionEnabled = true
            collectionView?.addGestureRecognizer(gestureRecognizer)
        }
    @objc func didPress(_ gesture: UILongPressGestureRecognizer) {
        
        guard gesture.state == .began else {
            return
        }
        
        let gestureLocation = gesture.location(in: collectionView)
        print("gestureLocation: \(gestureLocation)")
        
        guard let indexPath = collectionView?.indexPathForItem(at: gestureLocation), indexPath.section == 2 else {
            return
        }
        let gestureModel = tracks[indexPath.row]
        
        let actionSheet = UIAlertController(title: gestureModel.name, message: "Would you like to add this song to your playlist?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Add to Playlist", style: .default, handler: { [weak self] _ in
            DispatchQueue.main.async {
                let vc = LibraryPlaylistVC()
                vc.handler = { playlist in
                    APIManager.shared.addsongsToPlaylists(track: gestureModel, playlist: playlist) { success in
                        print("Successfully added to playlist: \(success)")
                    }
                    
                }
                vc.title = "Select Playlist"
                self?.present(UINavigationController(rootViewController: vc), animated: true, completion: nil)
            }
        }))
        present(actionSheet, animated: true)
    }
    

    private func createSpinner() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView()
        spinner.hidesWhenStopped = true
        return spinner
    }
    
    

    private func collectionViewConfiguration() {
       
           collectionView = UICollectionView(
               frame: .zero,
               collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ -> NSCollectionLayoutSection? in
                   return HomeVC.createSectionLayout(section: sectionIndex)
               }
           )
        
        collectionView?.register(CustomCell.self, forCellWithReuseIdentifier: "CustomCell")
        collectionView?.register(NewReleasesCollectionViewCell.self, forCellWithReuseIdentifier: NewReleasesCollectionViewCell.cellIdentifier)
        collectionView?.register(FeaturedPlaylistsCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistsCollectionViewCell.cellIdentifier)
        collectionView?.register(RecommendedTracksCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTracksCollectionViewCell.identifier)
        collectionView?.register(TitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderCollectionReusableView.cellIdentifier)
        
        
           collectionView?.dataSource = self
           collectionView?.delegate = self
        

        let myColor = UIColor(hex: "#121212")
        collectionView?.backgroundColor = myColor
           
           if let collectionView = collectionView {
               view.addSubview(collectionView)
           }
       }

    
    
       static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
           let suplementaryItems = [
               NSCollectionLayoutBoundarySupplementaryItem(
                   layoutSize: NSCollectionLayoutSize(
                       widthDimension: .fractionalWidth(1),
                       heightDimension: .absolute(60)
                   ),
                   elementKind: UICollectionView.elementKindSectionHeader,
                   alignment: .top
               ) 
           ]
                                                                                 
           switch section {
        case 0:
               let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                      let item = NSCollectionLayoutItem(layoutSize: itemSize)
                      item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

                     
                      let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
                      
                      let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(400)), subitem: item, count: 3)
                      let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(400)), subitem: verticalGroup, count: 1)
                     

                     
                      let section = NSCollectionLayoutSection(group: horizontalGroup)
                      section.orthogonalScrollingBehavior = .groupPaging
                      section.boundarySupplementaryItems = suplementaryItems
                      return section
        
        case 1:
               let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(200))
                      let item = NSCollectionLayoutItem(layoutSize: itemSize)
                      item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

                     
                      let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
               
               let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400)), subitem: item, count: 2)
                     
               let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400)), subitem: verticalGroup, count: 1)
                     

                     
                      let section = NSCollectionLayoutSection(group: horizontalGroup)
                      section.orthogonalScrollingBehavior = .continuous
                      section.boundarySupplementaryItems = suplementaryItems
                      return section
            
        case 2:
               let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                      let item = NSCollectionLayoutItem(layoutSize: itemSize)
                      item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

                     
                      let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
                      
                    
                      let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(80)), subitem: item, count: 1)
                     

                     
                      let section = NSCollectionLayoutSection(group: group)
                      section.boundarySupplementaryItems = suplementaryItems

                      return section
            
        default:
               let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
                      let item = NSCollectionLayoutItem(layoutSize: itemSize)
                      item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

                     
                      let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
                      
                      let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(400)), subitem: item, count: 1)
               
                     
                      let section = NSCollectionLayoutSection(group: group)
                      section.boundarySupplementaryItems = suplementaryItems
                      return section
               }
            
        
    }
    


    private func fetchData() {
        
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        print("Start fetch data")
        
        var fetchReleasesResponder: FetchReleasesResponder?
        var getFeaturedPlaylistsResponder: GetFeaturedPlaylistsResponder?
        var recommendationsResponder: RecommendationsResponder?
        
        
        APIManager.shared.fetchReleases { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let success): fetchReleasesResponder = success
            case .failure(let error): print(error.localizedDescription)
            }
        }
        APIManager.shared.getFeaturedPlaylists { result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let success): getFeaturedPlaylistsResponder = success
            case .failure(let error): print(error.localizedDescription)
            }
        }
        
        
        APIManager.shared.getRecommendedGenres { result in
            switch result {
            case .success(let model):
                let genres = model.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = genres.randomElement() {
                        seeds.insert(random)
                    }
                }
                
                APIManager.shared.getRecommendations(genres: seeds) { recommendationsResults in
                    defer {
                        group.leave()
                    }
                    switch recommendationsResults {
                    case .success(let success): recommendationsResponder = success
                    case .failure(let error):   print(error.localizedDescription)
                    }
                    
                }
                
            case .failure(let error): print(error.localizedDescription)
            }
        }
        group.notify(queue: .main) {
            guard let albums = fetchReleasesResponder?.albums.items,
                  let playlists = getFeaturedPlaylistsResponder?.playlists.items,
                  let tracks = recommendationsResponder?.tracks else {
                fatalError("Models are nil")
               
            }
            
            self.modelsConfiguration(albums: albums, playlists: playlists, tracks: tracks)
        }
        
    }
    
    
    

    
    private func modelsConfiguration(albums: [Album], playlists: [Playlist], tracks: [Tracks]) {
        self.albums = albums
        self.playlists = playlists
        self.tracks = tracks
        homeSections.append(.newReleases(viewModels: albums.compactMap({
            return NewReleasesCellVM(name: $0.name, totalTracks: $0.total_tracks, artistName: $0.artists.first?.name ?? "-", coverArtURL: URL(string: $0.images.first?.url ?? ""))
        })))
        
        homeSections.append(.featuredPlaylists(viewModels: playlists.compactMap({
            return FeaturedPlaylistCellVM(name: $0.name, playlistCoverUrl: URL(string: $0.images.first?.url ?? ""), creatorName: $0.owner.display_name)
        })))
      

        homeSections.append(.recommendedTracks(viewModels: tracks.compactMap({
            return RecommendedTracksCellVM(trackName: $0.name, artistName: $0.artists.first?.name ?? "-", coverArtURL: URL(string: $0.album?.images.first?.url ?? ""))
        })))
        collectionView?.reloadData()
    }



    @objc func touchSettings() {
            print("Settings button tapped")
            let vc = SettingsVC()
            vc.title = "Settings"
            navigationController?.pushViewController(vc, animated: true)
        }
    }

extension HomeVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = homeSections[section]
        switch type {
            
        case .newReleases(let viewModels):
            return viewModels.count
        case .featuredPlaylists(let viewModels):
            return viewModels.count
        case .recommendedTracks(let viewModels):
            return viewModels.count
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return homeSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = homeSections[indexPath.section]

        switch sectionType {
        case .newReleases(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleasesCollectionViewCell.cellIdentifier, for: indexPath) as? NewReleasesCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell

        case .featuredPlaylists(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistsCollectionViewCell.cellIdentifier, for: indexPath) as? FeaturedPlaylistsCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell

        case .recommendedTracks(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTracksCollectionViewCell.identifier, for: indexPath) as? RecommendedTracksCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.selectionVibration()
        let section = homeSections[indexPath.section]
        switch section {
            
        case .newReleases:
            let album = albums[indexPath.row]
            let vc = AlbumVC(album: album)
            vc.title = album.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .featuredPlaylists:
            let playlist = playlists[indexPath.row]
            let vc = PlaylistVC(playlist: playlist)
            vc.title = playlist.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .recommendedTracks:
            let track = tracks[indexPath.row]
            PlayPresent.shared.startPlaying(from: self, track: track)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TitleHeaderCollectionReusableView.cellIdentifier, for: indexPath) as? TitleHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let section = indexPath.section
        let title = homeSections[section].title
        header.configure(with: title)
        return header
    }

    
    class CustomCell: UICollectionViewCell {
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
}
