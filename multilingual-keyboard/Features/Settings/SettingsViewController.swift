import UIKit

class SettingsViewController: UIViewController {

    private let testTextField = UITextField()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemGroupedBackground
        
        setupTestField()
        setupTableView()
        
        // Dismiss keyboard when tapping anywhere outside the text field
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupTestField() {
        testTextField.placeholder = "Tap here to test keyboard..."
        testTextField.borderStyle = .roundedRect
        testTextField.backgroundColor = .secondarySystemGroupedBackground
        testTextField.clearButtonMode = .whileEditing
        testTextField.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        // Register standard styles
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "valueCell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: testTextField.bottomAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - TableView Data & Delegate
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Keyboard Height" : "Typing Feedback"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // SECTION 0: Keyboard Height
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "valueCell")
                cell.textLabel?.text = "Scale"
                let currentScale = KeyboardSettings.shared.keyboardHeightScale
                cell.detailTextLabel?.text = "\(Int(currentScale * 100))%"
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "sliderCell")
                cell.selectionStyle = .none
                
                let slider = UISlider()
                slider.minimumValue = 0.8
                slider.maximumValue = 1.2
                slider.value = KeyboardSettings.shared.keyboardHeightScale
                slider.minimumValueImage = UIImage(systemName: "keyboard")
                slider.maximumValueImage = UIImage(systemName: "keyboard.fill")
                slider.translatesAutoresizingMaskIntoConstraints = false
                
                // 1. Triggered while moving
                slider.addTarget(self, action: #selector(heightSliderDragging(_:)), for: .valueChanged)
                
                // 2. Triggered when the user lets go of the slider
                slider.addTarget(self, action: #selector(heightSliderEnded(_:)), for: [.touchUpInside, .touchUpOutside])
                
                cell.contentView.addSubview(slider)
                NSLayoutConstraint.activate([
                    slider.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
                    slider.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20),
                    slider.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
                ])
                return cell
            }
        }
        // SECTION 1: Typing Feedback
        else {
            if indexPath.row == 0 {
                // ROW 0: Long Press Delay (Stepper)
                let cell = UITableViewCell(style: .value1, reuseIdentifier: "delayCell")
                cell.textLabel?.text = "Key Long Press Delay"
                
                let currentDelay = KeyboardSettings.shared.longPressDelay
                cell.detailTextLabel?.text = String(format: "%.2fs", currentDelay)
                
                let stepper = UIStepper()
                stepper.minimumValue = 0.1
                stepper.maximumValue = 1.0
                stepper.stepValue = 0.05 // Increments of 50ms
                stepper.value = currentDelay
                stepper.addTarget(self, action: #selector(delayStepperChanged(_:)), for: .valueChanged)
                
                cell.accessoryView = stepper
                cell.selectionStyle = .none
                return cell
                
            } else {
                // ROW 1 & 2: Sounds and Haptics
                let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
                cell.textLabel?.text = indexPath.row == 1 ? "Keypress Sound" : "Keypress Haptics"
                let toggle = UISwitch()
                toggle.isOn = indexPath.row == 1 ? KeyboardSettings.shared.enableSounds : KeyboardSettings.shared.enableHaptics
                toggle.tag = indexPath.row
                toggle.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
                cell.accessoryView = toggle
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    @objc func heightSliderChanged(_ sender: UISlider) {
        // Snap the slider to 5% increments for a cleaner feel
        let step: Float = 0.05
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        
        KeyboardSettings.shared.keyboardHeightScale = roundedValue
        
        // Live update the percentage text above it
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            cell.detailTextLabel?.text = "\(Int(roundedValue * 100))%"
        }
    }
    
    @objc func heightSliderDragging(_ sender: UISlider) {
        // Snap the slider to 5% increments
        let step: Float = 0.05
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        
        // Hide the keyboard while the user is actively dragging
        if testTextField.isFirstResponder {
            testTextField.resignFirstResponder()
        }
        
        // Update the percentage text live
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
            cell.detailTextLabel?.text = "\(Int(roundedValue * 100))%"
        }
    }
    
    @objc func heightSliderEnded(_ sender: UISlider) {
        // Now that the user released the slider, save it to the App Group
        KeyboardSettings.shared.keyboardHeightScale = sender.value
        
        // THE FIX: Give iOS a tiny delay (0.15 seconds) to finish any
        // pending dismissal animations before requesting the keyboard again.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            self?.testTextField.becomeFirstResponder()
        }
    }
    
    @objc func delayStepperChanged(_ sender: UIStepper) {
        // Save the new delay to the App Group
        KeyboardSettings.shared.longPressDelay = sender.value
        
        // Update the cell's text label live
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) {
            cell.detailTextLabel?.text = String(format: "%.2fs", sender.value)
        }
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        if sender.tag == 1 {
            KeyboardSettings.shared.enableSounds = sender.isOn
        } else {
            KeyboardSettings.shared.enableHaptics = sender.isOn
        }
    }
}
