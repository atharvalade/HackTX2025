//
//  WishlistView.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

struct WishlistView: View {
    @Environment(\.dismiss) var dismiss
    let vehicles: [Vehicle]
    let manager: OnboardingManager
    let financingCalc: FinancingCalculator
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.tfsBackground.ignoresSafeArea()
                
                if vehicles.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 60, weight: .medium))
                            .foregroundStyle(Color.tfsSecondary.opacity(0.5))
                        
                        Text("No Saved Vehicles")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.tfsPrimary)
                        
                        Text("Swipe right on vehicles you like to add them to your wishlist")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(Color.tfsSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(vehicles) { vehicle in
                                WishlistCard(
                                    vehicle: vehicle,
                                    manager: manager,
                                    financingCalc: financingCalc
                                )
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Wishlist (\(vehicles.count))")
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
}

struct WishlistCard: View {
    let vehicle: Vehicle
    let manager: OnboardingManager
    let financingCalc: FinancingCalculator
    @State private var showCarDetails = false
    
    var taxRate: Double {
        manager.locationTaxData.salesTaxPercentage ?? 8.25
    }
    
    var creditScore: Int {
        manager.equifaxCreditData.creditScore ?? 700
    }
    
    var monthlyPayment: Double {
        financingCalc.calculateMonthlyPayment(
            msrp: vehicle.msrp_usd,
            creditScore: creditScore,
            taxRate: taxRate
        )
    }
    
    var body: some View {
        Button {
            let impactLight = UIImpactFeedbackGenerator(style: .light)
            impactLight.impactOccurred()
            showCarDetails = true
        } label: {
            HStack(spacing: 16) {
                // Vehicle Image
                AsyncImage(url: URL(string: vehicle.image_url)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure, .empty:
                        ZStack {
                            Color.tfsSecondaryBackground
                            Image(systemName: "car.fill")
                                .font(.system(size: 30, weight: .medium))
                                .foregroundStyle(Color.tfsSecondary.opacity(0.3))
                        }
                    @unknown default:
                        Color.tfsSecondaryBackground
                    }
                }
                .frame(width: 120, height: 90)
                .background(Color.tfsSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                
                // Vehicle Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(vehicle.displayName)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Color.tfsPrimary)
                        .lineLimit(1)
                    
                    Text(vehicle.trim)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.tfsSecondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(formatCurrency(monthlyPayment))
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(Color.tfsRed)
                        
                        Text("/mo")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.tfsSecondary)
                    }
                }
                
                Spacer()
                
                // Buy Button
                VStack(spacing: 4) {
                    Image(systemName: "cart.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                    
                    Text("Buy")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 60, height: 60)
                .background(
                    LinearGradient(
                        colors: [Color.tfsRed, Color.tfsRed.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: Color.tfsRed.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(16)
            .background(Color.tfsSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showCarDetails) {
            BuyView(
                vehicle: vehicle,
                manager: manager,
                financingCalc: financingCalc
            )
        }
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

#Preview {
    WishlistView(
        vehicles: [],
        manager: OnboardingManager(),
        financingCalc: FinancingCalculator()
    )
}

