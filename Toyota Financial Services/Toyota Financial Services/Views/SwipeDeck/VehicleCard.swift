//
//  VehicleCard.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

struct VehicleCard: View {
    let vehicle: Vehicle
    let manager: OnboardingManager
    @Bindable var financingCalc: FinancingCalculator
    
    @State private var scrollOffset: CGFloat = 0
    @State private var showAPRInfo = false
    @State private var showTenureSelector = false
    
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
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Vehicle Image - Uses preloaded cache
                    AsyncImage(
                        url: URL(string: vehicle.image_url),
                        transaction: Transaction(animation: .easeInOut(duration: 0.3))
                    ) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipped()
                                .transition(.opacity)
                        case .failure(_):
                            placeholderImage
                                .overlay(alignment: .bottom) {
                                    Text("Image not available")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(Color.tfsSecondary)
                                        .padding(8)
                                }
                        case .empty:
                            ZStack {
                                Color.tfsSecondaryBackground
                                ProgressView()
                                    .tint(Color.tfsRed)
                            }
                            .frame(height: 250)
                        @unknown default:
                            placeholderImage
                        }
                    }
                    .frame(height: 250)
                    .background(
                        LinearGradient(
                            colors: [Color.tfsSecondaryBackground, Color.tfsBackground],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Card Content
                    VStack(alignment: .leading, spacing: 20) {
                        // Title & Price
                        VStack(alignment: .leading, spacing: 8) {
                            Text(vehicle.displayName)
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.tfsPrimary)
                            
                            Text(vehicle.trim)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color.tfsSecondary)
                        }
                        
                        // Monthly Payment - PROMINENT
                        VStack(spacing: 12) {
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text(formatCurrency(monthlyPayment))
                                    .font(.system(size: 48, weight: .black, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.tfsRed, .tfsDarkRed],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Text("/mo")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(Color.tfsSecondary)
                            }
                            
                            HStack(spacing: 8) {
                                Button {
                                    let impactLight = UIImpactFeedbackGenerator(style: .light)
                                    impactLight.impactOccurred()
                                    showAPRInfo = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(String(format: "%.2f%% APR", financingCalc.getAPR(creditScore: creditScore)))
                                            .font(.system(size: 14, weight: .semibold))
                                        Image(systemName: "info.circle.fill")
                                            .font(.system(size: 12, weight: .semibold))
                                    }
                                    .foregroundStyle(Color.tfsRed)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.tfsRed.opacity(0.1))
                                    .clipShape(Capsule())
                                }
                                
                                Text(financingCalc.getCreditTier(creditScore: creditScore))
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.tfsGreen)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.tfsGreen.opacity(0.1))
                                    .clipShape(Capsule())
                                
                                Button {
                                    let impactLight = UIImpactFeedbackGenerator(style: .light)
                                    impactLight.impactOccurred()
                                    showTenureSelector = true
                                } label: {
                                    HStack(spacing: 4) {
                                        Text("\(financingCalc.isLeaseMode ? financingCalc.leaseTermMonths : financingCalc.loanTermMonths) mos")
                                            .font(.system(size: 14, weight: .semibold))
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 10, weight: .semibold))
                                    }
                                    .foregroundStyle(Color.tfsPrimary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.tfsSecondaryBackground)
                                    .clipShape(Capsule())
                                }
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.tfsRed.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        
                        // Finance/Lease Toggle
                        FinanceLeaseToggle(financingCalc: financingCalc)
                        
                        // Down Payment Slider
                        DownPaymentSlider(
                            financingCalc: financingCalc,
                            msrp: vehicle.msrp_usd,
                            taxRate: taxRate
                        )
                        
                        Divider()
                        
                        // Cost Breakdown
                        CostBreakdown(
                            vehicle: vehicle,
                            financingCalc: financingCalc,
                            taxRate: taxRate,
                            countyName: manager.locationTaxData.county ?? "Your County"
                        )
                        
                        Divider()
                        
                        // Vehicle Specs
                        VehicleSpecs(vehicle: vehicle)
                        
                        // Scroll indicator
                        if scrollOffset < 50 {
                            HStack {
                                Spacer()
                                VStack(spacing: 4) {
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .semibold))
                                    Text("Scroll for details")
                                        .font(.system(size: 11, weight: .medium))
                                }
                                .foregroundStyle(Color.tfsSecondary)
                                .opacity(1.0 - (scrollOffset / 50.0))
                                Spacer()
                            }
                            .padding(.top, 8)
                        }
                    }
                    .padding(24)
                }
                .background(GeometryReader { geo in
                    Color.clear.preference(
                        key: ScrollOffsetPreferenceKey.self,
                        value: geo.frame(in: .named("scroll")).minY
                    )
                })
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = -value
            }
        }
        .background(Color.tfsBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        .alert("APR Explanation", isPresented: $showAPRInfo) {
            Button("Got It", role: .cancel) { }
        } message: {
            Text("Based on your Equifax credit score of \(creditScore), you qualify for a \(String(format: "%.2f%%", financingCalc.getAPR(creditScore: creditScore))) APR in the \(financingCalc.getCreditTier(creditScore: creditScore)) tier. This rate is competitive and reflects your strong credit profile.")
        }
        .sheet(isPresented: $showTenureSelector) {
            TenureSelector(financingCalc: financingCalc)
        }
    }
    
    private var placeholderImage: some View {
        ZStack {
            Color.tfsSecondaryBackground
            Image(systemName: "car.fill")
                .font(.system(size: 60, weight: .medium))
                .foregroundStyle(Color.tfsSecondary.opacity(0.3))
        }
        .frame(height: 250)
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct FinanceLeaseToggle: View {
    @Bindable var financingCalc: FinancingCalculator
    
    var body: some View {
        HStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    financingCalc.isLeaseMode = false
                }
                let impactLight = UIImpactFeedbackGenerator(style: .light)
                impactLight.impactOccurred()
            } label: {
                Text("Finance")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(financingCalc.isLeaseMode ? Color.tfsSecondary : .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(financingCalc.isLeaseMode ? Color.clear : Color.tfsRed)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    financingCalc.isLeaseMode = true
                }
                let impactLight = UIImpactFeedbackGenerator(style: .light)
                impactLight.impactOccurred()
            } label: {
                Text("Lease")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(financingCalc.isLeaseMode ? .white : Color.tfsSecondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(financingCalc.isLeaseMode ? Color.tfsRed : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
        .padding(4)
        .background(Color.tfsSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct DownPaymentSlider: View {
    @Bindable var financingCalc: FinancingCalculator
    let msrp: Double
    let taxRate: Double
    
    var downPaymentAmount: Double {
        financingCalc.getDownPaymentAmount(msrp: msrp, taxRate: taxRate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Down Payment")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.tfsPrimary)
                
                Spacer()
                
                Text("\(Int(financingCalc.downPaymentPercentage))%")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.tfsRed)
                
                Text("·")
                    .foregroundStyle(Color.tfsSecondary)
                
                Text(formatCurrency(downPaymentAmount))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Color.tfsPrimary)
            }
            
            Slider(value: $financingCalc.downPaymentPercentage, in: 0...30, step: 5)
                .tint(Color.tfsRed)
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            // Prevent card swipe while dragging slider
                        }
                )
        }
        .padding(16)
        .background(Color.tfsSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .contentShape(Rectangle()) // Make entire area tappable but not swipeable
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

struct CostBreakdown: View {
    let vehicle: Vehicle
    let financingCalc: FinancingCalculator
    let taxRate: Double
    let countyName: String
    
    var totalPrice: Double {
        financingCalc.getTotalPrice(msrp: vehicle.msrp_usd, taxRate: taxRate)
    }
    
    var taxAmount: Double {
        vehicle.msrp_usd * (taxRate / 100.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cost Breakdown")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.tfsPrimary)
            
            BreakdownRow(label: "MSRP", value: formatCurrency(vehicle.msrp_usd))
            BreakdownRow(
                label: "Sales Tax (\(countyName))",
                value: formatCurrency(taxAmount),
                subtitle: String(format: "%.2f%%", taxRate)
            )
            
            Divider()
            
            BreakdownRow(
                label: "Total Price",
                value: formatCurrency(totalPrice),
                isHighlighted: true
            )
            
            BreakdownRow(
                label: "Down Payment",
                value: "-" + formatCurrency(financingCalc.getDownPaymentAmount(msrp: vehicle.msrp_usd, taxRate: taxRate)),
                isNegative: true
            )
            
            Divider()
            
            BreakdownRow(
                label: financingCalc.isLeaseMode ? "Amount to Lease" : "Amount to Finance",
                value: formatCurrency(totalPrice - financingCalc.getDownPaymentAmount(msrp: vehicle.msrp_usd, taxRate: taxRate)),
                isHighlighted: true
            )
        }
        .padding(16)
        .background(Color.tfsSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
    
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "$0"
    }
}

struct BreakdownRow: View {
    let label: String
    let value: String
    var subtitle: String? = nil
    var isHighlighted: Bool = false
    var isNegative: Bool = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: isHighlighted ? 15 : 14, weight: isHighlighted ? .semibold : .regular))
                    .foregroundStyle(isHighlighted ? Color.tfsPrimary : Color.tfsSecondary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.tfsSecondary)
                }
            }
            
            Spacer()
            
            Text(value)
                .font(.system(size: isHighlighted ? 17 : 15, weight: isHighlighted ? .bold : .semibold))
                .foregroundStyle(isNegative ? Color.tfsGreen : isHighlighted ? Color.tfsRed : Color.tfsPrimary)
        }
    }
}

struct VehicleSpecs: View {
    let vehicle: Vehicle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Vehicle Details")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(Color.tfsPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                if let hp = vehicle.horsepower_hp {
                    SpecItem(icon: "gauge.with.needle", label: "Horsepower", value: "\(hp) hp")
                }
                
                SpecItem(icon: "car.fill", label: "Body Style", value: vehicle.body_style)
                
                SpecItem(icon: "arrow.triangle.branch", label: "Drivetrain", value: vehicle.drivetrain)
                
                SpecItem(icon: "fuelpump.fill", label: "Powertrain", value: vehicle.powertrain)
            }
        }
        .padding(16)
        .background(Color.tfsSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct SpecItem: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color.tfsRed)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.tfsSecondary)
                
                Text(value)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.tfsPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            Spacer(minLength: 0)
        }
        .padding(10)
        .background(Color.tfsBackground)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

#Preview {
    VehicleCard(
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
    .padding()
}

