//  ===============================================
//  EmptyStateView.swift
//  FitnessJourneyPro

//  Created by Sheikh Naim on 2026-06-23.

//  Features: Reusable empty state component
//  Topics: Custom Views, SF Symbols, Accessibility
//  ===============================================

import SwiftUI

// MARK: - EmptyStateView
/// Shown when no workout is selected or no workouts exist
/// Provides a user-friendly message with an icon to indicate empty state
struct EmptyStateView: View {
    
    // MARK: - Properties
    /// SF Symbol name for the icon
    var icon: String = "figure.run"
    
    /// Main title displayed
    var title: String = "Select a Workout"
    
    /// Descriptive message explaining the empty state
    var message: String = "Choose a workout from the sidebar or add a new one to get started"
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Icon
            /// Large decorative icon representing the empty state
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            
            // MARK: - Title
            /// Main heading text
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            // MARK: - Message
            /// Secondary descriptive text
            Text(message)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    EmptyStateView()
}
