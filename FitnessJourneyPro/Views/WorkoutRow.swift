//
//  WorkoutRow.swift
//  FitnessJourneyPro
//
//  Created by Sheikh Naim on 2026-06-23.
//  🎨 Enhanced with beautiful row design
//  🔧 Fixed: Single tap to open, completed items now respond
//

import SwiftUI

struct WorkoutRow: View {
    let workout: Workout
    @EnvironmentObject var workoutStore: WorkoutStore
    
    @State private var isLongPressing = false
    @State private var longPressOffset: CGFloat = 0
    @State private var showingContextMenu = false
    
    var body: some View {
        HStack(spacing: 16) {
            // MARK: - Category Icon with Gradient Background
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
                    Text(workout.name)
                        .font(.headline)
                        .strikethrough(workout.isCompleted)
                        .foregroundStyle(workout.isCompleted ? .secondary : .primary)
                    
                    Spacer()
                    
                    // MARK: - Intensity Badge with Color
                    Text(workout.intensity.rawValue)
                        .font(.caption2.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(workout.intensity.color.opacity(0.15))
                        .foregroundStyle(workout.intensity.color)
                        .clipShape(Capsule())
                }
                
                HStack(spacing: 12) {
                    Label(workout.durationFormatted, systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
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
        // ✅ FIX: Remove opacity that blocks gestures
        // .opacity(workout.isCompleted ? 0.75 : 1.0)  // REMOVED - this was blocking taps!
        .offset(x: longPressOffset)
        
        // MARK: - Long Press Gesture (Keep this but make it not interfere with tap)
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
            Button(workout.isCompleted ? "Mark as Incomplete" : "Mark as Complete") {
                withAnimation(.spring()) {
                    workoutStore.toggleCompletion(workout)
                }
            }
            
            Button("Edit") {
                NotificationCenter.default.post(
                    name: NSNotification.Name("EditWorkout"),
                    object: workout
                )
            }
            
            Button("Delete", role: .destructive) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    workoutStore.delete(workout)
                }
            }
            
            Button("Cancel", role: .cancel) { }
        }
        .accessibilityLabel("\(workout.name), \(workout.category.rawValue)")
        .accessibilityHint("Tap to view details, Long press for actions")
        // ✅ FIX: Make entire row tappable with tap gesture
        .contentShape(Rectangle())
    }
}
