//
//  CarDetailsView.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

struct CarDetailsView: View {
    @Environment(\.dismiss) var dismiss
    let vehicle: Vehicle
    let manager: OnboardingManager
    @State var financingCalc: FinancingCalculator
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.tfsBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Close Button
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(Color.tfsSecondary, Color.tfsSecondaryBackground)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Vehicle Card (non-swipeable)
                ScrollView(showsIndicators: false) {
                    VehicleCard(
                        vehicle: vehicle,
                        manager: manager,
                        financingCalc: financingCalc
                    )
                    .allowsHitTesting(true)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
    }
}

#Preview {
    CarDetailsView(
        vehicle: Vehicle(
            year: 2025,
            make: "Toyota",
            model: "Camry",
            trim: "LE",
            msrp_usd_est: 28900,
            horsepower_hp: 225,
            drivetrain: "FWD",
            powertrain: "Hybrid",
            body_style: "Sedan",
            image_url: "https://www.pngplay.com/wp-content/uploads/13/Toyota-Camry-2019-PNG-Photos.png"
        ),
        manager: OnboardingManager(),
        financingCalc: FinancingCalculator()
    )
}

