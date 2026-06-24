//
//  EditWorkoutView.swift
//  FitnessJourneyPro
//
//  Created by Sheikh Naim on 2026-06-23.
//  Edit workout form with pre-populated data
//  Features: Form, Data Binding, Update Operations
//  Topics: Input Controls, Data Updates, Forms
//

import SwiftUI

// MARK: - EditWorkoutView
/// Form for editing an existing workout with pre-filled data
struct EditWorkoutView: View {
    
    // MARK: - Environment Objects
    @EnvironmentObject var workoutStore: WorkoutStore
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Properties
    let workout: Workout
    
    // MARK: - Bindings
    @Binding var isPresented: Bool
    
    // MARK: - State Variables
    @State private var name: String
    @State private var category: WorkoutCategory
    @State private var duration: Double
    @State private var intensity: Intensity
    @State private var date: Date
    @State private var notes: String
    @State private var caloriesBurned: String
    @State private var isCompleted: Bool
    
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // MARK: - Initialization
    init(workout: Workout, isPresented: Binding<Bool>) {
        self.workout = workout
        self._isPresented = isPresented
        
        // Initialize state with workout data
        _name = State(initialValue: workout.name)
        _category = State(initialValue: workout.category)
        _duration = State(initialValue: Double(workout.duration))
        _intensity = State(initialValue: workout.intensity)
        _date = State(initialValue: workout.date)
        _notes = State(initialValue: workout.notes)
        _caloriesBurned = State(initialValue: workout.caloriesBurned.map { String($0) } ?? "")
        _isCompleted = State(initialValue: workout.isCompleted)
    }
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Basic Information Section
                Section("Basic Information") {
                    TextField("Workout Name", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    // MARK: - Category Picker
                    Picker("Category", selection: $category) {
                        ForEach(WorkoutCategory.allCases) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                    
                    // MARK: - Duration Slider
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text("\(Int(duration)) minutes")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $duration, in: 5...120, step: 5)
                        .tint(.blue)
                }
                
                // MARK: - Intensity Section
                Section("Intensity") {
                    Picker("Intensity Level", selection: $intensity) {
                        ForEach(Intensity.allCases) { intensity in
                            HStack {
                                Text(intensity.emoji)
                                Text(intensity.rawValue)
                            }
                            .tag(intensity)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // MARK: - Date & Time Section
                Section("Schedule") {
                    DatePicker("Date & Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                }
                
                // MARK: - Status Section
                Section("Status") {
                    Toggle("Completed", isOn: $isCompleted)
                }
                
                // MARK: - Additional Info Section
                Section("Additional Information") {
                    TextField("Calories Burned (optional)", text: $caloriesBurned)
                        .keyboardType(.numberPad)
                    
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .navigationTitle("Edit Workout")
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
        .alert("Validation Error", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Helper Methods
    private func saveWorkout() {
        // Validate inputs
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter a workout name."
            showingAlert = true
            return
        }
        
        // Parse calories if provided
        let calories = Int(caloriesBurned)
        
        // Create updated workout
        var updatedWorkout = workout
        updatedWorkout.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        updatedWorkout.category = category
        updatedWorkout.duration = Int(duration)
        updatedWorkout.intensity = intensity
        updatedWorkout.date = date
        updatedWorkout.notes = notes
        updatedWorkout.caloriesBurned = calories
        updatedWorkout.isCompleted = isCompleted
        
        // Update in store
        workoutStore.update(updatedWorkout)
        
        // Dismiss view
        isPresented = false
    }
}

// MARK: - Preview
#Preview {
    EditWorkoutView(
        workout: Workout(
            name: "Morning Run",
            category: .running,
            duration: 30,
            intensity: .medium,
            date: Date(),
            isCompleted: false,
            notes: "Great workout!",
            caloriesBurned: 300
        ),
        isPresented: .constant(true)
    )
    .environmentObject(WorkoutStore())
}
