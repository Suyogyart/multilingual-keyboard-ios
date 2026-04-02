//
//  ThemesViewController.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 15/03/26.
//

import UIKit

class ThemesViewController: UIViewController {

    private let testTextField = UITextField()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // Theme list matching your requirements
    private let themes = ThemeType.allCases

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Themes"
        view.backgroundColor = .systemGroupedBackground
        
        setupTestField()
        setupTableView()
        
        // Tap to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupTestField() {
        testTextField.placeholder = "Tap here to test theme..."
        testTextField.borderStyle = .roundedRect
        testTextField.backgroundColor = .secondarySystemGroupedBackground
        testTextField.translatesAutoresizingMaskIntoConstraints = false
        testTextField.clearButtonMode = .always
        
        view.addSubview(testTextField)
        
        NSLayoutConstraint.activate([
            testTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            testTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            testTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            testTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "themeCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: testTextField.bottomAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            tableView.contentInset = contentInsets
            tableView.scrollIndicatorInsets = contentInsets
            
            // Optionally scroll to the selected theme so it's not buried
            if let selectedPath = tableView.indexPathForSelectedRow {
                tableView.scrollToRow(at: selectedPath, at: .middle, animated: true)
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = .zero
    }
}

extension ThemesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return themes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "themeCell", for: indexPath)
        let theme = themes[indexPath.row]
        
        cell.textLabel?.text = theme.displayName
        
        // Show checkmark for the currently selected theme
        if theme == KeyboardSettings.shared.selectedTheme {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedTheme = themes[indexPath.row]
        KeyboardSettings.shared.selectedTheme = selectedTheme
        
        // Update checkmarks
        tableView.reloadData()
        
        // Always trigger a fresh reload of the keyboard
        testTextField.resignFirstResponder()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.testTextField.becomeFirstResponder()
        }
    }
    
}
