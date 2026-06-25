//  ===============================================
//  WorkoutDetailView.swift
//  FitnessJourneyPro

//  Created by Sheikh Naim on 2026-06-23.

//  Enhanced with beautiful detail design
//  Added Timer-Based Progress & Fixed Badge Layout
//  ===============================================

import SwiftUI

// MARK: - WorkoutDetailView
/// Detailed view showing complete workout information
/// Displays workout details, progress, and action buttons
struct WorkoutDetailView: View {
    /// The workout being displayed (bindable for updates)
    @Binding var workout: Workout
    
    /// Callback for when the workout is deleted
    let onDelete: () -> Void
    
    // MARK: - Environment Objects
    /// Access to the workout store for updates
    @EnvironmentObject var workoutStore: WorkoutStore
    
    /// Access to user settings for display preferences
    @EnvironmentObject var settingsStore: SettingsStore
    
    // MARK: - State Variables
    /// Controls the delete confirmation alert
    @State private var showingDeleteAlert = false
    
    /// Controls the edit sheet presentation
    @State private var showingEditSheet = false
    
    /// Tracks if the workout timer is running
    @State private var isTimerRunning = false
    
    /// Current progress of the active workout timer
    @State private var timerProgress: Double = 0.0
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection
                statsGrid
                detailsSection
                progressSection
                actionButtons
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEditSheet = true
                }
                .font(.headline)
                .foregroundStyle(.blue)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditWorkoutView(workout: workout, isPresented: $showingEditSheet)
                .environmentObject(workoutStore)
        }
        .alert("Delete Workout", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                workoutStore.delete(workout)
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete '\(workout.name)'?")
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("EditWorkout"))) { notification in
            if let workout = notification.object as? Workout, workout.id == self.workout.id {
                showingEditSheet = true
            }
        }
        .onAppear {
            if workout.isActive {
                isTimerRunning = true
            }
        }
        .onReceive(workoutStore.$currentWorkoutProgress) { progress in
            if workout.isActive {
                timerProgress = progress
            }
        }
    }
    
    // MARK: - Header Section
    /// Displays the workout icon, name, and status badges
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Large Category Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                workout.category.color.opacity(0.2),
                                workout.category.color.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: workout.category.icon)
                    .font(.system(size: 50))
                    .foregroundStyle(workout.category.color)
            }
            .shadow(color: workout.category.color.opacity(0.3), radius: 20)
            
            Text(workout.name)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
            
            // Badges centered with flexible layout
            HStack(spacing: 8) {
                // Category Badge
                HStack(spacing: 4) {
                    Image(systemName: workout.category.icon)
                        .font(.caption)
                    Text(workout.category.rawValue)
                        .font(.caption.bold())
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(workout.category.color.opacity(0.15))
                .foregroundStyle(workout.category.color)
                .clipShape(Capsule())
                
                // Intensity Badge
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.caption)
                    Text(workout.intensity.rawValue)
                        .font(.caption.bold())
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(workout.intensity.color.opacity(0.15))
                .foregroundStyle(workout.intensity.color)
                .clipShape(Capsule())
                
                // Status Badge
                if workout.isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                        Text("Completed")
                            .font(.caption.bold())
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.green.opacity(0.15))
                    .foregroundStyle(.green)
                    .clipShape(Capsule())
                } else if workout.isActive {
                    HStack(spacing: 4) {
                        Image(systemName: "play.circle.fill")
                            .font(.caption)
                        Text("In Progress")
                            .font(.caption.bold())
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.15))
                    .foregroundStyle(.blue)
                    .clipShape(Capsule())
                } else if workout.date > Date() {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption)
                        Text("Upcoming")
                            .font(.caption.bold())
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.orange.opacity(0.15))
                    .foregroundStyle(.orange)
                    .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 30)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 10)
        )
    }
    
    // MARK: - Stats Grid
    /// Displays key workout statistics in a grid layout
    @ViewBuilder
    private var statsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            StatBox(
                icon: "clock",
                label: "Duration",
                value: workout.durationFormatted
            )
            
            StatBox(
                icon: "calendar",
                label: "Date",
                value: workout.formattedDate
            )
            
            if settingsStore.showCalories {
                if let calories = workout.caloriesBurned {
                    StatBox(
                        icon: "flame",
                        label: "Calories",
                        value: "\(calories)"
                    )
                } else {
                    StatBox(
                        icon: "checkmark.circle",
                        label: "Status",
                        value: workout.isCompleted ? "✅ Done" : (workout.isActive ? "⏳ In Progress" : "⏳ Pending")
                    )
                }
            } else {
                StatBox(
                    icon: "checkmark.circle",
                    label: "Status",
                    value: workout.isCompleted ? "✅ Done" : (workout.isActive ? "⏳ In Progress" : "⏳ Pending")
                )
            }
        }
    }
    
    // MARK: - Details Section
    /// Shows detailed workout information in a list format
    @ViewBuilder
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Details")
                .font(.headline)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                DetailRow(icon: "calendar", label: "Date", value: workout.formattedDate)
                Divider().padding(.leading, 44)
                DetailRow(icon: "clock", label: "Duration", value: workout.durationFormatted)
                Divider().padding(.leading, 44)
                DetailRow(icon: "tag", label: "Category", value: workout.category.rawValue)
                Divider().padding(.leading, 44)
                DetailRow(icon: "bolt", label: "Intensity", value: workout.intensity.rawValue)
                Divider().padding(.leading, 44)
                DetailRow(icon: "checkmark.circle", label: "Status", value: workout.isCompleted ? "Completed ✅" : (workout.isActive ? "In Progress ⏳" : "Pending ⏳"))
                
                if !workout.notes.isEmpty {
                    Divider().padding(.leading, 44)
                    DetailRow(icon: "note.text", label: "Notes", value: workout.notes)
                }
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Progress Section
    /// Displays workout progress with a circular progress bar
    @ViewBuilder
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Progress")
                .font(.headline)
                .padding(.horizontal, 4)
            
            VStack(spacing: 16) {
                HStack {
                    Spacer()
                    EnhancedCircularProgress(
                        progress: workoutStore.progressForWorkout(workout)
                    )
                    .frame(width: 120, height: 120)
                    .animation(.easeInOut(duration: 0.5), value: workoutStore.progressForWorkout(workout))
                    Spacer()
                }
                
                let status = workoutStore.progressStatusText(for: workout)
                Text(status.text)
                    .font(.headline)
                    .foregroundStyle(status.color)
                    .animation(.easeInOut(duration: 0.3), value: workout.isCompleted)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
        }
    }
    
    // MARK: - Action Buttons
    /// Provides interactive buttons for workout actions
    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Show Start Workout button only for pending workouts that are due
            if !workout.isCompleted && !workout.isActive && workout.date <= Date() {
                Button {
                    startWorkout()
                } label: {
                    Label("Start Workout", systemImage: "play.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .controlSize(.large)
            }
            
            // Toggle completion status
            Button {
                withAnimation(.spring()) {
                    workoutStore.toggleCompletion(workout)
                    if let updatedWorkout = workoutStore.workouts.first(where: { $0.id == workout.id }) {
                        workout = updatedWorkout
                    }
                }
            } label: {
                Label(
                    workout.isCompleted ? "Mark as Incomplete" : "Mark as Complete",
                    systemImage: workout.isCompleted ? "xmark.circle" : "checkmark.circle"
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
            .tint(workout.isCompleted ? .orange : .green)
            .controlSize(.large)
            
            // Delete button
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Delete Workout", systemImage: "trash")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Starts the workout timer and updates the binding
    private func startWorkout() {
        workoutStore.startWorkoutTimer(for: workout)
        if let updatedWorkout = workoutStore.workouts.first(where: { $0.id == workout.id }) {
            workout = updatedWorkout
        }
    }
}

// MARK: - Stat Box Component
/// Reusable statistics box displaying an icon, value, and label
struct StatBox: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
            
            Text(value)
                .font(.headline.bold())
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Detail Row Component
/// Reusable detail row for displaying key-value pairs
struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 28)
            
            Text(label)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
                .foregroundStyle(valueColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

// MARK: - Enhanced Circular Progress
/// Circular progress ring with gradient and percentage label
struct EnhancedCircularProgress: View {
    let progress: Double
    var size: CGFloat = 120
    var lineWidth: CGFloat = 12
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: lineWidth)
            
            // Animated progress ring
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    AngularGradient(
                        colors: progress >= 1.0 ? [.green, .mint] : [.blue, .purple, .pink],
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            // Percentage label
            Text("\(Int(progress * 100))%")
                .font(.title2.bold())
                .foregroundStyle(progress >= 1.0 ? .green : .primary)
        }
        .frame(width: size, height: size)
    }
}
