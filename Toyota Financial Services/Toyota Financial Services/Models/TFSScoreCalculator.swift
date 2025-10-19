//
//  TFSScoreCalculator.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import Foundation

/// TFS Score Calculator
/// Calculates a comprehensive financing score (0-100) based on multiple factors
class TFSScoreCalculator {
    
    /// Calculate TFS Score based on financial profile
    /// - Parameters:
    ///   - income: Annual income (expected range: $50K - $300K)
    ///   - creditScore: Credit score (range: 300 - 850)
    ///   - availableMonthly: Available monthly payment capacity
    ///   - monthlySavings: Monthly savings amount
    /// - Returns: TFS Score (0-100)
    static func calculateScore(
        income: Double,
        creditScore: Int,
        availableMonthly: Double,
        monthlySavings: Double
    ) -> Int {
        // Weight factors (total = 100%)
        let creditWeight = 0.40        // 40% - Most important factor
        let incomeWeight = 0.25        // 25% - Income stability
        let paymentCapacityWeight = 0.20  // 20% - Monthly payment capacity
        let savingsWeight = 0.15       // 15% - Financial cushion
        
        // 1. Credit Score Component (0-100)
        let creditComponent = calculateCreditComponent(creditScore: creditScore)
        
        // 2. Income Component (0-100)
        let incomeComponent = calculateIncomeComponent(income: income)
        
        // 3. Payment Capacity Component (0-100)
        let paymentComponent = calculatePaymentCapacityComponent(
            availableMonthly: availableMonthly,
            income: income
        )
        
        // 4. Savings Component (0-100)
        let savingsComponent = calculateSavingsComponent(
            monthlySavings: monthlySavings,
            income: income
        )
        
        // Calculate weighted score
        let totalScore = (
            creditComponent * creditWeight +
            incomeComponent * incomeWeight +
            paymentComponent * paymentCapacityWeight +
            savingsComponent * savingsWeight
        )
        
        // Round and clamp to 0-100
        return max(0, min(100, Int(totalScore.rounded())))
    }
    
    /// Credit score component (0-100)
    /// Excellent (750+): 95-100
    /// Very Good (700-749): 80-94
    /// Good (650-699): 65-79
    /// Fair (600-649): 50-64
    /// Poor (<600): 0-49
    private static func calculateCreditComponent(creditScore: Int) -> Double {
        switch creditScore {
        case 750...850:
            // Excellent: 95-100
            let normalized = Double(creditScore - 750) / 100.0
            return 95 + (normalized * 5)
        case 700..<750:
            // Very Good: 80-94
            let normalized = Double(creditScore - 700) / 50.0
            return 80 + (normalized * 14)
        case 650..<700:
            // Good: 65-79
            let normalized = Double(creditScore - 650) / 50.0
            return 65 + (normalized * 14)
        case 600..<650:
            // Fair: 50-64
            let normalized = Double(creditScore - 600) / 50.0
            return 50 + (normalized * 14)
        default:
            // Poor: 0-49
            let normalized = max(0, Double(creditScore - 300)) / 300.0
            return normalized * 49
        }
    }
    
    /// Income component (0-100)
    /// Excellent ($180K+): 90-100
    /// Very Good ($140K-$179K): 75-89
    /// Good ($100K-$139K): 60-74
    /// Fair ($70K-$99K): 40-59
    /// Limited (<$70K): 20-39
    private static func calculateIncomeComponent(income: Double) -> Double {
        switch income {
        case 180_000...:
            // Excellent: 90-100
            let normalized = min(1.0, (income - 180_000) / 120_000)
            return 90 + (normalized * 10)
        case 140_000..<180_000:
            // Very Good: 75-89
            let normalized = (income - 140_000) / 40_000
            return 75 + (normalized * 14)
        case 100_000..<140_000:
            // Good: 60-74
            let normalized = (income - 100_000) / 40_000
            return 60 + (normalized * 14)
        case 70_000..<100_000:
            // Fair: 40-59
            let normalized = (income - 70_000) / 30_000
            return 40 + (normalized * 19)
        default:
            // Limited: 20-39
            let normalized = max(0, min(1.0, income / 70_000))
            return 20 + (normalized * 19)
        }
    }
    
    /// Payment capacity component (0-100)
    /// Based on available monthly payment as percentage of monthly income
    /// Excellent (12%+): 90-100
    /// Very Good (9-11%): 75-89
    /// Good (6-8%): 60-74
    /// Fair (3-5%): 40-59
    /// Limited (<3%): 20-39
    private static func calculatePaymentCapacityComponent(
        availableMonthly: Double,
        income: Double
    ) -> Double {
        let monthlyIncome = income / 12.0
        guard monthlyIncome > 0 else { return 0 }
        
        let paymentRatio = (availableMonthly / monthlyIncome) * 100 // As percentage
        
        switch paymentRatio {
        case 12...:
            // Excellent: 90-100
            let normalized = min(1.0, (paymentRatio - 12) / 8)
            return 90 + (normalized * 10)
        case 9..<12:
            // Very Good: 75-89
            let normalized = (paymentRatio - 9) / 3
            return 75 + (normalized * 14)
        case 6..<9:
            // Good: 60-74
            let normalized = (paymentRatio - 6) / 3
            return 60 + (normalized * 14)
        case 3..<6:
            // Fair: 40-59
            let normalized = (paymentRatio - 3) / 3
            return 40 + (normalized * 19)
        default:
            // Limited: 20-39
            let normalized = max(0, min(1.0, paymentRatio / 3))
            return 20 + (normalized * 19)
        }
    }
    
    /// Savings component (0-100)
    /// Based on monthly savings as percentage of monthly income
    /// Excellent (20%+): 90-100
    /// Very Good (15-19%): 75-89
    /// Good (10-14%): 60-74
    /// Fair (5-9%): 40-59
    /// Limited (<5%): 20-39
    private static func calculateSavingsComponent(
        monthlySavings: Double,
        income: Double
    ) -> Double {
        let monthlyIncome = income / 12.0
        guard monthlyIncome > 0 else { return 0 }
        
        let savingsRatio = (monthlySavings / monthlyIncome) * 100 // As percentage
        
        switch savingsRatio {
        case 20...:
            // Excellent: 90-100
            let normalized = min(1.0, (savingsRatio - 20) / 10)
            return 90 + (normalized * 10)
        case 15..<20:
            // Very Good: 75-89
            let normalized = (savingsRatio - 15) / 5
            return 75 + (normalized * 14)
        case 10..<15:
            // Good: 60-74
            let normalized = (savingsRatio - 10) / 5
            return 60 + (normalized * 14)
        case 5..<10:
            // Fair: 40-59
            let normalized = (savingsRatio - 5) / 5
            return 40 + (normalized * 19)
        default:
            // Limited: 20-39
            let normalized = max(0, min(1.0, savingsRatio / 5))
            return 20 + (normalized * 19)
        }
    }
    
    /// Get score band (GREEN/YELLOW/RED)
    static func getScoreBand(score: Int) -> ScoreBand {
        switch score {
        case 75...100:
            return .green
        case 50..<75:
            return .yellow
        default:
            return .red
        }
    }
    
    /// Get score description
    static func getScoreDescription(score: Int) -> String {
        switch score {
        case 90...100:
            return "Exceptional"
        case 75..<90:
            return "Excellent"
        case 60..<75:
            return "Very Good"
        case 50..<60:
            return "Good"
        case 35..<50:
            return "Fair"
        default:
            return "Needs Improvement"
        }
    }
    
    /// Get detailed explanation of what TFS Score means
    static func getScoreExplanation() -> String {
        """
        Your TFS Score is a comprehensive 0-100 rating that reflects your auto financing readiness.
        
        This score combines:
        • Credit Score (40%) - Your creditworthiness
        • Income Level (25%) - Your earning capacity
        • Payment Capacity (20%) - Available monthly budget
        • Savings Rate (15%) - Financial cushion
        
        🟢 75-100: Excellent financing options with best rates
        🟡 50-74: Good options with competitive rates
        🔴 Below 50: Limited options, consider improving factors
        
        A higher score gives you access to better APR rates, higher loan amounts, and more flexible terms.
        """
    }
}

enum ScoreBand {
    case green, yellow, red
    
    var color: String {
        switch self {
        case .green: return "tfsGreen"
        case .yellow: return "tfsOrange"
        case .red: return "tfsRed"
        }
    }
}

