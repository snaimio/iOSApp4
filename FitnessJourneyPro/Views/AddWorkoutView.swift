//  ==================================================
//  AddWorkoutView.swift
//  FitnessJourneyPro

//  Created by Sheikh Naim on 2026-06-23.

//  Full screen add workout form
//  Features: Form, DatePicker, Picker, Slider, Toggle
//  Topics: Input Controls, Forms, Validation
//  ==================================================

import SwiftUI

// MARK: - AddWorkoutView
/// Full screen form for adding a new workout
/// Provides input fields for all workout properties with validation
struct AddWorkoutView: View {
    
    // MARK: - Environment Objects
    /// Access to the workout store for saving data
    @EnvironmentObject var workoutStore: WorkoutStore
    
    /// Environment variable to dismiss the view
    @Environment(\.dismiss) var dismiss
    
    // MARK: - Bindings
    /// Controls whether the view is presented
    @Binding var isPresented: Bool
    
    // MARK: - State Variables
    /// Name of the workout
    @State private var name = ""
    
    /// Selected workout category
    @State private var category = WorkoutCategory.cardio
    
    /// Duration in minutes (as Double for slider)
    @State private var duration = 30.0
    
    /// Selected intensity level
    @State private var intensity = Intensity.medium
    
    /// Scheduled date and time for the workout
    @State private var date = Date()
    
    /// Optional notes about the workout
    @State private var notes = ""
    
    /// Optional calories burned (as String for text input)
    @State private var caloriesBurned = ""
    
    /// Controls alert presentation
    @State private var showingAlert = false
    
    /// Message to display in alert
    @State private var alertMessage = ""
    
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
                    // MARK: - Intensity Picker (Segmented)
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
                    // MARK: - DatePicker
                    DatePicker("Date & Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                }
                
                // MARK: - Additional Info Section
                Section("Additional Information") {
                    // MARK: - Calories TextField
                    TextField("Calories Burned (optional)", text: $caloriesBurned)
                        .keyboardType(.numberPad)
                    
                    // MARK: - Notes TextEditor
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3)
                }
            }
            .navigationTitle("Add Workout")
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
    
    /// Validates input and saves the workout to the store
    /// - Displays an alert if validation fails
    private func saveWorkout() {
        // Validate inputs
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "Please enter a workout name."
            showingAlert = true
            return
        }
        
        // Parse calories if provided
        let calories = Int(caloriesBurned)
        
        // Create workout
        let workout = Workout(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category,
            duration: Int(duration),
            intensity: intensity,
            date: date,
            isCompleted: false,
            notes: notes,
            caloriesBurned: calories
        )
        
        // Save to store
        workoutStore.add(workout)
        
        // Dismiss view
        isPresented = false
    }
}

// MARK: - Preview
#Preview {
    AddWorkoutView(isPresented: .constant(true))
        .environmentObject(WorkoutStore())
}
