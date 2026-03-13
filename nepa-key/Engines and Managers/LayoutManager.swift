//
//  LayoutManager.swift
//  multilingual-keyboard
//
//  Created by Suyogya Ratna Tamrakar on 13/03/26.
//

import Foundation

class LayoutManager {
    
    /// Loads and parses a keyboard layout JSON file.
    /// - Parameter filename: The name of the JSON file (without the .json extension)
    /// - Returns: A parsed KeyboardLayout object, or nil if parsing fails.
    static func loadLayout(named filename: String) -> KeyboardLayout? {
        
        // Explicitly target the bundle containing this class
        let bundle = Bundle(for: LayoutManager.self)
        
        // 1. Locate the file in the App Extension's bundle
        guard let url = bundle.url(forResource: filename, withExtension: "json") else {
            print("❌ Error: Could not find \(filename).json in the bundle.")
            return nil
        }
        
        do {
            // 2. Load the raw data from the file
            let data = try Data(contentsOf: url)
            
            // 3. Decode the JSON into our struct
            let decoder = JSONDecoder()
            let layout = try decoder.decode(KeyboardLayout.self, from: data)
            
            print("✅ Successfully loaded layout for: \(layout.languageCode)")
            return layout
            
        } catch {
            print("❌ Error parsing \(filename).json: \(error)")
            return nil
        }
    }
}
