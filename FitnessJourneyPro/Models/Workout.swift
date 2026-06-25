//  ===================================================================
//  Workout.swift
//  FitnessJourneyPro

//  Created by Sheikh Naim on 2026-06-23.

//  Data Model for Workout tracking
//  Features: Identifiable, Codable, Equatable, Hashable, Timer Support
//  Topics: Structs, Enums, Computed Properties, Codable
//  ===================================================================

import Foundation
import SwiftUI

// MARK: - Workout Model
/// A workout model representing a single exercise session
/// Conforms to Identifiable for List usage, Codable for persistence,
/// Equatable for comparisons, and Hashable for List selection
struct Workout: Identifiable, Codable, Equatable, Hashable {
    
    // MARK: - Properties
    /// Unique identifier for the workout
    var id = UUID()
    
    /// Name of the workout (e.g., "Morning Run")
    var name: String
    
    /// Category of the workout (e.g., Cardio, Strength)
    var category: WorkoutCategory
    
    /// Duration in minutes
    var duration: Int
    
    /// Intensity level (Low, Medium, High, Extreme)
    var intensity: Intensity
    
    /// Scheduled date and time for the workout
    var date: Date
    
    /// Whether the workout has been completed
    var isCompleted: Bool = false
    
    /// Optional notes about the workout
    var notes: String = ""
    
    /// Optional calories burned during the workout
    var caloriesBurned: Int?
    
    /// Whether the workout is currently active (timer running)
    var isActive: Bool = false
    
    /// When the workout was started (for timer tracking)
    var startTime: Date?
    
    // MARK: - Computed Properties
    /// Formatted date string for display
    var formattedDate: String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
    
    /// Formatted duration (e.g., "1h 30m" or "45m")
    var durationFormatted: String {
        let hours = duration / 60
        let minutes = duration % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
    
    /// Number of days until the workout
    var daysUntil: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }
    
    /// Whether the workout is scheduled for today
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    /// Time interval until the workout starts (can be negative if past)
    var timeUntilStart: TimeInterval {
        date.timeIntervalSince(Date())
    }
    
    /// Formatted time until start (e.g., "2h 30m" or "Now")
    var timeUntilStartFormatted: String {
        let time = timeUntilStart
        if time <= 0 { return "Now" }
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
}

// MARK: - WorkoutCategory Enum
/// Categories with associated icons, colors, and emojis for visual distinction
enum WorkoutCategory: String, CaseIterable, Identifiable, Codable {
    case cardio = "Cardio"
    case strength = "Strength Training"
    case yoga = "Yoga"
    case pilates = "Pilates"
    case hiit = "HIIT"
    case running = "Running"
    case walking = "Walking"
    case swimming = "Swimming"
    case cycling = "Cycling"
    case other = "Other"
    
    /// Unique identifier for the category
    var id: String { rawValue }
    
    /// SF Symbol icon name for each category
    var icon: String {
        switch self {
        case .cardio: return "heart.circle.fill"      // ❤️ Heart
        case .strength: return "dumbbell.fill"        // 💪 Dumbbell
        case .yoga: return "figure.yoga"              // 🧘 Yoga
        case .pilates: return "figure.pilates"        // 🏋️ Pilates
        case .hiit: return "bolt.circle.fill"         // ⚡ Bolt
        case .running: return "figure.run"            // 🏃 Run
        case .walking: return "figure.walk"           // 🚶 Walk
        case .swimming: return "figure.pool.swim"     // 🏊 Swim
        case .cycling: return "bicycle.circle.fill"   // 🚴 Cycle
        case .other: return "square.grid.2x2.fill"    // 📋 Other
        }
    }
    
    /// Associated color for UI theming
    var color: Color {
        switch self {
        case .cardio: return .red
        case .strength: return .orange
        case .yoga: return .purple
        case .pilates: return .pink
        case .hiit: return .blue
        case .running: return .green
        case .walking: return .teal
        case .swimming: return .cyan
        case .cycling: return .indigo
        case .other: return .gray
        }
    }
    
    /// Emoji representation for quick visual reference
    var emoji: String {
        switch self {
        case .cardio: return "❤️"
        case .strength: return "💪"
        case .yoga: return "🧘"
        case .pilates: return "🧘‍♀️"
        case .hiit: return "⚡"
        case .running: return "🏃"
        case .walking: return "🚶"
        case .swimming: return "🏊"
        case .cycling: return "🚴"
        case .other: return "📋"
        }
    }
}

// MARK: - Intensity Enum
/// Workout intensity levels with visual indicators
enum Intensity: String, CaseIterable, Identifiable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case extreme = "Extreme"
    
    /// Unique identifier for the intensity
    var id: String { rawValue }
    
    /// Color coding for intensity
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        case .extreme: return .purple
        }
    }
    
    /// Emoji representation for quick visual reference
    var emoji: String {
        switch self {
        case .low: return "🟢"
        case .medium: return "🟡"
        case .high: return "🔴"
        case .extreme: return "🟣"
        }
    }
}
