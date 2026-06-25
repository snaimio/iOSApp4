//  ======================================

//  OnboardingItem.swift
//  FitnessJourneyPro

//  Created by Sheikh Naim on 2026-06-24.
//  Onboarding data model

//  ======================================

import SwiftUI

// MARK: - Onboarding Item
struct OnboardingItem: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let accentColor: Color
}

// MARK: - Sample Onboarding Data
extension OnboardingItem {
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
