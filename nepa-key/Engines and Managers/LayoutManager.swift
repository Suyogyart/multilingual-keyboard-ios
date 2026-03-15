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
    static func loadLayoutAsync(named filename: String, completion: @escaping (KeyboardLayout?) -> Void) {
        // userInitiated QOS tells iOS this is high priority but not UI-blocking
        DispatchQueue.global(qos: .userInitiated).async {
            let bundle = Bundle(for: LayoutManager.self)
            
            guard let url = bundle.url(forResource: filename, withExtension: "json"),
                  let data = try? Data(contentsOf: url) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let layout = try decoder.decode(KeyboardLayout.self, from: data)
                
                // Jump back to Main Thread to deliver the result
                DispatchQueue.main.async {
                    completion(layout)
                }
            } catch {
                print("❌ Parsing error: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }
    }
}
