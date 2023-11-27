//
//  SettingsVC.swift

//
//  Created by Deniz Dilbilir on 21/11/2023.
//

import UIKit

class SettingsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var tableView = UITableView()
    private var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        let myColor = UIColor(hex: "#121212")
        view.backgroundColor = myColor
        tableView.backgroundColor = myColor
        view.addSubview(tableView)
        configureTableView()
        configureModel()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        
        
    }
    
    // MARK: - Configuration
    
    private func configureModel() {
        sections.append(Section(title: "📀", options: [Option(title: "My Profile", handler: { [weak self] in
            DispatchQueue.main.async {
                self?.checkProfile()
            }
        })]))
        
        sections.append(Section(title: "💿", options: [Option(title: "Sign Out", handler: { [weak self] in
            DispatchQueue.main.async {
                self?.signOutPressed()
            }
        })]))
    }
    
    private func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - Actions
    
    private func signOutPressed() {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure to log out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { [weak self] _ in
            self?.performSignOut()
        }))
        present(alert, animated: true)
    }
    
    private func performSignOut() {
        AuthManager.shared.logOut { [weak self] logOut in
            if logOut {
                DispatchQueue.main.async {
                    let navigationVC = UINavigationController(rootViewController: IntroVC())
                    navigationVC.navigationBar.prefersLargeTitles = true
                    navigationVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
                    navigationVC.modalPresentationStyle = .fullScreen
                    self?.present(navigationVC, animated: true) {
                        self?.navigationController?.popToRootViewController(animated: false)
                    }
                }
            }
        }
    }
    
    private func checkProfile() {
        let vc = ProfileVC()
        vc.title = "Profile"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}
