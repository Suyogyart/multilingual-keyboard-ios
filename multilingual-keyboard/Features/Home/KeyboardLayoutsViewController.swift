//
//  KeyboardLayoutsViewController.swift
//  multilingual-keyboard
//

import UIKit

class KeyboardLayoutsViewController: UIViewController {

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
        stackView.spacing = 24
        stackView.alignment = .fill
        return stackView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Keyboard Layouts"
        view.backgroundColor = .systemGroupedBackground

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

            mainStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 16),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -16),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
            mainStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32)
        ])
    }

    private func buildContent() {
        // 1. Overview Intro Card
        let introText = "This keyboard supports 5 specialized layouts across three distinct writing traditions: Nepal Lipi (Prachalit script), Devanagari (Nepali), and Latin (English). Whether you prefer traditional typewriter arrangements or high-speed phonetic transliteration, each layout is optimized for accuracy, authentic typography, and low-latency typing."
        let introCard = createCardView(
            title: "Supported Layouts Overview",
            icon: "keyboard",
            content: createLabel(text: introText, font: .preferredFont(forTextStyle: .subheadline), color: .secondaryLabel)
        )
        mainStackView.addArrangedSubview(introCard)

        // 2. Nepal Lipi (Traditional)
        let newaTradBullets = [
            "Script: Nepal Lipi / Prachalit script (Unicode U+11400–U+1145F).",
            "Typewriter Layout: Direct key access to core consonants (𑐎, 𑐐, 𑐔, 𑐖, 𑐟, 𑐡, 𑐥, 𑐧, 𑐫, 𑐬, 𑐮, 𑐰, 𑐳, 𑐴).",
            "Shift Layer: Reveals aspirated consonants (𑐏, 𑐑, 𑐕, 𑐗, 𑐠, 𑐢, 𑐦, 𑐨), retroflex series (𑐚–𑐞), and independent vowels (𑐀–𑐍).",
            "Long-Press Alternates: Hold any consonant to access all 16 matra vowel combinations (𑐎𑐵, 𑐎𑐶, 𑐎𑐷, 𑐎𑐸, 𑐎𑐹, 𑐎𑐺, 𑐎𑐾, 𑐎𑑀, 𑐎𑑁, etc.), virama (𑑂), and nasal marks (𑑄, 𑑅).",
            "Special Ligatures: Native support for Newa conjuncts 𑐓 (Nyha), 𑐙 (Nnyha), and 𑐭 (Rha).",
            "Smart Autocorrect: Automatic Zero Width Non-Joiner (ZWNJ) on 𑐫𑑂‌ (Ya + Virama) to preserve clear locative suffixes without unwanted ligature collapsing."
        ]
        let newaTradCard = createCardView(
            title: "𑐣𑐾𑐥𑐵𑐮𑐨𑐵𑐲𑐵 (Traditional)",
            subtitle: "Direct Nepal Lipi Typewriter Layout",
            icon: "character.book.closed.fill",
            content: createBulletList(items: newaTradBullets)
        )
        mainStackView.addArrangedSubview(newaTradCard)

        // 3. Nepal Lipi (Transliteration)
        let newaTranslitBullets = [
            "Mode: Phonetic Roman-to-Nepal Lipi (EN → 𑐣𑐾𑐥𑐵𑐮𑐨𑐵𑐲𑐵).",
            "Familiar Typing: Type phonetically using standard Latin characters (e.g., 'jwojalapa', 'namaste', 'nepal').",
            // "Live Suggestion Bar: Real-time candidate predictions transformed directly into Nepal Lipi, powered by NewaTransliterationDictionary.",
            "Quick Commit: Press space or return to automatically commit the transliterated word.",
            "Ideal For: Anyone wanting to write authentic Nepal Lipi without memorizing traditional key positions."
        ]
        let newaTranslitCard = createCardView(
            title: "𑐣𑐾𑐥𑐵𑐮𑐨𑐵𑐲𑐵 (Transliteration)",
            subtitle: "Phonetic Roman → Nepal Lipi",
            icon: "character.cursor.ibeam",
            content: createBulletList(items: newaTranslitBullets)
        )
        mainStackView.addArrangedSubview(newaTranslitCard)

        // 4. Nepali (Traditional)
        let npTradBullets = [
            "Script: Devanagari (Unicode U+0900–U+097F).",
            "Typewriter Arrangement: Standard Nepali typewriter layout optimized for Nepali Unicode.",
            "Quick Conjuncts: Direct access to composite letters like क्ष, त्र, and ज्ञ.",
            "Full Barakhari Callouts: Long-press any consonant key to view all 16 matra variations (ा, ि, ी, ु, ू, ृ, ॄ, ॢ, ॣ, े, ै, ो, ौ, ं, ः, ्).",
            "Typographical Autocorrect: Automatic Zero Width Non-Joiner insertion on य्‌ (Ya + Virama) ensures standard Nepali orthography."
        ]
        let npTradCard = createCardView(
            title: "नेपाली (Traditional)",
            subtitle: "Devanagari Typewriter Layout",
            icon: "textformat",
            content: createBulletList(items: npTradBullets)
        )
        mainStackView.addArrangedSubview(npTradCard)

        // 5. Nepali (Transliteration)
        let npTranslitBullets = [
            "Mode: Phonetic Roman-to-Devanagari (EN → नेपाली).",
            "Greedy Phonetic Engine: Recognizes digraphs (kh, gh, ch, chh, jh, th, dh, ph, bh, sh), dental/retroflex contrasts (t/T, d/D, n/N), and vocalic R (rri → ऋ).",
            "Consonant Clustering: Automatic halanta injection between consecutive consonants (e.g., 'kt' → क्त).",
            // "Lexicon Suggestions: Suggestion bar provides short/long vowel alternatives, aspiration toggles, and dictionary prefix matches from NepaliTransliterationDictionary."
        ]
        let npTranslitCard = createCardView(
            title: "नेपाली (Transliteration)",
            subtitle: "Phonetic Roman → Devanagari",
            icon: "arrow.triangle.2.circlepath",
            content: createBulletList(items: npTranslitBullets)
        )
        mainStackView.addArrangedSubview(npTranslitCard)

        // 6. English (US)
        let enBullets = [
            "Layout: Standard American QWERTY arrangement.",
            // "Word Suggestions: Intelligent prefix completions as you type.",
            // "Next-Word Prediction: Contextual next-word suggestions following completed words.",
            "Convenience Shortcuts: Double-tap spacebar to insert a period and space ('. ')."
        ]
        let enCard = createCardView(
            title: "English (US)",
            subtitle: "Standard QWERTY Layout",
            icon: "globe",
            content: createBulletList(items: enBullets)
        )
        mainStackView.addArrangedSubview(enCard)

        // 7. Numbers, Symbols & Punctuation
        let symbolsBullets = [
            "English Mode: Standard ASCII digits (0–9) and Western punctuation.",
            "Nepali Mode: Native Devanagari digits (०–९), Purna Virama (।), Deergha Virama (॥), and Avagraha (ऽ).",
            "Nepal Lipi Mode: Authentic Nepal Lipi numerals (𑑐–𑑙) and traditional Lipi punctuation (𑑋, 𑑌).",
            "Emoji Layer: Integrated emoji keyboard with recent tracking and categorized emoji browsing."
        ]
        let symbolsCard = createCardView(
            title: "Numbers, Symbols & Punctuation",
            subtitle: "Script-Specific Auxiliary Layers",
            icon: "number",
            content: createBulletList(items: symbolsBullets)
        )
        mainStackView.addArrangedSubview(symbolsCard)

        // 8. Switching Between Layouts Tip Card
        let tipsBullets = [
            "Tap Globe (🌐): Quickly cycles through all enabled keyboard layouts.",
            "Hold Globe (🌐): Opens a popup picker to jump straight to any language.",
            "Spacebar Label: Shows the active layout name (e.g., 'नेपाली', '𑐣𑐾𑐥𑐵𑐮𑐨𑐵𑐲𑐵', 'English (US)').",
            "Settings: Customize keypress haptics, key sounds, and keyboard height in the Settings tab."
        ]
        let tipsCard = createCardView(
            title: "Quick Tips for Switching",
            subtitle: "Effortless Multilingual Navigation",
            icon: "lightbulb.fill",
            content: createBulletList(items: tipsBullets)
        )
        mainStackView.addArrangedSubview(tipsCard)
    }

    // MARK: - UI Helpers

    private func createCardView(title: String, subtitle: String? = nil, icon: String? = nil, content: UIView) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.layer.cornerRadius = 16
        container.layer.cornerCurve = .continuous

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        // Header Stack
        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.spacing = 12
        headerStack.alignment = .center

        if let iconName = icon, let image = UIImage(systemName: iconName) {
            let iconView = UIImageView(image: image)
            iconView.tintColor = .systemBlue
            iconView.contentMode = .scaleAspectFit
            iconView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconView.widthAnchor.constraint(equalToConstant: 24),
                iconView.heightAnchor.constraint(equalToConstant: 24)
            ])
            headerStack.addArrangedSubview(iconView)
        }

        let titleStack = UIStackView()
        titleStack.axis = .vertical
        titleStack.spacing = 2

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        titleStack.addArrangedSubview(titleLabel)

        if let sub = subtitle {
            let subLabel = UILabel()
            subLabel.text = sub
            subLabel.font = .preferredFont(forTextStyle: .caption1)
            subLabel.textColor = .secondaryLabel
            subLabel.numberOfLines = 0
            titleStack.addArrangedSubview(subLabel)
        }

        headerStack.addArrangedSubview(titleStack)
        stack.addArrangedSubview(headerStack)

        // Divider
        let divider = UIView()
        divider.backgroundColor = .separator.withAlphaComponent(0.5)
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        stack.addArrangedSubview(divider)

        // Content
        stack.addArrangedSubview(content)

        container.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])

        return container
    }

    private func createBulletList(items: [String]) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 10

        for item in items {
            let itemStack = UIStackView()
            itemStack.axis = .horizontal
            itemStack.spacing = 10
            itemStack.alignment = .top

            let bulletLabel = UILabel()
            bulletLabel.text = "•"
            bulletLabel.font = .systemFont(ofSize: 14, weight: .bold)
            bulletLabel.textColor = .systemBlue
            bulletLabel.setContentHuggingPriority(.required, for: .horizontal)

            let textLabel = UILabel()
            textLabel.text = item
            textLabel.font = .preferredFont(forTextStyle: .subheadline)
            textLabel.textColor = .label
            textLabel.numberOfLines = 0

            itemStack.addArrangedSubview(bulletLabel)
            itemStack.addArrangedSubview(textLabel)

            stack.addArrangedSubview(itemStack)
        }

        return stack
    }

    private func createLabel(text: String, font: UIFont, color: UIColor = .label) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.numberOfLines = 0
        return label
    }
}
