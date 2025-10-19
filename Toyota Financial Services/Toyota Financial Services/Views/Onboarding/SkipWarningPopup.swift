//
//  SkipWarningPopup.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

struct SkipWarningPopup: View {
    let manager: OnboardingManager
    
    var body: some View {
        VStack(spacing: 24) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.tfsOrange.opacity(0.15))
                    .frame(width: 64, height: 64)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(Color.tfsOrange)
            }
            
            // Title and Message
            VStack(spacing: 12) {
                Text(manager.skipWarningType.title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(Color.tfsPrimary)
                    .multilineTextAlignment(.center)
                
                Text(manager.skipWarningType.message)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.tfsSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 8)
            
            // Buttons
            VStack(spacing: 12) {
                Button {
                    let impactMed = UIImpactFeedbackGenerator(style: .light)
                    impactMed.impactOccurred()
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        manager.showSkipWarning = false
                    }
                } label: {
                    Text("Go Back")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [.tfsRed, .tfsDarkRed],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                
                Button {
                    let impactMed = UIImpactFeedbackGenerator(style: .light)
                    impactMed.impactOccurred()
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        manager.showSkipWarning = false
                    }
                    
                    // Small delay before moving to next step
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        manager.skipCurrentStep()
                    }
                } label: {
                    Text("Continue Anyway")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.tfsSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.tfsSecondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(32)
        .frame(maxWidth: 340)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.tfsBackground)
                .shadow(color: .black.opacity(0.2), radius: 30, x: 0, y: 10)
        )
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.4)
            .ignoresSafeArea()
        
        SkipWarningPopup(manager: OnboardingManager())
    }
}

