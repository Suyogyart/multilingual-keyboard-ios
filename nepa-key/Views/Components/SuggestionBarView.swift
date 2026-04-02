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
    
    static let barHeight: CGFloat = 40.0
    
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
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)
        
        contentStack.axis = .horizontal
        contentStack.spacing = 6
        contentStack.alignment = .center
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
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
        
        for (index, word) in words.enumerated() {
            if index > 0 {
                let separator = UIView()
                separator.translatesAutoresizingMaskIntoConstraints = false
                separator.backgroundColor = colors.textColor.withAlphaComponent(0.15)
                contentStack.addArrangedSubview(separator)
                NSLayoutConstraint.activate([
                    separator.widthAnchor.constraint(equalToConstant: 1),
                    separator.heightAnchor.constraint(equalTo: contentStack.heightAnchor, multiplier: 0.5)
                ])
            }
            
            let button = makePillButton(title: word, colors: colors)
            contentStack.addArrangedSubview(button)
        }
        
        scrollView.setContentOffset(.zero, animated: false)
    }
    
    private func makePillButton(title: String, colors: ThemeColors) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        button.setTitleColor(colors.textColor, for: .normal)
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
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
        
        for view in contentStack.arrangedSubviews {
            if let button = view as? UIButton {
                button.setTitleColor(colors.textColor, for: .normal)
            } else {
                view.backgroundColor = colors.textColor.withAlphaComponent(0.15)
            }
        }
    }
}
