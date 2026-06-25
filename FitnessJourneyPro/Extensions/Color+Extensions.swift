//  =======================================
//  Color+Extensions.swift
//  FitnessJourneyPro

//  Created by Sheikh Naim on 2026-06-23.

//  Color extensions for consistent theming
//  Topics: Color, View Modifiers
//  =======================================

import SwiftUI

// MARK: - Color Extensions
/// Extends SwiftUI Color with custom theme colors for consistent app styling
extension Color {
    /// Background color for workout cards
    static let workoutBackground = Color(.systemGroupedBackground)
    
    /// Card background color
    static let workoutCard = Color(.secondarySystemBackground)
    
    /// Intensity colors for visual feedback
    static let intensityLow = Color.green
    static let intensityMedium = Color.orange
    static let intensityHigh = Color.red
    static let intensityExtreme = Color.purple
}

// MARK: - View Extensions
/// Extends View with reusable styling modifiers
extension View {
    /// Applies consistent card styling to any view
    /// - Returns: A view with card styling applied
    func workoutCardStyle() -> some View {
        self
            .padding()
            .background(Color.workoutCard)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
