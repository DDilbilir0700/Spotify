//
//  ProfileVC.swift

//
//  Created by Deniz Dilbilir on 21/11/2023.
//

import UIKit
import SDWebImage

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var imageView = UIImageView()
    private var tableView = UITableView()
    private var models = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.addSubview(tableView)
        let myColor = UIColor(hex: "#121212")
        view.backgroundColor = myColor
        tableView.backgroundColor = myColor
        fetchUser()
        configureProfileTableView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func fetchUser() {
        APIManager.shared.getCurrentUserProfile { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let model):
                    self?.updateUI(with: model)
                case .failure(let error):
                    print("Error fetching profile: \(error.localizedDescription)")
                    self?.handleProfileError()
                }
            }
        }
    }
    
    private func updateUI(with model: User) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.isHidden = false
            self?.models.append("Full Name: \(model.display_name)")
            self?.models.append("Email Address: \(model.email)")
            self?.models.append("User Name: \(model.id)")
            self?.models.append("Subscription Plan: \(model.product)")
            self?.setUpTableHeader(with: model.images.first?.url)
            self?.tableView.reloadData()
        }
    }
    
    private func setUpTableHeader(with urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width / 1.5))
        
        let imageSize: CGFloat = headerView.frame.height / 2
        imageView.frame = CGRect(x: (headerView.frame.width - imageSize) / 2, y: (headerView.frame.height - imageSize) / 2, width: imageSize, height: imageSize)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageSize / 2
        imageView.sd_setImage(with: url, completed: nil)
        
        headerView.addSubview(imageView)
        tableView.tableHeaderView = headerView
    }
    
    private func handleProfileError() {
        DispatchQueue.main.async { [weak self] in
            let label = UILabel(frame: .zero)
            label.text = "Oops! We couldn't load your profile. Please try again.🫣"
            label.sizeToFit()
            label.textColor = .secondaryLabel
            self?.view.addSubview(label)
            label.center = self?.view.center ?? CGPoint.zero
        }
    }
    
    private func configureProfileTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = true
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row]
        cell.selectionStyle = .none
        let backgroundColor = UIColor(hex: "#121212")
        cell.backgroundColor = backgroundColor
        cell.textLabel?.textColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
}
