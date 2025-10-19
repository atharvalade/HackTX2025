//
//  OnboardingManager.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

@Observable
@MainActor
class OnboardingManager {
    var currentStep: OnboardingStep = .welcome
    var hasGrantedLocation = false
    var hasConnectedPlaid = false
    var hasConnectedEquifax = false
    var showSkipWarning = false
    var skipWarningType: SkipWarningType = .plaid
    var locationTaxData = LocationTaxData()
    var plaidFinancialData = PlaidFinancialData()
    var equifaxCreditData = EquifaxCreditData()
    
    /// Calculate TFS Score based on current financial data
    var tfsScore: Int {
        let income = plaidFinancialData.income ?? 100_000
        let creditScore = equifaxCreditData.creditScore ?? 650
        let availableMonthly = plaidFinancialData.income != nil ? plaidFinancialData.spendingCapacity : 1000
        let monthlySavings = plaidFinancialData.income != nil ? plaidFinancialData.monthlySavings : 500
        
        return TFSScoreCalculator.calculateScore(
            income: income,
            creditScore: creditScore,
            availableMonthly: availableMonthly,
            monthlySavings: monthlySavings
        )
    }
    
    enum OnboardingStep: Int, CaseIterable {
        case welcome = 0
        case location = 1
        case plaid = 2
        case equifax = 3
        case complete = 4
        
        var progress: Double {
            Double(rawValue) / Double(OnboardingStep.allCases.count - 1)
        }
    }
    
    enum SkipWarningType {
        case plaid
        case equifax
        
        var title: String {
            switch self {
            case .plaid:
                return "Skip Income Verification?"
            case .equifax:
                return "Skip Credit Check?"
            }
        }
        
        var message: String {
            switch self {
            case .plaid:
                return "Manual review may take additional time and you may not receive pre-approved offers immediately."
            case .equifax:
                return "Without a credit check, we won't be able to provide personalized pre-approved offers right away."
            }
        }
    }
    
    func nextStep() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            if let nextStep = OnboardingStep(rawValue: currentStep.rawValue + 1) {
                currentStep = nextStep
            }
        }
    }
    
    func skipCurrentStep() {
        nextStep()
    }
}

