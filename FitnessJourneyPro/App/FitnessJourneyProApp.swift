//  =========================================================================
//  FitnessJourneyProApp.swift
//  FitnessJourneyPro

//  Created by Sheikh Naim on 2026-06-23.

//  Features: @main, @StateObject, EnvironmentObject, AppDelegate, Onboarding
//  =========================================================================

import SwiftUI

@main
/// The main entry point for the Fitness Journey Pro application
/// Manages app-wide state, navigation, and notification setup
struct FitnessJourneyProApp: App {
    
    // MARK: - App Delegate
    /// App delegate adaptor for handling notification callbacks and app lifecycle events
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // MARK: - State Objects
    /// Manages all workout data and business logic
    @StateObject private var workoutStore = WorkoutStore()
    
    /// Manages user preferences and settings
    @StateObject private var settingsStore = SettingsStore()
    
    // MARK: - App Storage
    /// Tracks whether the user has seen the onboarding flow
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                // Main app content
                ContentView()
                    .environmentObject(workoutStore)
                    .environmentObject(settingsStore)
                    .onAppear {
                        setupNotifications()
                    }
            } else {
                // Onboarding flow for first-time users
                OnboardingView()
                    .environmentObject(workoutStore)
                    .environmentObject(settingsStore)
            }
        }
    }
    
    // MARK: - Notification Setup
    /// Sets up notification permissions and schedules reminders
    /// Requests authorization and schedules motivational reminders if enabled
    private func setupNotifications() {
        NotificationManager.shared.requestAuthorization { granted in
            if granted && settingsStore.notificationsEnabled {
                NotificationManager.shared.scheduleMotivationalReminder()
                workoutStore.scheduleAllNotifications()
            }
        }
        
        NotificationManager.shared.registerForRemoteNotifications()
    }
}
