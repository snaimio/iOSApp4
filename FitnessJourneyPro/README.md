# 🏋️ Fitness Journey Pro

> A comprehensive iPad fitness tracker app built with SwiftUI for iOS App Development Assignment 4.

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)](https://apple.com)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0+-purple.svg)](https://developer.apple.com/xcode/swiftui/)
[![Xcode](https://img.shields.io/badge/Xcode-15.0+-brightgreen.svg)](https://developer.apple.com/xcode/)
[![Platform](https://img.shields.io/badge/Platform-iPad-lightgrey.svg)](https://apple.com)

---

## 📱 App Overview

**Fitness Journey Pro** is a professional iPad fitness tracking application that helps users log workouts, track progress, and stay motivated. Built with SwiftUI, it features a modern, responsive design optimized for iPad with NavigationSplitView.

### ✨ Key Features

| Feature | Description |
|---------|-------------|
| 📋 **Workout Tracking** | Log workouts with name, category, duration, intensity, and date |
| ⏱️ **Timer-Based Progress** | Real-time progress tracking with countdown for upcoming workouts |
| 📊 **Statistics Dashboard** | Visual progress tracking with completion rates and category breakdown |
| 🔔 **Smart Notifications** | Reminders for upcoming workouts and motivational messages |
| 🎨 **Customizable Themes** | Light, Dark, and Auto theme support |
| 🏆 **Achievements** | Automatic achievement unlocking for milestones |
| 📱 **iPad Optimized** | NavigationSplitView for seamless iPad experience |
| 🔍 **Search & Filter** | Find workouts quickly with search and category filters |
| 🔄 **Reset All Data** | Reset to sample data with one tap |
| 👆 **Gestures** | Long press for actions, swipe to delete/complete |

---

## 🚀 Technologies Used

| Technology | Purpose |
|------------|---------|
| **SwiftUI** | Modern declarative UI framework |
| **Combine** | Reactive programming for state management |
| **UserNotifications** | Local notifications and reminders |
| **UserDefaults** | Persistent data storage with `@AppStorage` |
| **JSON Encoding/Decoding** | Data persistence and storage |
| **SF Symbols** | Beautiful iconography for categories |
| **UNUserNotificationCenter** | Notification handling and permissions |

---

## 🏗️ Project Structure

```
FitnessJourneyPro/
├── App/
│   ├── FitnessJourneyProApp.swift      # App entry point
│   └── AppDelegate.swift                # App delegate for notifications
├── Models/
│   ├── Workout.swift                    # Workout data model
│   ├── WorkoutStore.swift               # Workout data management
│   └── SettingsStore.swift              # Settings management
├── Views/
│   ├── ContentView.swift                # Main app view
│   ├── WorkoutListView.swift            # Workout list sidebar
│   ├── WorkoutRow.swift                 # Custom workout row
│   ├── WorkoutDetailView.swift          # Workout detail view
│   ├── AddWorkoutView.swift             # Add workout form
│   ├── EditWorkoutView.swift            # Edit workout form
│   ├── QuickAddWorkoutView.swift        # Quick add popover
│   ├── SettingsPopoverView.swift        # Settings view
│   ├── OnboardingView.swift             # Onboarding flow
│   ├── ProgressBarView.swift            # Linear progress bar
│   └── CircularProgressBar.swift        # Circular progress bar
├── Managers/
│   └── NotificationManager.swift        # Notification handling
├── Extensions/
│   └── Color+Extensions.swift           # Color extensions
└── Assets.xcassets                      # App assets
```

---

## 🎯 Topics Covered

| Topic | Implementation |
|-------|---------------|
| **SwiftUI State Management** | `@State`, `@Binding`, `@EnvironmentObject`, `@AppStorage` |
| **Navigation Patterns** | `NavigationSplitView`, `NavigationStack`, `Toolbar` |
| **User Input Controls** | `DatePicker`, `Picker`, `Slider`, `Toggle` |
| **Gestures** | `onLongPressGesture`, `onHover`, `SwipeActions` |
| **Animations** | `withAnimation`, `.animation`, `scaleEffect`, `trim` |
| **Notifications** | `UNUserNotificationCenter`, `UNCalendarNotificationTrigger` |
| **Data Persistence** | `@AppStorage`, `UserDefaults` with JSON |
| **Custom Components** | `@ViewBuilder`, Reusable Views, `GeometryReader` |
| **Accessibility** | `.accessibilityLabel`, `.accessibilityHint` |
| **Gradients & Styling** | `LinearGradient`, `AngularGradient`, `StrokeStyle` |

---

## 🛠️ Installation

### Prerequisites
- Xcode 15.0+
- iOS 17.0+ Simulator or iPad device
- Swift 5.9+

### Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/[yourusername]/iOSApp4.git
   ```

2. **Navigate to project**
   ```bash
   cd iOSApp4
   ```

3. **Open the project**
   ```bash
   open FitnessJourneyPro.xcodeproj
   ```

4. **Build and run**
   - Select an iPad simulator
   - Press `⌘ + R`

---

## 🧪 Testing Checklist

- [ ] Add new workouts
- [ ] Edit existing workouts
- [ ] Delete workouts (swipe or detail view)
- [ ] Mark workouts as complete/incomplete
- [ ] View statistics dashboard
- [ ] Test notifications in Settings
- [ ] Change themes (Auto/Light/Dark)
- [ ] Search and filter workouts
- [ ] Reset all data
- [ ] Onboarding flow
- [ ] Long press for context menu

---

## 📋 Assignment Requirements

| Requirement | Status |
|-------------|--------|
| New Xcode Project | ✅ |
| New GitHub Repository (iOSApp4) | ✅ |
| iPad or VisionOS App | ✅ (iPad) |
| Features from This Week | ✅ |
| Proper Comments with `// MARK: -` | ✅ |
| Committed & Pushed to GitHub | ✅ |
| Link Sent to Instructor | ✅ |

---

## 👨‍💻 Author

**Sheikh Naim**
- Course: iOS App Development
- Assignment: iOSApp4
- Date: June 2026

---

## 📊 Project Stats

| Metric | Value |
|--------|-------|
| **Total Files** | 14+ |
| **Lines of Code** | 1500+ |
| **SwiftUI Views** | 10+ |
| **Custom Components** | 5+ |
| **Features Implemented** | 15+ |

---

**Made with ❤️ for Fitness Journey Pro**
