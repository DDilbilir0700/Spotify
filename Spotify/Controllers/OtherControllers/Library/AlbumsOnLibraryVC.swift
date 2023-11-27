//
//  AlbumsOnLibraryVC.swift
//
//  Created by Deniz Dilbilir on 09/01/2024.
//

import UIKit

class AlbumsOnLibraryVC: UIViewController {

    var albums = [Album]()

    private let alertAlbumView = AlertLabelView()
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultsTitleTableViewCell.self, forCellReuseIdentifier: SearchResultsTitleTableViewCell.cellIdentifier)
        tableView.isHidden = true
        return tableView
    }()
    private var observer: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        let myColor = UIColor(hex: "#121212")
        view.backgroundColor = myColor
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)

        alertAlbumView.isUserInteractionEnabled = true

        createNoAlbumsView()
        fetchUserLibraryData()
        observer = NotificationCenter.default.addObserver(forName: .savedAlbumNotification, object: nil, queue: .main, using: { [weak self] _ in
            self?.fetchUserLibraryData()
        })
    }

    @objc func closeTouched() {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let myColor = UIColor(hex: "#121212")
        tableView.backgroundColor = myColor
        alertAlbumView.frame = CGRect(x: (view.width-150)/2, y: (view.height-150)/2, width: 150, height: 150)
        tableView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        tableView.frame = view.bounds
    }

    private func createNoAlbumsView() {
        view.addSubview(alertAlbumView)
        alertAlbumView.delegate = self
        alertAlbumView.configure(with: AlertLabelVM(text: "No saved albums yet. Explore Albums.", alertTitle: "Ok"))
    }

    private func fetchUserLibraryData() {
        albums.removeAll()
        APIManager.shared.getUserAlbums { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let album):
                    self?.albums = album
                    self?.updateUI()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }

    private func updateUI() {
        DispatchQueue.main.async {
            if self.albums.isEmpty {
                self.alertAlbumView.isHidden = false
                self.tableView.isHidden = true
            } else {
                self.tableView.reloadData()
                self.alertAlbumView.isHidden = true
                self.tableView.isHidden = false
            }
        }
    }
}

extension AlbumsOnLibraryVC: AlertLabelViewDelegate {
    func alertLabelViewButtonTouched(_ alertView: AlertLabelView) {
        tabBarController?.selectedIndex = 0
    }
}

extension AlbumsOnLibraryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let libraryPlaylistCell = tableView.dequeueReusableCell(withIdentifier: SearchResultsTitleTableViewCell.cellIdentifier, for: indexPath) as? SearchResultsTitleTableViewCell else {
            return UITableViewCell()
        }
        let album = albums[indexPath.row]
        libraryPlaylistCell.configure(with: SearchResultsTitleTableViewCellVM(title: album.name, subtitle: album.artists.first?.name ?? "NA", imageURL: URL(string: album.images.first?.url ?? "")))
        libraryPlaylistCell.selectionStyle = .none
        return libraryPlaylistCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.selectionVibration()
        let libraryAlbum = albums[indexPath.row]
        let vc = AlbumVC(album: libraryAlbum)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
