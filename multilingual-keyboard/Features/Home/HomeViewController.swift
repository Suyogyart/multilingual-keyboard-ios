import UIKit

class HomeViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    enum Section: Int, CaseIterable {
        case activation = 0
        case features = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Nepal Lipi Keyboard"
        tabBarItem.title = "Keyboard"
        view.backgroundColor = .systemGroupedBackground
        
        setupTableView()
        
        // 1. Listen for the app waking up from the background
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    // 2. Clean up the observer to prevent memory leaks
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // 3. Triggered the exact millisecond the user returns from iOS Settings
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
        tableView.register(KeyboardActivationBannerCell.self, forCellReuseIdentifier: "activationBannerCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // Add spacing above the top activation hero card
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 16))
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // 4. Safest way to check active keyboards using KVC
    private func isKeyboardActivated() -> Bool {
        guard let bundleID = Bundle.main.bundleIdentifier else { return false }
        
        let keyboardExtensionID = "\(bundleID).Nepal-Lipi"
        let activeInputModes = UITextInputMode.activeInputModes
        
        for mode in activeInputModes {
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
        case .activation: return 1
        case .features: return 2
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .activation:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "activationBannerCell", for: indexPath) as? KeyboardActivationBannerCell else {
                return UITableViewCell()
            }
            cell.configure(isActivated: isKeyboardActivated())
            return cell
            
        case .features:
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
            cell.accessoryType = .disclosureIndicator
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Keyboard Layouts"
                cell.detailTextLabel?.text = "Overview of supported scripts & typing modes"
                cell.detailTextLabel?.numberOfLines = 0
                cell.imageView?.image = UIImage(systemName: "character.cursor.ibeam")
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Key Maps"
                cell.detailTextLabel?.text = "Roman → Devanagari & Nepal Lipi transliteration rules"
                cell.detailTextLabel?.numberOfLines = 0
                cell.imageView?.image = UIImage(systemName: "map")
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Section(rawValue: section) {
        case .activation: return "Activation"
        case .features: return "References"
        default: return nil
        }
    }

//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        switch Section(rawValue: section) {
//        case .activation:
//            return 8
//        case .features:
//            return UITableView.automaticDimension
//        default:
//            return UITableView.automaticDimension
//        }
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if Section(rawValue: section) == .activation {
//            return UIView()
//        }
//        return nil
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch Section(rawValue: indexPath.section) {
        case .activation:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        case .features:
            if indexPath.row == 0 {
                let layoutsVC = KeyboardLayoutsViewController()
                navigationController?.pushViewController(layoutsVC, animated: true)
            } else if indexPath.row == 1 {
                let keyMapsVC = KeyMapsViewController()
                navigationController?.pushViewController(keyMapsVC, animated: true)
            }
        default:
            break
        }
    }
}

// MARK: - Activation Banner Cell (Apple Account Style)

class KeyboardActivationBannerCell: UITableViewCell {
    
    private let iconContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 28
        view.layer.cornerCurve = .continuous
        view.clipsToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13.5, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let chevronImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
        iv.image = UIImage(systemName: "chevron.right", withConfiguration: config)
        iv.tintColor = .tertiaryLabel
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        selectionStyle = .default
        
        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.alignment = .leading
        
        contentView.addSubview(textStack)
        contentView.addSubview(chevronImageView)
        
        NSLayoutConstraint.activate([
            // Circular icon container on left
            iconContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 56),
            iconContainerView.heightAnchor.constraint(equalToConstant: 56),
            iconContainerView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 14),
            iconContainerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -14),
            
            // Icon inside circle
            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
            
            // Title + Subtitle stack
            textStack.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 16),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            textStack.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            
            // Chevron disclosure on right
            chevronImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 10),
            chevronImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
    func configure(isActivated: Bool) {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 26, weight: .semibold)
        if isActivated {
            iconContainerView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.14)
            iconImageView.image = UIImage(systemName: "checkmark.seal.fill", withConfiguration: symbolConfig)
            iconImageView.tintColor = .systemGreen
            titleLabel.text = "Keyboard Activated"
            subtitleLabel.text = "Nepal Lipi Keyboard is active and ready to use in any app."
        } else {
            iconContainerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
            iconImageView.image = UIImage(systemName: "keyboard.fill", withConfiguration: symbolConfig)
            iconImageView.tintColor = .systemBlue
            titleLabel.text = "Enable Keyboard"
            subtitleLabel.text = "Tap to open Settings and turn on Nepal Lipi Keyboard to start typing."
        }
    }
}
