//
//  IntroViewController.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 25/11/25.
//

import UIKit

class IntroViewController: UIViewController {
    
    lazy private var introLabel: UILabel = {
        let label = UILabel()
        label.text = "Intro Label"
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy private var setupKeyboardButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Setup Keyboard", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        
        title = "Intro Page"
        
        // Add subviews
        view.addSubview(introLabel)
        view.addSubview(setupKeyboardButton)
        
        // Constrain button to center
        NSLayoutConstraint.activate([
            setupKeyboardButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            setupKeyboardButton.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        // Constrain intro label to top of button
        NSLayoutConstraint.activate([
            introLabel.bottomAnchor.constraint(equalTo: setupKeyboardButton.topAnchor, constant: -20),
            introLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // Add button targets
        setupKeyboardButton.addTarget(self, action: #selector(setupKeyboardButtonTapped), for: .touchUpInside)
    }
    
    @objc private func setupKeyboardButtonTapped() {
        print("Setup Keyboard")
    }


}

