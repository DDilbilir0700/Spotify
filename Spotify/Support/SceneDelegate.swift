//
//  SceneDelegate.swift
//
//  Created by Deniz Dilbilir on 21/11/2023.
//

import UIKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        self.window = UIWindow(windowScene: windowScene)
        setupRootViewController(for: self.window)

        configureNavigationBarAppearance()

        self.window?.makeKeyAndVisible()
    }

    private func setupRootViewController(for window: UIWindow?) {
        let rootVC = AuthManager.shared.registered ? TabBarVC() : UINavigationController(rootViewController: IntroVC())
        window?.rootViewController = rootVC
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

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
