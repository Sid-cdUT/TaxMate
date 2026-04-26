//
//  MainTabBarController.swift
//  TaxMate
//
//  Created by Siddharth Singh on 4/25/26.
//

import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }

    private func setupAppearance() {
        tabBar.tintColor = UIColor.systemGreen
        tabBar.unselectedItemTintColor = UIColor.systemGray
        tabBar.backgroundColor = .white
    }

    private func setupTabs() {
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))

        let expensesVC = UINavigationController(rootViewController: ExpenseListViewController())
        expensesVC.tabBarItem = UITabBarItem(title: "Expenses", image: UIImage(systemName: "list.bullet.rectangle"), selectedImage: UIImage(systemName: "list.bullet.rectangle.fill"))

        let taxVC = UINavigationController(rootViewController: TaxSummaryViewController())
        taxVC.tabBarItem = UITabBarItem(title: "Tax", image: UIImage(systemName: "doc.text"), selectedImage: UIImage(systemName: "doc.text.fill"))

        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(systemName: "person.circle"), selectedImage: UIImage(systemName: "person.circle.fill"))

        let settingsVC = UINavigationController(rootViewController: SettingsViewController())
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))

        viewControllers = [homeVC, expensesVC, taxVC, profileVC, settingsVC]
    }
}
