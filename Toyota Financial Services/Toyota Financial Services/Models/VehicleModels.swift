//
//  VehicleModels.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import Foundation

struct Vehicle: Codable, Identifiable {
    let id = UUID()
    let year: Int
    let make: String
    let model: String
    let trim: String
    let msrp_usd_est: Double
    let horsepower_hp: Int?
    let drivetrain: String
    let powertrain: String
    let body_style: String
    let image_url: String
    
    var displayName: String {
        "\(year) \(make) \(model)"
    }
    
    var fullName: String {
        "\(year) \(make) \(model) \(trim)"
    }
    
    // For compatibility with existing code
    var msrp_usd: Double {
        msrp_usd_est
    }
    
    enum CodingKeys: String, CodingKey {
        case year, make, model, trim
        case msrp_usd_est
        case horsepower_hp
        case drivetrain, powertrain
        case body_style
        case image_url
    }
}

// JSON is now a direct array of vehicles
typealias VehicleData = [Vehicle]

@Observable
class VehicleManager {
    var vehicles: [Vehicle] = []
    var currentIndex: Int = 0
    var wishlist: [Vehicle] = []
    var denied: [Vehicle] = []
    
    private let imageCache = ImageCacheManager.shared
    private let preloadCount = 5 // Number of images to preload initially
    
    var currentVehicle: Vehicle? {
        guard currentIndex < vehicles.count else { return nil }
        return vehicles[currentIndex]
    }
    
    var hasMoreVehicles: Bool {
        currentIndex < vehicles.count
    }
    
    init() {
        loadVehicles()
        preloadInitialImages()
    }
    
    func loadVehicles() {
        guard let url = Bundle.main.url(forResource: "models", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load vehicles data")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            vehicles = try decoder.decode([Vehicle].self, from: data)
            print("Successfully loaded \(vehicles.count) vehicles")
        } catch {
            print("Failed to decode vehicles: \(error)")
        }
    }
    
    /// Preload the first 5 images when the app starts
    private func preloadInitialImages() {
        let imagesToPreload = vehicles.prefix(preloadCount).map { $0.image_url }
        Task { @MainActor in
            imageCache.preloadImages(urlStrings: Array(imagesToPreload))
            print("🚀 Preloading first \(imagesToPreload.count) images...")
        }
    }
    
    /// Preload the next image after a swipe
    private func preloadNextImage() {
        let nextIndex = currentIndex + preloadCount
        if nextIndex < vehicles.count {
            let nextImageUrl = vehicles[nextIndex].image_url
            Task { @MainActor in
                imageCache.preloadImage(urlString: nextImageUrl)
            }
        }
    }
    
    func swipeRight() {
        guard let vehicle = currentVehicle else { return }
        wishlist.append(vehicle)
        currentIndex += 1
        preloadNextImage()
    }
    
    func swipeLeft() {
        guard let vehicle = currentVehicle else { return }
        denied.append(vehicle)
        currentIndex += 1
        preloadNextImage()
    }
}

@Observable
class FinancingCalculator {
    var downPaymentPercentage: Double = 10.0 // 10% default
    var isLeaseMode: Bool = false
    var loanTermMonths: Int = 60 // 5 years
    var leaseTermMonths: Int = 36 // 3 years
    
    func getAPR(creditScore: Int) -> Double {
        if creditScore >= 750 {
            return 3.99 // Excellent
        } else if creditScore >= 700 {
            return 5.49 // Very Good
        } else if creditScore >= 650 {
            return 7.99 // Good
        } else {
            return 11.99 // Poor
        }
    }
    
    func getCreditTier(creditScore: Int) -> String {
        if creditScore >= 750 {
            return "Excellent"
        } else if creditScore >= 700 {
            return "Very Good"
        } else if creditScore >= 650 {
            return "Good"
        } else {
            return "Poor"
        }
    }
    
    func calculateMonthlyPayment(msrp: Double, creditScore: Int, taxRate: Double) -> Double {
        let totalPrice = msrp * (1 + taxRate / 100.0)
        let downPayment = totalPrice * (downPaymentPercentage / 100.0)
        let principal = totalPrice - downPayment
        
        if isLeaseMode {
            return calculateLeasePayment(msrp: msrp, taxRate: taxRate)
        } else {
            return calculateFinancePayment(principal: principal, creditScore: creditScore)
        }
    }
    
    private func calculateFinancePayment(principal: Double, creditScore: Int) -> Double {
        let apr = getAPR(creditScore: creditScore)
        let monthlyRate = apr / 100.0 / 12.0
        let n = Double(loanTermMonths)
        
        if monthlyRate == 0 {
            return principal / n
        }
        
        let numerator = principal * monthlyRate * pow(1 + monthlyRate, n)
        let denominator = pow(1 + monthlyRate, n) - 1
        
        return numerator / denominator
    }
    
    private func calculateLeasePayment(msrp: Double, taxRate: Double) -> Double {
        let residualPercentage = 0.55 // 55% residual after 3 years
        let residualValue = msrp * residualPercentage
        let depreciation = msrp - residualValue
        let totalPrice = msrp * (1 + taxRate / 100.0)
        let downPayment = totalPrice * (downPaymentPercentage / 100.0)
        
        // Simplified lease calculation
        let monthlyDepreciation = (depreciation - downPayment) / Double(leaseTermMonths)
        let monthlyFinanceCharge = (msrp + residualValue) * 0.002 // ~5% APR equivalent
        let monthlyTax = (monthlyDepreciation + monthlyFinanceCharge) * (taxRate / 100.0)
        
        return monthlyDepreciation + monthlyFinanceCharge + monthlyTax
    }
    
    func getDownPaymentAmount(msrp: Double, taxRate: Double) -> Double {
        let totalPrice = msrp * (1 + taxRate / 100.0)
        return totalPrice * (downPaymentPercentage / 100.0)
    }
    
    func getTotalPrice(msrp: Double, taxRate: Double) -> Double {
        return msrp * (1 + taxRate / 100.0)
    }
}

