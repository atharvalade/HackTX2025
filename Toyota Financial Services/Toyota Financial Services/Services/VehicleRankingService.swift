//
//  VehicleRankingService.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import Foundation

/// Service to rank vehicles using Gemini AI based on user's financial profile
class VehicleRankingService {
    
    private let maxRetries = 3
    
    /// Rank vehicles based on user's financial profile using Gemini AI
    /// - Parameters:
    ///   - vehicles: Array of vehicles to rank
    ///   - income: User's annual income
    ///   - creditScore: User's credit score
    ///   - availableMonthly: Available monthly payment capacity
    ///   - taxRate: Local sales tax rate
    /// - Returns: Ranked array of vehicles
    func rankVehicles(
        vehicles: [Vehicle],
        income: Double,
        creditScore: Int,
        availableMonthly: Double,
        taxRate: Double
    ) async throws -> [Vehicle] {
        guard let apiKey = APIConfig.geminiAPIKey else {
            throw RankingError.missingAPIKey
        }
        
        // Try up to maxRetries times
        for attempt in 1...maxRetries {
            do {
                print("🤖 Attempting to rank vehicles (attempt \(attempt)/\(maxRetries))...")
                
                let rankedVehicles = try await performRanking(
                    vehicles: vehicles,
                    income: income,
                    creditScore: creditScore,
                    availableMonthly: availableMonthly,
                    taxRate: taxRate,
                    apiKey: apiKey,
                    attempt: attempt
                )
                
                print("✅ Successfully ranked \(rankedVehicles.count) vehicles!")
                return rankedVehicles
                
            } catch RankingError.invalidJSONFormat(let details) {
                print("❌ Attempt \(attempt) failed: Invalid JSON format - \(details)")
                if attempt == maxRetries {
                    throw RankingError.maxRetriesExceeded
                }
                // Wait a bit before retrying
                try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                continue
            } catch {
                print("❌ Attempt \(attempt) failed: \(error.localizedDescription)")
                if attempt == maxRetries {
                    throw error
                }
                try await Task.sleep(nanoseconds: 1_000_000_000)
                continue
            }
        }
        
        throw RankingError.maxRetriesExceeded
    }
    
    private func performRanking(
        vehicles: [Vehicle],
        income: Double,
        creditScore: Int,
        availableMonthly: Double,
        taxRate: Double,
        apiKey: String,
        attempt: Int
    ) async throws -> [Vehicle] {
        
        // Build the prompt
        let prompt = buildRankingPrompt(
            vehicles: vehicles,
            income: income,
            creditScore: creditScore,
            availableMonthly: availableMonthly,
            taxRate: taxRate,
            isRetry: attempt > 1
        )
        
        // Prepare the API request
        let url = URL(string: "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-goog-api-key")
        
        let requestBody: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.3, // Lower temperature for more consistent JSON
                "topK": 40,
                "topP": 0.95,
                "maxOutputTokens": 8192
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Make the API call
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw RankingError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw RankingError.apiError(statusCode: httpResponse.statusCode)
        }
        
        // Parse the response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let firstCandidate = candidates.first,
              let content = firstCandidate["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let firstPart = parts.first,
              let text = firstPart["text"] as? String else {
            throw RankingError.invalidResponse
        }
        
        print("📄 Gemini Response:\n\(text.prefix(500))...")
        
        // Extract JSON from response (it might be wrapped in markdown code blocks)
        let cleanedText = cleanJSONResponse(text)
        
        // Parse the ranked vehicle IDs
        let rankedData = try parseRankedJSON(cleanedText)
        
        // Validate and reorder vehicles
        let rankedVehicles = try reorderVehicles(vehicles: vehicles, rankedData: rankedData)
        
        // Validate the 2:1 ratio (approximately)
        try validateRanking(rankedVehicles: rankedVehicles, availableMonthly: availableMonthly, taxRate: taxRate, creditScore: creditScore)
        
        return rankedVehicles
    }
    
    private func buildRankingPrompt(
        vehicles: [Vehicle],
        income: Double,
        creditScore: Int,
        availableMonthly: Double,
        taxRate: Double,
        isRetry: Bool
    ) -> String {
        let vehiclesJSON = vehicles.map { vehicle -> [String: Any] in
            return [
                "year": vehicle.year,
                "make": vehicle.make,
                "model": vehicle.model,
                "trim": vehicle.trim,
                "msrp_usd_est": vehicle.msrp_usd_est,
                "horsepower_hp": vehicle.horsepower_hp ?? 0,
                "body_style": vehicle.body_style,
                "powertrain": vehicle.powertrain,
                "drivetrain": vehicle.drivetrain,
                "image_url": vehicle.image_url
            ]
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: vehiclesJSON, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return ""
        }
        
        let retryInstructions = isRetry ? """
        
        ⚠️ IMPORTANT: Your previous response had an invalid JSON format. Please ensure:
        - Return ONLY valid JSON, no markdown, no explanations, no code blocks
        - Use the exact structure specified below
        - Include all vehicles from the input array
        """ : ""
        
        return """
        You are a Toyota Financial Services AI advisor. Your task is to intelligently rank vehicles for a customer based on their financial profile.
        
        CUSTOMER FINANCIAL PROFILE:
        - Annual Income: $\(String(format: "%.0f", income))
        - Credit Score: \(creditScore)
        - Available Monthly Payment: $\(String(format: "%.0f", availableMonthly))
        - Sales Tax Rate: \(String(format: "%.2f", taxRate))%
        
        APR RATES (based on credit score):
        - 750+: 3.99% (Excellent)
        - 700-749: 5.49% (Very Good)
        - 650-699: 7.99% (Good)
        - 600-649: 11.99% (Fair)
        
        AVAILABLE VEHICLES (JSON format):
        \(jsonString)
        
        YOUR TASK:
        Rank these vehicles in order of recommendation for this customer. Follow these rules strictly:
        
        1. AFFORDABILITY PATTERN: For every 3 vehicles, 2 should be AFFORDABLE and 1 should be a STRETCH.
           - AFFORDABLE: Monthly payment (60-month loan) is ≤ 70% of available monthly payment
           - STRETCH: Monthly payment is 70-95% of available monthly payment (challenging but possible)
        
        2. Calculate estimated monthly payments using:
           - Total Price = MSRP × (1 + tax_rate/100)
           - Down Payment = 10% of total price
           - Financed Amount = Total Price - Down Payment
           - Monthly Payment = Standard loan formula with 60 months and appropriate APR
        
        3. Consider:
           - Value proposition (features, fuel efficiency, practicality)
           - Popular models that hold value
           - Mix of vehicle types (sedans, SUVs, trucks)
           - Customer's likely preferences based on income level
        
        4. Pattern examples:
           [Affordable, Affordable, Stretch, Affordable, Affordable, Stretch, ...]
        \(retryInstructions)
        
        RESPONSE FORMAT:
        Return ONLY a valid JSON object with this exact structure (no markdown, no extra text):
        
        {
          "ranked_vehicles": [
            {
              "year": 2025,
              "make": "Toyota",
              "model": "Camry",
              "trim": "LE",
              "reason": "Affordable hybrid with excellent value",
              "category": "affordable"
            },
            {
              "year": 2025,
              "make": "Toyota",
              "model": "RAV4",
              "trim": "LE",
              "reason": "Popular SUV, well within budget",
              "category": "affordable"
            },
            {
              "year": 2025,
              "make": "Toyota",
              "model": "Highlander",
              "trim": "LE",
              "reason": "Premium SUV, stretch but achievable",
              "category": "stretch"
            }
          ]
        }
        
        IMPORTANT:
        - Include ALL vehicles from the input
        - Use "category" field: either "affordable" or "stretch"
        - Maintain the 2:1 ratio (approximately 2 affordable for every 1 stretch)
        - year, make, model, and trim must EXACTLY match the input vehicles
        - Return ONLY the JSON object, nothing else
        """
    }
    
    private func cleanJSONResponse(_ text: String) -> String {
        var cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code blocks if present
        if cleaned.hasPrefix("```json") {
            cleaned = cleaned.replacingOccurrences(of: "```json", with: "")
        }
        if cleaned.hasPrefix("```") {
            cleaned = cleaned.replacingOccurrences(of: "```", with: "")
        }
        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }
        
        return cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func parseRankedJSON(_ jsonString: String) throws -> [RankedVehicle] {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw RankingError.invalidJSONFormat("Could not convert to data")
        }
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(RankedVehiclesResponse.self, from: jsonData)
            
            guard !response.ranked_vehicles.isEmpty else {
                throw RankingError.invalidJSONFormat("Empty ranked_vehicles array")
            }
            
            return response.ranked_vehicles
        } catch let decodingError as DecodingError {
            throw RankingError.invalidJSONFormat("Decoding error: \(decodingError.localizedDescription)")
        } catch {
            throw RankingError.invalidJSONFormat("Parse error: \(error.localizedDescription)")
        }
    }
    
    private func reorderVehicles(vehicles: [Vehicle], rankedData: [RankedVehicle]) throws -> [Vehicle] {
        var rankedVehicles: [Vehicle] = []
        
        for rankedItem in rankedData {
            // Find matching vehicle
            if let matchingVehicle = vehicles.first(where: { vehicle in
                vehicle.year == rankedItem.year &&
                vehicle.make.lowercased() == rankedItem.make.lowercased() &&
                vehicle.model.lowercased() == rankedItem.model.lowercased() &&
                vehicle.trim.lowercased() == rankedItem.trim.lowercased()
            }) {
                rankedVehicles.append(matchingVehicle)
            } else {
                print("⚠️ Warning: Could not find vehicle: \(rankedItem.year) \(rankedItem.make) \(rankedItem.model) \(rankedItem.trim)")
            }
        }
        
        // Add any missing vehicles at the end
        for vehicle in vehicles {
            if !rankedVehicles.contains(where: { $0.year == vehicle.year && $0.model == vehicle.model && $0.trim == vehicle.trim }) {
                rankedVehicles.append(vehicle)
            }
        }
        
        guard rankedVehicles.count == vehicles.count else {
            throw RankingError.invalidJSONFormat("Ranked list doesn't match input vehicle count")
        }
        
        return rankedVehicles
    }
    
    private func validateRanking(rankedVehicles: [Vehicle], availableMonthly: Double, taxRate: Double, creditScore: Int) throws {
        // Simple validation: check if we have a good mix
        let financingCalc = FinancingCalculator()
        
        var affordableCount = 0
        var stretchCount = 0
        
        for vehicle in rankedVehicles.prefix(9) { // Check first 9 vehicles
            let monthlyPayment = financingCalc.calculateMonthlyPayment(
                msrp: vehicle.msrp_usd,
                creditScore: creditScore,
                taxRate: taxRate
            )
            
            let affordabilityRatio = monthlyPayment / availableMonthly
            
            if affordabilityRatio <= 0.7 {
                affordableCount += 1
            } else {
                stretchCount += 1
            }
        }
        
        print("📊 Ranking validation: \(affordableCount) affordable, \(stretchCount) stretch in first 9 vehicles")
        
        // We want roughly 2:1 ratio, but allow some flexibility
        let expectedAffordable = 6 // Out of 9
        let tolerance = 2
        
        if abs(affordableCount - expectedAffordable) > tolerance {
            print("⚠️ Warning: Ranking doesn't follow 2:1 pattern (expected ~6 affordable, got \(affordableCount))")
            // Don't throw, just warn - we'll accept imperfect rankings
        }
    }
}

// MARK: - Models

struct RankedVehiclesResponse: Codable {
    let ranked_vehicles: [RankedVehicle]
}

struct RankedVehicle: Codable {
    let year: Int
    let make: String
    let model: String
    let trim: String
    let reason: String
    let category: String // "affordable" or "stretch"
}

enum RankingError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case apiError(statusCode: Int)
    case invalidJSONFormat(String)
    case maxRetriesExceeded
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Gemini API key not configured"
        case .invalidResponse:
            return "Invalid response from Gemini API"
        case .apiError(let statusCode):
            return "Gemini API error (status code: \(statusCode))"
        case .invalidJSONFormat(let details):
            return "Invalid JSON format: \(details)"
        case .maxRetriesExceeded:
            return "Maximum retry attempts exceeded"
        }
    }
}

