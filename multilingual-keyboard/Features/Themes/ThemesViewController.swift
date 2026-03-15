//
//  ThemesViewController.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 15/03/26.
//


import UIKit

class ThemesViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Themes"
        view.backgroundColor = .systemGroupedBackground
        
        // Placeholder for future UI
        let label = UILabel()
        label.text = "Theme Selection Coming Soon\n(Default, Light, Dark Fossil, etc.)"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}