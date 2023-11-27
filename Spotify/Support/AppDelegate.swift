//
//  AppDelegate.swift
//
//  Created by Deniz Dilbilir on 21/11/2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        setupRootViewController(for: window)

        configureNavigationBarAppearance()

        window.makeKeyAndVisible()
        self.window = window

        return true
    }

    private func setupRootViewController(for window: UIWindow) {
        if AuthManager.shared.registered {
            AuthManager.shared.refreshInNeed(completion: nil)
            window.rootViewController = TabBarVC()
        } else {
            let navigationVC = UINavigationController(rootViewController: IntroVC())
            navigationVC.navigationBar.prefersLargeTitles = true
            navigationVC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
            window.rootViewController = navigationVC
        }
    }

    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        let myColor = UIColor(hex: "#121212")
        appearance.backgroundColor = myColor
        
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
