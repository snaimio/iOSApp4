//  =====================================
//  WorkoutRow.swift
//  FitnessJourneyPro

//  Created by Sheikh Naim on 2026-06-23.

//  ======================================

import SwiftUI

// MARK: - WorkoutRow
/// Custom row view for displaying a workout in the list
/// Features category icon, workout details, intensity badge, and long press gesture
struct WorkoutRow: View {
    // MARK: - Properties
    /// The workout to display
    let workout: Workout
    
    /// Access to the workout store for actions
    @EnvironmentObject var workoutStore: WorkoutStore
    
    // MARK: - State Variables
    /// Tracks if the row is being long-pressed for animation
    @State private var isLongPressing = false
    
    /// Offset for the row during long press animation
    @State private var longPressOffset: CGFloat = 0
    
    /// Controls the context menu presentation
    @State private var showingContextMenu = false
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 16) {
            // MARK: - Category Icon with Gradient Background
            /// Circular icon with gradient background representing the workout category
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                workout.category.color.opacity(0.3),
                                workout.category.color.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: workout.category.icon)
                    .font(.title3)
                    .foregroundStyle(workout.category.color)
            }
            .scaleEffect(isLongPressing ? 0.85 : 1.0)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    // Workout name with strikethrough when completed
                    Text(workout.name)
                        .font(.headline)
                        .strikethrough(workout.isCompleted)
                        .foregroundStyle(workout.isCompleted ? .secondary : .primary)
                    
                    Spacer()
                    
                    // MARK: - Intensity Badge with Color
                    /// Capsule badge showing workout intensity level
                    Text(workout.intensity.rawValue)
                        .font(.caption2.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(workout.intensity.color.opacity(0.15))
                        .foregroundStyle(workout.intensity.color)
                        .clipShape(Capsule())
                }
                
                HStack(spacing: 12) {
                    // Duration with clock icon
                    Label(workout.durationFormatted, systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    // Category name with icon
                    Label(workout.category.rawValue, systemImage: workout.category.icon)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(workout.isCompleted ? Color.green.opacity(0.08) : Color.clear)
        )
        .offset(x: longPressOffset)
        
        // MARK: - Long Press Gesture
        /// Triggers haptic feedback and context menu on long press
        .onLongPressGesture(
            minimumDuration: 0.6,
            maximumDistance: 50,
            pressing: { isPressing in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isLongPressing = isPressing
                    longPressOffset = isPressing ? 10 : 0
                    if isPressing {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }
                }
            },
            perform: {
                withAnimation(.spring()) {
                    showingContextMenu = true
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.success)
                }
            }
        )
        .confirmationDialog(
            "\(workout.name)",
            isPresented: $showingContextMenu,
            titleVisibility: .visible
        ) {
            // Toggle completion
            Button(workout.isCompleted ? "Mark as Incomplete" : "Mark as Complete") {
                withAnimation(.spring()) {
                    workoutStore.toggleCompletion(workout)
                }
            }
            
            // Edit workout
            Button("Edit") {
                NotificationCenter.default.post(
                    name: NSNotification.Name("EditWorkout"),
                    object: workout
                )
            }
            
            // Delete workout
            Button("Delete", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    workoutStore.delete(workout)
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
        // MARK: - Accessibility
        .accessibilityLabel("\(workout.name), \(workout.category.rawValue)")
        .accessibilityHint("Tap to view details, Long press for actions")
        .contentShape(Rectangle())
    }
}
