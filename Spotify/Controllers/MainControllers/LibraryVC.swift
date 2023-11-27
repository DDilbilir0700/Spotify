//
//  LibraryVC.swift

//
//  Created by Deniz Dilbilir on 21/11/2023.
//

import UIKit

class LibraryVC: UIViewController {
    
    private let playlistsVC = LibraryPlaylistVC()
    private let albumsVC = AlbumsOnLibraryVC()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        return scrollView
    }()

    private let toggleView = LibraryToggleView()

    override func viewDidLoad() {
        super.viewDidLoad()
        let myColor = UIColor(hex: "#121212")
        view.backgroundColor = myColor

        view.addSubview(toggleView)
        toggleView.delegate = self

        view.addSubview(scrollView)
        scrollView.contentSize = CGSize(width: view.width*2, height: scrollView.height)
        scrollView.delegate = self

        addChildren()
        updateBarButtons()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top+55,
            width: view.width,
            height: view.height-view.safeAreaInsets.top-view.safeAreaInsets.bottom-55
        )
        toggleView.frame = CGRect(
            x: 0,
            y: view.safeAreaInsets.top,
            width: 200,
            height: 55
        )
    }

    private func updateBarButtons() {
        switch toggleView.state {
        case .playlist:
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        case .album:
            navigationItem.rightBarButtonItem = nil
        }
    }

    @objc private func didTapAdd() {
        playlistsVC.presentCreatePlaylistAlert()
    }

    private func addChildren() {
        addChild(playlistsVC)
        scrollView.addSubview(playlistsVC.view)
        playlistsVC.view.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height)
        playlistsVC.didMove(toParent: self)

        addChild(albumsVC)
        scrollView.addSubview(albumsVC.view)
        albumsVC.view.frame = CGRect(x: view.width, y: 0, width: scrollView.width, height: scrollView.height)
        albumsVC.didMove(toParent: self)
    }
    
}

extension LibraryVC: UIScrollViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
            let targetOffsetX: CGFloat = scrollView.bounds.width
            let isScrollingToAlbums = targetContentOffset.pointee.x >= (targetOffsetX - 100)

            toggleView.update(for: isScrollingToAlbums ? .album : .playlist)
            updateBarButtons()

            let targetContentOffsetX = isScrollingToAlbums ? targetOffsetX : 0
            targetContentOffset.pointee = CGPoint(x: targetContentOffsetX, y: 0)

            UIView.animate(withDuration: 0.1) {
                self.toggleView.layoutIndicator()
            }
        }
    }
extension LibraryVC: LibraryToggleViewDelegate {
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(.zero, animated: true)
        updateBarButtons()
    }

    func libraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView) {
        scrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: true)
        updateBarButtons()
    }
}

