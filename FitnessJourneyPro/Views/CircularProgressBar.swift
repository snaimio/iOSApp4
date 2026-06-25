//  ==================================================
//  CircularProgressBar.swift
//  FitnessJourneyPro

//  Created by [Your Name] on 2026-06-23.

//  Circular progress ring with gradient
//  Topics: Trim, Stroke, AngularGradient, Animations
//  ==================================================

import SwiftUI

// MARK: - CircularProgressBar
/// Circular progress ring with gradient and percentage label
/// Uses trim to create a circular progress effect with animated transitions
struct CircularProgressBar: View {
    
    // MARK: - Properties
    /// Progress value from 0.0 to 1.0
    var progress: Double
    
    /// Size of the circle
    var size: CGFloat = 120
    
    /// Line width of the progress ring
    var lineWidth: CGFloat = 12
    
    /// Colors for the gradient
    var gradientColors: [Color] = [.blue, .purple, .pink]
    
    /// Background ring color
    var backgroundColor: Color = Color.gray.opacity(0.2)
    
    /// Whether to show the percentage label
    var showLabel: Bool = true
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // MARK: - Background Circle
            /// Static background circle behind the progress ring
            Circle()
                .stroke(
                    backgroundColor,
                    lineWidth: lineWidth
                )
            
            // MARK: - Progress Circle (Animated)
            /// Progress ring that animates when the value changes
            /// Uses trim to control the filled portion of the circle
            Circle()
                .trim(from: 0, to: min(progress, 1.0))
                .stroke(
                    AngularGradient(
                        colors: gradientColors,
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90)) // Start from top (12 o'clock)
                .animation(.easeInOut(duration: 0.8), value: progress)
            
            // MARK: - Percentage Label
            /// Displays the progress percentage in the center
            if showLabel {
                Text("\(Int(progress * 100))%")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Preview
#Preview {
    HStack(spacing: 30) {
        CircularProgressBar(progress: 0.25, size: 100)
        CircularProgressBar(progress: 0.50, size: 100, gradientColors: [.green, .mint])
        CircularProgressBar(progress: 0.75, size: 100, gradientColors: [.orange, .red])
        CircularProgressBar(progress: 1.0, size: 100, gradientColors: [.green, .blue])
    }
    .padding()
}
