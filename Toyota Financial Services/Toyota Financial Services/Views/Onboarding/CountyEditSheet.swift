//
//  CountyEditSheet.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

struct CountyEditSheet: View {
    @Environment(\.dismiss) var dismiss
    let locationTaxData: LocationTaxData
    
    @State private var countyName: String = ""
    @State private var taxPercentage: String = ""
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.tfsRed, .tfsDarkRed],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Update Location Info")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.tfsPrimary)
                    
                    Text("Manually adjust your county and tax rate")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.tfsSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Form Fields
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("County Name")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.tfsPrimary)
                        
                        TextField("e.g., Travis County", text: $countyName)
                            .textFieldStyle(.plain)
                            .padding(16)
                            .background(Color.tfsSecondaryBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .font(.system(size: 16, weight: .regular))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Sales Tax Percentage")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.tfsPrimary)
                        
                        HStack {
                            TextField("e.g., 8.25", text: $taxPercentage)
                                .textFieldStyle(.plain)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 16, weight: .regular))
                            
                            Text("%")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.tfsSecondary)
                        }
                        .padding(16)
                        .background(Color.tfsSecondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(.horizontal, 24)
                
                if showError {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.tfsOrange)
                        
                        Text("Please fill in both fields with valid information")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.tfsSecondary)
                    }
                    .padding(.horizontal, 24)
                }
                
                Spacer()
                
                // Buttons
                VStack(spacing: 12) {
                    Button {
                        saveChanges()
                    } label: {
                        Text("Save Changes")
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
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.tfsSecondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onAppear {
            countyName = locationTaxData.county ?? ""
            if let tax = locationTaxData.salesTaxPercentage {
                taxPercentage = String(format: "%.2f", tax)
            }
        }
    }
    
    private func saveChanges() {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        
        guard !countyName.trimmingCharacters(in: .whitespaces).isEmpty,
              let tax = Double(taxPercentage), tax > 0, tax < 100 else {
            showError = true
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.error)
            return
        }
        
        showError = false
        impactMed.impactOccurred()
        
        locationTaxData.updateData(
            county: countyName.trimmingCharacters(in: .whitespaces),
            tax: tax,
            zipCode: locationTaxData.zipCode ?? ""
        )
        
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        dismiss()
    }
}

#Preview {
    CountyEditSheet(locationTaxData: LocationTaxData())
}

