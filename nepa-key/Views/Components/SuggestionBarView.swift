//
//  SuggestionBarView.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 01/04/26.
//

import UIKit

protocol SuggestionBarDelegate: AnyObject {
    func didSelectSuggestion(_ word: String)
}

class SuggestionBarView: UIView {
    
    static let barHeight: CGFloat = 44.0
    
    weak var delegate: SuggestionBarDelegate?
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupTraitObservation()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupTraitObservation()
    }
    
    private func setupViews() {
        let colors = ThemeManager.current(traitCollection: traitCollection)
        backgroundColor = KeyboardSettings.shared.enableKeyboardBackground ? colors.keyboardBackground : UIColor.clear
        
        scrollView.layer.cornerRadius = 10
        scrollView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        scrollView.clipsToBounds = true

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        contentStack.axis = .horizontal
        contentStack.spacing = 6
        contentStack.alignment = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 4),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -4),
            
            // Locks vertical height, allows horizontal scroll
            contentStack.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
        ])
    }
    
    private func setupTraitObservation() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (view: SuggestionBarView, _) in
                view.applyTheme()
            }
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #unavailable(iOS 17.0) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                applyTheme()
            }
        }
    }
    
    func updateSuggestions(_ words: [String]) {
        contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard !words.isEmpty else { return }
        
        let colors = ThemeManager.current(traitCollection: traitCollection)
        
        // 2. In updateSuggestions(_:), update the loop:
        for (index, word) in words.enumerated() {
            if index > 0 {
                let separatorContainer = UIView()
                let separator = UIView()
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.backgroundColor = colors.textColor.withAlphaComponent(0.15)
                
                separatorContainer.addSubview(separator)
                contentStack.addArrangedSubview(separatorContainer)
                
                NSLayoutConstraint.activate([
                    separatorContainer.widthAnchor.constraint(equalToConstant: 1),
                    separator.widthAnchor.constraint(equalTo: separatorContainer.widthAnchor),
                    separator.heightAnchor.constraint(equalTo: separatorContainer.heightAnchor, multiplier: 0.5),
                    separator.centerYAnchor.constraint(equalTo: separatorContainer.centerYAnchor),
                    separator.centerXAnchor.constraint(equalTo: separatorContainer.centerXAnchor)
                ])
            }
            
            let button = makePillButton(title: word, colors: colors)
            contentStack.addArrangedSubview(button)
            
            // Note: The explicit button.heightAnchor constraint is completely removed here.
        }
        
        scrollView.setContentOffset(.zero, animated: false)
    }
    
    private func makePillButton(title: String, colors: ThemeColors) -> UIButton {
        let button = UIButton(type: .custom)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.setTitleColor(colors.textColor, for: .normal)
        
        // CRITICAL: Pin alignment to top. This guarantees an integer Y-origin of 0, entirely preventing Retina blur.
        button.contentVerticalAlignment = .top
        
        // Push the text to the visual center. (44pt bar height - 18pt font height = 26pt diff / 2 = 13pt inset)
        button.contentEdgeInsets = UIEdgeInsets(top: 13, left: 14, bottom: 13, right: 14)
        
        button.addTarget(self, action: #selector(suggestionTapped(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func suggestionTapped(_ sender: UIButton) {
        guard let word = sender.title(for: .normal) else { return }
        delegate?.didSelectSuggestion(word)
    }
    
    func applyTheme() {
        let colors = ThemeManager.current(traitCollection: traitCollection)
        self.overrideUserInterfaceStyle = colors.interfaceStyle
        
        if !KeyboardSettings.shared.enableKeyboardBackground {
            scrollView.backgroundColor = .clear
        } else if KeyboardSettings.shared.selectedTheme == .system {
            scrollView.backgroundColor = .clear
        } else {
            scrollView.backgroundColor = colors.keyboardBackground
        }
        
        for view in contentStack.arrangedSubviews {
            if let button = view as? UIButton {
                button.setTitleColor(colors.textColor, for: .normal)
            } else {
                view.backgroundColor = colors.textColor.withAlphaComponent(0.15)
            }
        }
    }
}

