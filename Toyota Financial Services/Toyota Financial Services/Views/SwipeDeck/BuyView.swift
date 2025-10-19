//
//  BuyView.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

struct BuyView: View {
    @Environment(\.dismiss) var dismiss
    let vehicle: Vehicle
    let manager: OnboardingManager
    @State var financingCalc: FinancingCalculator
    @State private var selectedTab: BuyTab = .overview
    
    var taxRate: Double {
        manager.locationTaxData.salesTaxPercentage ?? 8.25
    }
    
    var creditScore: Int {
        manager.equifaxCreditData.creditScore ?? 700
    }
    
    var monthlyPayment: Double {
        financingCalc.calculateMonthlyPayment(
            msrp: vehicle.msrp_usd,
            creditScore: creditScore,
            taxRate: taxRate
        )
    }
    
    var totalPrice: Double {
        financingCalc.getTotalPrice(msrp: vehicle.msrp_usd, taxRate: taxRate)
    }
    
    var downPayment: Double {
        financingCalc.getDownPaymentAmount(msrp: vehicle.msrp_usd, taxRate: taxRate)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.tfsBackground.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Vehicle Image & Name
                        VStack(spacing: 16) {
                            AsyncImage(url: URL(string: vehicle.image_url)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .clipped()
                                case .failure(_), .empty:
                                    ZStack {
                                        Color.tfsSecondaryBackground
                                        Image(systemName: "car.fill")
                                            .font(.system(size: 60, weight: .medium))
                                            .foregroundStyle(Color.tfsSecondary.opacity(0.3))
                                    }
                                    .frame(height: 200)
                                @unknown default:
                                    Color.tfsSecondaryBackground
                                        .frame(height: 200)
                                }
                            }
                            .frame(height: 200)
                            .background(Color.tfsSecondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            
                            VStack(spacing: 4) {
                                Text(vehicle.fullName)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.tfsPrimary)
                                
                                HStack(spacing: 12) {
                                    Label(vehicle.powertrain, systemImage: "fuelpump.fill")
                                    Label(vehicle.drivetrain, systemImage: "arrow.triangle.branch")
                                    if let hp = vehicle.horsepower_hp {
                                        Label("\(hp) hp", systemImage: "gauge.with.needle")
                                    }
                                }
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.tfsSecondary)
                            }
                        }
                        .padding(20)
                        .background(Color.tfsSecondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        
                        // Monthly Payment Highlight
                        VStack(spacing: 12) {
                            Text("Estimated Monthly Payment")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.tfsSecondary)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(formatCurrency(monthlyPayment))
                                    .font(.system(size: 48, weight: .black, design: .rounded))
                                    .foregroundStyle(Color.tfsRed)
                                
                                Text("/mo")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(Color.tfsSecondary)
                            }
                            
                            Text("\(financingCalc.isLeaseMode ? "Lease" : "Finance") • \(financingCalc.isLeaseMode ? financingCalc.leaseTermMonths : financingCalc.loanTermMonths) months • \(String(format: "%.1f%%", financingCalc.getAPR(creditScore: creditScore))) APR")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(Color.tfsSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(24)
                        .background(
                            LinearGradient(
                                colors: [Color.tfsRed.opacity(0.1), Color.tfsRed.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.tfsRed.opacity(0.2), lineWidth: 1)
                        )
                        
                        // Tab Selector
                        Picker("View", selection: $selectedTab) {
                            Text("Overview").tag(BuyTab.overview)
                            Text("Financing").tag(BuyTab.financing)
                            Text("Breakdown").tag(BuyTab.breakdown)
                        }
                        .pickerStyle(.segmented)
                        
                        // Tab Content
                        Group {
                            switch selectedTab {
                            case .overview:
                                OverviewTab(
                                    vehicle: vehicle,
                                    manager: manager,
                                    financingCalc: financingCalc,
                                    monthlyPayment: monthlyPayment,
                                    totalPrice: totalPrice
                                )
                            case .financing:
                                FinancingTab(
                                    vehicle: vehicle,
                                    manager: manager,
                                    financingCalc: financingCalc
                                )
                            case .breakdown:
                                BreakdownTab(
                                    vehicle: vehicle,
                                    manager: manager,
                                    financingCalc: financingCalc,
                                    totalPrice: totalPrice,
                                    downPayment: downPayment,
                                    monthlyPayment: monthlyPayment
                                )
                            }
                        }
                        .animation(.easeInOut, value: selectedTab)
                        
                        // Pre-Approval CTA
                        PreApprovalCTA(tfsScore: manager.tfsScore)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Purchase Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28, weight: .medium))
                            .foregroundStyle(Color.tfsSecondary, Color.tfsSecondaryBackground)
                    }
                }
            }
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

enum BuyTab {
    case overview, financing, breakdown
}

// MARK: - Overview Tab
struct OverviewTab: View {
    let vehicle: Vehicle
    let manager: OnboardingManager
    let financingCalc: FinancingCalculator
    let monthlyPayment: Double
    let totalPrice: Double
    
    var body: some View {
        VStack(spacing: 20) {
            // Your Financial Profile
            VStack(alignment: .leading, spacing: 16) {
                Text("Your Financial Profile")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.tfsPrimary)
                
                VStack(spacing: 12) {
                    ProfileRow(
                        icon: "chart.bar.fill",
                        title: "TFS Score",
                        value: "\(manager.tfsScore)",
                        color: getScoreColor(manager.tfsScore)
                    )
                    
                    ProfileRow(
                        icon: "creditcard.fill",
                        title: "Credit Score",
                        value: "\(manager.equifaxCreditData.creditScore ?? 0)",
                        color: Color.tfsRed
                    )
                    
                    ProfileRow(
                        icon: "dollarsign.circle.fill",
                        title: "Annual Income",
                        value: manager.plaidFinancialData.formattedIncome,
                        color: Color.tfsGreen
                    )
                    
                    ProfileRow(
                        icon: "banknote.fill",
                        title: "Available Monthly",
                        value: manager.plaidFinancialData.formattedSpendingCapacity,
                        color: Color.tfsPrimary
                    )
                }
            }
            .padding(20)
            .background(Color.tfsSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            // Affordability Check
            AffordabilityCheck(
                monthlyPayment: monthlyPayment,
                availableMonthly: manager.plaidFinancialData.spendingCapacity
            )
            
            // Key Features
            VStack(alignment: .leading, spacing: 16) {
                Text("Why This Vehicle Fits")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.tfsPrimary)
                
                VStack(spacing: 12) {
                    FeatureChip(
                        icon: "checkmark.circle.fill",
                        text: "Payment within your budget",
                        color: Color.tfsGreen
                    )
                    
                    FeatureChip(
                        icon: "checkmark.circle.fill",
                        text: "Excellent APR rate for your credit tier",
                        color: Color.tfsGreen
                    )
                    
                    FeatureChip(
                        icon: "checkmark.circle.fill",
                        text: "Pre-qualified based on your profile",
                        color: Color.tfsGreen
                    )
                }
            }
            .padding(20)
            .background(Color.tfsSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
    
    private func getScoreColor(_ score: Int) -> Color {
        let band = TFSScoreCalculator.getScoreBand(score: score)
        switch band {
        case .green: return Color.tfsGreen
        case .yellow: return Color.tfsOrange
        case .red: return Color.tfsRed
        }
    }
}

// MARK: - Financing Tab
struct FinancingTab: View {
    let vehicle: Vehicle
    let manager: OnboardingManager
    @Bindable var financingCalc: FinancingCalculator
    
    var taxRate: Double {
        manager.locationTaxData.salesTaxPercentage ?? 8.25
    }
    
    var creditScore: Int {
        manager.equifaxCreditData.creditScore ?? 700
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Finance/Lease Toggle
            VStack(alignment: .leading, spacing: 12) {
                Text("Financing Type")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.tfsPrimary)
                
                Picker("Type", selection: $financingCalc.isLeaseMode) {
                    Text("Finance").tag(false)
                    Text("Lease").tag(true)
                }
                .pickerStyle(.segmented)
            }
            .padding(20)
            .background(Color.tfsSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            // Down Payment Slider
            VStack(alignment: .leading, spacing: 16) {
                Text("Down Payment")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.tfsPrimary)
                
                VStack(spacing: 12) {
                    HStack {
                        Text(String(format: "%.0f%%", financingCalc.downPaymentPercentage))
                            .font(.system(size: 32, weight: .black, design: .rounded))
                            .foregroundStyle(Color.tfsRed)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Amount")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color.tfsSecondary)
                            
                            Text(formatCurrency(financingCalc.getDownPaymentAmount(msrp: vehicle.msrp_usd, taxRate: taxRate)))
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.tfsPrimary)
                        }
                    }
                    
                    Slider(value: $financingCalc.downPaymentPercentage, in: 0...30, step: 5)
                        .tint(Color.tfsRed)
                    
                    HStack {
                        Text("0%")
                        Spacer()
                        Text("30%")
                    }
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.tfsSecondary)
                }
            }
            .padding(20)
            .background(Color.tfsSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            // Term Length
            VStack(alignment: .leading, spacing: 16) {
                Text("Loan Term")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.tfsPrimary)
                
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ForEach([36, 48, 60, 72], id: \.self) { months in
                            TermButton(
                                months: months,
                                isSelected: financingCalc.isLeaseMode ? 
                                    financingCalc.leaseTermMonths == months : 
                                    financingCalc.loanTermMonths == months,
                                action: {
                                    if financingCalc.isLeaseMode {
                                        financingCalc.leaseTermMonths = months
                                    } else {
                                        financingCalc.loanTermMonths = months
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .padding(20)
            .background(Color.tfsSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            // APR Information
            VStack(alignment: .leading, spacing: 16) {
                Text("Your APR Rate")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.tfsPrimary)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(format: "%.2f%%", financingCalc.getAPR(creditScore: creditScore)))
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(Color.tfsRed)
                        
                        Text("Based on \(financingCalc.getCreditTier(creditScore: creditScore)) credit tier")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.tfsSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 48, weight: .medium))
                        .foregroundStyle(Color.tfsGreen)
                }
            }
            .padding(20)
            .background(Color.tfsSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// MARK: - Breakdown Tab
struct BreakdownTab: View {
    let vehicle: Vehicle
    let manager: OnboardingManager
    let financingCalc: FinancingCalculator
    let totalPrice: Double
    let downPayment: Double
    let monthlyPayment: Double
    
    var taxRate: Double {
        manager.locationTaxData.salesTaxPercentage ?? 8.25
    }
    
    var taxAmount: Double {
        vehicle.msrp_usd * (taxRate / 100.0)
    }
    
    var loanAmount: Double {
        totalPrice - downPayment
    }
    
    var totalPaidOverTerm: Double {
        let months = Double(financingCalc.isLeaseMode ? financingCalc.leaseTermMonths : financingCalc.loanTermMonths)
        return (monthlyPayment * months) + downPayment
    }
    
    var totalInterest: Double {
        totalPaidOverTerm - totalPrice
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Price Breakdown
            VStack(alignment: .leading, spacing: 16) {
                Text("Price Breakdown")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.tfsPrimary)
                
                VStack(spacing: 12) {
                    PriceBreakdownRow(
                        title: "MSRP",
                        value: formatCurrency(vehicle.msrp_usd),
                        isBold: false
                    )
                    
                    PriceBreakdownRow(
                        title: "Sales Tax (\(manager.locationTaxData.county ?? "Your County"), \(String(format: "%.2f%%", taxRate)))",
                        value: formatCurrency(taxAmount),
                        isBold: false
                    )
                    
                    Divider()
                    
                    PriceBreakdownRow(
                        title: "Total Price",
                        value: formatCurrency(totalPrice),
                        isBold: true
                    )
                }
            }
            .padding(20)
            .background(Color.tfsSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            // Loan Breakdown
            VStack(alignment: .leading, spacing: 16) {
                Text("\(financingCalc.isLeaseMode ? "Lease" : "Loan") Breakdown")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.tfsPrimary)
                
                VStack(spacing: 12) {
                    PriceBreakdownRow(
                        title: "Down Payment",
                        value: formatCurrency(downPayment),
                        isBold: false
                    )
                    
                    PriceBreakdownRow(
                        title: "Amount Financed",
                        value: formatCurrency(loanAmount),
                        isBold: false
                    )
                    
                    PriceBreakdownRow(
                        title: "Monthly Payment",
                        value: formatCurrency(monthlyPayment),
                        isBold: false
                    )
                    
                    PriceBreakdownRow(
                        title: "Term Length",
                        value: "\(financingCalc.isLeaseMode ? financingCalc.leaseTermMonths : financingCalc.loanTermMonths) months",
                        isBold: false
                    )
                    
                    Divider()
                    
                    PriceBreakdownRow(
                        title: "Total Paid Over Term",
                        value: formatCurrency(totalPaidOverTerm),
                        isBold: true
                    )
                    
                    PriceBreakdownRow(
                        title: "Total Interest",
                        value: formatCurrency(totalInterest),
                        isBold: false,
                        color: Color.tfsOrange
                    )
                }
            }
            .padding(20)
            .background(Color.tfsSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            
            // Total Cost of Ownership
            VStack(alignment: .leading, spacing: 16) {
                Text("Quick Facts")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.tfsPrimary)
                
                VStack(spacing: 12) {
                    QuickFactRow(
                        icon: "calendar",
                        title: "First Payment Due",
                        value: "30 days after delivery"
                    )
                    
                    QuickFactRow(
                        icon: "doc.text",
                        title: "Pre-Qualification",
                        value: "Approved based on TFS Score"
                    )
                    
                    QuickFactRow(
                        icon: "shield.checkered",
                        title: "Soft Credit Pull",
                        value: "No impact on credit score"
                    )
                }
            }
            .padding(20)
            .background(Color.tfsSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

// MARK: - Supporting Views

struct ProfileRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 32)
            
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(Color.tfsSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color.tfsPrimary)
        }
        .padding(.vertical, 4)
    }
}

struct AffordabilityCheck: View {
    let monthlyPayment: Double
    let availableMonthly: Double
    
    var percentage: Double {
        guard availableMonthly > 0 else { return 0 }
        return (monthlyPayment / availableMonthly) * 100
    }
    
    var isAffordable: Bool {
        percentage <= 80 // Payment should be <= 80% of available
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: isAffordable ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(isAffordable ? Color.tfsGreen : Color.tfsOrange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Affordability Check")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.tfsPrimary)
                    
                    Text(isAffordable ? 
                         "This payment is well within your budget" : 
                         "This payment is near your budget limit")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.tfsSecondary)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.tfsSecondaryBackground)
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(isAffordable ? Color.tfsGreen : Color.tfsOrange)
                        .frame(width: geometry.size.width * min(percentage / 100, 1.0), height: 8)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("Payment: \(String(format: "%.0f%%", percentage)) of available budget")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.tfsSecondary)
                
                Spacer()
            }
        }
        .padding(20)
        .background(
            isAffordable ? 
                Color.tfsGreen.opacity(0.1) : 
                Color.tfsOrange.opacity(0.1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(isAffordable ? Color.tfsGreen.opacity(0.3) : Color.tfsOrange.opacity(0.3), lineWidth: 1)
        )
    }
}

struct FeatureChip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color)
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.tfsPrimary)
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct TermButton: View {
    let months: Int
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(months)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                
                Text("months")
                    .font(.system(size: 11, weight: .medium))
            }
            .foregroundStyle(isSelected ? .white : Color.tfsPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? Color.tfsRed : Color.tfsBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.tfsRed, lineWidth: isSelected ? 0 : 1)
            )
        }
    }
}

private struct PriceBreakdownRow: View {
    let title: String
    let value: String
    let isBold: Bool
    var color: Color = Color.tfsPrimary
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: isBold ? 16 : 15, weight: isBold ? .bold : .medium))
                .foregroundStyle(isBold ? Color.tfsPrimary : Color.tfsSecondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: isBold ? 17 : 16, weight: isBold ? .bold : .semibold, design: .rounded))
                .foregroundStyle(color)
        }
        .padding(.vertical, 2)
    }
}

struct QuickFactRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color.tfsRed)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.tfsSecondary)
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.tfsPrimary)
            }
            
            Spacer()
        }
    }
}

struct PreApprovalCTA: View {
    let tfsScore: Int
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 48, weight: .medium))
                    .foregroundStyle(Color.tfsGreen)
                
                Text("Ready to Proceed")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.tfsPrimary)
                
                Text("Based on your TFS Score of \(tfsScore), you're pre-qualified for this vehicle with the rates shown above.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.tfsSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            } label: {
                Text("Start Application")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
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
        .padding(24)
        .background(Color.tfsSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

#Preview {
    BuyView(
        vehicle: Vehicle(
            year: 2025,
            make: "Toyota",
            model: "Camry",
            trim: "LE",
            msrp_usd_est: 28900,
            horsepower_hp: 225,
            drivetrain: "FWD",
            powertrain: "Hybrid",
            body_style: "Sedan",
            image_url: "https://www.pngplay.com/wp-content/uploads/13/Toyota-Camry-2019-PNG-Photos.png"
        ),
        manager: OnboardingManager(),
        financingCalc: FinancingCalculator()
    )
}

