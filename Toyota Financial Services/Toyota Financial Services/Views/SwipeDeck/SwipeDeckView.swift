//
//  SwipeDeckView.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

struct SwipeDeckView: View {
    let manager: OnboardingManager
    @State private var vehicleManager = VehicleManager()
    @State private var financingCalc = FinancingCalculator()
    @State private var showWishlist = false
    @State private var offset = CGSize.zero
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [Color.tfsBackground, Color.tfsSecondaryBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                SwipeDeckHeader(wishlistCount: vehicleManager.wishlist.count, showWishlist: $showWishlist)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                if vehicleManager.hasMoreVehicles {
                    // Card Stack
                    ZStack {
                        // Background cards (preview of next 2 cards) - only show when not swiping
                        if abs(offset.width) < 10 {
                            if let nextVehicle = vehicleManager.vehicles.indices.contains(vehicleManager.currentIndex + 1) ?
                                vehicleManager.vehicles[vehicleManager.currentIndex + 1] : nil {
                                VehicleCard(
                                    vehicle: nextVehicle,
                                    manager: manager,
                                    financingCalc: financingCalc
                                )
                                .scaleEffect(0.95)
                                .offset(y: 10)
                                .opacity(0.5)
                                .allowsHitTesting(false)
                            }
                            
                            if let nextNextVehicle = vehicleManager.vehicles.indices.contains(vehicleManager.currentIndex + 2) ?
                                vehicleManager.vehicles[vehicleManager.currentIndex + 2] : nil {
                                VehicleCard(
                                    vehicle: nextNextVehicle,
                                    manager: manager,
                                    financingCalc: financingCalc
                                )
                                .scaleEffect(0.90)
                                .offset(y: 20)
                                .opacity(0.3)
                                .allowsHitTesting(false)
                            }
                        }
                        
                        // Current card
                        if let currentVehicle = vehicleManager.currentVehicle {
                            VehicleCard(
                                vehicle: currentVehicle,
                                manager: manager,
                                financingCalc: financingCalc
                            )
                            .offset(offset)
                            .rotationEffect(.degrees(rotation))
                            .zIndex(1)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        offset = gesture.translation
                                        rotation = Double(gesture.translation.width / 20)
                                    }
                                    .onEnded { gesture in
                                        handleSwipeEnd(gesture)
                                    }
                            )
                            .overlay(alignment: .topLeading) {
                                if offset.width > 50 {
                                    SwipeIndicator(type: .like)
                                        .padding(30)
                                }
                            }
                            .overlay(alignment: .topTrailing) {
                                if offset.width < -50 {
                                    SwipeIndicator(type: .nope)
                                        .padding(30)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    
                    // Action Buttons
                    SwipeActionButtons(
                        onNope: { handleLeftSwipe() },
                        onLike: { handleRightSwipe() }
                    )
                    .padding(.horizontal, 60)
                    .padding(.bottom, 30)
                } else {
                    // No more vehicles - centered completion view
                    Spacer()
                    
                    CompleteDeckView(wishlistCount: vehicleManager.wishlist.count)
                        .transition(.scale.combined(with: .opacity))
                    
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showWishlist) {
            WishlistView(vehicles: vehicleManager.wishlist, manager: manager, financingCalc: financingCalc)
        }
    }
    
    private func handleSwipeEnd(_ gesture: DragGesture.Value) {
        let threshold: CGFloat = 150
        
        if gesture.translation.width > threshold {
            // Swipe right - Like
            handleRightSwipe()
        } else if gesture.translation.width < -threshold {
            // Swipe left - Nope
            handleLeftSwipe()
        } else {
            // Return to center
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                offset = .zero
                rotation = 0
            }
        }
    }
    
    private func handleRightSwipe() {
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            offset = CGSize(width: 500, height: 0)
            rotation = 20
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            vehicleManager.swipeRight()
            offset = .zero
            rotation = 0
        }
    }
    
    private func handleLeftSwipe() {
        let impactLight = UIImpactFeedbackGenerator(style: .light)
        impactLight.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            offset = CGSize(width: -500, height: 0)
            rotation = -20
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            vehicleManager.swipeLeft()
            offset = .zero
            rotation = 0
        }
    }
}

struct SwipeDeckHeader: View {
    let wishlistCount: Int
    @Binding var showWishlist: Bool
    
    var body: some View {
        HStack {
            Image("TFS Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            
            Text("Swipe Deals")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color.tfsPrimary)
            
            Spacer()
            
            Button {
                let impactLight = UIImpactFeedbackGenerator(style: .light)
                impactLight.impactOccurred()
                showWishlist = true
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(Color.tfsRed)
                    
                    if wishlistCount > 0 {
                        Text("\(wishlistCount)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.tfsRed)
                            .clipShape(Circle())
                            .offset(x: 8, y: -8)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct SwipeIndicator: View {
    enum IndicatorType {
        case like, nope
    }
    
    let type: IndicatorType
    
    var body: some View {
        Text(type == .like ? "LIKE" : "NOPE")
            .font(.system(size: 40, weight: .black, design: .rounded))
            .foregroundStyle(type == .like ? Color.tfsGreen : Color.tfsRed)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(type == .like ? Color.tfsGreen : Color.tfsRed, lineWidth: 4)
            )
            .rotationEffect(.degrees(type == .like ? -20 : 20))
    }
}

struct SwipeActionButtons: View {
    let onNope: () -> Void
    let onLike: () -> Void
    
    var body: some View {
        HStack(spacing: 40) {
            Button(action: onNope) {
                Image(systemName: "xmark")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(Color.tfsRed)
                    .clipShape(Circle())
                    .shadow(color: .tfsRed.opacity(0.4), radius: 12, x: 0, y: 6)
            }
            
            Button(action: onLike) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        LinearGradient(
                            colors: [.tfsGreen, .tfsGreen.opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: .tfsGreen.opacity(0.4), radius: 12, x: 0, y: 6)
            }
        }
    }
}

struct CompleteDeckView: View {
    let wishlistCount: Int
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80, weight: .medium))
                .foregroundStyle(Color.tfsGreen)
            
            Text("You've seen all vehicles!")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.tfsPrimary)
            
            Text("Check your wishlist to review \(wishlistCount) saved vehicles")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.tfsSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
}

#Preview {
    SwipeDeckView(manager: OnboardingManager())
}

