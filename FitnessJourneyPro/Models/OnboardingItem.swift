//  =====================================
//  OnboardingItem.swift
//  FitnessJourneyPro

//  Created by Sheikh Naim on 2026-06-24.

//  Onboarding data model
//  =====================================

import SwiftUI

// MARK: - Onboarding Item
/// A data model representing a single onboarding screen
/// Conforms to Identifiable for use in Lists and ForEach loops
struct OnboardingItem: Identifiable {
    /// Unique identifier for the onboarding item
    let id = UUID()
    
    /// The main title displayed on the onboarding screen
    let title: String
    
    /// The descriptive text explaining the feature
    let description: String
    
    /// The SF Symbol name for the icon
    let imageName: String
    
    /// The accent color used for the icon and highlights
    let accentColor: Color
}

// MARK: - Sample Onboarding Data
/// Provides sample onboarding data for the app
extension OnboardingItem {
    /// Collection of sample onboarding items
    static let sampleItems: [OnboardingItem] = [
        OnboardingItem(
            title: "💪 Welcome to Fitness Journey",
            description: "Track your workouts, monitor progress, and stay motivated on your fitness journey.",
            imageName: "figure.run",
            accentColor: .blue
        ),
        OnboardingItem(
            title: "📋 Log Your Workouts",
            description: "Easily add and track your workouts with duration, intensity, and category.",
            imageName: "list.clipboard.fill",
            accentColor: .green
        ),
        OnboardingItem(
            title: "📊 Track Your Progress",
            description: "View detailed statistics, completion rates, and monitor your fitness streak.",
            imageName: "chart.bar.fill",
            accentColor: .purple
        ),
        OnboardingItem(
            title: "🔔 Get Reminders",
            description: "Never miss a workout with smart notifications and motivational reminders.",
            imageName: "bell.badge.fill",
            accentColor: .orange
        )
    ]
}
