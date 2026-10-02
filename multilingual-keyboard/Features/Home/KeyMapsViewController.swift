//
//  KeyMapsViewController.swift
//  multilingual-keyboard
//
//  Visual reference and interactive guide for Roman → Devanagari & Nepal Lipi (Newa)
//  mappings and transliteration rules implemented in NepaliTransliterator.
//

import UIKit

class KeyMapsViewController: UIViewController {

    // MARK: - Data Models
    
    enum KeyMapCategory: String, CaseIterable {
        case all = "All"
        case consonants = "Consonants"
        case vowels = "Vowels"
        case conjuncts = "Conjuncts"
        case diacritics = "Diacritics"
        case numbers = "Numbers"
        case rules = "Rules"

        var displayName: String {
            switch self {
            case .all: return "All"
            case .consonants: return "Consonants"
            case .vowels: return "Vowels & Matras"
            case .conjuncts: return "Conjuncts"
            case .diacritics: return "Diacritics"
            case .numbers: return "Numbers & Signs"
            case .rules: return "Rules & Autocorrect"
            }
        }
    }

    struct KeyMapItem {
        let roman: String
        let devanagari: String
        let newa: String
        let name: String
        let note: String
        let category: KeyMapCategory
    }

    struct TransliterationRuleItem {
        let title: String
        let romanExample: String
        let devaResult: String
        let newaResult: String
        let explanation: String
        let badge: String
    }

    // MARK: - Properties

    private let searchBar = UISearchBar()
    private let pillScrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsHorizontalScrollIndicator = false
        sv.alwaysBounceHorizontal = true
        sv.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return sv
    }()

    private let pillStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()

    private var pillButtons: [UIButton] = []
    private var selectedCategoryIndex: Int = 0

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    // Interactive Live Test Box
    private let testContainerView = UIView()
    private let testTextField = UITextField()
    private let devaResultLabel = UILabel()
    private let newaResultLabel = UILabel()

    private var selectedCategory: KeyMapCategory = .all
    private var searchText: String = ""
    private var filteredItems: [KeyMapItem] = []

    // MARK: - Static Data

    private let items: [KeyMapItem] = [
        // MARK: Consonants - Ka-varga
        KeyMapItem(roman: "k", devanagari: "क", newa: "𑐎", name: "क (Ka)", note: "कण्ठ्य (Velar). Example: kamal → कमल", category: .consonants),
        KeyMapItem(roman: "kh, Kh", devanagari: "ख", newa: "𑐏", name: "ख (Kha)", note: "कण्ठ्य महाप्राण. Example: khabar → खबर", category: .consonants),
        KeyMapItem(roman: "g", devanagari: "ग", newa: "𑐐", name: "ग (Ga)", note: "कण्ठ्य घोष. Example: gaaun → गाउँ", category: .consonants),
        KeyMapItem(roman: "gh, Gh", devanagari: "घ", newa: "𑐑", name: "घ (Gha)", note: "कण्ठ्य घोष महाप्राण. Example: ghar → घर", category: .consonants),
        KeyMapItem(roman: "ng, Ng", devanagari: "ङ", newa: "𑐒", name: "ङ (Nga)", note: "कण्ठ्य अनुनासिक. Example: aanga → अङ्ग", category: .consonants),

        // MARK: Consonants - Cha-varga
        KeyMapItem(roman: "c, ch", devanagari: "च", newa: "𑐔", name: "च (Cha)", note: "तालव्य (Palatal). Example: chamach → चम्चा", category: .consonants),
        KeyMapItem(roman: "chh, Ch, C", devanagari: "छ", newa: "𑐕", name: "छ (Chha)", note: "तालव्य महाप्राण. Example: chhatri → छाता", category: .consonants),
        KeyMapItem(roman: "j", devanagari: "ज", newa: "𑐖", name: "ज (Ja)", note: "तालव्य घोष. Example: jal → जल", category: .consonants),
        KeyMapItem(roman: "jh, Jh, z", devanagari: "झ", newa: "𑐗", name: "झ (Jha)", note: "तालव्य घोष महाप्राण. Example: jharana → झरना", category: .consonants),
        KeyMapItem(roman: "nh, Nh", devanagari: "ञ", newa: "𑐘", name: "ञ (Nya)", note: "तालव्य अनुनासिक", category: .consonants),

        // MARK: Consonants - Ta-varga (Retroflex)
        KeyMapItem(roman: "T", devanagari: "ट", newa: "𑐚", name: "ट (Ta - Retroflex)", note: "मूर्धन्य (Uppercase T). Example: Topi → टोपी", category: .consonants),
        KeyMapItem(roman: "Th", devanagari: "ठ", newa: "𑐛", name: "ठ (Tha - Retroflex)", note: "मूर्धन्य महाप्राण (Uppercase T). Example: Theka → ठेक्का", category: .consonants),
        KeyMapItem(roman: "D", devanagari: "ड", newa: "𑐜", name: "ड (Da - Retroflex)", note: "मूर्धन्य घोष (Uppercase D). Example: Damaru → डमरु", category: .consonants),
        KeyMapItem(roman: "Dh", devanagari: "ढ", newa: "𑐝", name: "ढ (Dha - Retroflex)", note: "मूर्धन्य घोष महाप्राण (Uppercase D). Example: Dhakani → ढकनी", category: .consonants),
        KeyMapItem(roman: "N", devanagari: "ण", newa: "𑐞", name: "ण (Na - Retroflex)", note: "मूर्धन्य अनुनासिक (Uppercase N). Example: kAran → कारण", category: .consonants),

        // MARK: Consonants - Ta-varga (Dental)
        KeyMapItem(roman: "t", devanagari: "त", newa: "𑐟", name: "त (Ta - Dental)", note: "दन्त्य (Lowercase t). Example: tara → तर", category: .consonants),
        KeyMapItem(roman: "th", devanagari: "थ", newa: "𑐠", name: "थ (Tha - Dental)", note: "दन्त्य महाप्राण (Lowercase t). Example: thali → थाली", category: .consonants),
        KeyMapItem(roman: "d", devanagari: "द", newa: "𑐡", name: "द (Da - Dental)", note: "दन्त्य घोष (Lowercase d). Example: dadhi → दही", category: .consonants),
        KeyMapItem(roman: "dh", devanagari: "ध", newa: "𑐢", name: "ध (Dha - Dental)", note: "दन्त्य घोष महाप्राण (Lowercase d). Example: dhan → धन", category: .consonants),
        KeyMapItem(roman: "n", devanagari: "न", newa: "𑐣", name: "न (Na - Dental)", note: "दन्त्य अनुनासिक (Lowercase n). Example: nadi → नदी", category: .consonants),

        // MARK: Consonants - Pa-varga
        KeyMapItem(roman: "p", devanagari: "प", newa: "𑐥", name: "प (Pa)", note: "ओष्ठ्य (Labial). Example: paani → पानी", category: .consonants),
        KeyMapItem(roman: "ph, Ph, f, F", devanagari: "फ", newa: "𑐦", name: "फ (Pha / Fa)", note: "ओष्ठ्य महाप्राण. Example: phool → फूल", category: .consonants),
        KeyMapItem(roman: "b", devanagari: "ब", newa: "𑐧", name: "ब (Ba)", note: "ओष्ठ्य घोष. Example: baal → बाल", category: .consonants),
        KeyMapItem(roman: "bh, Bh, B", devanagari: "भ", newa: "𑐨", name: "भ (Bha)", note: "ओष्ठ्य घोष महाप्राण. Example: bhat → भात", category: .consonants),
        KeyMapItem(roman: "m", devanagari: "म", newa: "𑐩", name: "म (Ma)", note: "ओष्ठ्य अनुनासिक. Example: ma → म", category: .consonants),

        // MARK: Consonants - Antastha & Ushma
        KeyMapItem(roman: "y", devanagari: "य", newa: "𑐫", name: "य (Ya)", note: "अन्तस्थ. Followed by virama gets ZWNJ: य्‌ / 𑐫𑑂‌", category: .consonants),
        KeyMapItem(roman: "r", devanagari: "र", newa: "𑐬", name: "र (Ra)", note: "कम्पित अन्तस्थ. Example: raat → रात", category: .consonants),
        KeyMapItem(roman: "l", devanagari: "ल", newa: "𑐮", name: "ल (La)", note: "पार्श्विक अन्तस्थ. Example: laal → लाल", category: .consonants),
        KeyMapItem(roman: "v, w", devanagari: "व", newa: "𑐰", name: "व (Va / Wa)", note: "दन्त्यौष्ठ्य अन्तस्थ. Example: vikas → विकास", category: .consonants),
        KeyMapItem(roman: "sh", devanagari: "श", newa: "𑐱", name: "श (Talavya Sha)", note: "तालव्य ऊष्म. Example: shanti → शान्ति", category: .consonants),
        KeyMapItem(roman: "Sh", devanagari: "ष", newa: "𑐲", name: "ष (Murdhanya Sha)", note: "मूर्धन्य ऊष्म (Uppercase S). Example: kaShTa → कष्ट", category: .consonants),
        KeyMapItem(roman: "s, S", devanagari: "स", newa: "𑐳", name: "स (Dantya Sa)", note: "दन्त्य ऊष्म. Example: sach → सच", category: .consonants),
        KeyMapItem(roman: "h", devanagari: "ह", newa: "𑐴", name: "ह (Ha)", note: "कण्ठ्य ऊष्म. Example: haat → हात", category: .consonants),
        KeyMapItem(roman: "L, lh, Lh", devanagari: "ळ", newa: "𑐯", name: "ळ (Retroflex La)", note: "मूर्धन्य ल (वैदिक / नेवा)", category: .consonants),

        // MARK: Vowels
        KeyMapItem(roman: "a", devanagari: "अ", newa: "𑐀", name: "अ (Short a)", note: "Independent vowel or implicit schwa on consonants", category: .vowels),
        KeyMapItem(roman: "aa, A", devanagari: "आ (ा)", newa: "𑐁 (𑐵)", name: "आ / आकार", note: "Long aa. Matra: kaa → का / 𑐎𑐵", category: .vowels),
        KeyMapItem(roman: "i", devanagari: "इ (ि)", newa: "𑐂 (𑐶)", name: "इ / ह्रस्व इकार", note: "Short i. Matra: ki → कि / 𑐎𑐶", category: .vowels),
        KeyMapItem(roman: "ii, ee, I", devanagari: "ई (ी)", newa: "𑐃 (𑐷)", name: "ई / दीर्घ ईकार", note: "Long ii. Matra: kii / kee → की / 𑐎𑐷", category: .vowels),
        KeyMapItem(roman: "u", devanagari: "उ (ु)", newa: "𑐄 (𑐸)", name: "उ / ह्रस्व उकार", note: "Short u. Matra: ku → कु / 𑐎𑐸", category: .vowels),
        KeyMapItem(roman: "uu, oo, U", devanagari: "ऊ (ू)", newa: "𑐅 (𑐹)", name: "ऊ / दीर्घ ऊकार", note: "Long uu. Matra: kuu / koo → कू / 𑐎𑐹", category: .vowels),
        KeyMapItem(roman: "rri", devanagari: "ऋ (ृ)", newa: "𑐆 (𑐺)", name: "ऋ / ऋकार (Vocalic R)", note: "Vocalic R. Example: rriSi → ऋषि, krripa → कृपा", category: .vowels),
        KeyMapItem(roman: "e", devanagari: "ए (े)", newa: "𑐊 (𑐾)", name: "ए / एकार", note: "Vowel e. Matra: ke → के / 𑐎𑐾", category: .vowels),
        KeyMapItem(roman: "ai, E", devanagari: "ऐ (ै)", newa: "𑐋 (𑐿)", name: "ऐ / ऐकार", note: "Diphthong ai. Matra: kai → कै / 𑐎𑐿", category: .vowels),
        KeyMapItem(roman: "o", devanagari: "ओ (ो)", newa: "𑐌 (𑑀)", name: "ओ / ओकार", note: "Vowel o. Matra: ko → को / 𑐎𑑀", category: .vowels),
        KeyMapItem(roman: "au, O", devanagari: "औ (ौ)", newa: "𑐍 (𑑁)", name: "औ / औकार", note: "Diphthong au. Matra: kau → कौ / 𑐎𑑁", category: .vowels),

        // MARK: Conjuncts
        KeyMapItem(roman: "ksh, Ksh, x, X", devanagari: "क्ष", newa: "𑐎𑑂𑐲", name: "क्ष (Ksha)", note: "क + ष संयुक्त. Example: kshama → क्षमा", category: .conjuncts),
        KeyMapItem(roman: "tr, Tr", devanagari: "त्र", newa: "𑐟𑑂𑐬", name: "त्र (Tra)", note: "त + र संयुक्त. Example: patra → पत्र", category: .conjuncts),
        KeyMapItem(roman: "gn, Gn, Z", devanagari: "ज्ञ", newa: "𑐖𑑂𑐘", name: "ज्ञ (Gya)", note: "ज + ञ संयुक्त. Example: gyan → ज्ञान", category: .conjuncts),
        KeyMapItem(roman: "Q", devanagari: "क्व", newa: "𑐎𑑂𑐰", name: "क्व (Q shortcut)", note: "क + व संयुक्त संक्षेप", category: .conjuncts),
        KeyMapItem(roman: "hm", devanagari: "ह्म", newa: "𑐴𑑂𑐩", name: "ह्म (Hma)", note: "ह + म संयुक्त. Example: brahma → ब्रह्म", category: .conjuncts),
        KeyMapItem(roman: "hn", devanagari: "ह्न", newa: "𑐴𑑂𑐣", name: "ह्न (Hna)", note: "ह + न संयुक्त. Example: chinha → चिह्न", category: .conjuncts),
        KeyMapItem(roman: "ng + h", devanagari: "ङ्ह", newa: "𑐓", name: "𑐓 (Newa letter NGAH)", note: "Newa independent aspirated letter NGAH", category: .conjuncts),
        KeyMapItem(roman: "nh + h", devanagari: "ञ्ह", newa: "𑐙", name: "𑐙 (Newa letter NYAH)", note: "Newa independent aspirated letter NYAH", category: .conjuncts),
        KeyMapItem(roman: "r + h", devanagari: "र्ह", newa: "𑐭", name: "𑐭 (Newa letter RHA)", note: "Newa independent aspirated letter RHA", category: .conjuncts),

        // MARK: Diacritics
        KeyMapItem(roman: "M", devanagari: "ं", newa: "𑑄", name: "Anusvara (शिरोबिन्दु)", note: "Nasal dot. Example: saMbidhan → संविधान / 𑐳𑑄𑐰𑐶𑐢𑐵𑐣", category: .diacritics),
        KeyMapItem(roman: "~", devanagari: "ँ", newa: "𑑃", name: "Chandrabindu (चन्द्रबिन्दु)", note: "Nasal sign. Example: kaha~ → कहाँ / 𑐎𑐴𑐵𑑃", category: .diacritics),
        KeyMapItem(roman: "H", devanagari: "ः", newa: "𑑅", name: "Visarga (विसर्ग)", note: "Voiceless aspiration. Example: duHkha → दुःख / 𑐡𑐸𑑅𑐏", category: .diacritics),
        KeyMapItem(roman: "|", devanagari: "्", newa: "𑑂", name: "Virama / Halant (हलन्त)", note: "Explicit vowel suppressor. Example: k| → क् / 𑐎𑑂", category: .diacritics),
        KeyMapItem(roman: "'", devanagari: "ऽ", newa: "ऽ", name: "Avagraha (अवग्रह)", note: "Elision / prolongation sign (U+093D)", category: .diacritics),

        // MARK: Numbers & Punctuation
        KeyMapItem(roman: "0 ... 9", devanagari: "० - ९", newa: "𑑐 - 𑑙", name: "Digits (अंकहरु)", note: "0=०(𑑐), 1=१(𑑑), 2=२(𑑒), 3=३(𑑓), 4=४(𑑔), 5=५(𑑕), 6=६(𑑖), 7=७(𑑗), 8=८(𑑘), 9=९(𑑙)", category: .numbers),
        KeyMapItem(roman: ".", devanagari: "।", newa: "𑑋", name: "Purna Virama (पूर्णविराम)", note: "Single Danda sentence separator", category: .numbers),
        KeyMapItem(roman: "..", devanagari: "॥", newa: "𑑌", name: "Dirgha Virama (दीर्घविराम)", note: "Double Danda stanza / section separator", category: .numbers),
    ]

    private let ruleItems: [TransliterationRuleItem] = [
        TransliterationRuleItem(
            title: "Automatic Halant between Consonants",
            romanExample: "kt → क्त",
            devaResult: "क्त",
            newaResult: "𑐎𑑂𑐟",
            explanation: "When you type two consonants consecutively without a vowel (like 'k' followed by 't'), a Virama (Halant) is automatically inserted between them to form a ligature or conjunct.",
            badge: "Ligature"
        ),
        TransliterationRuleItem(
            title: "Ya + Virama Autocorrect (ZWNJ)",
            romanExample: "y + | → य्‌",
            devaResult: "य्‌",
            newaResult: "𑐫𑑂‌",
            explanation: "Typing 'y' followed by Virama/Halant automatically attaches a Zero-Width Non-Joiner (U+200C). This preserves the authentic half-Ya glyph (य्‌ / 𑐫𑑂‌) and prevents undesirable ligatures.",
            badge: "Autocorrect"
        ),
        TransliterationRuleItem(
            title: "Vocalic ऋ vs Consonant Ri",
            romanExample: "rri → ऋ vs ri → रि",
            devaResult: "ऋषि vs रितु",
            newaResult: "𑐆𑐲𑐶 vs 𑐬𑐶𑐟𑐸",
            explanation: "Type 'rri' for the Sanskrit vocalic vowel ऋ (or matra ृ after consonants, e.g. 'krripa' → कृपा). Type 'ri' for the normal consonant र + matra ि (e.g. 'ritu' → रितु).",
            badge: "Vowels"
        ),
        TransliterationRuleItem(
            title: "Retroflex vs Dental Distinction",
            romanExample: "T/D/N vs t/d/n",
            devaResult: "ट/ड/ण vs त/द/न",
            newaResult: "𑐚/𑐜/𑐞 vs 𑐟/𑐡/𑐣",
            explanation: "Capital letters 'T', 'D', 'N', 'Sh' map to retroflex (मूर्धन्य) sounds (ट, ड, ण, ष). Lowercase 't', 'd', 'n', 's' map to dental (दन्त्य) sounds (त, द, न, स).",
            badge: "Casing"
        ),
        TransliterationRuleItem(
            title: "Newa Special Aspirated Triplets",
            romanExample: "ng+h, nh+h, r+h",
            devaResult: "ङ्ह, ञ्ह, र्ह",
            newaResult: "𑐓, 𑐙, 𑐭",
            explanation: "The transliteration engine automatically converts ङ+्+ह, ञ+्+ह, and र+्+ह into the dedicated native Nepal Lipi letters NGAH (𑐓), NYAH (𑐙), and RHA (𑐭).",
            badge: "Nepal Lipi"
        )
    ]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Key Maps"
        view.backgroundColor = .systemGroupedBackground

        setupInteractiveTestBox()
        setupControls()
        setupTableView()
        filterData()
    }

    // MARK: - UI Setup

    private func setupInteractiveTestBox() {
        testContainerView.translatesAutoresizingMaskIntoConstraints = false
        testContainerView.backgroundColor = .secondarySystemGroupedBackground
        testContainerView.layer.cornerRadius = 14
        testContainerView.layer.cornerCurve = .continuous
        testContainerView.clipsToBounds = true

        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = "TRY TRANSLITERATION"
        headerLabel.font = .systemFont(ofSize: 11.5, weight: .bold)
        headerLabel.textColor = .secondaryLabel

        testTextField.translatesAutoresizingMaskIntoConstraints = false
        testTextField.placeholder = "Type in Roman (e.g. namaste, ksh, rri, nepal)"
        testTextField.font = .systemFont(ofSize: 16, weight: .regular)
        testTextField.autocapitalizationType = .none
        testTextField.autocorrectionType = .no
        testTextField.clearButtonMode = .whileEditing
        testTextField.addTarget(self, action: #selector(testTextFieldChanged(_:)), for: .editingChanged)

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .separator

        // Devanagari output row
        let devaBadge = createScriptBadge(text: "देवनागरी", color: .systemOrange)
        devaResultLabel.translatesAutoresizingMaskIntoConstraints = false
        devaResultLabel.font = .systemFont(ofSize: 19, weight: .semibold)
        devaResultLabel.textColor = .label
        devaResultLabel.text = "नमस्ते"

        let devaStack = UIStackView(arrangedSubviews: [devaBadge, devaResultLabel])
        devaStack.translatesAutoresizingMaskIntoConstraints = false
        devaStack.axis = .horizontal
        devaStack.spacing = 10
        devaStack.alignment = .center

        // Newa output row
        let newaBadge = createScriptBadge(text: "नेपाल लिपि", color: .systemIndigo)
        newaResultLabel.translatesAutoresizingMaskIntoConstraints = false
        newaResultLabel.font = .systemFont(ofSize: 19, weight: .semibold)
        newaResultLabel.textColor = .label
        newaResultLabel.text = "𑐣𑐩𑐳𑑂𑐟𑐾"

        let newaStack = UIStackView(arrangedSubviews: [newaBadge, newaResultLabel])
        newaStack.translatesAutoresizingMaskIntoConstraints = false
        newaStack.axis = .horizontal
        newaStack.spacing = 10
        newaStack.alignment = .center

        view.addSubview(testContainerView)
        testContainerView.addSubview(headerLabel)
        testContainerView.addSubview(testTextField)
        testContainerView.addSubview(divider)
        testContainerView.addSubview(devaStack)
        testContainerView.addSubview(newaStack)

        NSLayoutConstraint.activate([
            testContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            testContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            testContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            headerLabel.topAnchor.constraint(equalTo: testContainerView.topAnchor, constant: 12),
            headerLabel.leadingAnchor.constraint(equalTo: testContainerView.leadingAnchor, constant: 14),
            headerLabel.trailingAnchor.constraint(equalTo: testContainerView.trailingAnchor, constant: -14),

            testTextField.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 6),
            testTextField.leadingAnchor.constraint(equalTo: testContainerView.leadingAnchor, constant: 14),
            testTextField.trailingAnchor.constraint(equalTo: testContainerView.trailingAnchor, constant: -14),
            testTextField.heightAnchor.constraint(equalToConstant: 32),

            divider.topAnchor.constraint(equalTo: testTextField.bottomAnchor, constant: 8),
            divider.leadingAnchor.constraint(equalTo: testContainerView.leadingAnchor, constant: 14),
            divider.trailingAnchor.constraint(equalTo: testContainerView.trailingAnchor, constant: -14),
            divider.heightAnchor.constraint(equalToConstant: 0.5),

            devaStack.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 8),
            devaStack.leadingAnchor.constraint(equalTo: testContainerView.leadingAnchor, constant: 14),
            devaStack.trailingAnchor.constraint(equalTo: testContainerView.trailingAnchor, constant: -14),

            newaStack.topAnchor.constraint(equalTo: devaStack.bottomAnchor, constant: 6),
            newaStack.leadingAnchor.constraint(equalTo: testContainerView.leadingAnchor, constant: 14),
            newaStack.trailingAnchor.constraint(equalTo: testContainerView.trailingAnchor, constant: -14),
            newaStack.bottomAnchor.constraint(equalTo: testContainerView.bottomAnchor, constant: -12)
        ])
    }

    private func createScriptBadge(text: String, color: UIColor) -> UIView {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = color

        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = color.withAlphaComponent(0.12)
        container.layer.cornerRadius = 6
        container.layer.cornerCurve = .continuous
        container.addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 3),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -3),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 8),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -8)
        ])
        return container
    }

    private func setupControls() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = "Search Roman, Devanagari or Newa"
        searchBar.delegate = self

        view.addSubview(searchBar)
        view.addSubview(pillScrollView)
        pillScrollView.addSubview(pillStackView)

        for (index, category) in KeyMapCategory.allCases.enumerated() {
            let button = createPillButton(for: category, index: index)
            pillButtons.append(button)
            pillStackView.addArrangedSubview(button)
        }
        updatePillStyles()

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: testContainerView.bottomAnchor, constant: 6),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            pillScrollView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 2),
            pillScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pillScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pillScrollView.heightAnchor.constraint(equalToConstant: 38),

            pillStackView.topAnchor.constraint(equalTo: pillScrollView.contentLayoutGuide.topAnchor),
            pillStackView.bottomAnchor.constraint(equalTo: pillScrollView.contentLayoutGuide.bottomAnchor),
            pillStackView.leadingAnchor.constraint(equalTo: pillScrollView.contentLayoutGuide.leadingAnchor),
            pillStackView.trailingAnchor.constraint(equalTo: pillScrollView.contentLayoutGuide.trailingAnchor),
            pillStackView.heightAnchor.constraint(equalTo: pillScrollView.frameLayoutGuide.heightAnchor)
        ])
    }

    private func createPillButton(for category: KeyMapCategory, index: Int) -> UIButton {
        var config = UIButton.Configuration.filled()
        config.title = category.displayName
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 7, leading: 14, bottom: 7, trailing: 14)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 13, weight: .semibold)
            return outgoing
        }

        let button = UIButton(configuration: config)
        button.tag = index
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(pillTapped(_:)), for: .touchUpInside)
        return button
    }

    private func updatePillStyles() {
        for (index, button) in pillButtons.enumerated() {
            let isSelected = (index == selectedCategoryIndex)
            var config = button.configuration ?? UIButton.Configuration.filled()
            if isSelected {
                config.baseBackgroundColor = .systemBlue
                config.baseForegroundColor = .white
                config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var outgoing = incoming
                    outgoing.font = .systemFont(ofSize: 13, weight: .bold)
                    return outgoing
                }
            } else {
                config.baseBackgroundColor = .secondarySystemGroupedBackground
                config.baseForegroundColor = .secondaryLabel
                config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                    var outgoing = incoming
                    outgoing.font = .systemFont(ofSize: 13, weight: .medium)
                    return outgoing
                }
            }
            button.configuration = config
        }
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(KeyMapItemCell.self, forCellReuseIdentifier: "KeyMapItemCell")
        tableView.register(TransliterationRuleCell.self, forCellReuseIdentifier: "TransliterationRuleCell")
        tableView.keyboardDismissMode = .onDrag

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: pillScrollView.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Actions & Filtering

    @objc private func testTextFieldChanged(_ sender: UITextField) {
        let input = sender.text ?? ""
        if input.isEmpty {
            devaResultLabel.text = "नमस्ते"
            newaResultLabel.text = "𑐣𑐩𑐳𑑂𑐟𑐾"
            return
        }

        let deva = NepaliTransliterator.transliterate(input)
        let newa = NepaliTransliterator.devaToNewa(deva)
        devaResultLabel.text = deva
        newaResultLabel.text = newa
    }

    @objc private func pillTapped(_ sender: UIButton) {
        selectedCategoryIndex = sender.tag
        selectedCategory = KeyMapCategory.allCases[sender.tag]
        updatePillStyles()

        let rect = sender.convert(sender.bounds, to: pillScrollView)
        pillScrollView.scrollRectToVisible(rect.insetBy(dx: -24, dy: 0), animated: true)
        filterData()
    }

    private func filterData() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if selectedCategory == .rules {
            filteredItems = []
        } else {
            filteredItems = items.filter { item in
                let categoryMatches = (selectedCategory == .all) || (item.category == selectedCategory)
                if !categoryMatches { return false }

                if query.isEmpty { return true }
                return item.roman.lowercased().contains(query) ||
                    item.devanagari.contains(query) ||
                    item.newa.contains(query) ||
                    item.name.lowercased().contains(query) ||
                    item.note.lowercased().contains(query)
            }
        }

        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension KeyMapsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        filterData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension KeyMapsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if selectedCategory == .rules {
            return 1
        }
        return (selectedCategory == .all && searchText.isEmpty) ? 2 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedCategory == .rules {
            return ruleItems.count
        }
        if selectedCategory == .all && searchText.isEmpty {
            if section == 0 {
                return filteredItems.count
            } else {
                return ruleItems.count
            }
        }
        return filteredItems.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if selectedCategory == .rules {
            return "Transliteration Rules & Autocorrect"
        }
        if selectedCategory == .all && searchText.isEmpty {
            return section == 0 ? "Character Mappings" : "Special Typing Rules & Autocorrect"
        }
        return "\(selectedCategory.rawValue) (\(filteredItems.count))"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isRuleSection = (selectedCategory == .rules) || (selectedCategory == .all && searchText.isEmpty && indexPath.section == 1)

        if isRuleSection {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransliterationRuleCell", for: indexPath) as? TransliterationRuleCell else {
                return UITableViewCell()
            }
            let rule = ruleItems[indexPath.row]
            cell.configure(with: rule)
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "KeyMapItemCell", for: indexPath) as? KeyMapItemCell else {
            return UITableViewCell()
        }
        let item = filteredItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let isRuleSection = (selectedCategory == .rules) || (selectedCategory == .all && searchText.isEmpty && indexPath.section == 1)
        if !isRuleSection {
            let item = filteredItems[indexPath.row]
            let firstKey = item.roman.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespaces) ?? item.roman
            testTextField.text = firstKey
            testTextFieldChanged(testTextField)
            testTextField.becomeFirstResponder()
        }
    }
}

// MARK: - KeyMapItemCell (Roman Keystroke -> Devanagari & Newa)

class KeyMapItemCell: UITableViewCell {

    private let keyBadgeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedSystemFont(ofSize: 13, weight: .bold)
        label.textColor = .systemBlue
        label.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        label.layer.cornerRadius = 6
        label.layer.cornerCurve = .continuous
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()

    private let devaGlyphLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()

    private let newaGlyphLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .systemIndigo
        label.textAlignment = .center
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let noteLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12.5, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
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
        contentView.addSubview(keyBadgeLabel)

        let glyphStack = UIStackView(arrangedSubviews: [devaGlyphLabel, newaGlyphLabel])
        glyphStack.translatesAutoresizingMaskIntoConstraints = false
        glyphStack.axis = .horizontal
        glyphStack.spacing = 10
        glyphStack.alignment = .center

        let textStack = UIStackView(arrangedSubviews: [nameLabel, noteLabel])
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading

        contentView.addSubview(glyphStack)
        contentView.addSubview(textStack)

        NSLayoutConstraint.activate([
            // Left: Monospace Roman keystroke badge
            keyBadgeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            keyBadgeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            keyBadgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            keyBadgeLabel.heightAnchor.constraint(equalToConstant: 28),

            // Middle: Glyphs (Deva + Newa)
            glyphStack.leadingAnchor.constraint(equalTo: keyBadgeLabel.trailingAnchor, constant: 12),
            glyphStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            glyphStack.widthAnchor.constraint(equalToConstant: 70),

            // Right: Name + Note details
            textStack.leadingAnchor.constraint(equalTo: glyphStack.trailingAnchor, constant: 10),
            textStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    func configure(with item: KeyMapsViewController.KeyMapItem) {
        keyBadgeLabel.text = " \(item.roman) "
        devaGlyphLabel.text = item.devanagari
        newaGlyphLabel.text = item.newa
        nameLabel.text = item.name
        noteLabel.text = item.note
    }
}

// MARK: - TransliterationRuleCell (Special Rules & Autocorrect)

class TransliterationRuleCell: UITableViewCell {

    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .systemGreen
        label.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.12)
        label.layer.cornerRadius = 5
        label.layer.cornerCurve = .continuous
        label.clipsToBounds = true
        label.textAlignment = .center
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15.5, weight: .bold)
        label.textColor = .label
        return label
    }()

    private let exampleContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .tertiarySystemGroupedBackground
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        return view
    }()

    private let romanExampleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .monospacedSystemFont(ofSize: 13, weight: .semibold)
        label.textColor = .systemBlue
        return label
    }()

    private let resultGlyphsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .label
        return label
    }()

    private let explanationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
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
        selectionStyle = .none

        let topRow = UIStackView(arrangedSubviews: [badgeLabel, titleLabel])
        topRow.translatesAutoresizingMaskIntoConstraints = false
        topRow.axis = .horizontal
        topRow.spacing = 8
        topRow.alignment = .center

        exampleContainer.addSubview(romanExampleLabel)
        exampleContainer.addSubview(resultGlyphsLabel)

        contentView.addSubview(topRow)
        contentView.addSubview(exampleContainer)
        contentView.addSubview(explanationLabel)

        NSLayoutConstraint.activate([
            topRow.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            topRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            topRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),

            badgeLabel.heightAnchor.constraint(equalToConstant: 20),
            badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 54),

            exampleContainer.topAnchor.constraint(equalTo: topRow.bottomAnchor, constant: 8),
            exampleContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            exampleContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            exampleContainer.heightAnchor.constraint(equalToConstant: 34),

            romanExampleLabel.leadingAnchor.constraint(equalTo: exampleContainer.leadingAnchor, constant: 10),
            romanExampleLabel.centerYAnchor.constraint(equalTo: exampleContainer.centerYAnchor),

            resultGlyphsLabel.trailingAnchor.constraint(equalTo: exampleContainer.trailingAnchor, constant: -10),
            resultGlyphsLabel.centerYAnchor.constraint(equalTo: exampleContainer.centerYAnchor),

            explanationLabel.topAnchor.constraint(equalTo: exampleContainer.bottomAnchor, constant: 8),
            explanationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            explanationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14),
            explanationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(with rule: KeyMapsViewController.TransliterationRuleItem) {
        badgeLabel.text = " \(rule.badge) "
        titleLabel.text = rule.title
        romanExampleLabel.text = rule.romanExample
        resultGlyphsLabel.text = "→ \(rule.devaResult)  /  \(rule.newaResult)"
        explanationLabel.text = rule.explanation
    }
}
