//
//  AboutCallijatraViewController.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 01/10/26.
//
import UIKit

class AboutCallijatraViewController: UIViewController {

    private let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isScrollEnabled = true
        tv.dataDetectorTypes = [.link]
        tv.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 24, right: 16)
        tv.backgroundColor = .systemBackground
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About Callijatra"
        view.backgroundColor = .systemBackground

        setupLayout()
        loadMarkdownContent()
    }

    private func setupLayout() {
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func loadMarkdownContent() {
        // Option A: Load from bundle .md file
        guard let url = Bundle.main.url(forResource: "AboutCallijatra", withExtension: "md"),
              let rawString = try? String(contentsOf: url) else {
            return
        }

        // Option B: Or use an inline String:
        // let rawString = """
        // ### This keyboard
        // Nepal Lipi Keyboard is one of those Lipi tools...
        // [Lipi tools](https://callijatra.github.io)
        // """

        do {
            // Parse Markdown into modern AttributedString
            var attributedString = try AttributedString(
                markdown: rawString,
                options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
            )
            
            // Apply a default font size and color
            attributedString.font = UIFont.systemFont(ofSize: 15)
            attributedString.foregroundColor = UIColor.label

            // Bridge to NSAttributedString for UIKit
            textView.attributedText = NSAttributedString(attributedString)
        } catch {
            print("Markdown parsing error: \(error)")
        }
    }
}
