//
//  OnboardingContainerView.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

struct OnboardingContainerView: View {
    @State private var manager = OnboardingManager()
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.tfsBackground, Color.tfsSecondaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content
            Group {
                switch manager.currentStep {
                case .welcome:
                    WelcomeView(manager: manager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .location:
                    LocationPermissionView(manager: manager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .plaid:
                    PlaidConnectionView(manager: manager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .equifax:
                    EquifaxConnectionView(manager: manager)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                case .complete:
                    CompletionView()
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .opacity
                        ))
                }
            }
            .id(manager.currentStep)
            
            // Skip Warning Popup
            if manager.showSkipWarning {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            manager.showSkipWarning = false
                        }
                    }
                
                SkipWarningPopup(manager: manager)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: manager.currentStep)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: manager.showSkipWarning)
    }
}

#Preview {
    OnboardingContainerView()
}

