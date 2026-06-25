//  ==============================================================
//  NotificationManager.swift
//  FitnessJourneyPro

//  Created by Sheikh Naim on 2026-06-23.

//  Features: UNUserNotificationCenter, Notifications, Permissions
//  Topics: Notifications, Permissions, Background Tasks
//  ==============================================================

import Foundation
import UserNotifications
import UIKit

// MARK: - NotificationManager
/// Singleton manager for handling all notification-related functionality
/// Uses the Singleton pattern to provide a shared instance across the app
class NotificationManager {
    
    // MARK: - Singleton
    /// Shared instance for global access
    static let shared = NotificationManager()
    
    // MARK: - Private Initializer
    /// Private init to enforce singleton pattern
    private init() {}
    
    // MARK: - Notification Categories
    /// Define notification categories for different types of notifications
    enum NotificationCategory: String {
        case workoutReminder = "WORKOUT_REMINDER"
        case motivational = "MOTIVATIONAL"
        case achievement = "ACHIEVEMENT"
        case test = "TEST_NOTIFICATION"
        
        /// Unique identifier for the notification category
        var identifier: String {
            return rawValue
        }
        
        /// Display title for the notification based on category
        var title: String {
            switch self {
            case .workoutReminder: return "💪 Workout Reminder"
            case .motivational: return "🔥 Stay Motivated!"
            case .achievement: return "🏆 Achievement Unlocked!"
            case .test: return "🔔 Test Notification"
            }
        }
        
        /// Notification sound based on category importance
        var sound: UNNotificationSound {
            switch self {
            case .workoutReminder: return .default
            case .motivational: return .default
            case .achievement: return .defaultCritical
            case .test: return .default
            }
        }
    }
    
    // MARK: - Permission Management
    
    /// Request authorization for notifications with completion handler
    /// - Parameter completion: Optional completion handler with grant result
    func requestAuthorization(completion: ((Bool) -> Void)? = nil) {
        // Create notification center instance
        let center = UNUserNotificationCenter.current()
        
        // Request authorization with options
        center.requestAuthorization(
            options: [.alert, .sound, .badge, .criticalAlert, .providesAppNotificationSettings]
        ) { granted, error in
            // Handle errors
            if let error = error {
                print("❌ Notification authorization error: \(error.localizedDescription)")
                completion?(false)
                return
            }
            
            // Log result
            if granted {
                print("✅ Notification permission granted")
                // Register for remote notifications (if needed)
                DispatchQueue.main.async {
                    self.registerForRemoteNotifications()
                }
                // Register notification categories
                self.registerNotificationCategories()
            } else {
                print("⚠️ Notification permission denied")
            }
            
            // Call completion handler
            completion?(granted)
        }
    }
    
    /// Check current notification authorization status
    /// - Parameter completion: Completion handler with authorization status
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    /// Register notification categories with actions
    /// Sets up custom actions for workout reminders (Complete, Postpone)
    private func registerNotificationCategories() {
        // Create actions for workout reminders
        let completeAction = UNNotificationAction(
            identifier: "COMPLETE_ACTION",
            title: "✅ Mark Complete",
            options: [.foreground]
        )
        
        let postponeAction = UNNotificationAction(
            identifier: "POSTPONE_ACTION",
            title: "⏰ Postpone",
            options: [.foreground]
        )
        
        // Create category with actions
        let workoutCategory = UNNotificationCategory(
            identifier: NotificationCategory.workoutReminder.identifier,
            actions: [completeAction, postponeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        // Register categories
        UNUserNotificationCenter.current().setNotificationCategories([workoutCategory])
        print("✅ Notification categories registered")
    }
    
    // MARK: - Schedule Notifications
    
    /// Schedule a reminder for a workout
    /// - Parameter workout: The workout to remind about
    func scheduleReminder(for workout: Workout) {
        // Don't schedule for completed workouts
        guard !workout.isCompleted else {
            print("⏭️ Workout already completed - no reminder scheduled")
            return
        }
        
        // Check if notifications are enabled
        checkAuthorizationStatus { status in
            guard status == .authorized else {
                print("⚠️ Notifications not authorized - cannot schedule reminder")
                return
            }
            
            // Create notification content
            let content = self.createNotificationContent(
                category: .workoutReminder,
                title: "💪 Workout Reminder",
                body: "Time for your \(workout.name) workout! Stay consistent! 💪",
                userInfo: ["workoutId": workout.id.uuidString]
            )
            
            // Remind 1 hour before (or 30 minutes if within 1 hour)
            let reminderTime: TimeInterval = -3600 // 1 hour before
            let reminderDate = workout.date.addingTimeInterval(reminderTime)
            
            // If reminder date is in the past, schedule for immediate notification
            if reminderDate < Date() {
                self.scheduleImmediateNotification(for: workout)
                return
            }
            
            // Create trigger for specific date/time
            let triggerDate = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute],
                from: reminderDate
            )
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
            
            // Create notification request
            let request = UNNotificationRequest(
                identifier: "reminder_\(workout.id.uuidString)",
                content: content,
                trigger: trigger
            )
            
            // Add to notification center
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling reminder: \(error.localizedDescription)")
                } else {
                    print("✅ Reminder scheduled for \(workout.name) at \(reminderDate.formatted(date: .abbreviated, time: .shortened))")
                }
            }
        }
    }
    
    /// Schedule an immediate notification for a workout (when the workout is already due)
    /// - Parameter workout: The workout to notify about
    private func scheduleImmediateNotification(for workout: Workout) {
        let content = self.createNotificationContent(
            category: .workoutReminder,
            title: "💪 Workout Time!",
            body: "Your \(workout.name) workout is scheduled for now! Don't miss it! 💪",
            userInfo: ["workoutId": workout.id.uuidString]
        )
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "immediate_\(workout.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling immediate notification: \(error.localizedDescription)")
            } else {
                print("✅ Immediate notification scheduled for \(workout.name)")
            }
        }
    }
    
    /// Schedule a motivational daily reminder at 8:00 AM
    func scheduleMotivationalReminder() {
        checkAuthorizationStatus { status in
            guard status == .authorized else {
                print("⚠️ Notifications not authorized - cannot schedule motivational reminder")
                return
            }
            
            let content = self.createNotificationContent(
                category: .motivational,
                title: "🔥 Stay Motivated!",
                body: "Your fitness journey continues! Don't give up today! 💪",
                userInfo: ["type": "motivational"]
            )
            
            // Schedule for 8:00 AM every day
            var dateComponents = DateComponents()
            dateComponents.hour = 8
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(
                identifier: "motivational_reminder",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling motivational reminder: \(error.localizedDescription)")
                } else {
                    print("✅ Motivational reminder scheduled for 8:00 AM daily")
                }
            }
        }
    }
    
    /// Schedule an achievement notification when user unlocks a milestone
    /// - Parameter achievement: The achievement name/description
    func scheduleAchievementNotification(achievement: String) {
        checkAuthorizationStatus { status in
            guard status == .authorized else { return }
            
            let content = self.createNotificationContent(
                category: .achievement,
                title: "🏆 Achievement Unlocked!",
                body: "🎉 You've achieved: \(achievement)! Keep going! 💪",
                userInfo: ["achievement": achievement]
            )
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "achievement_\(UUID().uuidString)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling achievement notification: \(error.localizedDescription)")
                } else {
                    print("✅ Achievement notification scheduled")
                }
            }
        }
    }
    
    /// Schedule a weekly summary notification on Sunday at 8:00 PM
    /// - Parameters:
    ///   - workoutCount: Number of workouts completed this week
    ///   - totalMinutes: Total minutes spent on workouts this week
    func scheduleWeeklySummary(workoutCount: Int, totalMinutes: Int) {
        checkAuthorizationStatus { status in
            guard status == .authorized else { return }
            
            let content = self.createNotificationContent(
                category: .motivational,
                title: "📊 Weekly Summary",
                body: "This week: \(workoutCount) workouts, \(totalMinutes) minutes! Keep it up! 💪",
                userInfo: ["type": "weekly_summary"]
            )
            
            // Schedule for Sunday at 8:00 PM
            var dateComponents = DateComponents()
            dateComponents.weekday = 1 // Sunday
            dateComponents.hour = 20
            dateComponents.minute = 0
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(
                identifier: "weekly_summary",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error scheduling weekly summary: \(error.localizedDescription)")
                } else {
                    print("✅ Weekly summary scheduled for Sunday at 8:00 PM")
                }
            }
        }
    }
    
    // MARK: - Notification Content Creation
    
    /// Create notification content with common settings
    /// - Parameters:
    ///   - category: The notification category
    ///   - title: Notification title
    ///   - body: Notification body text
    ///   - userInfo: Additional data for the notification
    /// - Returns: Configured UNMutableNotificationContent
    private func createNotificationContent(
        category: NotificationCategory,
        title: String,
        body: String,
        userInfo: [String: Any] = [:]
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = category.sound
        content.categoryIdentifier = category.identifier
        content.userInfo = userInfo
        
        // Simple badge management
        content.badge = 1
        
        return content
    }
    
    // MARK: - Manage Notifications
    
    /// Cancel all notifications for a workout
    /// - Parameter workout: The workout to cancel notifications for
    func cancelNotifications(for workout: Workout) {
        let identifiers = [
            "reminder_\(workout.id.uuidString)",
            "immediate_\(workout.id.uuidString)",
            workout.id.uuidString
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        print("✅ Cancelled notifications for \(workout.name)")
    }
    
    /// Cancel all pending notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("✅ All notifications cancelled")
    }
    
    /// Get all pending notifications
    /// - Parameter completion: Completion handler with the pending notification requests
    func getPendingNotifications(completion: @escaping ([UNNotificationRequest]) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(requests)
            }
        }
    }
    
    /// Get all delivered notifications
    /// - Parameter completion: Completion handler with the delivered notifications
    func getDeliveredNotifications(completion: @escaping ([UNNotification]) -> Void) {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            DispatchQueue.main.async {
                completion(notifications)
            }
        }
    }
    
    /// Remove a delivered notification by identifier
    /// - Parameter identifier: The notification identifier to remove
    func removeDeliveredNotification(identifier: String) {
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    /// Clear all delivered notifications and reset badge count
    func clearAllDeliveredNotifications() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        // Use setBadgeCount to clear badge
        UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                print("❌ Error clearing badge: \(error.localizedDescription)")
            } else {
                print("✅ Badge cleared")
            }
        }
    }
    
    // MARK: - Test Notifications
    
    /// Send a test notification to verify settings
    func sendTestNotification() {
        checkAuthorizationStatus { status in
            guard status == .authorized else {
                print("⚠️ Notifications not authorized - cannot send test")
                return
            }
            
            let content = self.createNotificationContent(
                category: .test,
                title: "🔔 Test Notification",
                body: "Your notification settings are working perfectly! 🎉",
                userInfo: ["test": "true"]
            )
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            
            let request = UNNotificationRequest(
                identifier: "test_notification",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("❌ Error sending test notification: \(error.localizedDescription)")
                } else {
                    print("✅ Test notification sent successfully!")
                }
            }
        }
    }
    
    // MARK: - App Delegate Integration
    
    /// Handle notification response from app delegate
    /// - Parameter response: The user's response to a notification
    func handleNotificationResponse(_ response: UNNotificationResponse) {
        let userInfo = response.notification.request.content.userInfo
        
        // Handle different actions
        switch response.actionIdentifier {
        case "COMPLETE_ACTION":
            // Handle complete action
            if let workoutId = userInfo["workoutId"] as? String {
                print("✅ Mark workout as complete: \(workoutId)")
                // Post notification to mark workout as complete
                NotificationCenter.default.post(
                    name: NSNotification.Name("CompleteWorkout"),
                    object: workoutId
                )
            }
        case "POSTPONE_ACTION":
            // Handle postpone action
            print("⏰ Postpone workout")
        default:
            // Handle default tap
            print("📱 Notification tapped")
        }
    }
    
    // MARK: - UI Application Delegate Methods
    
    /// Register for remote notifications - skips on simulator
    func registerForRemoteNotifications() {
        #if targetEnvironment(simulator)
        // Skip remote notification registration on simulator
        print("ℹ️ Running on simulator - skipping remote notification registration")
        #else
        UIApplication.shared.registerForRemoteNotifications()
        #endif
    }
    
    /// Unregister from remote notifications - skips on simulator
    func unregisterForRemoteNotifications() {
        #if targetEnvironment(simulator)
        print("ℹ️ Running on simulator - skipping remote notification unregistration")
        #else
        UIApplication.shared.unregisterForRemoteNotifications()
        #endif
    }
}
