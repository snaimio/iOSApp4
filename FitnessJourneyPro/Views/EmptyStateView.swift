//
//  EmptyStateView.swift
//  FitnessJourneyPro
//
//  Created by Sheikh Naim on 2026-06-23.
//  Assignment: iOSApp4 - Empty State View
//  Features: Reusable empty state component
//  Topics: Custom Views, SF Symbols, Accessibility
//

import SwiftUI

// MARK: - EmptyStateView
/// Shown when no workout is selected or no workouts exist
struct EmptyStateView: View {
    
    // MARK: - Properties
    var icon: String = "figure.run"
    var title: String = "Select a Workout"
    var message: String = "Choose a workout from the sidebar or add a new one to get started"
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            // MARK: - Icon
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            
            // MARK: - Title
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
            
            // MARK: - Message
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
