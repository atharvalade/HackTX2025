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
            
            // Scrollable Content Area
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 20)
                    
                    // Credit Data Display or Benefits
                    if manager.equifaxCreditData.hasData {
                VStack(spacing: 16) {
                    // Success checkmark
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.tfsGreen)
                        
                        Text("Credit check completed")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.tfsGreen)
                    }
                    
                    // Credit info card
                    VStack(spacing: 16) {
                        // Credit Score - Big Display
                        VStack(spacing: 8) {
                            Text("Your Credit Score")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.tfsSecondary)
                            
                            if let score = manager.equifaxCreditData.creditScore {
                                Text("\(score)")
                                    .font(.system(size: 56, weight: .bold, design: .rounded))
                                    .foregroundStyle(
                                        score >= 750 ? Color.tfsGreen :
                                        score >= 670 ? Color.tfsYellow :
                                        score >= 580 ? Color.tfsOrange : Color.tfsRed
                                    )
                                
                                Text(manager.equifaxCreditData.creditRating)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color.tfsPrimary)
                            }
                        }
                        .padding(.vertical, 12)
                        
                        Divider()
                        
                        // Credit Band
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Credit Band")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.tfsSecondary)
                                
                                Text(manager.equifaxCreditData.creditBand ?? "N/A")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color.tfsPrimary)
                            }
                            
                            Spacer()
                        }
                        
                        Divider()
                        
                        // Credit Utilization
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Credit Utilization")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.tfsSecondary)
                                
                                Text(manager.equifaxCreditData.formattedUtilization)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(Color.tfsPrimary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Open Accounts")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.tfsSecondary)
                                
                                if let accounts = manager.equifaxCreditData.accountsOpen {
                                    Text("\(accounts)")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(Color.tfsPrimary)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Top Credit Factors
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Key Credit Factors")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.tfsPrimary)
                            
                            ForEach(manager.equifaxCreditData.topFactors, id: \.self) { factor in
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(Color.tfsGreen)
                                    
                                    Text(factor)
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundStyle(Color.tfsPrimary)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding(12)
                        .background(Color.tfsGreen.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .padding(20)
                    .background(Color.tfsSecondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            } else if manager.equifaxCreditData.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(Color.tfsRed)
                    
                    Text("Performing soft credit check...")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.tfsSecondary)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
                .transition(.opacity)
            } else {
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
            }
            
            // Important Note
            if !manager.equifaxCreditData.hasData {
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
                    }
                    
                    Spacer()
                        .frame(height: 20)
                }
            }
            
            // Buttons
            VStack(spacing: 12) {
                if manager.equifaxCreditData.hasData {
                    Button {
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                        manager.nextStep()
                    } label: {
                        HStack(spacing: 8) {
                            Text("Continue")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
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
                } else {
                    Button {
                        connectEquifax()
                        } label: {
                        HStack(spacing: 8) {
                            if isConnecting || manager.equifaxCreditData.isLoading {
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
                    .disabled(isConnecting || manager.equifaxCreditData.isLoading)
                    
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
        manager.equifaxCreditData.isLoading = true
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        
        // Simulate Equifax connection and credit check
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                isConnecting = false
                manager.hasConnectedEquifax = true
                
                // Simulate fetched credit data
                manager.equifaxCreditData.updateData(
                    score: 742,
                    band: "Good to Very Good",
                    factors: [
                        "Low credit utilization (18%)",
                        "No recent delinquencies",
                        "Good payment history",
                        "Established credit age (8+ years)"
                    ],
                    accounts: 7,
                    utilization: 18.3
                )
                manager.equifaxCreditData.isLoading = false
            }
            
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
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

