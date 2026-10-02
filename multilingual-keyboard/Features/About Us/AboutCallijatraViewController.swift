import UIKit
import SafariServices

class AboutCallijatraViewController: UIViewController {

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 32
        stackView.alignment = .fill
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About Us"
        view.backgroundColor = .systemBackground

        setupLayout()
        buildContent()
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            mainStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 24),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -24),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
            mainStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -48)
        ])
    }

    private func buildContent() {
        // 1. Header
        let headerLogo = UIImageView(image: UIImage(named: "CallijatraLogo"))
        headerLogo.contentMode = .scaleAspectFit
        headerLogo.translatesAutoresizingMaskIntoConstraints = false
        headerLogo.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        let logoContainer = UIView()
        logoContainer.addSubview(headerLogo)
        NSLayoutConstraint.activate([
            headerLogo.topAnchor.constraint(equalTo: logoContainer.topAnchor),
            headerLogo.bottomAnchor.constraint(equalTo: logoContainer.bottomAnchor),
            headerLogo.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor)
        ])
        mainStackView.addArrangedSubview(logoContainer)

        let introText = "Callijatra Foundation is a youth-led initiative dedicated to the revival of the Ranjana script, Nepal Lipi, and the Nepalbhasa language, with a mission to preserve Nepal's rich cultural heritage. By blending traditional practices with modern digital innovation, Callijatra bridges the past and the present — ensuring that ancient scripts, languages, and artistic traditions remain accessible and relevant in today's digital age.\n\nThe initiative brings together a community of artists, calligraphers, designers, developers, teachers, and cultural enthusiasts, fostering learning through workshops, creative collaborations, calligraphy challenges, educational content, mobile applications, fonts, and public exhibitions."
        mainStackView.addArrangedSubview(createLabel(text: introText, font: .preferredFont(forTextStyle: .body)))

        // 2. Quote Card
        let quoteCard = createCardView(content: createLabel(
            text: "“The word 'Jatra' means festival in Nepali — Callijatra is a festival of calligraphy.”",
            font: .italicSystemFont(ofSize: 18),
            color: .secondaryLabel,
            alignment: .center
        ))
        mainStackView.addArrangedSubview(quoteCard)

        let historyText = "Founded in 2017 as a creative challenge inviting participants to submit calligraphy in any script on a given theme, Callijatra has grown into a national movement — through Lipi mobile apps, script-based digital fonts, calligraphy tools, video tutorials and online courses, books and learning materials, and workshops, live calligraphy, exhibitions and cultural events."
        mainStackView.addArrangedSubview(createLabel(text: historyText, font: .preferredFont(forTextStyle: .body)))
        
        // 3. This Keyboard Section
        mainStackView.addArrangedSubview(createSectionHeader(title: "This Keyboard"))
        let keyboardText = "Nepal Lipi Keyboard is one of those Lipi tools — a way to type Ranjana script, Nepal Lipi and Nepalbhasa on an ordinary phone, with layouts, dictionaries and transliteration for scripts that most keyboards have never supported. Writing a script every day is what keeps it alive; this is meant to make that ordinary."
        mainStackView.addArrangedSubview(createLabel(text: keyboardText, font: .preferredFont(forTextStyle: .body)))

        // 4. Mission Section
        mainStackView.addArrangedSubview(createSectionHeader(title: "Our Mission"))
        let missionIntro = "To preserve, promote, and revitalize Nepal's indigenous scripts and the Nepalbhasa language, so that these traditions remain:"
        mainStackView.addArrangedSubview(createLabel(text: missionIntro, font: .preferredFont(forTextStyle: .body)))

        let missionBullets = [
            "Relevant in modern society",
            "Accessible through digital tools and learning resources",
            "Actively practiced, taught, and celebrated",
            "Sustainable for future generations"
        ]
        let missionBulletView = createBulletList(items: missionBullets)
        mainStackView.addArrangedSubview(missionBulletView)

        let missionOutro = "By supporting artisans, calligraphers, and educators with platforms and opportunities, the Foundation also contributes to sustainable livelihoods within cultural and creative industries."
        mainStackView.addArrangedSubview(createLabel(text: missionOutro, font: .preferredFont(forTextStyle: .body)))

        // 4.5 How the work happens Section
        mainStackView.addArrangedSubview(createSectionHeader(title: "How the work happens"))
        let howWorkBullets = [
            "Hands-on workshops on Ranjana script, Nepal Lipi and traditional writing systems, and training for youth, students and educators to learn and teach them",
            "Lipi mobile apps, script fonts, calligraphy tools and practice materials for self-paced learning",
            "Calligraphy challenges, exhibitions, festivals and public demonstrations, giving local artisans a place to teach, earn and show their work",
            "Books, practice guides and educational texts, and the documenting of traditional scripts in print and digitally",
            "Partnerships with schools, cultural institutions and libraries, and mentorship between script experts and new learners"
        ]
        let howWorkBulletView = createBulletList(items: howWorkBullets)
        mainStackView.addArrangedSubview(howWorkBulletView)

        // 5. Links Section
        mainStackView.addArrangedSubview(createSectionHeader(title: "More Lipi Tools"))
        let websiteBtn = createLinkButton(title: "callijatra.github.io", icon: "link", urlString: "https://callijatra.github.io")
        mainStackView.addArrangedSubview(websiteBtn)

        mainStackView.addArrangedSubview(createSectionHeader(title: "Follow Callijatra"))
        let socialStack = UIStackView()
        socialStack.axis = .vertical
        socialStack.spacing = 12
        socialStack.addArrangedSubview(createLinkButton(title: "Instagram @callijatra", icon: "camera.fill", urlString: "https://instagram.com/callijatra"))
        socialStack.addArrangedSubview(createLinkButton(title: "Facebook /callijatra", icon: "person.2.fill", urlString: "https://facebook.com/callijatra"))
        socialStack.addArrangedSubview(createLinkButton(title: "YouTube @callijatra", icon: "play.rectangle.fill", urlString: "https://youtube.com/@callijatra"))
        mainStackView.addArrangedSubview(socialStack)
        
        // 6. Footer
        // 6. Footer
        let footerStack = UIStackView()
        footerStack.axis = .vertical
        footerStack.spacing = 16
        footerStack.alignment = .fill
        
        // GGF Footer Card
        let ggfContainer = UIView()
        ggfContainer.backgroundColor = UIColor(red: 110/255.0, green: 152/255.0, blue: 52/255.0, alpha: 1.0)
        ggfContainer.layer.cornerRadius = 16
        ggfContainer.layer.cornerCurve = .continuous
        
        let ggfStack = UIStackView()
        ggfStack.axis = .vertical
        ggfStack.spacing = 12
        ggfStack.alignment = .center
        ggfStack.translatesAutoresizingMaskIntoConstraints = false
        
        let supportedByLabel = createLabel(text: "Supported By", font: .preferredFont(forTextStyle: .subheadline), color: .white, alignment: .center)
        let ggfLogo = UIImageView(image: UIImage(named: "ggfLogoWhite"))
        ggfLogo.contentMode = .scaleAspectFit
        ggfLogo.translatesAutoresizingMaskIntoConstraints = false
        ggfLogo.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        ggfStack.addArrangedSubview(supportedByLabel)
        ggfStack.addArrangedSubview(ggfLogo)
        
        ggfContainer.addSubview(ggfStack)
        NSLayoutConstraint.activate([
            ggfStack.topAnchor.constraint(equalTo: ggfContainer.topAnchor, constant: 20),
            ggfStack.bottomAnchor.constraint(equalTo: ggfContainer.bottomAnchor, constant: -20),
            ggfStack.leadingAnchor.constraint(equalTo: ggfContainer.leadingAnchor, constant: 20),
            ggfStack.trailingAnchor.constraint(equalTo: ggfContainer.trailingAnchor, constant: -20)
        ])
        
        footerStack.addArrangedSubview(ggfContainer)
        
        // App Info & Privacy Policy Stack (At the bottom, centered)
        let bottomMetaStack = UIStackView()
        bottomMetaStack.axis = .vertical
        bottomMetaStack.spacing = 6
        bottomMetaStack.alignment = .center
        
        let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let buildString = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        let versionText: String
        if let build = buildString, !build.isEmpty {
            versionText = "Nepal Lipi Keyboard • Version \(versionString) (\(build))"
        } else {
            versionText = "Nepal Lipi Keyboard • Version \(versionString)"
        }
        let appInfoLabel = createLabel(text: versionText, font: .preferredFont(forTextStyle: .footnote), color: .secondaryLabel, alignment: .center)
        bottomMetaStack.addArrangedSubview(appInfoLabel)
        
        let privacyButton = UIButton(type: .system)
        privacyButton.setTitle("Privacy Policy", for: .normal)
        privacyButton.titleLabel?.font = .systemFont(ofSize: 13.5, weight: .medium)
        privacyButton.setTitleColor(.systemBlue, for: .normal)
        privacyButton.addTarget(self, action: #selector(openPrivacyPolicy), for: .touchUpInside)
        bottomMetaStack.addArrangedSubview(privacyButton)
        
        footerStack.addArrangedSubview(bottomMetaStack)
        
        // Add some top padding to footer
        let footerContainer = UIView()
        footerContainer.addSubview(footerStack)
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            footerStack.topAnchor.constraint(equalTo: footerContainer.topAnchor, constant: 24),
            footerStack.bottomAnchor.constraint(equalTo: footerContainer.bottomAnchor),
            footerStack.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor),
            footerStack.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor)
        ])
        
        mainStackView.addArrangedSubview(footerContainer)
    }

    @objc private func openPrivacyPolicy() {
        let privacyVC = PrivacyPolicyViewController()
        navigationController?.pushViewController(privacyVC, animated: true)
    }

    // MARK: - UI Helpers

    private func createLabel(text: String, font: UIFont, color: UIColor = .label, alignment: NSTextAlignment = .left) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.textAlignment = alignment
        label.numberOfLines = 0
        return label
    }
    
    private func createSectionHeader(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        return label
    }

    private func createCardView(content: UIView) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 16
        container.layer.cornerCurve = .continuous
        
        container.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20)
        ])
        
        return container
    }

    private func createBulletList(items: [String]) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        
        for item in items {
            let itemStack = UIStackView()
            itemStack.axis = .horizontal
            itemStack.spacing = 12
            itemStack.alignment = .top
            
            let bulletLabel = UILabel()
            bulletLabel.text = "•"
            bulletLabel.font = .preferredFont(forTextStyle: .body)
            bulletLabel.textColor = .tintColor
            bulletLabel.setContentHuggingPriority(.required, for: .horizontal)
            
            let textLabel = createLabel(text: item, font: .preferredFont(forTextStyle: .body))
            
            itemStack.addArrangedSubview(bulletLabel)
            itemStack.addArrangedSubview(textLabel)
            
            stack.addArrangedSubview(itemStack)
        }
        
        return stack
    }

    private func createLinkButton(title: String, icon: String, urlString: String) -> UIButton {
        var config = UIButton.Configuration.tinted()
        config.title = title
        if let image = UIImage(systemName: icon) {
            config.image = image
            config.imagePadding = 12
            config.imagePlacement = .leading
        }
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 20, bottom: 14, trailing: 20)
        
        let button = UIButton(configuration: config, primaryAction: UIAction { _ in
            if let url = URL(string: urlString) {
                let vc = SFSafariViewController(url: url)
                self.present(vc, animated: true)
            }
        })
        button.contentHorizontalAlignment = .leading
        return button
    }
}
