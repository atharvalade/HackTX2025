//
//  CompletionView.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

struct CompletionView: View {
    let manager: OnboardingManager
    @State private var showContent = false
    @State private var showConfetti = false
    @State private var navigateToSwipeDeck = false
    @State private var step1Complete = false
    @State private var step2Complete = false
    @State private var step3Complete = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Success Animation
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color.tfsGreen.opacity(0.2), lineWidth: 8)
                    .frame(width: 140, height: 140)
                    .scaleEffect(showContent ? 1.2 : 0.8)
                    .opacity(showContent ? 0.5 : 0)
                
                // Inner circle
                Circle()
                    .fill(Color.tfsGreen.opacity(0.15))
                    .frame(width: 120, height: 120)
                    .scaleEffect(showContent ? 1 : 0.5)
                
                // Checkmark
                Image(systemName: "checkmark")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundStyle(Color.tfsGreen)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)
            }
            
            Spacer()
                .frame(height: 40)
            
            // Title and Description
            VStack(spacing: 16) {
                Text("You're All Set!")
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.tfsPrimary)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                
                Text("We're analyzing your profile to find the perfect financing options for you.")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.tfsSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Processing Cards
            VStack(spacing: 16) {
                ProcessingCard(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Calculating TFS Score",
                    status: step1Complete ? "Complete" : "In Progress"
                )
                .opacity(showContent ? 1 : 0)
                .offset(x: showContent ? 0 : -20)
                
                ProcessingCard(
                    icon: "car.fill",
                    title: "Finding Vehicle Matches",
                    status: step2Complete ? "Complete" : (step1Complete ? "In Progress" : "Pending")
                )
                .opacity(showContent ? 1 : 0)
                .offset(x: showContent ? 0 : -20)
                
                ProcessingCard(
                    icon: "dollarsign.circle",
                    title: "Preparing Pre-Approvals",
                    status: step3Complete ? "Complete" : (step2Complete ? "In Progress" : "Pending")
                )
                .opacity(showContent ? 1 : 0)
                .offset(x: showContent ? 0 : -20)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
            
            // Continue Button
            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                navigateToSwipeDeck = true
            } label: {
                HStack(spacing: 8) {
                    Text("View My Deals")
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
                showContent = true
            }
            
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
            
            // Animate through the steps
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    step1Complete = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    step2Complete = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    step3Complete = true
                }
            }
        }
        .fullScreenCover(isPresented: $navigateToSwipeDeck) {
            SwipeDeckView(manager: manager)
        }
    }
}

struct ProcessingCard: View {
    let icon: String
    let title: String
    let status: String
    
    var statusColor: Color {
        switch status {
        case "Complete":
            return .tfsGreen
        case "In Progress":
            return .tfsOrange
        default:
            return .tfsSecondary
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Color.tfsRed)
                .frame(width: 44, height: 44)
                .background(Color.tfsRed.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.tfsPrimary)
                
                HStack(spacing: 6) {
                    if status == "In Progress" {
                        ProgressView()
                            .scaleEffect(0.7)
                            .frame(width: 12, height: 12)
                    } else if status == "Complete" {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(statusColor)
                    } else {
                        Circle()
                            .fill(statusColor.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                    
                    Text(status)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(statusColor)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.tfsSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    CompletionView(manager: OnboardingManager())
}

