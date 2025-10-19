//
//  PlaidConnectionView.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

struct PlaidConnectionView: View {
    let manager: OnboardingManager
    @State private var showContent = false
    @State private var isConnecting = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Bar
            ProgressBar(progress: manager.currentStep.progress)
                .padding(.horizontal, 32)
                .padding(.top, 20)
            
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(Color.tfsRed.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 50, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.tfsRed, .tfsDarkRed],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .scaleEffect(showContent ? 1 : 0.8)
            .opacity(showContent ? 1 : 0)
            
            Spacer()
                .frame(height: 40)
            
            // Title and Description
            VStack(spacing: 16) {
                Text("Connect with Plaid")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.tfsPrimary)
                    .multilineTextAlignment(.center)
                
                Text("We'll securely fetch your income data and spending habits to provide personalized financing options.")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.tfsSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 40)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            
            Spacer()
            
            // What We'll Access
            VStack(alignment: .leading, spacing: 16) {
                Text("What we'll access:")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.tfsPrimary)
                
                VStack(spacing: 12) {
                    AccessItem(icon: "dollarsign.circle", text: "Income and pay cadence")
                    AccessItem(icon: "chart.bar", text: "Transaction patterns")
                    AccessItem(icon: "calendar", text: "Payment stability")
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.tfsSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            
            // Security Badge
            HStack(spacing: 8) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color.tfsGreen)
                
                Text("256-bit encryption • We never see your login credentials")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.tfsSecondary)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
            .opacity(showContent ? 1 : 0)
            
            // Buttons
            VStack(spacing: 12) {
                Button {
                    connectPlaid()
                } label: {
                    HStack(spacing: 8) {
                        if isConnecting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "link")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Text("Connect with Plaid")
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
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
                .disabled(isConnecting)
                
                Button {
                    let impactMed = UIImpactFeedbackGenerator(style: .light)
                    impactMed.impactOccurred()
                    showSkipWarning()
                } label: {
                    Text("Submit financial documents later")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.tfsSecondary)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
    
    private func connectPlaid() {
        isConnecting = true
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        
        // Simulate Plaid connection
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isConnecting = false
            manager.hasConnectedPlaid = true
            
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
            
            manager.nextStep()
        }
    }
    
    private func showSkipWarning() {
        manager.skipWarningType = .plaid
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            manager.showSkipWarning = true
        }
    }
}

struct AccessItem: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.tfsRed)
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.tfsPrimary)
            
            Spacer()
        }
    }
}

#Preview {
    PlaidConnectionView(manager: OnboardingManager())
}

