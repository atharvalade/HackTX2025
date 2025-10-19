//
//  EquifaxConnectionView.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

struct EquifaxConnectionView: View {
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
                
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
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
                Text("Check Your Credit")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.tfsPrimary)
                    .multilineTextAlignment(.center)
                
                Text("We'll perform a soft credit check with Equifax to provide accurate pre-approved offers. This won't impact your credit score.")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.tfsSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 40)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            
            Spacer()
            
            // Benefits
            VStack(alignment: .leading, spacing: 16) {
                Text("You'll receive:")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.tfsPrimary)
                
                VStack(spacing: 12) {
                    BenefitItem(icon: "checkmark.seal.fill", text: "Personalized interest rates", color: .tfsGreen)
                    BenefitItem(icon: "star.fill", text: "Instant pre-approval decisions", color: .tfsYellow)
                    BenefitItem(icon: "chart.bar.fill", text: "Your TFS Score (0-100)", color: .tfsOrange)
                    BenefitItem(icon: "hand.thumbsup.fill", text: "Best-fit vehicle recommendations", color: .tfsRed)
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
            
            // Important Note
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.blue)
                
                Text("Soft check only • No impact on your credit score")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.tfsSecondary)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 24)
            .opacity(showContent ? 1 : 0)
            
            // Buttons
            VStack(spacing: 12) {
                Button {
                    connectEquifax()
                } label: {
                    HStack(spacing: 8) {
                        if isConnecting {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 16, weight: .semibold))
                            
                            Text("Connect with Equifax")
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
                    Text("I'll do this later")
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
    
    private func connectEquifax() {
        isConnecting = true
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        
        // Simulate Equifax connection
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isConnecting = false
            manager.hasConnectedEquifax = true
            
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
            
            manager.nextStep()
        }
    }
    
    private func showSkipWarning() {
        manager.skipWarningType = .equifax
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            manager.showSkipWarning = true
        }
    }
}

struct BenefitItem: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(color)
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(Color.tfsPrimary)
            
            Spacer()
        }
    }
}

#Preview {
    EquifaxConnectionView(manager: OnboardingManager())
}

