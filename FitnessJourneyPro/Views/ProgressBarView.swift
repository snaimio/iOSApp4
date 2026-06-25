//  ===========================================================
//  ProgressBarView.swift
//  FitnessJourneyPro

//  Created by [Your Name] on 2026-06-23.

//  Linear progress bar with gradient fill
//  Topics: GeometryReader, Animations, Gradients, Custom Views
//  ===========================================================

import SwiftUI

// MARK: - ProgressBar
/// Linear progress bar with gradient fill and percentage label
/// Uses GeometryReader for dynamic width calculation based on progress value
struct ProgressBar: View {
    
    // MARK: - Properties
    /// Progress value from 0.0 to 1.0
    var progress: Double
    
    /// Height of the progress bar
    var barHeight: CGFloat = 20
    
    /// Corner radius for rounded corners
    var cornerRadius: CGFloat = 10
    
    /// Colors for the gradient
    var gradientColors: [Color] = [.blue, .purple, .pink]
    
    /// Background color
    var backgroundColor: Color = Color.gray.opacity(0.3)
    
    /// Whether to show the percentage label
    var showLabel: Bool = true
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // MARK: - Background Track
                /// Static background bar that fills the entire width
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                
                // MARK: - Progress Fill (Animated)
                /// Animated progress fill that expands based on progress value
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: gradientColors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(min(progress, 1.0)))
                    .animation(.easeInOut(duration: 0.8), value: progress)
                
                // MARK: - Percentage Label
                /// Displays the progress percentage on top of the bar
                if showLabel {
                    Text("\(Int(progress * 100))%")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.leading, 12)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
            }
        }
        .frame(height: barHeight)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        ProgressBar(progress: 0.0)
            .frame(height: 20)
            .padding(.horizontal)
        
        ProgressBar(progress: 0.5, gradientColors: [.green, .mint])
            .frame(height: 20)
            .padding(.horizontal)
        
        ProgressBar(progress: 0.75, gradientColors: [.orange, .red])
            .frame(height: 20)
            .padding(.horizontal)
        
        ProgressBar(progress: 1.0, gradientColors: [.green, .blue])
            .frame(height: 20)
            .padding(.horizontal)
    }
    .padding()
}
