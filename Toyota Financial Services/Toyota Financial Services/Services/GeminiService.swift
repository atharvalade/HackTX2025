//
//  GeminiService.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import Foundation
import CoreLocation

actor GeminiService {
    static let shared = GeminiService()
    
    private init() {}
    
    struct TaxInfo: Codable {
        let county: String
        let salesTaxPercentage: Double
        let zipCode: String
    }
    
    func fetchCountyAndTax(for location: CLLocation) async throws -> TaxInfo {
        // First, reverse geocode to get zip code
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        
        guard let placemark = placemarks.first,
              let zipCode = placemark.postalCode else {
            throw GeminiError.locationNotFound
        }
        
        // Get API key from config
        guard let apiKey = APIConfig.geminiAPIKey else {
            throw GeminiError.missingAPIKey
        }
        
        // Prepare Gemini API request
        let prompt = """
        For ZIP code \(zipCode) in the United States, provide ONLY the following information in this exact format:
        County: [county name]
        Tax: [sales tax percentage as a number, for example 8.25 for 8.25%, not 0.0825]
        
        Respond with only these two lines, nothing else. The tax should be the percentage value like 8.25, not the decimal 0.0825.
        """
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-goog-api-key")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GeminiError.invalidResponse
        }
        
        // Parse Gemini response
        let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let candidates = jsonResponse?["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw GeminiError.parsingFailed
        }
        
        // Parse the structured response
        let lines = text.split(separator: "\n").map { String($0).trimmingCharacters(in: .whitespaces) }
        var county = "Unknown County"
        var taxPercentage = 0.0
        
        for line in lines {
            if line.lowercased().starts(with: "county:") {
                county = line.replacingOccurrences(of: "County:", with: "")
                    .replacingOccurrences(of: "county:", with: "")
                    .trimmingCharacters(in: .whitespaces)
            } else if line.lowercased().starts(with: "tax:") {
                let taxString = line.replacingOccurrences(of: "Tax:", with: "")
                    .replacingOccurrences(of: "tax:", with: "")
                    .trimmingCharacters(in: .whitespaces)
                    .replacingOccurrences(of: "%", with: "")
                if let parsedTax = Double(taxString) {
                    // If the tax is less than 1, it's likely in decimal form (e.g., 0.0825)
                    // Convert to percentage by multiplying by 100
                    taxPercentage = parsedTax < 1.0 ? parsedTax * 100.0 : parsedTax
                }
            }
        }
        
        return TaxInfo(county: county, salesTaxPercentage: taxPercentage, zipCode: zipCode)
    }
    
    enum GeminiError: LocalizedError {
        case locationNotFound
        case missingAPIKey
        case invalidResponse
        case parsingFailed
        
        var errorDescription: String? {
            switch self {
            case .locationNotFound:
                return "Unable to determine location information"
            case .missingAPIKey:
                return "API key not configured"
            case .invalidResponse:
                return "Invalid response from server"
            case .parsingFailed:
                return "Unable to parse location data"
            }
        }
    }
}

