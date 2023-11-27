//
//  AlbumVC.swift
//
//  Created by Deniz Dilbilir on 13/12/2023.
//

import UIKit

class AlbumVC: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70)), subitem: item, count: 1)
            
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top)
            ]
            
            return section
        }
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor(hex: "#121212")
        collectionView.register(AlbumSongsCollectionViewCell.self, forCellWithReuseIdentifier: AlbumSongsCollectionViewCell.cellIdentifier)
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    private var viewModels = [AlbumCollectionViewCellVM]()
    private var tracks = [Tracks]()
    private let album: Album
    
    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = album.name
        setupUI()
        getData()
    }
    
    private func setupUI() {
        let plusSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let plusImage = UIImage(systemName: "plus.circle", withConfiguration: plusSymbolConfiguration)
        let plusButton = UIBarButtonItem(image: plusImage, style: .plain, target: self, action: #selector(saveToLibraryButton))
        navigationItem.leftBarButtonItem = plusButton
        
        view.addSubview(collectionView)
    }
    
    @objc private func saveToLibraryButton() {
        let actionSheet = UIAlertController(title: album.name, message: "Action", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Save this album to your library.", style: .default) { [weak self] _ in
            guard let self = self else { return }
            APIManager.shared.saveAlbumsToLibrary(album: self.album) { success in
                if success {
                    HapticsManager.shared.vibrate(for: .success)
                    NotificationCenter.default.post(name: .savedAlbumNotification, object: nil)
                } else {
                    HapticsManager.shared.vibrate(for: .error)
                }
            }
        })
        present(actionSheet, animated: true)
    }
    
    private func getData() {
        APIManager.shared.getAlbum(for: album) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.tracks = model.tracks.items
                    self?.viewModels = model.tracks.items.compactMap { AlbumCollectionViewCellVM(trackName: $0.name, artistName: $0.artists.first?.name ?? "-") }
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

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension AlbumVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumSongsCollectionViewCell.cellIdentifier, for: indexPath) as? AlbumSongsCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: viewModels[indexPath.row])
        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PlaylistHeaderCollectionReusableView.cellIdentifier, for: indexPath) as? PlaylistHeaderCollectionReusableView,
              kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        let headerVM = PlaylistHeaderVM(name: album.name, owner: album.artists.first?.name, description: String.dateFormatted(string: album.release_date), artWork: URL(string: album.images.first?.url ?? ""))
        header.configure(with: headerVM)
        header.delegate = self
        return header
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        var track = tracks[indexPath.row]
        track.album = self.album
        PlayPresent.shared.startPlaying(from: self, track: track)
    }
}

// MARK: - PlaylistHeaderCollectionReusableViewDelegate
extension AlbumVC: PlaylistHeaderCollectionReusableViewDelegate {
    func PlaylistHeaderCollectionReusableViewDidTapPlay(_ header: PlaylistHeaderCollectionReusableView) {
        let albumTracks: [Tracks] = tracks.compactMap {
            var track = $0
            track.album = self.album
            return track
        }
        PlayPresent.shared.startPlaying(from: self, tracks: albumTracks)
    }
}
