//
//  WordSuggestionEngine.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 01/04/26.
//

import Foundation

private class TrieNode {
    var children: [Character: TrieNode] = [:]
    var rank: Int?
}

class WordSuggestionEngine {
    
    private var root = TrieNode()
    private var bigramMap: [String: [String]] = [:]
    private(set) var isReady = false
    private var currentLanguage: KeyboardLanguage?
    
    func load(for language: KeyboardLanguage) {
        guard language != currentLanguage else { return }
        
        root = TrieNode()
        bigramMap = [:]
        isReady = false
        currentLanguage = language
        
        let bundle = Bundle(for: type(of: self))
        let wordsFilename = "\(language.rawValue)-words"
        let bigramsFilename = "\(language.rawValue)-bigrams"
        
        let wordsURL = bundle.url(forResource: wordsFilename, withExtension: "txt")
        let bigramsURL = bundle.url(forResource: bigramsFilename, withExtension: "txt")
        
        guard wordsURL != nil else { return }
        
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let self = self else { return }
            
            let newRoot = TrieNode()
            if let url = wordsURL, let data = try? Data(contentsOf: url),
               let contents = String(data: data, encoding: .utf8) {
                var rank = 0
                contents.enumerateLines { line, _ in
                    let word = line.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                    guard !word.isEmpty else { return }
                    
                    var node = newRoot
                    for char in word {
                        if node.children[char] == nil {
                            node.children[char] = TrieNode()
                        }
                        node = node.children[char]!
                    }
                    node.rank = rank
                    rank += 1
                }
            }
            
            var newBigrams: [String: [String]] = [:]
            if let url = bigramsURL, let data = try? Data(contentsOf: url),
               let contents = String(data: data, encoding: .utf8) {
                contents.enumerateLines { line, _ in
                    let parts = line.split(separator: "\t", maxSplits: 1)
                    guard parts.count == 2 else { return }
                    let word = String(parts[0]).lowercased()
                    let followers = parts[1].split(separator: ",").map { String($0).lowercased() }
                    newBigrams[word] = followers
                }
            }
            
            DispatchQueue.main.async {
                self.root = newRoot
                self.bigramMap = newBigrams
                self.isReady = true
            }
        }
    }
    
    private static let defaultStarters = ["I", "the", "hello", "how", "what"]
    
    func starterSuggestions() -> [String] {
        return Self.defaultStarters
    }
    
    func nextWordSuggestions(after word: String, limit: Int = 5) -> [String] {
        guard isReady, !word.isEmpty else { return [] }
        return Array(bigramMap[word.lowercased()]?.prefix(limit) ?? [])
    }
    
    func suggestions(for prefix: String, limit: Int = 5) -> [String] {
        guard isReady, !prefix.isEmpty else { return [] }
        
        let lowered = prefix.lowercased()
        
        var node = root
        for char in lowered {
            guard let child = node.children[char] else { return [] }
            node = child
        }
        
        var results: [(word: String, rank: Int)] = []
        collectWords(node: node, prefix: lowered, results: &results, limit: limit * 4)
        
        results.sort { $0.rank < $1.rank }
        
        let filtered = results.prefix(limit).map { $0.word }
        return filtered.filter { $0 != lowered }
    }
    
    private func collectWords(node: TrieNode, prefix: String, results: inout [(word: String, rank: Int)], limit: Int) {
        if results.count >= limit { return }
        
        if let rank = node.rank {
            results.append((prefix, rank))
        }
        
        for (char, child) in node.children.sorted(by: { ($0.value.rank ?? Int.max) < ($1.value.rank ?? Int.max) }) {
            if results.count >= limit { return }
            collectWords(node: child, prefix: prefix + String(char), results: &results, limit: limit)
        }
    }
}
