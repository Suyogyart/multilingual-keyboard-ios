//
//  EmojiKeyboardView.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 02/04/26.
//

import UIKit

protocol EmojiKeyboardDelegate: AnyObject {
    func didSelectEmoji(_ emoji: String)
    func didTapABCKey()
    func didTapBackspace()
}

class EmojiKeyboardView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: EmojiKeyboardDelegate?
    
    private let categories = EmojiCategory.allCategories
    private var collectionView: UICollectionView!
    private let categoryBar = UIStackView()
    private let abcButton = UIButton(type: .system)
    private let backspaceButton = UIButton(type: .system)
    private var backspaceTimer: Timer?
    private var selectedCategoryIndex = 0
    
    private static let cellID = "EmojiCell"
    private static let headerID = "SectionHeader"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        let colors = ThemeManager.current(traitCollection: traitCollection)
        
        setupTopBar(colors: colors)
        setupCollectionView(colors: colors)
        setupCategoryBar(colors: colors)
        layoutAllViews()
    }
    
    // MARK: - Top Bar (ABC + Backspace)
    
    private func setupTopBar(colors: ThemeColors) {
        abcButton.setTitle("ABC", for: .normal)
        abcButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        abcButton.setTitleColor(colors.textColor, for: .normal)
        abcButton.backgroundColor = colors.specialKeyBackground
        abcButton.layer.cornerRadius = 6
        abcButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        abcButton.setContentHuggingPriority(.required, for: .horizontal)
        abcButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        abcButton.addTarget(self, action: #selector(abcTapped), for: .touchUpInside)
        abcButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(abcButton)
        
        let deleteIcon = UIImage(systemName: "delete.left")
        backspaceButton.setImage(deleteIcon, for: .normal)
        backspaceButton.tintColor = colors.textColor
        backspaceButton.backgroundColor = colors.specialKeyBackground
        backspaceButton.layer.cornerRadius = 6
        backspaceButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
        backspaceButton.setContentHuggingPriority(.required, for: .horizontal)
        backspaceButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        backspaceButton.addTarget(self, action: #selector(backspaceTapped), for: .touchUpInside)
        backspaceButton.addTarget(self, action: #selector(backspaceHeld), for: .touchDown)
        backspaceButton.addTarget(self, action: #selector(backspaceReleased), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        backspaceButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backspaceButton)
    }
    
    // MARK: - Collection View
    
    private func setupCollectionView(colors: ThemeColors) {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 6
        layout.sectionInset = UIEdgeInsets(top: 4, left: 6, bottom: 8, right: 6)
        layout.headerReferenceSize = CGSize(width: 0, height: 28)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: Self.cellID)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Self.headerID)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
    }
    
    // MARK: - Category Bar
    
    private func setupCategoryBar(colors: ThemeColors) {
        categoryBar.axis = .horizontal
        categoryBar.distribution = .fillEqually
        categoryBar.alignment = .center
        categoryBar.spacing = 0
        categoryBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(categoryBar)
        
        for (index, category) in categories.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(category.displayIcon, for: .normal)
            btn.titleLabel?.font = .systemFont(ofSize: 20)
            btn.tag = index
            btn.addTarget(self, action: #selector(categoryTapped(_:)), for: .touchUpInside)
            if index == 0 {
                btn.alpha = 1.0
            } else {
                btn.alpha = 0.5
            }
            categoryBar.addArrangedSubview(btn)
        }
    }
    
    // MARK: - Layout
    
    private func layoutAllViews() {
        NSLayoutConstraint.activate([
            abcButton.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            abcButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            abcButton.heightAnchor.constraint(equalToConstant: 30),
            
            backspaceButton.centerYAnchor.constraint(equalTo: abcButton.centerYAnchor),
            backspaceButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            backspaceButton.heightAnchor.constraint(equalToConstant: 30),
            
            categoryBar.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            categoryBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            categoryBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            categoryBar.heightAnchor.constraint(equalToConstant: 36),
            
            collectionView.topAnchor.constraint(equalTo: abcButton.bottomAnchor, constant: 4),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: categoryBar.topAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func abcTapped() {
        delegate?.didTapABCKey()
    }
    
    @objc private func backspaceTapped() {
        delegate?.didTapBackspace()
    }
    
    @objc private func backspaceHeld() {
        backspaceTimer?.invalidate()
        backspaceTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.delegate?.didTapBackspace()
        }
    }
    
    @objc private func backspaceReleased() {
        backspaceTimer?.invalidate()
        backspaceTimer = nil
    }
    
    @objc private func categoryTapped(_ sender: UIButton) {
        let index = sender.tag
        selectedCategoryIndex = index
        updateCategoryHighlight()
        
        if collectionView.numberOfSections > index {
            collectionView.scrollToItem(at: IndexPath(item: 0, section: index), at: .top, animated: true)
        }
    }
    
    private func updateCategoryHighlight() {
        for (i, view) in categoryBar.arrangedSubviews.enumerated() {
            view.alpha = (i == selectedCategoryIndex) ? 1.0 : 0.5
        }
    }
    
    // MARK: - UICollectionView DataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].emoji.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.cellID, for: indexPath) as! EmojiCell
        cell.configure(with: categories[indexPath.section].emoji[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Self.headerID, for: indexPath) as! SectionHeaderView
        header.configure(with: categories[indexPath.section].displayName, colors: ThemeManager.current(traitCollection: traitCollection))
        return header
    }
    
    // MARK: - UICollectionView Delegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns: CGFloat = 8
        let inset: CGFloat = 6 * 2
        let spacing: CGFloat = 2 * (columns - 1)
        let width = (collectionView.bounds.width - inset - spacing) / columns
        return CGSize(width: floor(width), height: floor(width))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell,
              let emoji = cell.currentEmoji else { return }
        delegate?.didSelectEmoji(emoji)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let topIndexPath = collectionView.indexPathsForVisibleItems.min(by: { $0.section < $1.section }) {
            if topIndexPath.section != selectedCategoryIndex {
                selectedCategoryIndex = topIndexPath.section
                updateCategoryHighlight()
            }
        }
    }
    
    func reloadRecents() {
        collectionView.reloadSections(IndexSet(integer: 0))
    }
    
    // MARK: - Theme
    
    func applyTheme() {
        let colors = ThemeManager.current(traitCollection: traitCollection)
        self.overrideUserInterfaceStyle = colors.interfaceStyle
        
        abcButton.setTitleColor(colors.textColor, for: .normal)
        abcButton.backgroundColor = colors.specialKeyBackground
        backspaceButton.tintColor = colors.textColor
        backspaceButton.backgroundColor = colors.specialKeyBackground
        
        collectionView.reloadData()
    }
}

// MARK: - Emoji Cell

private class EmojiCell: UICollectionViewCell {
    private let label = UILabel()
    private(set) var currentEmoji: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = .systemFont(ofSize: 28)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with emoji: String) {
        currentEmoji = emoji
        label.text = emoji
    }
}

// MARK: - Section Header

private class SectionHeaderView: UICollectionReusableView {
    private let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(with title: String, colors: ThemeColors) {
        label.text = title
        label.textColor = colors.textColor.withAlphaComponent(0.6)
    }
}
