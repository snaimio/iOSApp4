//  ====================================================================================
//  ContentView.swift
//  FitnessJourneyPro

//  Created by Sheikh Naim on 2026-06-23.

//  Features: NavigationSplitView, EnvironmentObject, Sheets, Popovers, Hover Animations
//  Topics: iPad Layout, Modal Presentations, State Management, Gestures
//  Enhanced with beautiful UI design
//  WorkoutDetailView now uses @Binding for proper updates
//  ====================================================================================

import SwiftUI

// MARK: - ContentView
/// Main app view containing the split view navigation for iPad
/// Uses NavigationSplitView with a sidebar list and detail view
struct ContentView: View {
    
    // MARK: - Environment Objects
    /// Access to the workout data store
    @EnvironmentObject var workoutStore: WorkoutStore
    
    /// Access to user settings and preferences
    @EnvironmentObject var settingsStore: SettingsStore
    
    // MARK: - State Variables
    /// Currently selected workout in the sidebar
    @State private var selectedWorkout: Workout?
    
    /// Controls the add workout sheet
    @State private var showingAddWorkout = false
    
    /// Controls the quick add popover
    @State private var showingQuickAdd = false
    
    /// Controls the settings sheet
    @State private var showingSettings = false
    
    /// Controls the statistics sheet
    @State private var showingStats = false
    
    // MARK: - Hover States
    /// Hover state for the add button (iPad pointer feedback)
    @State private var isHoveringAddButton = false
    
    /// Hover state for the statistics button
    @State private var isHoveringStatsButton = false
    
    /// Hover state for the settings button
    @State private var isHoveringSettingsButton = false
    
    // MARK: - Body
    var body: some View {
        // MARK: - NavigationSplitView (iPad Split View)
        NavigationSplitView {
            // MARK: Sidebar: Workout List
            WorkoutListView(
                selectedWorkout: $selectedWorkout,
                showingAddWorkout: $showingAddWorkout
            )
            .navigationTitle("💪 Fitness Journey")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 16) {
                        // MARK: - Statistics Button with Hover Animation
                        Button {
                            showingStats = true
                        } label: {
                            Image(systemName: "chart.bar")
                                .font(.title3)
                                .foregroundStyle(.blue)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .onHover { hovering in
                            withAnimation(.easeInOut(duration: 0.15)) {
                                isHoveringStatsButton = hovering
                            }
                        }
                        .scaleEffect(isHoveringStatsButton ? 1.15 : 1.0)
                        .accessibilityLabel("View Statistics")
                        
                        // MARK: - Settings Button with Hover Animation
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gear")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .onHover { hovering in
                            withAnimation(.easeInOut(duration: 0.15)) {
                                isHoveringSettingsButton = hovering
                            }
                        }
                        .scaleEffect(isHoveringSettingsButton ? 1.15 : 1.0)
                        .accessibilityLabel("Open Settings")
                        
                        // MARK: - Add Button with Gradient and Hover Animation
                        Button {
                            showingQuickAdd = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .symbolRenderingMode(.hierarchical)
                        }
                        .onHover { hovering in
                            withAnimation(.easeInOut(duration: 0.15)) {
                                isHoveringAddButton = hovering
                            }
                        }
                        .scaleEffect(isHoveringAddButton ? 1.2 : 1.0)
                        .accessibilityLabel("Quick Add Workout")
                    }
                }
            }
        } detail: {
            // MARK: Detail View: Selected Workout or Empty State
            if let workout = selectedWorkout {
                // Create a binding to keep the detail view in sync with the store
                let binding = Binding<Workout>(
                    get: { workout },
                    set: { updatedWorkout in
                        if let index = workoutStore.workouts.firstIndex(where: { $0.id == updatedWorkout.id }) {
                            workoutStore.workouts[index] = updatedWorkout
                        }
                        if let updated = workoutStore.workouts.first(where: { $0.id == updatedWorkout.id }) {
                            selectedWorkout = updated
                        }
                    }
                )
                WorkoutDetailView(
                    workout: binding,
                    onDelete: {
                        selectedWorkout = nil
                    }
                )
            } else {
                EnhancedEmptyStateView()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .preferredColorScheme(settingsStore.colorScheme)
        
        // MARK: - Sheets (for full-screen modals)
        .sheet(isPresented: $showingAddWorkout) {
            AddWorkoutView(isPresented: $showingAddWorkout)
                .environmentObject(workoutStore)
                .environmentObject(settingsStore)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsPopoverView(isPresented: $showingSettings)
                .environmentObject(workoutStore)
                .environmentObject(settingsStore)
        }
        .sheet(isPresented: $showingStats) {
            EnhancedStatisticsView()
                .environmentObject(workoutStore)
        }
        
        // MARK: - Popover (for quick actions)
        .popover(isPresented: $showingQuickAdd) {
            QuickAddWorkoutView(isPresented: $showingQuickAdd)
                .environmentObject(workoutStore)
                .environmentObject(settingsStore)
                .preferredColorScheme(settingsStore.colorScheme)
        }
        .onAppear {
            NotificationManager.shared.requestAuthorization()
        }
    }
}

// MARK: - Enhanced Statistics View
/// Comprehensive statistics dashboard with progress tracking
struct EnhancedStatisticsView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header
                    VStack(spacing: 8) {
                        Text("📊 Your Fitness Stats")
                            .font(.largeTitle.bold())
                        Text("Track your progress and stay motivated!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // MARK: - Summary Cards
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        EnhancedStatCard(
                            title: "Total Workouts",
                            value: "\(workoutStore.totalWorkouts)",
                            icon: "figure.run",
                            gradient: [.blue, .cyan]
                        )
                        
                        EnhancedStatCard(
                            title: "Completion Rate",
                            value: "\(Int(workoutStore.completionRate * 100))%",
                            icon: "percent",
                            gradient: [.green, .mint]
                        )
                        
                        EnhancedStatCard(
                            title: "Total Minutes",
                            value: "\(workoutStore.totalMinutes)",
                            icon: "clock",
                            gradient: [.orange, .yellow]
                        )
                        
                        EnhancedStatCard(
                            title: "Streak Days",
                            value: "\(workoutStore.streakDays) 🔥",
                            icon: "flame",
                            gradient: [.red, .pink]
                        )
                    }
                    .padding(.horizontal)
                    
                    // MARK: - Progress Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Progress Overview")
                            .font(.title2.bold())
                            .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Overall Completion")
                                    .font(.headline)
                                Spacer()
                                Text("\(Int(workoutStore.completionRate * 100))%")
                                    .font(.headline.bold())
                                    .foregroundStyle(.blue)
                            }
                            
                            EnhancedProgressBar(progress: workoutStore.completionRate)
                                .frame(height: 24)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // MARK: - Category Progress
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Category Breakdown")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(WorkoutCategory.allCases, id: \.self) { category in
                                let rate = workoutStore.completionRate(for: category)
                                let count = workoutStore.workouts(for: category).count
                                if count > 0 {
                                    HStack {
                                        Image(systemName: category.icon)
                                            .foregroundStyle(category.color)
                                            .frame(width: 24)
                                        
                                        Text(category.rawValue)
                                            .font(.subheadline)
                                            .frame(width: 100, alignment: .leading)
                                        
                                        Spacer()
                                        
                                        EnhancedProgressBar(progress: rate, height: 8)
                                            .frame(width: 150, height: 8)
                                        
                                        Text("\(Int(rate * 100))%")
                                            .font(.caption.bold())
                                            .foregroundStyle(category.color)
                                            .frame(width: 40, alignment: .trailing)
                                    }
                                    .padding(.vertical, 4)
                                    .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.vertical)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.headline)
                    .foregroundStyle(.blue)
                }
            }
        }
    }
}

// MARK: - Enhanced Stat Card
/// Reusable statistics card with gradient background
struct EnhancedStatCard: View {
    let title: String
    let value: String
    let icon: String
    let gradient: [Color]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.white)
            
            Text(value)
                .font(.title.bold())
                .foregroundStyle(.white)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            LinearGradient(
                colors: gradient,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: gradient.first?.opacity(0.3) ?? .clear, radius: 8, y: 4)
    }
}

// MARK: - Enhanced Progress Bar
/// Custom progress bar with gradient fill and percentage label
struct EnhancedProgressBar: View {
    let progress: Double
    var height: CGFloat = 12
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(Color.gray.opacity(0.15))
                
                // Animated progress fill
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(min(progress, 1.0)))
                    .animation(.easeInOut(duration: 0.8), value: progress)
                
                // Percentage label (only show when progress > 10%)
                if progress > 0.1 {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: height * 0.6))
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.leading, 8)
                        .animation(.easeInOut(duration: 0.8), value: progress)
                }
            }
        }
        .frame(height: height)
    }
}

// MARK: - Enhanced Empty State View
/// Shown when no workout is selected in the detail view
struct EnhancedEmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            // Animated gradient circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.1), .purple.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)
                
                Image(systemName: "figure.run")
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text("Select a Workout")
                .font(.title.bold())
            
            Text("Choose a workout from the sidebar or add a new one to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Decorative dots
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.blue.opacity(0.6))
                    .frame(width: 8, height: 8)
                Circle()
                    .fill(Color.purple.opacity(0.6))
                    .frame(width: 8, height: 8)
                Circle()
                    .fill(Color.pink.opacity(0.6))
                    .frame(width: 8, height: 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Preview
#Preview {
    ContentView()
        .environmentObject(WorkoutStore())
        .environmentObject(SettingsStore())
}
