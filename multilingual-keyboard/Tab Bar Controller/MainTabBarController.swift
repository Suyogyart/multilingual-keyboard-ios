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
        selectedIndex = 0
    }
    
    private func setupTabs() {
        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "keyboard"), selectedImage: UIImage(systemName: "keyboard.fill"))
        
        let themesVC = ThemesViewController()
        themesVC.tabBarItem = UITabBarItem(title: "Themes", image: UIImage(systemName: "paintbrush"), selectedImage: UIImage(systemName: "paintbrush.fill"))
        
        let settingsVC = SettingsViewController()
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), selectedImage: UIImage(systemName: "gearshape.fill"))
        
        let aboutVc = AboutCallijatraViewController()
        aboutVc.tabBarItem = UITabBarItem(title: "About Us", image: UIImage(systemName: "info.circle"), selectedImage: UIImage(systemName: "info.circle.fill"))
        
        // Wrap them in Navigation Controllers so we get nice top titles
        let nav1 = UINavigationController(rootViewController: homeVC)
        let nav2 = UINavigationController(rootViewController: themesVC)
        let nav3 = UINavigationController(rootViewController: settingsVC)
        let nav4 = UINavigationController(rootViewController: aboutVc)
        
        // Large titles look great on iOS settings apps
        nav1.navigationBar.prefersLargeTitles = true
        nav2.navigationBar.prefersLargeTitles = true
        nav3.navigationBar.prefersLargeTitles = true
        nav4.navigationBar.prefersLargeTitles = true
        
        self.viewControllers = [nav1, nav2, nav3, nav4]
    }
    
    private func customizeTabBarAppearance() {
        self.tabBar.tintColor = .systemBlue // Or your app's accent color
        self.tabBar.backgroundColor = .systemBackground
    }
}
