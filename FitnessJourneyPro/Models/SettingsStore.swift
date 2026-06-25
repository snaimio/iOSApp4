//  ====================================================
//  SettingsStore.swift
//  FitnessJourneyPro

//  Created by Sheikh Naim on 2026-06-23.

//  User preferences and settings management
//  Features: @AppStorage for persistent settings
//  Topics: @AppStorage, UserDefaults, EnvironmentObject
//  ====================================================

import SwiftUI
import Combine

// MARK: - SettingsStore
/// Manages user preferences with automatic persistence using @AppStorage
/// All settings are automatically saved to UserDefaults when changed
final class SettingsStore: ObservableObject {
    
    // MARK: - @AppStorage Properties (Auto-saved to UserDefaults)
    /// Theme preference (Automatic, Light, Dark)
    @AppStorage("theme") var themeRaw: String = Theme.automatic.rawValue
    
    /// Whether notifications are enabled
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = true
    
    /// Weekly workout goal (number of workouts per week)
    @AppStorage("weeklyGoal") var weeklyGoal: Int = 5
    
    /// Daily workout goal (minutes per day)
    @AppStorage("dailyGoal") var dailyGoal: Int = 30
    
    /// Whether to show calories burned in workout details
    @AppStorage("showCalories") var showCalories: Bool = true
    
    // MARK: - Computed Properties
    
    /// Theme with automatic color scheme detection
    /// Converts raw string value to Theme enum
    var theme: Theme {
        get { Theme(rawValue: themeRaw) ?? .automatic }
        set { themeRaw = newValue.rawValue }
    }
    
    /// Converts theme to ColorScheme for SwiftUI
    /// - Returns: The appropriate ColorScheme or nil for automatic
    var colorScheme: ColorScheme? {
        switch theme {
        case .automatic: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    // MARK: - Theme Enum
    /// Available theme options for the app
    enum Theme: String, CaseIterable, Identifiable {
        case automatic = "Automatic"
        case light = "Light"
        case dark = "Dark"
        
        /// Unique identifier for the theme
        var id: String { rawValue }
    }
}
