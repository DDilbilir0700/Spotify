//
//  LibraryPlaylistVC.swift
//
//  Created by Deniz Dilbilir on 09/01/2024.
//

import UIKit

class LibraryPlaylistVC: UIViewController {
    
    var playlists = [Playlist]()
    
    public var handler: ((Playlist) -> Void)?
    
    private let alertLabelView = AlertLabelView()
    
    private let tableView: UITableView = {
        
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchResultsTitleTableViewCell.self, forCellReuseIdentifier: SearchResultsTitleTableViewCell.cellIdentifier)
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myColor = UIColor(hex: "#121212")
        view.backgroundColor = myColor
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        alertLabelView.isUserInteractionEnabled = true
      
        
        createNoPlaylistView()
        fetchUserLibraryData()
        
        if handler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeTouched))
        }
    }
    
    @objc func closeTouched() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let myColor = UIColor(hex: "#121212")
        tableView.backgroundColor = myColor
        alertLabelView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        alertLabelView.center = view.center
        tableView.frame = view.bounds
    }
    
    private func createNoPlaylistView() {
        
        view.addSubview(alertLabelView)
        alertLabelView.delegate = self
        alertLabelView.configure(with: AlertLabelVM(text: "No Playlists Found.", alertTitle: "You haven't created any playlists yet."))
        
    }
    
    private func fetchUserLibraryData() {
        APIManager.shared.getUserPlaylists { [weak self] result in
            DispatchQueue.main.async {
                
                switch result {
                    
                case .success(let playlist):
                    self?.playlists = playlist
                    self?.updateUI()
                    
                    print("API response playlists: \(playlist)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            if self.playlists.isEmpty {
                self.alertLabelView.isHidden = false
                self.tableView.isHidden = true
            } else {
                self.tableView.reloadData()
                self.alertLabelView.isHidden = true
                self.tableView.isHidden = false
            }
        }
    }

    
    func  presentCreatePlaylistAlert() {
        
        
        print("Button touched")
        let alert = UIAlertController(title: "Create a New Playlist", message: "Enter a name for your playlist.", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Create A Playlist"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            guard let field = alert.textFields?.first,
                  let text = field.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            APIManager.shared.createPlaylists(with: text) { [weak self] success in
                if success {
                    HapticsManager.shared.vibrate(for: .success)
                    
                    self?.fetchUserLibraryData()
                    
                }
                else {
                    HapticsManager.shared.vibrate(for: .error)
                    print("Couldn't create a playlist.")
                }
            }
        }))
        
        present(alert, animated: true)
        
    }
}

extension LibraryPlaylistVC: AlertLabelViewDelegate {
    func alertLabelViewButtonTouched(_ alertView: AlertLabelView) {
    presentCreatePlaylistAlert()
    }
    

}
extension LibraryPlaylistVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let libraryPlaylistCell = tableView.dequeueReusableCell(withIdentifier: SearchResultsTitleTableViewCell.cellIdentifier, for: indexPath) as? SearchResultsTitleTableViewCell else {
            return UITableViewCell()
        }
        let playlists = playlists[indexPath.row]
        
        libraryPlaylistCell.configure(with: SearchResultsTitleTableViewCellVM(title: playlists.name, subtitle: playlists.owner.display_name, imageURL: URL(string: playlists.images.first?.url ?? "")))
        libraryPlaylistCell.selectionStyle = .none
        
        return libraryPlaylistCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.selectionVibration()
        let libraryPlaylist = playlists[indexPath.row]
        guard handler == nil else {
            handler?(libraryPlaylist)
            dismiss(animated: true, completion: nil)
            return
        }
       
        let vc = PlaylistVC(playlist: libraryPlaylist)
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.isUser = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
