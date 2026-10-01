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
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 4),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -4),
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
                // Wrap separator in a container to maintain 50% height with .fill alignment
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
    
    // 3. Replace makePillButton to use modern configuration:
    private func makePillButton(title: String, colors: ThemeColors) -> UIButton {
        var config = UIButton.Configuration.plain()
        
        var container = AttributeContainer()
        container.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        config.attributedTitle = AttributedString(title, attributes: container)
        config.baseForegroundColor = colors.textColor
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14)
        
        let button = UIButton(configuration: config)
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

