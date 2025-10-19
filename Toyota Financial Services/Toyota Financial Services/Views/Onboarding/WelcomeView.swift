//
//  WelcomeView.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

struct WelcomeView: View {
    let manager: OnboardingManager
    @State private var isAnimating = false
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Logo and Title Section
            VStack(spacing: 32) {
                // TFS Logo
                Image("TFS Logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 140, height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .shadow(color: .tfsRed.opacity(0.3), radius: 20, x: 0, y: 10)
                    .scaleEffect(isAnimating ? 1 : 0.8)
                    .opacity(isAnimating ? 1 : 0)
                
                // Title and Subtitle
                VStack(spacing: 12) {
                    Text("Welcome to TFS")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.tfsRed, .tfsDarkRed],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                    
                    Text("World's easiest financing option")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.tfsSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                }
                .padding(.horizontal, 32)
            }
            
            Spacer()
            
            // Features
            VStack(spacing: 20) {
                FeatureRow(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Instant Pre-Approval",
                    description: "Get pre-approved in minutes, not days"
                )
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
                
                FeatureRow(
                    icon: "lock.shield",
                    title: "Bank-Level Security",
                    description: "Your data is encrypted and protected"
                )
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
                
                FeatureRow(
                    icon: "hand.thumbsup",
                    title: "Zero Friction",
                    description: "Just a few taps to your dream car"
                )
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            
            // Get Started Button
            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                manager.nextStep()
            } label: {
                HStack(spacing: 8) {
                    Text("Get Started")
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
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 30)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAnimating = true
            }
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                showContent = true
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(Color.tfsRed)
                .frame(width: 48, height: 48)
                .background(Color.tfsRed.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.tfsPrimary)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.tfsSecondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    WelcomeView(manager: OnboardingManager())
}

