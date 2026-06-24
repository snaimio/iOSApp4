//
//  WorkoutListView.swift
//  FitnessJourneyPro
//
//  Created by Sheikh Naim on 2026-06-23.
//  🎨 Enhanced with beautiful list design
//  🔧 Fixed: Removed duplicate search icon
//

import SwiftUI

struct WorkoutListView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    @Binding var selectedWorkout: Workout?
    @Binding var showingAddWorkout: Bool
    
    @State private var searchText = ""
    @State private var showingFilters = false
    
    private var filteredWorkouts: [Workout] {
        if searchText.isEmpty {
            return workoutStore.filteredWorkouts
        }
        return workoutStore.filteredWorkouts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.category.rawValue.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Enhanced Stats Bar
            HStack(spacing: 16) {
                EnhancedQuickStat(
                    value: "\(workoutStore.todayWorkouts.count)",
                    label: "Today",
                    icon: "calendar",
                    color: .blue
                )
                
                Divider()
                    .frame(height: 30)
                
                EnhancedQuickStat(
                    value: "\(workoutStore.completedCount)",
                    label: "Done",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                Divider()
                    .frame(height: 30)
                
                EnhancedQuickStat(
                    value: "\(Int(workoutStore.completionRate * 100))%",
                    label: "Rate",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .purple
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemBackground))
            
            // MARK: - List with Search
            List(filteredWorkouts, id: \.id, selection: $selectedWorkout) { workout in
                WorkoutRow(workout: workout)
                    .tag(workout)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowBackground(Color.clear)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation {
                            if selectedWorkout?.id == workout.id {
                                selectedWorkout = nil
                            } else {
                                selectedWorkout = workout
                            }
                        }
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            withAnimation {
                                workoutStore.delete(workout)
                                if selectedWorkout?.id == workout.id {
                                    selectedWorkout = nil
                                }
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            workoutStore.toggleCompletion(workout)
                        } label: {
                            Label(
                                workout.isCompleted ? "Undo" : "Complete",
                                systemImage: workout.isCompleted ? "arrow.uturn.backward" : "checkmark"
                            )
                        }
                        .tint(workout.isCompleted ? .orange : .green)
                    }
            }
            .listStyle(.plain)
            // ✅ FIXED: Custom search with no duplicate icon
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search workouts..."
            )
            // ✅ HIDE the search icon in navigation bar
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    // Empty view to hide the search icon
                    EmptyView()
                }
            }
            .overlay {
                if filteredWorkouts.isEmpty {
                    ContentUnavailableView(
                        "No Workouts Found",
                        systemImage: "figure.run",
                        description: Text("Add your first workout to get started!")
                    )
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingFilters.toggle()
                } label: {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                        Text("Filters")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            FilterView(isPresented: $showingFilters)
                .environmentObject(workoutStore)
        }
    }
}

// MARK: - Enhanced Quick Stat
struct EnhancedQuickStat: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.headline.bold())
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Filter View
struct FilterView: View {
    @EnvironmentObject var workoutStore: WorkoutStore
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Category Picker
                Section("Category") {
                    Picker("Filter by Category", selection: $workoutStore.selectedCategory) {
                        Text("All Categories").tag(nil as WorkoutCategory?)
                        ForEach(WorkoutCategory.allCases) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category as WorkoutCategory?)
                        }
                    }
                }
                
                // MARK: - Intensity Picker
                Section("Intensity") {
                    Picker("Filter by Intensity", selection: $workoutStore.selectedIntensity) {
                        Text("All Intensities").tag(nil as Intensity?)
                        ForEach(Intensity.allCases) { intensity in
                            HStack {
                                Text(intensity.rawValue)
                                Text(intensity.emoji)
                            }
                            .tag(intensity as Intensity?)
                        }
                    }
                }
                
                // MARK: - Toggle
                Section {
                    Toggle("Show Completed Only", isOn: $workoutStore.showCompletedOnly)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Clear button
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") {
                        withAnimation {
                            workoutStore.selectedCategory = nil
                            workoutStore.selectedIntensity = nil
                            workoutStore.showCompletedOnly = false
                        }
                    }
                }
                // Done button
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        isPresented = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
