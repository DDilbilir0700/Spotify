//
//  TabBarVC.swift

//
//  Created by Deniz Dilbilir on 21/11/2023.
//

import UIKit

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
        setupViewControllers()
    }

    private func setupTabBarAppearance() {
        let myColor = UIColor(hex: "#121212")
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: myColor]

        tabBar.isTranslucent = true
        tabBar.backgroundImage = UIImage()
        tabBar.shadowImage = UIImage()

        tabBar.backgroundColor = myColor.withAlphaComponent(0.97)
        tabBar.tintColor = UIColor.white
        tabBar.unselectedItemTintColor = UIColor.gray
    }

    private func setupViewControllers() {
        let firstVC = createViewController(HomeVC(), title: "", image: "music.note.house")
        let secondVC = createViewController(SearchVC(), title: "", image: "waveform.badge.magnifyingglass")
        let thirdVC = createViewController(LibraryVC(), title: "", image: "music.note.list")

        setViewControllers([firstVC, secondVC, thirdVC], animated: false)
    }

    private func createViewController(_ viewController: UIViewController, title: String, image: String) -> UIViewController {
        let customTintColor = UIColor(hex: "#b3b3b3")
        let navController = UINavigationController(rootViewController: viewController)
        navController.navigationBar.tintColor = customTintColor
        navController.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: image), tag: 1)
        navController.navigationBar.prefersLargeTitles = true
        viewController.title = title
        viewController.navigationItem.largeTitleDisplayMode = .always

        return navController
    }
}
