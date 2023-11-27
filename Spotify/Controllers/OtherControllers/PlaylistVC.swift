//
//  PlaylistVC.swift

//
//  Created by Deniz Dilbilir on 21/11/2023.
//

import UIKit

class PlaylistVC: UIViewController {
    
    
    private let playlist: Playlist
    
    public var isUser = false
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ ->  NSCollectionLayoutSection? in
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 2, bottom: 1, trailing: 2)
        
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
        
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(70)), subitem: item, count: 1)
        
        
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [ NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top) ]
        
        return section
    }))
    
    
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private var viewModels = [RecommendedTracksCellVM]()
    private var tracks = [Tracks]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = playlist.name
        let myColor = UIColor(hex: "#121212")
        collectionView.backgroundColor = myColor
        
        view.addSubview(collectionView)
        collectionView.register(RecommendedTracksCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTracksCollectionViewCell.identifier)
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        APIManager.shared.getPlaylist(for: playlist) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.tracks = model.tracks.items.compactMap({ $0.track })
                    self?.viewModels = model.tracks.items.compactMap({ RecommendedTracksCellVM(trackName: $0.track.name, artistName: $0.track.artists.first?.name ?? "-", coverArtURL: URL(string: $0.track.album?.images.first?.url ?? ""))
                        
                    })
                    self?.collectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(didTapShare)
        )

        let gesture = UILongPressGestureRecognizer(target: self,
                                                   action: #selector(songTouchedToRemove(_:)))
        collectionView.addGestureRecognizer(gesture)
    }

    @objc func songTouchedToRemove(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else {
            return
        }
        let gestureLocation = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: gestureLocation) else {
            return
        }
        let songsToRemove = tracks[indexPath.row]

        let actionSheet = UIAlertController(
            title: songsToRemove.name,
            message: "Do you want to remove this song from the playlist?",
            preferredStyle: .actionSheet
        )
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(
            UIAlertAction(
                title: "Remove",
                style: .destructive,
                handler: { [weak self] _ in
                    guard let self = self else {
                        return
                    }
                    APIManager.shared.removeSongFromPlaylist(track: songsToRemove, playlist: self.playlist) { success in
                        DispatchQueue.main.async {
                            if success {
                                print("successfully removed")
                                self.tracks.remove(at: indexPath.row)
                                self.viewModels.remove(at: indexPath.row)
                                self.collectionView.reloadData()
                            }
                            else {
                                print("Failed to remove")
                            }
                        }
                    }
                }
            )
        )
        present(actionSheet,
                animated: true,
                completion: nil)
    }

    @objc private func didTapShare() {
        guard let url = URL(string: playlist.external_urls["spotify"] ?? "") else {
            return
        }

        let vc = UIActivityViewController(
            activityItems: [url],
            applicationActivities: []
        )
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
}
extension PlaylistVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTracksCollectionViewCell.identifier, for: indexPath) as? RecommendedTracksCollectionViewCell else {
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
        let headerVM = PlaylistHeaderVM(name: playlist.name, owner: playlist.owner.display_name, description: playlist.description, artWork: URL(string: playlist.images.first?.url ?? ""))
        header.configure(with: headerVM)
        header.delegate = self
        return header
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let indexPath = indexPath.row
        let track = tracks[indexPath]
        PlayPresent.shared.startPlaying(from: self, track: track)
    }
}
extension PlaylistVC: PlaylistHeaderCollectionReusableViewDelegate {
    func PlaylistHeaderCollectionReusableViewDidTapPlay(_ header: PlaylistHeaderCollectionReusableView) {
        PlayPresent.shared.startPlaying(from: self, tracks: tracks)
    }
}
