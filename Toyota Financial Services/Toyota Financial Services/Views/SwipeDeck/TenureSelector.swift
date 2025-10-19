//
//  TenureSelector.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

struct TenureSelector: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var financingCalc: FinancingCalculator
    
    let financeOptions = [24, 36, 48, 60, 72, 84]
    let leaseOptions = [24, 36, 48]
    
    var options: [Int] {
        financingCalc.isLeaseMode ? leaseOptions : financeOptions
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.tfsRed, .tfsDarkRed],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Select \(financingCalc.isLeaseMode ? "Lease" : "Loan") Term")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.tfsPrimary)
                    
                    Text("Choose your preferred payment period")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.tfsSecondary)
                }
                .padding(.top, 20)
                
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(options, id: \.self) { months in
                            TenureOption(
                                months: months,
                                isSelected: financingCalc.isLeaseMode ? 
                                    financingCalc.leaseTermMonths == months :
                                    financingCalc.loanTermMonths == months,
                                action: {
                                    selectTenure(months)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                }
                
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [.tfsRed, .tfsDarkRed],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: .tfsRed.opacity(0.4), radius: 12, x: 0, y: 6)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    private func selectTenure(_ months: Int) {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            if financingCalc.isLeaseMode {
                financingCalc.leaseTermMonths = months
            } else {
                financingCalc.loanTermMonths = months
            }
        }
    }
}

struct TenureOption: View {
    let months: Int
    let isSelected: Bool
    let action: () -> Void
    
    var years: Double {
        Double(months) / 12.0
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(months) Months")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.tfsPrimary)
                    
                    Text(String(format: "%.1f years", years))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.tfsSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(Color.tfsGreen)
                } else {
                    Image(systemName: "circle")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(Color.tfsSecondary.opacity(0.3))
                }
            }
            .padding(16)
            .background(isSelected ? Color.tfsGreen.opacity(0.1) : Color.tfsSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Color.tfsGreen : Color.clear, lineWidth: 2)
            )
        }
    }
}

#Preview {
    TenureSelector(financingCalc: FinancingCalculator())
}

