//
//  ColorTheme.swift
//  Toyota Financial Services
//
//  Created by Atharva Lade on 10/19/25.
//

import SwiftUI

extension Color {
    // TFS Brand Colors
    static let tfsRed = Color(red: 235/255, green: 10/255, blue: 30/255)
    static let tfsDarkRed = Color(red: 200/255, green: 8/255, blue: 25/255)
    
    // Semantic Colors
    static let tfsBackground = Color(UIColor.systemBackground)
    static let tfsSecondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tfsTertiaryBackground = Color(UIColor.tertiarySystemBackground)
    
    // Text Colors
    static let tfsPrimary = Color.primary
    static let tfsSecondary = Color.secondary
    static let tfsTertiary = Color(UIColor.tertiaryLabel)
    
    // Status Colors
    static let tfsGreen = Color(red: 52/255, green: 199/255, blue: 89/255)
    static let tfsYellow = Color(red: 255/255, green: 204/255, blue: 0/255)
    static let tfsOrange = Color(red: 255/255, green: 149/255, blue: 0/255)
}

