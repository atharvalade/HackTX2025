//
//  APIConfig.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import Foundation

struct APIConfig {
    /// Gemini API Key - Retrieved from APIKeys.plist
    nonisolated(unsafe) static var geminiAPIKey: String? {
        // Try to load from APIKeys.plist first (gitignored file)
        if let path = Bundle.main.path(forResource: "APIKeys", ofType: "plist"),
           let keys = NSDictionary(contentsOfFile: path) as? [String: String],
           let apiKey = keys["GEMINI_API_KEY"], !apiKey.isEmpty {
            return apiKey
        }
        
        // Fallback to Info.plist (for development)
        if let apiKey = Bundle.main.infoDictionary?["GEMINI_API_KEY"] as? String, !apiKey.isEmpty {
            return apiKey
        }
        
        return nil
    }
}

