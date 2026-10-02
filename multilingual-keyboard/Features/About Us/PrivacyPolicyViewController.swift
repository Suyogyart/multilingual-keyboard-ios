//
//  PrivacyPolicyViewController.swift
//  multilingual-keyboard
//
//  Comprehensive on-device Privacy Policy detailing zero-data-collection,
//  keystroke privacy, offline operation, and Full Access security guarantees.
//

import UIKit

class PrivacyPolicyViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Privacy Policy"
        view.backgroundColor = .systemGroupedBackground
        
        setupViews()
    }

    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 20
        contentStack.alignment = .fill
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])

        buildContent()
    }

    private func buildContent() {
        // 1. Hero Guarantee Banner
        let heroCard = createHeroCard()
        contentStack.addArrangedSubview(heroCard)

        // 2. Keystroke Privacy & Zero Logging
        let keystrokeCard = createPolicySectionCard(
            icon: "hand.raised.fill",
            iconColor: .systemBlue,
            title: "Zero Keystroke Logging",
            summary: "Everything you type stays solely on your device. We do not monitor, record, or store any text.",
            bullets: [
                "No Keystroke Logging: We do not log, capture, or record any key taps or typed text.",
                "No Text Harvesting: We never read, inspect, or copy messages, emails, notes, passwords, or personal details.",
                "Direct Input Passing: Typed and transliterated characters are passed directly to the iOS text system (textDocumentProxy) and are not retained in any intermediate cache."
            ]
        )
        contentStack.addArrangedSubview(keystrokeCard)

        // 3. 100% Offline & On-Device Processing
        let offlineCard = createPolicySectionCard(
            icon: "wifi.slash",
            iconColor: .systemGreen,
            title: "100% Offline & On-Device",
            summary: "The keyboard extension has zero network communication capabilities and never connects to the internet.",
            bullets: [
                "Zero External Network Requests: The keyboard does not make HTTP/HTTPS calls, socket connections, or backend requests.",
                "Local Transliteration: Roman-to-Devanagari and Roman-to-Nepal Lipi conversion algorithms execute entirely on your device processor in real-time.",
                "Local Dictionaries: Word lists and suggestion dictionaries reside exclusively inside the local app bundle.",
                "Air-Gapped Reliability: The keyboard operates seamlessly without an internet connection or in Airplane Mode."
            ]
        )
        contentStack.addArrangedSubview(offlineCard)

        // 4. "Allow Full Access" Permission Explained
        let fullAccessCard = createPolicySectionCard(
            icon: "exclamationmark.shield.fill",
            iconColor: .systemOrange,
            title: "Why iOS Requests \"Full Access\"",
            summary: "iOS displays a standard warning for all third-party keyboards. Here is our transparent guarantee of what we do and do not use it for.",
            bullets: [
                "Why Apple Prompts: iOS displays a universal message warning that Full Access could allow transmitting typed content.",
                "What We Use It For: We only use Full Access to trigger Taptic Engine haptic vibration, play system key click sounds, and sync your selected theme via local App Group settings.",
                "Our Absolute Guarantee: Even with Full Access granted, we NEVER transmit your keystrokes, personal messages, or credentials outside your device."
            ]
        )
        contentStack.addArrangedSubview(fullAccessCard)

        // 5. No Third-Party Analytics or Advertising
        let noTrackingCard = createPolicySectionCard(
            icon: "shield.slash.fill",
            iconColor: .systemIndigo,
            title: "No Ads & No Analytics Tracking",
            summary: "We respect your digital sovereignty. There are no tracking scripts, ads, or third-party data brokers.",
            bullets: [
                "No Analytics SDKs: No user behavior tracking, session recording, or analytics frameworks are integrated into the keyboard extension.",
                "No Advertising Networks: We do not serve advertisements, build advertising profiles, or monetize your usage.",
                "No Identifier Collection: We do not access, track, or share device advertising IDs (IDFA/IDFV)."
            ]
        )
        contentStack.addArrangedSubview(noTrackingCard)

        // 6. Sensitive Input & Password Security
        let securityCard = createPolicySectionCard(
            icon: "lock.fill",
            iconColor: .systemTeal,
            title: "Sensitive Information Protection",
            summary: "Your passwords and payment credentials are kept safe by design.",
            bullets: [
                "Automatic Password Switching: iOS automatically switches to the built-in system keyboard for secure password fields.",
                "Payment Security: Credit card numbers, CVVs, and authentication fields are handled directly by iOS; Nepal Lipi Keyboard never accesses or stores them."
            ]
        )
        contentStack.addArrangedSubview(securityCard)

        // 7. Contact & Transparency Card
        let contactCard = createContactCard()
        contentStack.addArrangedSubview(contactCard)
    }

    // MARK: - UI Builders

    private func createHeroCard() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        container.layer.cornerRadius = 16
        container.layer.cornerCurve = .continuous
        container.layer.borderWidth = 1
        container.layer.borderColor = UIColor.systemGreen.withAlphaComponent(0.25).cgColor

        let shieldImageView = UIImageView()
        shieldImageView.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 34, weight: .semibold)
        shieldImageView.image = UIImage(systemName: "checkmark.shield.fill", withConfiguration: config)
        shieldImageView.tintColor = .systemGreen
        shieldImageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Your Privacy is Absolute"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = .label

        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.text = "Nepal Lipi Keyboard is built with a zero-data-collection architecture. We do not collect, monitor, track, store, or transmit any user input data outside this application."
        bodyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 4

        let hStack = UIStackView(arrangedSubviews: [shieldImageView, textStack])
        hStack.translatesAutoresizingMaskIntoConstraints = false
        hStack.axis = .horizontal
        hStack.spacing = 14
        hStack.alignment = .top

        container.addSubview(hStack)
        NSLayoutConstraint.activate([
            shieldImageView.widthAnchor.constraint(equalToConstant: 38),
            shieldImageView.heightAnchor.constraint(equalToConstant: 38),

            hStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            hStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            hStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])

        return container
    }

    private func createPolicySectionCard(icon: String, iconColor: UIColor, title: String, summary: String, bullets: [String]) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 16
        container.layer.cornerCurve = .continuous

        let iconContainer = UIView()
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.backgroundColor = iconColor.withAlphaComponent(0.14)
        iconContainer.layer.cornerRadius = 18
        iconContainer.layer.cornerCurve = .continuous

        let iconView = UIImageView()
        iconView.translatesAutoresizingMaskIntoConstraints = false
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        iconView.image = UIImage(systemName: icon, withConfiguration: iconConfig)
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit
        iconContainer.addSubview(iconView)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16.5, weight: .bold)
        titleLabel.textColor = .label

        let headerStack = UIStackView(arrangedSubviews: [iconContainer, titleLabel])
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .horizontal
        headerStack.spacing = 12
        headerStack.alignment = .center

        let summaryLabel = UILabel()
        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.text = summary
        summaryLabel.font = .systemFont(ofSize: 13.5, weight: .regular)
        summaryLabel.textColor = .secondaryLabel
        summaryLabel.numberOfLines = 0

        let bulletsStack = UIStackView()
        bulletsStack.translatesAutoresizingMaskIntoConstraints = false
        bulletsStack.axis = .vertical
        bulletsStack.spacing = 8

        for bullet in bullets {
            let bulletRow = createBulletRow(text: bullet)
            bulletsStack.addArrangedSubview(bulletRow)
        }

        let mainStack = UIStackView(arrangedSubviews: [headerStack, summaryLabel, bulletsStack])
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.axis = .vertical
        mainStack.spacing = 12

        container.addSubview(mainStack)
        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 36),
            iconContainer.heightAnchor.constraint(equalToConstant: 36),
            iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),

            mainStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            mainStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            mainStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])

        return container
    }

    private func createBulletRow(text: String) -> UIView {
        let dot = UIView()
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.backgroundColor = .systemBlue
        dot.layer.cornerRadius = 3.5

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0

        let parts = text.components(separatedBy: ": ")
        if parts.count >= 2 {
            let attributed = NSMutableAttributedString(
                string: parts[0] + ": ",
                attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .semibold)]
            )
            let rest = parts.dropFirst().joined(separator: ": ")
            attributed.append(NSAttributedString(
                string: rest,
                attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular), .foregroundColor: UIColor.secondaryLabel]
            ))
            label.attributedText = attributed
        } else {
            label.text = text
        }

        let row = UIStackView()
        row.translatesAutoresizingMaskIntoConstraints = false
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .top

        let dotContainer = UIView()
        dotContainer.translatesAutoresizingMaskIntoConstraints = false
        dotContainer.addSubview(dot)
        dotContainer.widthAnchor.constraint(equalToConstant: 12).isActive = true
        dot.topAnchor.constraint(equalTo: dotContainer.topAnchor, constant: 6).isActive = true
        dot.centerXAnchor.constraint(equalTo: dotContainer.centerXAnchor).isActive = true
        dot.widthAnchor.constraint(equalToConstant: 7).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 7).isActive = true

        row.addArrangedSubview(dotContainer)
        row.addArrangedSubview(label)
        return row
    }

    private func createContactCard() -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 16
        container.layer.cornerCurve = .continuous

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Transparency & Questions"
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
        titleLabel.textColor = .label

        let bodyLabel = UILabel()
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        bodyLabel.text = "Nepal Lipi Keyboard is developed by Callijatra to preserve indigenous scripts. If you have any inquiries regarding your privacy or security, reach out to us directly."
        bodyLabel.font = .systemFont(ofSize: 13.5, weight: .regular)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 0

        let emailLabel = UILabel()
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.text = "Callijatra • callijatrafoundation@gmail.com"
        emailLabel.font = .systemFont(ofSize: 12.5, weight: .semibold)
        emailLabel.textColor = .systemBlue
        emailLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel, emailLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])

        return container
    }
}
