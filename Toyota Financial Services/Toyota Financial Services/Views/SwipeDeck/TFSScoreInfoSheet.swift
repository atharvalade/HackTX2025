//
//  TFSScoreInfoSheet.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

struct TFSScoreInfoSheet: View {
    @Environment(\.dismiss) var dismiss
    let score: Int
    
    var scoreBand: ScoreBand {
        TFSScoreCalculator.getScoreBand(score: score)
    }
    
    var scoreDescription: String {
        TFSScoreCalculator.getScoreDescription(score: score)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.tfsBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Score Display
                        VStack(spacing: 16) {
                            Text("Your TFS Score")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.tfsSecondary)
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.tfsSecondaryBackground, lineWidth: 12)
                                    .frame(width: 160, height: 160)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(score) / 100.0)
                                    .stroke(
                                        getScoreColor(),
                                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                    )
                                    .frame(width: 160, height: 160)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack(spacing: 4) {
                                    Text("\(score)")
                                        .font(.system(size: 56, weight: .black, design: .rounded))
                                        .foregroundStyle(getScoreColor())
                                    
                                    Text(scoreDescription)
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(Color.tfsSecondary)
                                }
                            }
                            .padding(.vertical, 20)
                        }
                        
                        // Explanation
                        VStack(alignment: .leading, spacing: 20) {
                            Text("What is TFS Score?")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.tfsPrimary)
                            
                            Text("Your TFS Score is a comprehensive 0-100 rating that reflects your auto financing readiness.")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundStyle(Color.tfsSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            VStack(spacing: 16) {
                                ScoreFactorRow(
                                    icon: "creditcard.fill",
                                    title: "Credit Score",
                                    weight: "40%",
                                    description: "Your creditworthiness"
                                )
                                
                                ScoreFactorRow(
                                    icon: "dollarsign.circle.fill",
                                    title: "Income Level",
                                    weight: "25%",
                                    description: "Your earning capacity"
                                )
                                
                                ScoreFactorRow(
                                    icon: "chart.bar.fill",
                                    title: "Payment Capacity",
                                    weight: "20%",
                                    description: "Available monthly budget"
                                )
                                
                                ScoreFactorRow(
                                    icon: "banknote.fill",
                                    title: "Savings Rate",
                                    weight: "15%",
                                    description: "Financial cushion"
                                )
                            }
                            
                            // Score Bands
                            VStack(spacing: 12) {
                                Text("Score Bands")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.tfsPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                ScoreBandRow(
                                    color: Color.tfsGreen,
                                    range: "75-100",
                                    description: "Excellent financing options with best rates"
                                )
                                
                                ScoreBandRow(
                                    color: Color.tfsOrange,
                                    range: "50-74",
                                    description: "Good options with competitive rates"
                                )
                                
                                ScoreBandRow(
                                    color: Color.tfsRed,
                                    range: "0-49",
                                    description: "Limited options, consider improving factors"
                                )
                            }
                            
                            Text("A higher score gives you access to better APR rates, higher loan amounts, and more flexible terms.")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(Color.tfsSecondary)
                                .padding(.top, 8)
                        }
                        .padding(20)
                        .background(Color.tfsSecondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .padding(20)
                }
            }
            .navigationTitle("TFS Score")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Color.tfsRed)
                }
            }
        }
    }
    
    private func getScoreColor() -> Color {
        switch scoreBand {
        case .green:
            return Color.tfsGreen
        case .yellow:
            return Color.tfsOrange
        case .red:
            return Color.tfsRed
        }
    }
}

struct ScoreFactorRow: View {
    let icon: String
    let title: String
    let weight: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.tfsRed)
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.tfsPrimary)
                    
                    Text(weight)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.tfsRed)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.tfsRed.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.tfsSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ScoreBandRow: View {
    let color: Color
    let range: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            
            Text(range)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.tfsPrimary)
                .frame(width: 60, alignment: .leading)
            
            Text(description)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.tfsSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    TFSScoreInfoSheet(score: 78)
}

