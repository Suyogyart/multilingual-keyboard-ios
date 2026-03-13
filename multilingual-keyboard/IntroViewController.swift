//
//  IntroViewController.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 25/11/25.
//

import UIKit

class IntroViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupUI()
    }
    
    private func setupUI() {
        // 1. Setup Instructions Label
        let instructionsLabel = UILabel()
        instructionsLabel.text = """
        To test your keyboard:
        1. Go to Settings > General > Keyboard
        2. Tap Keyboards > Add New Keyboard...
        3. Select your app's name
        4. Tap the text field below and use the 🌐 icon to switch to it.
        """
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textAlignment = .center
        instructionsLabel.font = .systemFont(ofSize: 16)
        instructionsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(instructionsLabel)
        
        // 2. Setup Testing Text Field
        let textField = UITextField()
        textField.placeholder = "Tap here to test your custom keyboard..."
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 18)
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textField)
        
        // 3. Add Auto Layout Constraints
        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textField.heightAnchor.constraint(equalToConstant: 50),
            
            instructionsLabel.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -40),
            instructionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            instructionsLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        
        // Optional: Dismiss keyboard when tapping outside
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
