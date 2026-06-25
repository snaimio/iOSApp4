//  ===========================================
//  AppDelegate.swift
//  FitnessJourneyPro

//  Created by Sheikh Naim on 2026-06-23.

//  App Delegate for handling notifications
//  Features: UNUserNotificationCenterDelegate
//  Topics: App Delegate, Notification Handling
//  ===========================================

import UIKit
import UserNotifications

// MARK: - AppDelegate
/// The app delegate class responsible for handling application-level events
/// and notification-related callbacks
class AppDelegate: NSObject, UIApplicationDelegate {
    
    // MARK: - Application Launch
    
    /// Called when the application has finished launching
    /// - Parameters:
    ///   - application: The shared application instance
    ///   - launchOptions: Dictionary containing launch options
    /// - Returns: Boolean indicating successful launch
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Set notification delegate to handle incoming notifications
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    // MARK: - Remote Notification Registration
    
    /// Called when the app successfully registers for remote notifications
    /// - Parameters:
    ///   - application: The shared application instance
    ///   - deviceToken: The device token for push notifications
    func application(_ application: UIApplication,
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert token to string format for debugging
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("✅ Device Token: \(token)")
    }
    
    /// Called when the app fails to register for remote notifications
    /// - Parameters:
    ///   - application: The shared application instance
    ///   - error: The error that occurred during registration
    func application(_ application: UIApplication,
                    didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
    }
}

// MARK: - UNUserNotificationCenterDelegate
/// Extension to handle notification center delegate methods
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    /// Called when a notification is delivered while the app is in the foreground
    /// - Parameters:
    ///   - center: The notification center
    ///   - notification: The notification being delivered
    ///   - completionHandler: Handler to specify presentation options
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification banner even when app is in foreground
        completionHandler([.banner, .sound, .badge, .list])
    }
    
    /// Called when the user responds to a notification
    /// - Parameters:
    ///   - center: The notification center
    ///   - response: The user's response to the notification
    ///   - completionHandler: Handler to call when processing is complete
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        // Delegate the response handling to the notification manager
        NotificationManager.shared.handleNotificationResponse(response)
        completionHandler()
    }
}
