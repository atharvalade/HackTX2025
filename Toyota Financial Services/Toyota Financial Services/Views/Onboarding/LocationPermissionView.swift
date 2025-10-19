//
//  LocationPermissionView.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI
import CoreLocation

struct LocationPermissionView: View {
    let manager: OnboardingManager
    @State private var locationManager = CLLocationManager()
    @State private var locationDelegate = LocationDelegate()
    @State private var showContent = false
    @State private var isRequesting = false
    @State private var showCountyEdit = false
    
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
                
                Image(systemName: "location.fill")
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
                Text("Let's determine your location")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.tfsPrimary)
                    .multilineTextAlignment(.center)
                
                Text("We need your location to calculate accurate taxes, fees, and insurance rates for your area.")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(Color.tfsSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 40)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 20)
            
            Spacer()
            
            // Tax Info Display or Info Cards
            if manager.locationTaxData.hasData {
                VStack(spacing: 16) {
                    // Success checkmark
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(Color.tfsGreen)
                        
                        Text("Location determined successfully")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.tfsGreen)
                    }
                    
                    // Tax info card
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Your County")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.tfsSecondary)
                                
                                Text(manager.locationTaxData.county ?? "N/A")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Color.tfsPrimary)
                            }
                            
                            Spacer()
                        }
                        
                        Divider()
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Sales Tax Rate")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(Color.tfsSecondary)
                                
                                Text(manager.locationTaxData.formattedTaxPercentage)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(Color.tfsPrimary)
                            }
                            
                            Spacer()
                        }
                        
                        if let zipCode = manager.locationTaxData.zipCode {
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("ZIP Code")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(Color.tfsSecondary)
                                    
                                    Text(zipCode)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(Color.tfsPrimary)
                                }
                                
                                Spacer()
                            }
                        }
                        
                        // Change County Button
                        Button {
                            let impactLight = UIImpactFeedbackGenerator(style: .light)
                            impactLight.impactOccurred()
                            showCountyEdit = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 13, weight: .medium))
                                Text("Change County Info")
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .foregroundStyle(Color.tfsRed)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .background(Color.tfsRed.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                    }
                    .padding(20)
                    .background(Color.tfsSecondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
                .transition(.asymmetric(
                    insertion: .move(edge: .bottom).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            } else if manager.locationTaxData.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(Color.tfsRed)
                    
                    Text("Determining your county and tax rate...")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.tfsSecondary)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
                .transition(.opacity)
            } else {
                VStack(spacing: 12) {
                    InfoCard(
                        icon: "shield.checkered",
                        text: "Your location is only used for pricing calculations"
                    )
                    
                    InfoCard(
                        icon: "eye.slash",
                        text: "We never share your location with third parties"
                    )
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
            }
            
            // Error message if any
            if let error = manager.locationTaxData.error {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.tfsOrange)
                    
                    Text(error)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.tfsSecondary)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 16)
            }
            
            // Buttons
            VStack(spacing: 12) {
                if manager.locationTaxData.hasData {
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
                        requestLocationPermission()
                    } label: {
                        HStack(spacing: 8) {
                            if isRequesting || manager.locationTaxData.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                
                                Text("Enable Location")
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
                    .disabled(isRequesting || manager.locationTaxData.isLoading)
                    
                    Button {
                        let impactMed = UIImpactFeedbackGenerator(style: .light)
                        impactMed.impactOccurred()
                        manager.nextStep()
                    } label: {
                        Text("Skip for now")
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
            locationManager.delegate = locationDelegate
            locationDelegate.onLocationUpdate = { location in
                Task {
                    await fetchTaxInfo(for: location)
                }
            }
        }
        .sheet(isPresented: $showCountyEdit) {
            CountyEditSheet(locationTaxData: manager.locationTaxData)
        }
    }
    
    private func requestLocationPermission() {
        isRequesting = true
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        
        manager.locationTaxData.clearError()
        
        // Request location permission
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        // Timeout after 10 seconds if no location is received
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if !manager.locationTaxData.hasData && manager.locationTaxData.isLoading {
                isRequesting = false
                manager.locationTaxData.isLoading = false
                manager.locationTaxData.setError("Unable to determine location. Please try again or skip.")
            }
        }
    }
    
    private func fetchTaxInfo(for location: CLLocation) async {
        isRequesting = false
        manager.locationTaxData.isLoading = true
        manager.hasGrantedLocation = true
        
        do {
            let taxInfo = try await GeminiService.shared.fetchCountyAndTax(for: location)
            
            await MainActor.run {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    manager.locationTaxData.updateData(
                        county: taxInfo.county,
                        tax: taxInfo.salesTaxPercentage,
                        zipCode: taxInfo.zipCode
                    )
                    manager.locationTaxData.isLoading = false
                }
                
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.success)
            }
        } catch {
            await MainActor.run {
                manager.locationTaxData.setError(error.localizedDescription)
                
                let notificationFeedback = UINotificationFeedbackGenerator()
                notificationFeedback.notificationOccurred(.error)
            }
        }
    }
}

// MARK: - Location Delegate
class LocationDelegate: NSObject, CLLocationManagerDelegate {
    var onLocationUpdate: ((CLLocation) -> Void)?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        manager.stopUpdatingLocation()
        onLocationUpdate?(location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        manager.stopUpdatingLocation()
    }
}

struct InfoCard: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(Color.tfsRed)
                .frame(width: 32, height: 32)
            
            Text(text)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(Color.tfsSecondary)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(16)
        .background(Color.tfsSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct ProgressBar: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.tfsSecondaryBackground)
                    .frame(height: 6)
                
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [.tfsRed, .tfsDarkRed],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 6)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
            }
        }
        .frame(height: 6)
    }
}

#Preview {
    LocationPermissionView(manager: OnboardingManager())
}

