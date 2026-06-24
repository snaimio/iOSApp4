//
//  QuickAddWorkoutView.swift
//  FitnessJourneyPro
//
//  Created by Sheikh Naim on 2026-06-23.
//  Quick add workout popover
//  Features: .popover(), attachmentAnchor, arrowEdge
//  Topics: Popovers, Compact Forms, Quick Actions
//

import SwiftUI

// MARK: - QuickAddWorkoutView
/// Compact popover view for quickly adding a workout
struct QuickAddWorkoutView: View {
    
    // MARK: - Environment Objects
    @EnvironmentObject var workoutStore: WorkoutStore
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Bindings
    @Binding var isPresented: Bool
    
    // MARK: - State Variables
    @State private var name = ""
    @State private var category = WorkoutCategory.cardio
    @State private var duration = 30.0
    @State private var intensity = Intensity.medium
    @State private var date = Date()
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Quick Add Form
                Section("Quick Add") {
                    TextField("Workout Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    // MARK: - Category Picker
                    Picker("Category", selection: $category) {
                        ForEach(WorkoutCategory.allCases) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    
                    // MARK: - Duration with Slider
                    HStack {
                        Text("Duration: \(Int(duration)) min")
                        Spacer()
                        Slider(value: $duration, in: 5...120, step: 5)
                            .frame(width: 120)
                            .tint(.blue)
                    }
                    
                    // MARK: - Intensity Picker (Segmented)
                    Picker("Intensity", selection: $intensity) {
                        ForEach(Intensity.allCases) { intensity in
                            Text(intensity.rawValue).tag(intensity)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    // MARK: - DatePicker
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                }
            }
            .navigationTitle("Quick Add")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // MARK: - Cancel Button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                // MARK: - Save Button
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
        .frame(minWidth: 320, idealWidth: 360, maxWidth: 400,
               minHeight: 400, idealHeight: 450, maxHeight: 500)
    }
    
    // MARK: - Helper Methods
    private func saveWorkout() {
        let workout = Workout(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            duration: Int(duration),
            intensity: intensity,
            date: date,
            isCompleted: false,
            notes: "",
            caloriesBurned: nil
        )
        workoutStore.add(workout)
        isPresented = false
    }
}

// MARK: - Preview
#Preview {
    QuickAddWorkoutView(isPresented: .constant(true))
        .environmentObject(WorkoutStore())
}
