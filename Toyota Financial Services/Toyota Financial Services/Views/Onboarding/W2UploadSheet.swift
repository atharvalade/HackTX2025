//
//  W2UploadSheet.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct W2UploadSheet: View {
    @Environment(\.dismiss) var dismiss
    let plaidData: PlaidFinancialData
    
    @State private var annualIncome: String = ""
    @State private var showError = false
    @State private var showFilePicker = false
    @State private var uploadedFileName: String?
    @State private var showSuccessMessage = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.tfsRed, .tfsDarkRed],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Text("Update Income Info")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.tfsPrimary)
                    
                    Text("Manually enter your annual income from W-2")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(Color.tfsSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Upload W-2 Section
                VStack(spacing: 16) {
                    Button {
                        let impactLight = UIImpactFeedbackGenerator(style: .light)
                        impactLight.impactOccurred()
                        showFilePicker = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: uploadedFileName == nil ? "doc.badge.plus" : "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundStyle(uploadedFileName == nil ? Color.tfsRed : Color.tfsGreen)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(uploadedFileName == nil ? "Upload W-2 Document" : "Document Uploaded")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color.tfsPrimary)
                                
                                Text(uploadedFileName ?? "PDF, JPG, PNG (Max 10MB)")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundStyle(Color.tfsSecondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.tfsSecondary)
                        }
                        .padding(16)
                        .background(Color.tfsSecondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    
                    Text("— OR —")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color.tfsSecondary)
                    
                    // Manual Entry
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Annual Income (Before Taxes)")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.tfsPrimary)
                        
                        HStack {
                            Text("$")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.tfsSecondary)
                            
                            TextField("e.g., 134560", text: $annualIncome)
                                .textFieldStyle(.plain)
                                .keyboardType(.numberPad)
                                .font(.system(size: 16, weight: .regular))
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
                        
                        Text("Please enter a valid income amount")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.tfsSecondary)
                    }
                    .padding(.horizontal, 24)
                }
                
                // Info
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.blue)
                    
                    Text("This will be used to calculate your payment capacity")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.tfsSecondary)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Success Message
                if showSuccessMessage {
                    VStack(spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.blue)
                            
                            Text("Document Submitted")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.tfsPrimary)
                        }
                        
                        Text("Your W-2 will be manually reviewed and income will be updated within 48 hours. You'll receive a notification once processed.")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.tfsSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(16)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .padding(.horizontal, 24)
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Buttons
                VStack(spacing: 12) {
                    if !showSuccessMessage {
                        Button {
                            saveChanges()
                        } label: {
                            Text(uploadedFileName == nil ? "Update Income" : "Submit for Review")
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
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Text(showSuccessMessage ? "Done" : "Cancel")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(showSuccessMessage ? Color.tfsRed : Color.tfsSecondary)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.pdf, .jpeg, .png],
            allowsMultipleSelection: false
        ) { result in
            handleFileSelection(result)
        }
        .onAppear {
            if let income = plaidData.income {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = 0
                annualIncome = formatter.string(from: NSNumber(value: income)) ?? ""
            }
        }
    }
    
    private func handleFileSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            uploadedFileName = url.lastPathComponent
            let impactMed = UIImpactFeedbackGenerator(style: .medium)
            impactMed.impactOccurred()
        case .failure:
            showError = true
        }
    }
    
    private func saveChanges() {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        
        // If file was uploaded, show success message
        if uploadedFileName != nil {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showSuccessMessage = true
            }
            impactMed.impactOccurred()
            
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
            return
        }
        
        // Otherwise, validate manual entry
        guard let income = Double(annualIncome.replacingOccurrences(of: ",", with: "")), income > 0 else {
            showError = true
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.error)
            return
        }
        
        showError = false
        impactMed.impactOccurred()
        
        plaidData.updateData(
            income: income,
            spending: plaidData.averageSpending ?? 0
        )
        
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
        
        dismiss()
    }
}

#Preview {
    W2UploadSheet(plaidData: PlaidFinancialData())
}

