//
//  LibraryToggleView.swift
//
//  Created by Deniz Dilbilir on 10/01/2024.
//

import UIKit

protocol LibraryToggleViewDelegate: AnyObject {
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView)
    func libraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView)
}

class LibraryToggleView: UIView {

    enum State {
        case playlist
        case album
    }

    private var isAnimating: Bool = false
    var state: State = .playlist

    weak var delegate: LibraryToggleViewDelegate?

    private let playlistButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Playlists", for: .normal)
        return button
    }()

    private let albumsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Albums", for: .normal)
        return button
    }()

    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 2
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(playlistButton)
        addSubview(albumsButton)
        addSubview(indicatorView)
        playlistButton.addTarget(self, action: #selector(didTapPlaylists), for: .touchUpInside)
        albumsButton.addTarget(self, action: #selector(didTapAlbums), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc private func didTapPlaylists() {
        guard !isAnimating else { return }
        isAnimating = true
        state = .playlist
        UIView.animate(withDuration: 0.1, animations: {
            self.layoutIndicator()
        }) { _ in
            self.isAnimating = false
        }
        delegate?.libraryToggleViewDidTapPlaylists(self)
    }

    @objc private func didTapAlbums() {
        guard !isAnimating else { return }
        isAnimating = true
        state = .album
        UIView.animate(withDuration: 0.1, animations: {
            self.layoutIndicator()
        }) { _ in
            self.isAnimating = false
        }
        delegate?.libraryToggleViewDidTapAlbums(self)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playlistButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        albumsButton.frame = CGRect(x: playlistButton.right, y: 0, width: 100, height: 40)
        layoutIndicator()
    }

    private let indicatorWidth: CGFloat = 70

    func layoutIndicator() {
        let indicatorHeight: CGFloat = 3

        switch state {
        case .playlist:
            indicatorView.frame = CGRect(
                x: playlistButton.center.x - (indicatorWidth / 2),
                y: playlistButton.bottom,
                width: indicatorWidth,
                height: indicatorHeight
            )
        case .album:
            indicatorView.frame = CGRect(
                x: albumsButton.center.x - (indicatorWidth / 2),
                y: playlistButton.bottom,
                width: indicatorWidth,
                height: indicatorHeight
            )
        }
    }

    func update(for state: State) {
        self.state = state
        UIView.animate(withDuration: 0.1) {
            self.layoutIndicator()
        }
    }
}
