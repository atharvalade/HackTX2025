//
//  DemoSettingsSheet.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

struct DemoSettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var manager: OnboardingManager
    @State private var tempIncome: Double
    @State private var tempCreditScore: Double
    @State private var tempTaxRate: Double
    @State private var tempCounty: String
    @State private var tempSpendingPercentage: Double // Percentage of monthly income spent
    
    let onApply: () async -> Void
    
    init(manager: OnboardingManager, onApply: @escaping () async -> Void) {
        self.manager = manager
        self.onApply = onApply
        
        // Initialize temp values
        let income = manager.plaidFinancialData.income ?? 134217.0
        let spending = manager.plaidFinancialData.averageSpending ?? (income / 12.0 * 0.70)
        let spendingPercent = (spending / (income / 12.0)) * 100.0
        
        _tempIncome = State(initialValue: income)
        _tempCreditScore = State(initialValue: Double(manager.equifaxCreditData.creditScore ?? 742))
        _tempTaxRate = State(initialValue: manager.locationTaxData.salesTaxPercentage ?? 8.25)
        _tempCounty = State(initialValue: manager.locationTaxData.county ?? "Travis County")
        _tempSpendingPercentage = State(initialValue: spendingPercent)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.tfsBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Warning Banner
                        HStack(spacing: 12) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color.tfsOrange)
                            
                            Text("Demo Settings - Adjust parameters to see how they affect your TFS Score and vehicle recommendations")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.tfsSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(16)
                        .background(Color.tfsOrange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        // Income
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Annual Income")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.tfsPrimary)
                            
                            VStack(spacing: 12) {
                                Text(formatCurrency(tempIncome))
                                    .font(.system(size: 36, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.tfsRed)
                                
                                Slider(value: $tempIncome, in: 50_000...300_000, step: 5_000)
                                    .tint(Color.tfsRed)
                                
                                HStack {
                                    Text("$50K")
                                    Spacer()
                                    Text("$300K")
                                }
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.tfsSecondary)
                            }
                        }
                        .padding(20)
                        .background(Color.tfsSecondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        // Monthly Spending
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Monthly Spending")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.tfsPrimary)
                            
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(formatCurrency(calculateMonthlySpending(income: tempIncome, percentage: tempSpendingPercentage)))
                                            .font(.system(size: 36, weight: .black, design: .rounded))
                                            .foregroundStyle(Color.tfsRed)
                                        
                                        Text("\(Int(tempSpendingPercentage))% of monthly income")
                                            .font(.system(size: 13, weight: .medium))
                                            .foregroundStyle(Color.tfsSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("Available")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundStyle(Color.tfsSecondary)
                                        
                                        Text(formatCurrency(calculateAvailableMonthly(income: tempIncome, spendingPercentage: tempSpendingPercentage)))
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color.tfsGreen)
                                    }
                                }
                                
                                Slider(value: $tempSpendingPercentage, in: 20...80, step: 5)
                                    .tint(Color.tfsRed)
                                
                                HStack {
                                    Text("20%")
                                    Spacer()
                                    Text("80%")
                                }
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.tfsSecondary)
                            }
                        }
                        .padding(20)
                        .background(Color.tfsSecondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        // Credit Score
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Credit Score")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.tfsPrimary)
                            
                            VStack(spacing: 12) {
                                Text("\(Int(tempCreditScore))")
                                    .font(.system(size: 36, weight: .black, design: .rounded))
                                    .foregroundStyle(getCreditScoreColor(Int(tempCreditScore)))
                                
                                Text(getCreditTier(Int(tempCreditScore)))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.tfsSecondary)
                                
                                Slider(value: $tempCreditScore, in: 300...850, step: 10)
                                    .tint(getCreditScoreColor(Int(tempCreditScore)))
                                
                                HStack {
                                    Text("300")
                                    Spacer()
                                    Text("850")
                                }
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.tfsSecondary)
                            }
                        }
                        .padding(20)
                        .background(Color.tfsSecondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        // Tax Rate & County
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Sales Tax")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.tfsPrimary)
                            
                            TextField("County", text: $tempCounty)
                                .textFieldStyle(.plain)
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(Color.tfsPrimary)
                                .padding(12)
                                .background(Color.tfsBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            
                            VStack(spacing: 12) {
                                Text(String(format: "%.2f%%", tempTaxRate))
                                    .font(.system(size: 36, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.tfsRed)
                                
                                Slider(value: $tempTaxRate, in: 0...15, step: 0.25)
                                    .tint(Color.tfsRed)
                                
                                HStack {
                                    Text("0%")
                                    Spacer()
                                    Text("15%")
                                }
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.tfsSecondary)
                            }
                        }
                        .padding(20)
                        .background(Color.tfsSecondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        // Preview TFS Score
                        VStack(spacing: 16) {
                            Text("Estimated TFS Score")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.tfsPrimary)
                            
                            let previewScore = calculatePreviewScore()
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.tfsSecondaryBackground, lineWidth: 12)
                                    .frame(width: 120, height: 120)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(previewScore) / 100.0)
                                    .stroke(
                                        getScoreColor(previewScore),
                                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                    )
                                    .frame(width: 120, height: 120)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack(spacing: 4) {
                                    Text("\(previewScore)")
                                        .font(.system(size: 40, weight: .black, design: .rounded))
                                        .foregroundStyle(getScoreColor(previewScore))
                                    
                                    Text(TFSScoreCalculator.getScoreDescription(score: previewScore))
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(Color.tfsSecondary)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(Color.tfsSecondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        // Apply Button
                        Button {
                            applyChanges()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("Apply & Re-Rank Vehicles")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [Color.tfsRed, Color.tfsRed.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.tfsRed.opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Demo Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.tfsRed)
                }
            }
        }
    }
    
    private func applyChanges() {
        // Update manager values with actual spending amount
        let monthlySpending = calculateMonthlySpending(income: tempIncome, percentage: tempSpendingPercentage)
        
        manager.plaidFinancialData.updateData(
            income: tempIncome,
            spending: monthlySpending
        )
        
        manager.equifaxCreditData.updateCreditData(
            score: Int(tempCreditScore),
            band: getCreditTier(Int(tempCreditScore)),
            utilization: calculateCreditUtilization(score: Int(tempCreditScore))
        )
        
        manager.locationTaxData.county = tempCounty
        manager.locationTaxData.salesTaxPercentage = tempTaxRate
        
        // Trigger re-ranking
        Task {
            await onApply()
            await MainActor.run {
                dismiss()
            }
        }
    }
    
    private func calculatePreviewScore() -> Int {
        let availableMonthly = calculateAvailableMonthly(income: tempIncome, spendingPercentage: tempSpendingPercentage)
        let monthlySavings = calculateMonthlySavings(income: tempIncome)
        
        return TFSScoreCalculator.calculateScore(
            income: tempIncome,
            creditScore: Int(tempCreditScore),
            availableMonthly: availableMonthly,
            monthlySavings: monthlySavings
        )
    }
    
    private func calculateMonthlySpending(income: Double, percentage: Double) -> Double {
        let monthlyIncome = income / 12.0
        return monthlyIncome * (percentage / 100.0)
    }
    
    private func calculateAvailableMonthly(income: Double, spendingPercentage: Double) -> Double {
        let monthlyIncome = income / 12.0
        let spending = calculateMonthlySpending(income: income, percentage: spendingPercentage)
        let savings = calculateMonthlySavings(income: income)
        return max(0, monthlyIncome - spending - savings)
    }
    
    private func calculateMonthlySavings(income: Double) -> Double {
        let monthlyIncome = income / 12.0
        return monthlyIncome * 0.20 // 20% savings rate
    }
    
    private func calculateCreditUtilization(score: Int) -> Double {
        // Better credit = lower utilization
        if score >= 750 { return 15.0 }
        else if score >= 700 { return 25.0 }
        else if score >= 650 { return 35.0 }
        else { return 50.0 }
    }
    
    private func getCreditTier(_ score: Int) -> String {
        if score >= 750 { return "Excellent" }
        else if score >= 700 { return "Very Good" }
        else if score >= 650 { return "Good" }
        else if score >= 600 { return "Fair" }
        else { return "Poor" }
    }
    
    private func getCreditScoreColor(_ score: Int) -> Color {
        if score >= 750 { return Color.tfsGreen }
        else if score >= 700 { return Color.tfsGreen }
        else if score >= 650 { return Color.tfsOrange }
        else { return Color.tfsRed }
    }
    
    private func getScoreColor(_ score: Int) -> Color {
        let band = TFSScoreCalculator.getScoreBand(score: score)
        switch band {
        case .green: return Color.tfsGreen
        case .yellow: return Color.tfsOrange
        case .red: return Color.tfsRed
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

#Preview {
    DemoSettingsSheet(manager: OnboardingManager(), onApply: {})
}

