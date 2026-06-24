//
//  Workout.swift
//  FitnessJourneyPro
//
//  Created by Sheikh Naim on 2026-06-23.
//  Data Model for Workout tracking
//  Features: Identifiable, Codable, Equatable, Hashable, Timer Support
//  Topics: Structs, Enums, Computed Properties, Codable
//

import Foundation
import SwiftUI

// MARK: - Workout Model
struct Workout: Identifiable, Codable, Equatable, Hashable {
    
    // MARK: - Properties
    var id = UUID()
    var name: String
    var category: WorkoutCategory
    var duration: Int
    var intensity: Intensity
    var date: Date
    var isCompleted: Bool = false
    var notes: String = ""
    var caloriesBurned: Int?
    var isActive: Bool = false
    var startTime: Date?
    
    // MARK: - Computed Properties
    var formattedDate: String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
    
    var durationFormatted: String {
        let hours = duration / 60
        let minutes = duration % 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        }
        return "\(minutes)m"
    }
    
    var daysUntil: Int {
        Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var timeUntilStart: TimeInterval {
        date.timeIntervalSince(Date())
    }
    
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

// MARK: - WorkoutCategory Enum - ✅ UNIQUE ICONS
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
    
    var id: String { rawValue }
    
    // ✅ UNIQUE ICONS - No duplicates!
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
    
    // ✅ UNIQUE COLORS
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
    
    // ✅ UNIQUE EMOJIS
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
enum Intensity: String, CaseIterable, Identifiable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case extreme = "Extreme"
    
    var id: String { rawValue }
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        case .extreme: return .purple
        }
    }
    
    var emoji: String {
        switch self {
        case .low: return "🟢"
        case .medium: return "🟡"
        case .high: return "🔴"
        case .extreme: return "🟣"
        }
    }
}
