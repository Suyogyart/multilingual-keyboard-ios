//
//  MainTabBarController.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 15/03/26.
//


import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        customizeTabBarAppearance()
        selectedIndex = 2
    }
    
    private func setupTabs() {
        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
        
        let themesVC = ThemesViewController()
        themesVC.tabBarItem = UITabBarItem(title: "Themes", image: UIImage(systemName: "paintbrush"), selectedImage: UIImage(systemName: "paintbrush.fill"))
        
        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        
        // Wrap them in Navigation Controllers so we get nice top titles
        let nav1 = UINavigationController(rootViewController: homeVC)
        let nav2 = UINavigationController(rootViewController: themesVC)
        let nav3 = UINavigationController(rootViewController: settingsVC)
        
        // Large titles look great on iOS settings apps
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        
        self.viewControllers = [nav1, nav2, nav3]
    }
    
    private func customizeTabBarAppearance() {
        self.tabBar.tintColor = .systemBlue // Or your app's accent color
        self.tabBar.backgroundColor = .systemBackground
    }
}
