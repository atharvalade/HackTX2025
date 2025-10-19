//
//  FinancialData.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import Foundation

@Observable
class PlaidFinancialData {
    var income: Double?
    var averageSpending: Double?
    var isLoading = false
    var error: String?
    
    var hasData: Bool {
        income != nil && averageSpending != nil
    }
    
    var formattedIncome: String {
        guard let income = income else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: income)) ?? "N/A"
    }
    
    var formattedSpending: String {
        guard let spending = averageSpending else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: spending)) ?? "N/A"
    }
    
    var spendingCapacity: Double {
        guard let income = income, let spending = averageSpending else { return 0 }
        let monthlyIncome = income / 12.0
        let savingsRate = 0.20 // Save 20% of income
        let afterSavings = monthlyIncome * (1 - savingsRate)
        let capacity = afterSavings - spending
        return max(capacity, 0)
    }
    
    var formattedSpendingCapacity: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: spendingCapacity)) ?? "N/A"
    }
    
    var monthlySavings: Double {
        guard let income = income else { return 0 }
        let monthlyIncome = income / 12.0
        return monthlyIncome * 0.20
    }
    
    var formattedMonthlySavings: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: monthlySavings)) ?? "N/A"
    }
    
    func updateData(income: Double, spending: Double) {
        self.income = income
        self.averageSpending = spending
        self.error = nil
    }
    
    func setError(_ message: String) {
        self.error = message
        self.isLoading = false
    }
    
    func clearError() {
        self.error = nil
    }
    
    func clearData() {
        self.income = nil
        self.averageSpending = nil
        self.isLoading = false
        self.error = nil
    }
}

@Observable
class EquifaxCreditData {
    var creditScore: Int?
    var creditBand: String?
    var topFactors: [String] = []
    var accountsOpen: Int?
    var creditUtilization: Double?
    var isLoading = false
    var error: String?
    
    var hasData: Bool {
        creditScore != nil
    }
    
    var creditScoreColor: String {
        guard let score = creditScore else { return "gray" }
        if score >= 750 { return "green" }
        if score >= 670 { return "yellow" }
        if score >= 580 { return "orange" }
        return "red"
    }
    
    var creditRating: String {
        guard let score = creditScore else { return "Unknown" }
        if score >= 800 { return "Exceptional" }
        if score >= 740 { return "Very Good" }
        if score >= 670 { return "Good" }
        if score >= 580 { return "Fair" }
        return "Poor"
    }
    
    var formattedUtilization: String {
        guard let util = creditUtilization else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: util / 100.0)) ?? "N/A"
    }
    
    func updateData(score: Int, band: String, factors: [String], accounts: Int, utilization: Double) {
        self.creditScore = score
        self.creditBand = band
        self.topFactors = factors
        self.accountsOpen = accounts
        self.creditUtilization = utilization
        self.error = nil
    }
    
    func setError(_ message: String) {
        self.error = message
        self.isLoading = false
    }
    
    func clearError() {
        self.error = nil
    }
    
    func updateCreditData(score: Int, band: String, utilization: Double) {
        self.creditScore = score
        self.creditBand = band
        self.creditUtilization = utilization
        self.isLoading = false
    }
    
    func clearData() {
        self.creditScore = nil
        self.creditBand = nil
        self.topFactors = []
        self.accountsOpen = nil
        self.creditUtilization = nil
        self.isLoading = false
        self.error = nil
    }
}

