//
//  WorkoutStore.swift
//  FitnessJourneyPro
//
//  Created by Sheikh Naim on 2026-06-23.
//  Assignment: iOSApp4 - Data Persistence and Business Logic
//  Features: @Published, @AppStorage, JSON Persistence, Computed Properties, Animations, Timer Progress
//  Topics: ObservableObject, CRUD Operations, Persistence, Statistics, Notifications
//  MARK: - WorkoutStore - Manages all workout data and business logic
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

// MARK: - WorkoutStore
@MainActor
class WorkoutStore: ObservableObject {
    
    // MARK: - Published Properties
    @Published var workouts: [Workout] = []
    @Published var selectedCategory: WorkoutCategory?
    @Published var selectedIntensity: Intensity?
    @Published var showCompletedOnly: Bool = false
    @Published var currentWorkoutProgress: Double = 0.0
    
    // MARK: - Private Constants
    private let saveKey = "savedWorkouts"
    private let sampleDataKey = "sampleDataLoaded"
    private var progressTimer: Timer?
    private var activeWorkoutId: UUID?
    
    // MARK: - Initialization
    init() {
        load()
        // Load sample data only once
        if !UserDefaults.standard.bool(forKey: sampleDataKey) {
            addSampleData()
            UserDefaults.standard.set(true, forKey: sampleDataKey)
        }
    }
    
    // MARK: - CRUD Operations with Animations
    
    func add(_ workout: Workout) {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            workouts.append(workout)
            save()
        }
        scheduleNotification(for: workout)
    }
    
    func delete(_ workout: Workout) {
        NotificationManager.shared.cancelNotifications(for: workout)
        withAnimation(.easeInOut(duration: 0.3)) {
            workouts.removeAll { $0.id == workout.id }
            save()
        }
    }
    
    func update(_ workout: Workout) {
        withAnimation(.easeInOut(duration: 0.4)) {
            if let index = workouts.firstIndex(where: { $0.id == workout.id }) {
                NotificationManager.shared.cancelNotifications(for: workouts[index])
                workouts[index] = workout
                if !workout.isCompleted {
                    scheduleNotification(for: workout)
                }
                save()
            }
        }
    }
    
    func toggleCompletion(_ workout: Workout) {
        guard let index = workouts.firstIndex(where: { $0.id == workout.id }) else {
            print("❌ Workout not found")
            return
        }
        
        withAnimation(.easeInOut(duration: 0.8)) {
            workouts[index].isCompleted.toggle()
        }
        
        let isNowCompleted = workouts[index].isCompleted
        print("🔄 Toggled completion for \(workouts[index].name) to \(isNowCompleted)")
        
        if isNowCompleted {
            stopProgressTimer()
            workouts[index].isActive = false
            NotificationManager.shared.cancelNotifications(for: workouts[index])
            checkAchievements()
        } else {
            scheduleNotification(for: workouts[index])
        }
        
        save()
        objectWillChange.send()
    }
    
    // MARK: - Timer-Based Progress
    
    func startWorkoutTimer(for workout: Workout) {
        guard let index = workouts.firstIndex(where: { $0.id == workout.id }) else { return }
        guard !workouts[index].isCompleted else { return }
        
        stopProgressTimer()
        
        workouts[index].isActive = true
        workouts[index].startTime = Date()
        activeWorkoutId = workout.id
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.updateProgress()
        }
        
        save()
        objectWillChange.send()
    }
    
    func stopProgressTimer() {
        progressTimer?.invalidate()
        progressTimer = nil
        currentWorkoutProgress = 0.0
        
        if let id = activeWorkoutId, let index = workouts.firstIndex(where: { $0.id == id }) {
            workouts[index].isActive = false
            save()
            objectWillChange.send()
        }
        activeWorkoutId = nil
    }
    
    private func updateProgress() {
        guard let id = activeWorkoutId,
              let index = workouts.firstIndex(where: { $0.id == id }),
              let startTime = workouts[index].startTime else {
            return
        }
        
        let totalDuration = Double(workouts[index].duration * 60)
        let elapsedTime = Date().timeIntervalSince(startTime)
        let progress = min(elapsedTime / totalDuration, 1.0)
        
        currentWorkoutProgress = progress
        
        if progress >= 1.0 {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let workout = self.workouts[index]
                self.toggleCompletion(workout)
                self.stopProgressTimer()
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func progressForWorkout(_ workout: Workout) -> Double {
        if workout.isCompleted { return 1.0 }
        
        if workout.isActive, let startTime = workout.startTime {
            let totalDuration = Double(workout.duration * 60)
            let elapsedTime = Date().timeIntervalSince(startTime)
            return min(elapsedTime / totalDuration, 0.99)
        }
        
        if workout.date > Date() {
            let timeUntil = workout.date.timeIntervalSince(Date())
            let totalTime: TimeInterval = 24 * 60 * 60
            return max(0, 1.0 - (timeUntil / totalTime))
        }
        
        return 0.0
    }
    
    func progressStatusText(for workout: Workout) -> (text: String, color: Color) {
        if workout.isCompleted {
            return ("🎉 Workout Complete!", .green)
        } else if workout.isActive {
            let progress = progressForWorkout(workout)
            return ("💪 \(Int(progress * 100))% complete", .blue)
        } else if workout.date > Date() {
            let time = workout.timeUntilStartFormatted
            return ("⏰ Starts in \(time)", .orange)
        } else {
            return ("💪 Ready to start!", .blue)
        }
    }
    
    // MARK: - Filtered Workouts
    
    var filteredWorkouts: [Workout] {
        var filtered = workouts
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        if let intensity = selectedIntensity {
            filtered = filtered.filter { $0.intensity == intensity }
        }
        if showCompletedOnly {
            filtered = filtered.filter { $0.isCompleted }
        }
        return filtered.sorted { $0.date > $1.date }
    }
    
    var todayWorkouts: [Workout] {
        workouts.filter { Calendar.current.isDateInToday($0.date) }
            .sorted { $0.date < $1.date }
    }
    
    var upcomingWorkouts: [Workout] {
        workouts.filter { !$0.isCompleted && $0.date > Date() }
            .sorted { $0.date < $1.date }
    }
    
    var completedWorkouts: [Workout] {
        workouts.filter { $0.isCompleted }
            .sorted { $0.date > $1.date }
    }
    
    var overdueWorkouts: [Workout] {
        workouts.filter { !$0.isCompleted && $0.date < Date() }
            .sorted { $0.date < $1.date }
    }
    
    var upcomingWeekWorkouts: [Workout] {
        let nextWeek = Date().addingTimeInterval(7 * 24 * 60 * 60)
        return workouts.filter {
            !$0.isCompleted && $0.date > Date() && $0.date < nextWeek
        }.sorted { $0.date < $1.date }
    }
    
    // MARK: - Statistics
    
    var totalWorkouts: Int { workouts.count }
    var completedCount: Int { workouts.filter { $0.isCompleted }.count }
    var pendingCount: Int { workouts.filter { !$0.isCompleted }.count }
    
    var completionRate: Double {
        workouts.isEmpty ? 0 : Double(completedCount) / Double(totalWorkouts)
    }
    
    var totalMinutes: Int {
        workouts.filter { $0.isCompleted }.reduce(0) { $0 + $1.duration }
    }
    
    var totalCaloriesBurned: Int {
        workouts.filter { $0.isCompleted }
            .compactMap { $0.caloriesBurned }
            .reduce(0, +)
    }
    
    var averageDuration: Int {
        let completed = workouts.filter { $0.isCompleted }
        guard !completed.isEmpty else { return 0 }
        return completed.reduce(0) { $0 + $1.duration } / completed.count
    }
    
    var streakDays: Int {
        var streak = 0
        let calendar = Calendar.current
        var date = Date()
        while true {
            let dayWorkouts = workouts.filter {
                calendar.isDate($0.date, inSameDayAs: date) && $0.isCompleted
            }
            if dayWorkouts.isEmpty { break }
            streak += 1
            date = calendar.date(byAdding: .day, value: -1, to: date) ?? date
        }
        return streak
    }
    
    var longestStreak: Int {
        var currentStreak = 0
        var longest = 0
        let calendar = Calendar.current
        let sortedWorkouts = workouts.filter { $0.isCompleted }.sorted { $0.date < $1.date }
        guard !sortedWorkouts.isEmpty else { return 0 }
        var previousDate: Date?
        for workout in sortedWorkouts {
            if let prev = previousDate {
                let daysBetween = calendar.dateComponents([.day], from: prev, to: workout.date).day ?? 0
                if daysBetween <= 1 {
                    currentStreak += 1
                } else {
                    currentStreak = 1
                }
            } else {
                currentStreak = 1
            }
            longest = max(longest, currentStreak)
            previousDate = workout.date
        }
        return longest
    }
    
    // MARK: - Category Statistics
    
    func workouts(for category: WorkoutCategory) -> [Workout] {
        workouts.filter { $0.category == category }
    }
    
    func completionRate(for category: WorkoutCategory) -> Double {
        let categoryWorkouts = workouts(for: category)
        let completed = categoryWorkouts.filter { $0.isCompleted }
        return categoryWorkouts.isEmpty ? 0 : Double(completed.count) / Double(categoryWorkouts.count)
    }
    
    func totalMinutes(for category: WorkoutCategory) -> Int {
        workouts(for: category).filter { $0.isCompleted }.reduce(0) { $0 + $1.duration }
    }
    
    var categoryBreakdown: [(category: WorkoutCategory, count: Int, percentage: Double)] {
        let total = totalWorkouts
        guard total > 0 else { return [] }
        return WorkoutCategory.allCases.map { category in
            let count = workouts(for: category).count
            let percentage = Double(count) / Double(total)
            return (category: category, count: count, percentage: percentage)
        }.filter { $0.count > 0 }
        .sorted { $0.count > $1.count }
    }
    
    // MARK: - Date-Based Statistics
    
    func workouts(on date: Date) -> [Workout] {
        workouts.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func workouts(forWeekContaining date: Date) -> [Workout] {
        guard let weekInterval = Calendar.current.dateInterval(of: .weekOfYear, for: date) else {
            return []
        }
        return workouts.filter {
            weekInterval.contains($0.date)
        }
    }
    
    func workouts(forMonthContaining date: Date) -> [Workout] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: date) else {
            return []
        }
        return workouts.filter {
            monthInterval.contains($0.date)
        }
    }
    
    // MARK: - Achievement Checks
    
    private func checkAchievements() {
        if completedCount == 1 {
            NotificationManager.shared.scheduleAchievementNotification(achievement: "First Workout Complete! 🎉")
        }
        if completedCount == 10 {
            NotificationManager.shared.scheduleAchievementNotification(achievement: "10 Workouts Complete! 💪")
        }
        if completedCount == 25 {
            NotificationManager.shared.scheduleAchievementNotification(achievement: "25 Workouts Complete! 🔥")
        }
        if completedCount == 50 {
            NotificationManager.shared.scheduleAchievementNotification(achievement: "50 Workouts Complete! 🔥")
        }
        if completedCount == 100 {
            NotificationManager.shared.scheduleAchievementNotification(achievement: "100 Workouts Complete! 🏆")
        }
        if streakDays == 7 {
            NotificationManager.shared.scheduleAchievementNotification(achievement: "7-Day Streak! 🔥")
        }
        if streakDays == 30 {
            NotificationManager.shared.scheduleAchievementNotification(achievement: "30-Day Streak! 🌟")
        }
    }
    
    // MARK: - Persistence
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([Workout].self, from: data) else {
            return
        }
        workouts = decoded
    }
    
    // MARK: - Sample Data - ✅ PREVENTS DUPLICATES
    
    private func addSampleData() {
        // ✅ Clear existing workouts first to prevent duplicates
        workouts.removeAll()
        
        let calendar = Calendar.current
        let today = Date()
        
        let sampleWorkouts = [
            Workout(
                name: "Morning Run",
                category: .running,
                duration: 30,
                intensity: .medium,
                date: calendar.date(byAdding: .day, value: -2, to: today) ?? today,
                isCompleted: false,
                notes: "Great run! Felt energetic.",
                caloriesBurned: 300,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Yoga Flow",
                category: .yoga,
                duration: 45,
                intensity: .low,
                date: calendar.date(byAdding: .day, value: -1, to: today) ?? today,
                isCompleted: false,
                notes: "Focused on breathing and flexibility.",
                caloriesBurned: 200,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Upper Body Strength",
                category: .strength,
                duration: 60,
                intensity: .high,
                date: today,
                isCompleted: false,
                notes: "Chest, shoulders, and triceps.",
                caloriesBurned: 400,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "HIIT Session",
                category: .hiit,
                duration: 25,
                intensity: .extreme,
                date: calendar.date(byAdding: .day, value: 1, to: today) ?? today,
                isCompleted: false,
                notes: "30 seconds on, 10 seconds rest.",
                caloriesBurned: 350,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Evening Walk",
                category: .walking,
                duration: 20,
                intensity: .low,
                date: calendar.date(byAdding: .day, value: -3, to: today) ?? today,
                isCompleted: false,
                notes: "Relaxing walk in the park.",
                caloriesBurned: 100,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Leg Day",
                category: .strength,
                duration: 55,
                intensity: .high,
                date: calendar.date(byAdding: .day, value: -4, to: today) ?? today,
                isCompleted: false,
                notes: "Squats, lunges, leg press.",
                caloriesBurned: 450,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Swimming",
                category: .swimming,
                duration: 40,
                intensity: .medium,
                date: calendar.date(byAdding: .day, value: -5, to: today) ?? today,
                isCompleted: false,
                notes: "Freestyle and breaststroke.",
                caloriesBurned: 500,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Core Workout",
                category: .pilates,
                duration: 30,
                intensity: .medium,
                date: calendar.date(byAdding: .day, value: -6, to: today) ?? today,
                isCompleted: false,
                notes: "Planks, crunches, leg raises.",
                caloriesBurned: 200,
                isActive: false,
                startTime: nil
            )
        ]
        
        // ✅ ASSIGN directly (not append) to prevent duplicates
        workouts = sampleWorkouts
        save()
        print("✅ Sample data loaded: \(workouts.count) workouts")
    }
    
    // MARK: - Notification Integration
    
    private func scheduleNotification(for workout: Workout) {
        guard !workout.isCompleted else { return }
        NotificationManager.shared.scheduleReminder(for: workout)
    }
    
    func scheduleAllNotifications() {
        let pendingWorkouts = workouts.filter { !$0.isCompleted && $0.date > Date() }
        for workout in pendingWorkouts {
            NotificationManager.shared.scheduleReminder(for: workout)
        }
        print("✅ Scheduled notifications for \(pendingWorkouts.count) pending workouts")
    }
    
    func cancelAllNotifications() {
        for workout in workouts {
            NotificationManager.shared.cancelNotifications(for: workout)
        }
        NotificationManager.shared.cancelAllNotifications()
        print("✅ Cancelled all workout notifications")
    }
    
    func checkAndScheduleReminders() {
        let upcomingWorkouts = workouts.filter {
            !$0.isCompleted &&
            $0.date > Date() &&
            $0.date < Date().addingTimeInterval(24 * 60 * 60)
        }
        for workout in upcomingWorkouts {
            NotificationManager.shared.scheduleReminder(for: workout)
        }
    }
    
    func scheduleWeeklySummary() {
        let weeklyWorkouts = workouts(forWeekContaining: Date())
        let completedWeekly = weeklyWorkouts.filter { $0.isCompleted }
        let totalWeeklyMinutes = completedWeekly.reduce(0) { $0 + $1.duration }
        NotificationManager.shared.scheduleWeeklySummary(
            workoutCount: completedWeekly.count,
            totalMinutes: totalWeeklyMinutes
        )
    }
    
    // MARK: - Reset and Debug - ✅ PREVENTS DUPLICATES

    /// Reset all data (clear all workouts and reload sample data)
    func resetAllData() {
        print("🔄 === RESET START ===")
        stopProgressTimer()
        
        // Step 1: CLEAR EVERYTHING - Force remove all
        workouts = []
        print("   Workouts cleared: \(workouts.count)")
        
        // Step 2: Remove ALL UserDefaults keys
        UserDefaults.standard.removeObject(forKey: saveKey)
        UserDefaults.standard.removeObject(forKey: sampleDataKey)
        print("   UserDefaults keys removed")
        
        // Step 3: Save empty array
        save()
        print("   Empty state saved")
        
        // Step 4: Load sample data DIRECTLY (overwrite, don't append)
        let calendar = Calendar.current
        let today = Date()
        
        let sampleWorkouts = [
            Workout(
                name: "Morning Run",
                category: .running,
                duration: 30,
                intensity: .medium,
                date: calendar.date(byAdding: .day, value: -2, to: today) ?? today,
                isCompleted: false,
                notes: "Great run! Felt energetic.",
                caloriesBurned: 300,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Yoga Flow",
                category: .yoga,
                duration: 45,
                intensity: .low,
                date: calendar.date(byAdding: .day, value: -1, to: today) ?? today,
                isCompleted: false,
                notes: "Focused on breathing and flexibility.",
                caloriesBurned: 200,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Upper Body Strength",
                category: .strength,
                duration: 60,
                intensity: .high,
                date: today,
                isCompleted: false,
                notes: "Chest, shoulders, and triceps.",
                caloriesBurned: 400,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "HIIT Session",
                category: .hiit,
                duration: 25,
                intensity: .extreme,
                date: calendar.date(byAdding: .day, value: 1, to: today) ?? today,
                isCompleted: false,
                notes: "30 seconds on, 10 seconds rest.",
                caloriesBurned: 350,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Evening Walk",
                category: .walking,
                duration: 20,
                intensity: .low,
                date: calendar.date(byAdding: .day, value: -3, to: today) ?? today,
                isCompleted: false,
                notes: "Relaxing walk in the park.",
                caloriesBurned: 100,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Leg Day",
                category: .strength,
                duration: 55,
                intensity: .high,
                date: calendar.date(byAdding: .day, value: -4, to: today) ?? today,
                isCompleted: false,
                notes: "Squats, lunges, leg press.",
                caloriesBurned: 450,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Swimming",
                category: .swimming,
                duration: 40,
                intensity: .medium,
                date: calendar.date(byAdding: .day, value: -5, to: today) ?? today,
                isCompleted: false,
                notes: "Freestyle and breaststroke.",
                caloriesBurned: 500,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Core Workout",
                category: .pilates,
                duration: 30,
                intensity: .medium,
                date: calendar.date(byAdding: .day, value: -6, to: today) ?? today,
                isCompleted: false,
                notes: "Planks, crunches, leg raises.",
                caloriesBurned: 200,
                isActive: false,
                startTime: nil
            )
        ]
        
        // Step 5: ASSIGN directly (not append)
        workouts = sampleWorkouts
        print("   Sample data assigned: \(workouts.count)")
        
        // Step 6: Save
        save()
        print("   Sample data saved")
        
        // Step 7: Force UI update
        DispatchQueue.main.async {
            self.objectWillChange.send()
            print("   UI update sent")
        }
        
        print("🔄 === RESET COMPLETE ===")
        print("   Final workouts: \(workouts.count)")
    }
    
    /// Directly add sample data without checking flags - ✅ PREVENTS DUPLICATES
    private func addSampleDataDirectly() {
        // ✅ Clear existing workouts first
        workouts.removeAll()
        
        let calendar = Calendar.current
        let today = Date()
        
        let sampleWorkouts = [
            Workout(
                name: "Morning Run",
                category: .running,
                duration: 30,
                intensity: .medium,
                date: calendar.date(byAdding: .day, value: -2, to: today) ?? today,
                isCompleted: false,
                notes: "Great run! Felt energetic.",
                caloriesBurned: 300,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Yoga Flow",
                category: .yoga,
                duration: 45,
                intensity: .low,
                date: calendar.date(byAdding: .day, value: -1, to: today) ?? today,
                isCompleted: false,
                notes: "Focused on breathing and flexibility.",
                caloriesBurned: 200,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Upper Body Strength",
                category: .strength,
                duration: 60,
                intensity: .high,
                date: today,
                isCompleted: false,
                notes: "Chest, shoulders, and triceps.",
                caloriesBurned: 400,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "HIIT Session",
                category: .hiit,
                duration: 25,
                intensity: .extreme,
                date: calendar.date(byAdding: .day, value: 1, to: today) ?? today,
                isCompleted: false,
                notes: "30 seconds on, 10 seconds rest.",
                caloriesBurned: 350,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Evening Walk",
                category: .walking,
                duration: 20,
                intensity: .low,
                date: calendar.date(byAdding: .day, value: -3, to: today) ?? today,
                isCompleted: false,
                notes: "Relaxing walk in the park.",
                caloriesBurned: 100,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Leg Day",
                category: .strength,
                duration: 55,
                intensity: .high,
                date: calendar.date(byAdding: .day, value: -4, to: today) ?? today,
                isCompleted: false,
                notes: "Squats, lunges, leg press.",
                caloriesBurned: 450,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Swimming",
                category: .swimming,
                duration: 40,
                intensity: .medium,
                date: calendar.date(byAdding: .day, value: -5, to: today) ?? today,
                isCompleted: false,
                notes: "Freestyle and breaststroke.",
                caloriesBurned: 500,
                isActive: false,
                startTime: nil
            ),
            Workout(
                name: "Core Workout",
                category: .pilates,
                duration: 30,
                intensity: .medium,
                date: calendar.date(byAdding: .day, value: -6, to: today) ?? today,
                isCompleted: false,
                notes: "Planks, crunches, leg raises.",
                caloriesBurned: 200,
                isActive: false,
                startTime: nil
            )
        ]
        
        // ✅ ASSIGN directly (not append)
        workouts = sampleWorkouts
        save()
        print("   Sample data added directly: \(workouts.count)")
    }
    
    /// Remove duplicate workouts (keep unique IDs) - ✅ HELPER
    func removeDuplicates() {
        var seen = Set<UUID>()
        let uniqueWorkouts = workouts.filter { workout in
            if seen.contains(workout.id) {
                return false
            } else {
                seen.insert(workout.id)
                return true
            }
        }
        
        if uniqueWorkouts.count != workouts.count {
            workouts = uniqueWorkouts
            save()
            objectWillChange.send()
            print("✅ Removed \(workouts.count - uniqueWorkouts.count) duplicates")
        }
    }
    
    func debugPrintAllWorkouts() {
        print("📋 === All Workouts (\(workouts.count)) ===")
        for (index, workout) in workouts.enumerated() {
            print("  \(index + 1). \(workout.name) - \(workout.category.rawValue) - \(workout.duration)m - \(workout.isCompleted ? "✅" : "⏳")")
        }
        print("📊 === Statistics ===")
        print("  Total: \(totalWorkouts)")
        print("  Completed: \(completedCount)")
        print("  Pending: \(pendingCount)")
        print("  Completion Rate: \(Int(completionRate * 100))%")
        print("  Total Minutes: \(totalMinutes)")
        print("  Streak: \(streakDays) days")
        print("  Longest Streak: \(longestStreak) days")
    }
}

// MARK: - Preview Helper
extension WorkoutStore {
    static var preview: WorkoutStore {
        let store = WorkoutStore()
        return store
    }
}

// MARK: - Notification Extension for Achievement
extension Notification.Name {
    static let workoutCompleted = Notification.Name("workoutCompleted")
    static let achievementUnlocked = Notification.Name("achievementUnlocked")
    static let editWorkout = Notification.Name("EditWorkout")
}
