//  ==========================================================================

//  FitnessJourneyProApp.swift
//  FitnessJourneyPro

//  Created by Sheikh Naim on 2026-06-23.

//  Features: @main, @StateObject, EnvironmentObject, AppDelegate, Onboarding

//  ==========================================================================

import SwiftUI

@main
struct FitnessJourneyProApp: App {
    
    // MARK: - App Delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // MARK: - State Objects
    @StateObject private var workoutStore = WorkoutStore()
    @StateObject private var settingsStore = SettingsStore()
    
    // MARK: - App Storage
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                ContentView()
                    .environmentObject(workoutStore)
                    .environmentObject(settingsStore)
                    .onAppear {
                        setupNotifications()
                    }
            } else {
                OnboardingView()
                    .environmentObject(workoutStore)
                    .environmentObject(settingsStore)
            }
        }
    }
    
    // MARK: - Notification Setup
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
