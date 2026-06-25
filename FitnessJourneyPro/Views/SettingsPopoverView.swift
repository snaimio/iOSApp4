//  ==============================================================================
//  SettingsPopoverView.swift
//  FitnessJourneyPro

//  Created by Sheikh Naim on 2026-06-23.

//  Enhanced with beautiful settings design
//  Settings Popover View
//  Features: @AppStorage, Picker, Slider, Toggle, Notifications, Onboarding Reset
//  Topics: Settings, Preferences, Persistence, Notifications
//  ==============================================================================

import SwiftUI
import UserNotifications

// MARK: - SettingsPopoverView
/// Main settings view for managing app preferences and user settings
/// Provides controls for appearance, goals, notifications, and data management
struct SettingsPopoverView: View {
    
    // MARK: - Environment Objects
    /// Access to user settings and preferences
    @EnvironmentObject var settingsStore: SettingsStore
    
    /// Access to the workout data store
    @EnvironmentObject var workoutStore: WorkoutStore
    
    // MARK: - Bindings
    /// Controls whether the settings view is presented
    @Binding var isPresented: Bool
    
    // MARK: - State Variables
    /// Controls the test notification alert
    @State private var showingTestAlert = false
    
    /// Message displayed in notification alerts
    @State private var testAlertMessage = ""
    
    /// Indicates if a notification test is in progress
    @State private var isTesting = false
    
    /// Prevents multiple reset operations from running simultaneously
    @State private var isResetting = false
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Appearance Section
                /// Theme selection with visual buttons for Auto/Light/Dark
                Section {
                    HStack(spacing: 12) {
                        ThemeOptionButton(
                            theme: .automatic,
                            currentTheme: settingsStore.theme,
                            icon: "iphone",
                            label: "Auto",
                            color: .blue,
                            action: { settingsStore.theme = .automatic }
                        )
                        
                        ThemeOptionButton(
                            theme: .light,
                            currentTheme: settingsStore.theme,
                            icon: "sun.max.fill",
                            label: "Light",
                            color: .orange,
                            action: { settingsStore.theme = .light }
                        )
                        
                        ThemeOptionButton(
                            theme: .dark,
                            currentTheme: settingsStore.theme,
                            icon: "moon.fill",
                            label: "Dark",
                            color: .purple,
                            action: { settingsStore.theme = .dark }
                        )
                    }
                    .padding(.vertical, 4)
                } header: {
                    HStack {
                        Image(systemName: "paintbrush.fill")
                            .foregroundStyle(.blue)
                        Text("Appearance")
                    }
                }
                
                // MARK: - Goals Section
                /// User fitness goals configuration
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Weekly Goal", systemImage: "calendar.circle.fill")
                                .foregroundStyle(.blue)
                            Spacer()
                            Text("\(settingsStore.weeklyGoal) workouts")
                                .font(.headline.bold())
                                .foregroundStyle(.blue)
                        }
                        Slider(
                            value: Binding(
                                get: { Double(settingsStore.weeklyGoal) },
                                set: { settingsStore.weeklyGoal = Int($0) }
                            ),
                            in: 1...14,
                            step: 1
                        )
                        .tint(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label("Daily Goal", systemImage: "clock.circle.fill")
                                .foregroundStyle(.green)
                            Spacer()
                            Text("\(settingsStore.dailyGoal) minutes")
                                .font(.headline.bold())
                                .foregroundStyle(.green)
                        }
                        Slider(
                            value: Binding(
                                get: { Double(settingsStore.dailyGoal) },
                                set: { settingsStore.dailyGoal = Int($0) }
                            ),
                            in: 5...120,
                            step: 5
                        )
                        .tint(.green)
                    }
                } header: {
                    HStack {
                        Image(systemName: "target")
                            .foregroundStyle(.orange)
                        Text("Goals")
                    }
                }
                
                // MARK: - Notifications Section
                /// Notification settings and test controls
                Section {
                    Toggle("Enable Notifications", isOn: $settingsStore.notificationsEnabled)
                        .onChange(of: settingsStore.notificationsEnabled) { oldValue, newValue in
                            if newValue {
                                NotificationManager.shared.requestAuthorization { granted in
                                    if granted {
                                        NotificationManager.shared.scheduleMotivationalReminder()
                                        workoutStore.scheduleAllNotifications()
                                        DispatchQueue.main.async {
                                            testAlertMessage = "Notifications enabled! Reminders scheduled."
                                            showingTestAlert = true
                                        }
                                    } else {
                                        DispatchQueue.main.async {
                                            settingsStore.notificationsEnabled = false
                                            testAlertMessage = "Please allow notifications in Settings to use this feature."
                                            showingTestAlert = true
                                        }
                                    }
                                }
                            } else {
                                workoutStore.cancelAllNotifications()
                                NotificationManager.shared.cancelAllNotifications()
                                DispatchQueue.main.async {
                                    testAlertMessage = "Notifications disabled. All reminders cancelled."
                                    showingTestAlert = true
                                }
                            }
                        }
                    
                    if settingsStore.notificationsEnabled {
                        HStack {
                            Label("Status", systemImage: "bell.badge.fill")
                                .foregroundStyle(.blue)
                            Spacer()
                            HStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                Text("Active")
                                    .font(.caption.bold())
                                    .foregroundStyle(.green)
                            }
                        }
                        
                        // MARK: - Test Notification Button
                        Button(action: testNotification) {
                            HStack {
                                Label("Test Notification", systemImage: "bell.fill")
                                    .foregroundStyle(.blue)
                                Spacer()
                                if isTesting {
                                    ProgressView()
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .disabled(isTesting)
                        
                        // MARK: - Schedule Demo Reminder Button
                        Button(action: scheduleDemoReminder) {
                            HStack {
                                Label("Schedule Demo Reminder", systemImage: "clock.badge")
                                    .foregroundStyle(.green)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        // MARK: - Clear All Notifications Button
                        Button(action: clearNotifications) {
                            HStack {
                                Label("Clear All Notifications", systemImage: "bell.slash.fill")
                                    .foregroundStyle(.red)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } header: {
                    HStack {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(.purple)
                        Text("Notifications")
                    }
                } footer: {
                    if settingsStore.notificationsEnabled {
                        Text("You will receive reminders for upcoming workouts and motivational messages.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text("Enable notifications to get workout reminders and stay on track!")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // MARK: - Display Section
                Section {
                    Toggle("Show Calories", isOn: $settingsStore.showCalories)
                } header: {
                    HStack {
                        Image(systemName: "eye.fill")
                            .foregroundStyle(.teal)
                        Text("Display")
                    }
                }
                
                // MARK: - About Section
                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle.fill")
                            .foregroundStyle(.blue)
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Workouts", systemImage: "figure.run")
                            .foregroundStyle(.green)
                        Spacer()
                        Text("\(workoutStore.totalWorkouts)")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Label("Completed", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Spacer()
                        Text("\(workoutStore.completedCount)")
                            .foregroundStyle(.secondary)
                    }
                    
                    // MARK: - Reset Onboarding Button - ✅ FIXED
                    Button(action: resetOnboarding) {
                        HStack {
                            Label("Show Onboarding Again", systemImage: "arrow.counterclockwise.circle.fill")
                                .foregroundStyle(.blue)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // MARK: - Reset Data Button
                    Button(action: resetData) {
                        HStack {
                            Label("Reset All Data", systemImage: "trash.circle.fill")
                                .foregroundStyle(.red)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .disabled(isResetting)
                } header: {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundStyle(.blue)
                        Text("About")
                    }
                }
                // ✅ footer: REMOVED
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .font(.headline)
                    .foregroundStyle(.blue)
                }
            }
        }
        .frame(minWidth: 340, idealWidth: 380, maxWidth: 440,
               minHeight: 500, idealHeight: 600, maxHeight: 700)
        .alert("Notification Status", isPresented: $showingTestAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(testAlertMessage)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Test notification functionality
    /// Sends a test notification to verify that notifications are working correctly
    private func testNotification() {
        guard !isTesting else { return }
        isTesting = true
        
        NotificationManager.shared.checkAuthorizationStatus { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    NotificationManager.shared.sendTestNotification()
                    self.testAlertMessage = "✅ Test notification sent! Check your notification center."
                    self.showingTestAlert = true
                    self.isTesting = false
                    
                case .denied:
                    self.testAlertMessage = "⚠️ Notification access denied. Please enable in Settings."
                    self.showingTestAlert = true
                    self.isTesting = false
                    
                case .notDetermined:
                    NotificationManager.shared.requestAuthorization { granted in
                        DispatchQueue.main.async {
                            if granted {
                                NotificationManager.shared.sendTestNotification()
                                self.testAlertMessage = "✅ Test notification sent! Check your notification center."
                            } else {
                                self.testAlertMessage = "⚠️ Notification access denied. Please enable in Settings."
                            }
                            self.showingTestAlert = true
                            self.isTesting = false
                        }
                    }
                    
                case .provisional:
                    NotificationManager.shared.sendTestNotification()
                    self.testAlertMessage = "✅ Test notification sent! (Provisional authorization)"
                    self.showingTestAlert = true
                    self.isTesting = false
                    
                case .ephemeral:
                    NotificationManager.shared.sendTestNotification()
                    self.testAlertMessage = "✅ Test notification sent! (Ephemeral authorization)"
                    self.showingTestAlert = true
                    self.isTesting = false
                    
                @unknown default:
                    self.testAlertMessage = "⚠️ Unknown notification status. Please try again."
                    self.showingTestAlert = true
                    self.isTesting = false
                }
            }
        }
    }
    
    /// Schedule a demo reminder (5 minutes from now)
    /// Used to demonstrate notification scheduling functionality
    private func scheduleDemoReminder() {
        let content = UNMutableNotificationContent()
        content.title = "⏰ Demo Reminder"
        content.body = "This is a demo reminder! Your notification scheduling is working perfectly!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 300, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "demo_reminder_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.testAlertMessage = "❌ Failed to schedule demo reminder: \(error.localizedDescription)"
                } else {
                    self.testAlertMessage = "✅ Demo reminder scheduled for 5 minutes from now!"
                }
                self.showingTestAlert = true
            }
        }
    }
    
    /// Clear all notifications and badge count
    private func clearNotifications() {
        NotificationManager.shared.clearAllDeliveredNotifications()
        NotificationManager.shared.cancelAllNotifications()
        workoutStore.cancelAllNotifications()
        testAlertMessage = "✅ All notifications cleared successfully!"
        showingTestAlert = true
    }
    
    /// Reset onboarding to show again
    /// Sets the onboarding flag to false so it appears on next launch
    private func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
        testAlertMessage = "✅ Onboarding will show on next app launch!"
        // Force the alert to stay visible
        showingTestAlert = true
    }
    
    /// Reset all data and reload sample workouts
    /// Shows a confirmation alert before performing the reset
    private func resetData() {
        // Prevent multiple resets
        guard !isResetting else { return }
        isResetting = true
        
        // Create alert
        let alert = UIAlertController(
            title: "Reset All Data?",
            message: "This will delete all your workouts and reset to sample data. This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.isResetting = false
        })
        
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { _ in
            // Perform reset
            self.workoutStore.resetAllData()
            
            // Show confirmation
            self.testAlertMessage = "✅ All data has been reset to sample data. (\(self.workoutStore.workouts.count) workouts loaded)"
            self.showingTestAlert = true
            
            // Re-enable reset button
            self.isResetting = false
        })
        
        // Present alert on main thread
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                // Dismiss any presented view controller first
                rootVC.dismiss(animated: false) { [weak rootVC] in
                    rootVC?.present(alert, animated: true)
                }
            }
        }
    }
}

// MARK: - Theme Option Button
/// Reusable theme selection button with visual feedback
struct ThemeOptionButton: View {
    let theme: SettingsStore.Theme
    let currentTheme: SettingsStore.Theme
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    /// Whether this theme option is currently selected
    var isSelected: Bool {
        theme == currentTheme
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? color.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(isSelected ? color : .gray)
                }
                
                Text(label)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? color : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? color.opacity(0.1) : Color.clear)
                    .stroke(isSelected ? color.opacity(0.3) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    SettingsPopoverView(isPresented: .constant(true))
        .environmentObject(SettingsStore())
        .environmentObject(WorkoutStore.preview)
}
