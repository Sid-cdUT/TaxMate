//
//  SceneDelegate.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/24/26.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        NotificationManager.shared.requestAuthorization { granted in
            print("Notification permission granted:", granted)
        }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        // Route based on auth state
        if Auth.auth().currentUser != nil {
            window?.rootViewController = makeMainTabBar()
        } else {
            window?.rootViewController = makeLoginNavController()
        }

        window?.makeKeyAndVisible()
    }

    func makeLoginNavController() -> UINavigationController {
        let loginVC = LoginViewController()
        let nav = UINavigationController(rootViewController: loginVC)
        nav.navigationBar.isHidden = true
        return nav
    }

    func makeMainTabBar() -> UITabBarController {
        return MainTabBarController()
    }
}
