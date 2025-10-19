//
//  LocationTaxData.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import Foundation

@Observable
class LocationTaxData {
    var county: String?
    var salesTaxPercentage: Double?
    var zipCode: String?
    var isLoading = false
    var error: String?
    
    var hasData: Bool {
        county != nil && salesTaxPercentage != nil
    }
    
    var formattedTaxPercentage: String {
        guard let tax = salesTaxPercentage else { return "N/A" }
        return String(format: "%.2f%%", tax)
    }
    
    func updateData(county: String, tax: Double, zipCode: String) {
        self.county = county
        self.salesTaxPercentage = tax
        self.zipCode = zipCode
        self.error = nil
    }
    
    func setError(_ message: String) {
        self.error = message
        self.isLoading = false
    }
    
    func clearError() {
        self.error = nil
    }
}

