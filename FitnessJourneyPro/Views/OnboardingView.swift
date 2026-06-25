//  ======================================================================
//  OnboardingView.swift
//  FitnessJourneyPro

//  Created by Sheikh Naim on 2026-06-24.

//  Professional Onboarding flow for new users
//  Features: Glassmorphism, Parallax, Animated Gradients, Professional UI
//  ======================================================================

import SwiftUI

// MARK: - OnboardingView
/// Main onboarding flow view displayed to new users
/// Features animated backgrounds, glassmorphism effects, and page navigation
struct OnboardingView: View {
    
    // MARK: - Properties
    /// Stores whether the user has seen the onboarding flow
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    /// Current page index
    @State private var currentPage = 0
    
    /// Controls various animations throughout the onboarding
    @State private var isAnimating = false
    
    /// Tracks drag gesture offset for parallax effect
    @State private var dragOffset: CGFloat = 0
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // MARK: - Animated Background
            AnimatedBackground()
            
            VStack(spacing: 0) {
                // MARK: - Top Bar with Skip
                HStack {
                    // Brand Logo
                    HStack(spacing: 8) {
                        Image(systemName: "figure.run")
                            .font(.title2)
                            .foregroundStyle(.blue)
                        Text("Fitness Journey")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    // Skip Button with Glass Effect
                    Button("Skip") {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            hasSeenOnboarding = true
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 10)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // MARK: - Main Content
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        ForEach(Array(OnboardingItem.professionalItems.enumerated()), id: \.offset) { index, item in
                            ProfessionalOnboardingPage(
                                item: item,
                                isLast: index == OnboardingItem.professionalItems.count - 1,
                                onGetStarted: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                        hasSeenOnboarding = true
                                    }
                                },
                                geometry: geometry
                            )
                            .frame(width: geometry.size.width)
                            .offset(x: -CGFloat(currentPage) * geometry.size.width + dragOffset)
                            .animation(.interpolatingSpring(stiffness: 100, damping: 20), value: currentPage)
                        }
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                dragOffset = value.translation.width
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                if value.translation.width < -threshold && currentPage < OnboardingItem.professionalItems.count - 1 {
                                    withAnimation {
                                        currentPage += 1
                                    }
                                } else if value.translation.width > threshold && currentPage > 0 {
                                    withAnimation {
                                        currentPage -= 1
                                    }
                                }
                                withAnimation {
                                    dragOffset = 0
                                }
                            }
                    )
                }
                .frame(height: UIScreen.main.bounds.height * 0.75)
                
                // MARK: - Bottom Controls
                VStack(spacing: 20) {
                    // Page Control with Professional Dots
                    HStack(spacing: 12) {
                        ForEach(0..<OnboardingItem.professionalItems.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPage == index ? Color.blue : Color.white.opacity(0.3))
                                .frame(width: currentPage == index ? 32 : 8, height: 8)
                                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    
                    // Next/Get Started Button
                    Button(action: {
                        if currentPage < OnboardingItem.professionalItems.count - 1 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                hasSeenOnboarding = true
                            }
                        }
                    }) {
                        HStack {
                            Text(currentPage == OnboardingItem.professionalItems.count - 1 ? "Get Started" : "Continue")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Image(systemName: currentPage == OnboardingItem.professionalItems.count - 1 ? "checkmark.circle.fill" : "arrow.right.circle.fill")
                                .font(.title3)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        )
                        .shadow(color: .blue.opacity(0.3), radius: 20, y: 10)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Animated Background
/// Dynamic animated background with floating gradient orbs
struct AnimatedBackground: View {
    @State private var animate = false
    
    var body: some View {
        ZStack {
            // Base Gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color(red: 0.05, green: 0.1, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated Orbs
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 300, height: 300)
                .position(x: animate ? UIScreen.main.bounds.width * 0.8 : UIScreen.main.bounds.width * 0.2, y: animate ? UIScreen.main.bounds.height * 0.2 : UIScreen.main.bounds.height * 0.8)
                .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animate)
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.2), .pink.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 250, height: 250)
                .position(x: animate ? UIScreen.main.bounds.width * 0.2 : UIScreen.main.bounds.width * 0.7, y: animate ? UIScreen.main.bounds.height * 0.7 : UIScreen.main.bounds.height * 0.3)
                .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animate)
            
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.pink.opacity(0.15), .orange.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 200, height: 200)
                .position(x: animate ? UIScreen.main.bounds.width * 0.5 : UIScreen.main.bounds.width * 0.9, y: animate ? UIScreen.main.bounds.height * 0.5 : UIScreen.main.bounds.height * 0.1)
                .animation(.easeInOut(duration: 12).repeatForever(autoreverses: true), value: animate)
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Professional Onboarding Page
/// Individual onboarding page with glassmorphism effects and animations
struct ProfessionalOnboardingPage: View {
    let item: OnboardingItem
    let isLast: Bool
    let onGetStarted: () -> Void
    let geometry: GeometryProxy
    
    @State private var isAnimating = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // MARK: - 3D Floating Icon
            ZStack {
                // Glass Background
                RoundedRectangle(cornerRadius: 40)
                    .fill(.ultraThinMaterial)
                    .frame(width: 200, height: 200)
                    .shadow(color: .black.opacity(0.2), radius: 30)
                    .overlay(
                        RoundedRectangle(cornerRadius: 40)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .scaleEffect(scale)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2), value: scale)
                
                // Icon with Gradient
                Image(systemName: item.imageName)
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [item.accentColor, item.accentColor.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(scale * 1.1)
                    .animation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3), value: scale)
            }
            .padding(.bottom, 40)
            
            // MARK: - Title with Gradient
            Text(item.title)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.8)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: .black.opacity(0.1), radius: 10)
                .padding(.horizontal, 30)
                .opacity(opacity)
                .animation(.easeOut(duration: 0.6).delay(0.3), value: opacity)
            
            // MARK: - Description
            Text(item.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal, 40)
                .padding(.top, 12)
                .opacity(opacity)
                .animation(.easeOut(duration: 0.6).delay(0.5), value: opacity)
            
            // MARK: - Feature Tags (Professional Touch)
            if !isLast {
                HStack(spacing: 12) {
                    ForEach(0..<3) { _ in
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .frame(width: 60, height: 6)
                            .opacity(0.5)
                    }
                }
                .padding(.top, 30)
                .opacity(opacity)
                .animation(.easeOut(duration: 0.6).delay(0.7), value: opacity)
            }
            
            Spacer()
            Spacer()
        }
        .padding()
        .onAppear {
            scale = 1.0
            opacity = 1.0
        }
        .onDisappear {
            scale = 0.8
            opacity = 0
        }
    }
}

// MARK: - Professional Onboarding Item
/// Provides professional onboarding content with modern design
extension OnboardingItem {
    static let professionalItems: [OnboardingItem] = [
        OnboardingItem(
            title: "Transform Your Fitness Journey",
            description: "Track workouts, monitor progress, and achieve your goals with AI-powered insights.",
            imageName: "figure.run.circle.fill",
            accentColor: .blue
        ),
        OnboardingItem(
            title: "Smart Workout Tracking",
            description: "Log any workout with intelligent categorization and real-time statistics.",
            imageName: "list.clipboard.fill",
            accentColor: .green
        ),
        OnboardingItem(
            title: "Visual Progress Analytics",
            description: "Beautiful charts and insights to visualize your fitness transformation.",
            imageName: "chart.bar.xaxis",
            accentColor: .purple
        ),
        OnboardingItem(
            title: "Never Miss a Workout",
            description: "Smart reminders and notifications keep you consistent and motivated.",
            imageName: "bell.badge.fill",
            accentColor: .orange
        )
    ]
}

// MARK: - Preview
#Preview {
    OnboardingView()
}
