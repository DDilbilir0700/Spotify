//
//  ResultsVC.swift

//
//  Created by Deniz Dilbilir on 21/11/2023.
//

import UIKit

struct SearchResultsSection {
    let title: String
    let results: [SearchBarResults]
}

protocol ResultsVCDelegate: AnyObject {
    func didTapResult(_ result: SearchBarResults)
}

class ResultsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: ResultsVCDelegate?
    
    private var sections: [SearchResultsSection] = []
    
    private let customBackgroundColor = UIColor(hex: "#121212")
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SearchBarResultsTableViewCell.self, forCellReuseIdentifier: SearchBarResultsTableViewCell.cellIdentifier)
        
        tableView.register(SearchResultsTitleTableViewCell.self, forCellReuseIdentifier: SearchResultsTitleTableViewCell.cellIdentifier)
        
        tableView.isHidden = true
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = customBackgroundColor
        tableView.backgroundColor = customBackgroundColor
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    func update(with results: [SearchBarResults]) {
        
        let artist = results.filter({
            switch $0 {
            case .artist: return true
            default: return false
            }
        })
       
        
        let album = results.filter({
            switch $0 {
            case .album: return true
            default: return false
            }
        })
        
        let track = results.filter({
            switch $0 {
            case .track: return true
            default: return false
            }
        })
        
        let playlist = results.filter({
            switch $0 {
            case .playlist: return true
            default: return false
            }
        })
        
        
        self.sections = [SearchResultsSection(title: "Tracks", results: track), SearchResultsSection(title: "Artists", results: artist), SearchResultsSection(title: "Albums", results: album), SearchResultsSection(title: "Playlists", results: playlist)]
        
        tableView.reloadData()
        tableView.isHidden = results.isEmpty
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
       return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let result = sections[indexPath.section].results[indexPath.row]
        
       
        switch result {
            
        case .artist(model: let artist):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchBarResultsTableViewCell.cellIdentifier, for: indexPath) as? SearchBarResultsTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchBarResultsTableViewCellVM(title: artist.name, imageURL: URL(string: artist.images?.first?.url ?? ""))
            cell.configure(with: viewModel)
            
            return cell
        case .track(model: let track):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsTitleTableViewCell.cellIdentifier, for: indexPath) as? SearchResultsTitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultsTitleTableViewCellVM(title: track.name, subtitle: track.artists.first?.name ?? "", imageURL: URL(string: track.album?.images.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
            
        case .playlist(model: let playlist):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsTitleTableViewCell.cellIdentifier, for: indexPath) as? SearchResultsTitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultsTitleTableViewCellVM(title: playlist.name, subtitle: playlist.owner.display_name, imageURL: URL(string: playlist.images.first?.url ?? ""))
            cell.configure(with: viewModel)
         return cell
            
        case .album(model: let album):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsTitleTableViewCell.cellIdentifier, for: indexPath) as? SearchResultsTitleTableViewCell else {
                return UITableViewCell()
            }
            let viewModel = SearchResultsTitleTableViewCellVM(title: album.name, subtitle: album.artists.first?.name ?? "", imageURL: URL(string: album.images.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
            
        }

    }
    
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sections[section].title
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = sections[indexPath.section].results[indexPath.row]
        
        delegate?.didTapResult(result)
    }
}


