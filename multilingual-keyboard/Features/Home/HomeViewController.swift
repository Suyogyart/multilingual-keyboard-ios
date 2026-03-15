import UIKit

class HomeViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    enum Section: Int, CaseIterable {
        case features = 0
        case activation = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Keyboard"
        view.backgroundColor = .systemGroupedBackground
        
        setupTableView()
        
        // 1. ADD THIS: Listen for the app waking up from the background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    // 2. ADD THIS: Clean up the observer to prevent memory leaks
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 3. ADD THIS: Triggered the exact millisecond the user returns from iOS Settings
    @objc private func appDidBecomeActive() {
        // Reloading the table forces the cell to re-run isKeyboardActivated()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // 4. UPDATED: The safest way to check active keyboards using KVC
    private func isKeyboardActivated() -> Bool {
        guard let bundleID = Bundle.main.bundleIdentifier else { return false }
        
        // IMPORTANT: Ensure this matches your exact Extension Bundle ID!
        // Usually, it's the main app's bundle ID + the extension target name.
        let keyboardExtensionID = "\(bundleID).nepa-key"
        
        let activeInputModes = UITextInputMode.activeInputModes
        
        for mode in activeInputModes {
            // mode.value(forKey:) safely extracts the hidden identifier string
            if let identifier = mode.value(forKey: "identifier") as? String, identifier == keyboardExtensionID {
                return true
            }
        }
        
        return false
    }
}

// MARK: - TableView DataSource & Delegate
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .features: return 3
        case .activation: return 1
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.accessoryType = .disclosureIndicator
        
        switch Section(rawValue: indexPath.section) {
        case .features:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Keyboard Layouts"
                cell.imageView?.image = UIImage(systemName: "character.cursor.ibeam")
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Help View"
                cell.imageView?.image = UIImage(systemName: "questionmark.circle")
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "Key Maps"
                cell.imageView?.image = UIImage(systemName: "map")
            }
            
        case .activation:
            if isKeyboardActivated() {
                cell.textLabel?.text = "Keyboard is Activated!"
                cell.textLabel?.textColor = .systemGreen
                cell.imageView?.image = UIImage(systemName: "checkmark.seal.fill")
                cell.imageView?.tintColor = .systemGreen
                cell.accessoryType = .none
                cell.selectionStyle = .none // Disable tapping if it's already active
            } else {
                cell.textLabel?.text = "Go to Settings to enable the Keyboard"
                cell.textLabel?.textColor = .systemBlue
                cell.imageView?.image = UIImage(systemName: "gear")
                cell.selectionStyle = .default
            }
        
        default: break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .features: return "Features"
        case .activation: return "Activation"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == Section.activation.rawValue {
            // Prevent opening settings if already activated
            if !isKeyboardActivated() {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }
        // TODO: Navigation to other views will go here
    }
}
