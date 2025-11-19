//
//  ImprovedContentView.swift
//  Neon Jump
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI
import Charts

// MARK: - Improved Home Tab
struct ImprovedHomeTabView: View {
    @StateObject private var viewModel = GameViewModel()
    @Binding var selectedTab: Int
    @State private var showLevelUp = false
    
    var dailyChallenge = GameDataService.shared.getDailyChallenge()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Player Level Card
                PlayerLevelCard(player: viewModel.player)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                // Daily Challenge
                DailyChallengeCard(challenge: dailyChallenge)
                    .padding(.horizontal, 20)
                
                // Quick Play Buttons
                VStack(spacing: 16) {
                    Text("QUICK PLAY")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                    
                    HStack(spacing: 12) {
                        QuickPlayButton(
                            title: "Jump",
                            icon: "arrow.up.circle.fill",
                            color: Color(hex: "F9FF14"),
                            action: { selectedTab = 1 }
                        )
                        
                        QuickPlayButton(
                            title: "Dodge",
                            icon: "arrow.left.arrow.right.circle.fill",
                            color: Color.red.opacity(0.8),
                            action: { selectedTab = 1 }
                        )
                    }
                    .padding(.horizontal, 20)
                }
                
                // Recent Achievements
                RecentAchievementsSection(player: viewModel.player)
                    .padding(.horizontal, 20)
                
                // Stats Grid
                StatsGrid(player: viewModel.player)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            viewModel.player = GameDataService.shared.loadPlayerData()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("GameDataReset"))) { _ in
            viewModel.player = GameDataService.shared.loadPlayerData()
        }
    }
}

struct PlayerLevelCard: View {
    let player: PlayerModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Level Badge
            HStack {
                ZStack {
                    Circle()
                        .fill(Color(hex: "F9FF14").opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    VStack(spacing: 2) {
                        Text("LVL")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Color(hex: "F9FF14"))
                        Text("\(player.level)")
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(Color(hex: "F9FF14"))
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Level \(player.level) Player")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("\(player.experience) / \(player.experienceForNextLevel) XP")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                // High Score
                VStack(alignment: .trailing, spacing: 4) {
                    Text("HIGH SCORE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                    Text("\(player.highScore)")
                        .font(.system(size: 24, weight: .black))
                        .foregroundColor(Color(hex: "F9FF14"))
                }
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "F9FF14"), Color(hex: "F9FF14").opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(player.progressToNextLevel), height: 12)
                }
            }
            .frame(height: 12)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(hex: "F9FF14").opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color(hex: "F9FF14").opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

struct DailyChallengeCard: View {
    let challenge: DailyChallenge
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: "F9FF14").opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: challenge.icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "F9FF14"))
            }
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("DAILY CHALLENGE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(Color(hex: "F9FF14"))
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                        Text("+\(challenge.reward) XP")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(Color(hex: "F9FF14"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(hex: "F9FF14").opacity(0.2))
                    )
                }
                
                Text(challenge.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text(challenge.description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "F9FF14").opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct QuickPlayButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(color)
                }
                
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
}

struct RecentAchievementsSection: View {
    let player: PlayerModel
    
    var achievements: [Achievement] {
        let all = GameDataService.shared.loadAchievements(player: player)
        return Array(all.filter { !$0.isUnlocked && $0.progress > 0 }.sorted { $0.progressPercentage > $1.progressPercentage }.prefix(3))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("IN PROGRESS")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
            
            if achievements.isEmpty {
                Text("Complete games to unlock achievements!")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(achievements) { achievement in
                    AchievementProgressRow(achievement: achievement)
                }
            }
        }
    }
}

struct AchievementProgressRow: View {
    let achievement: Achievement
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "F9FF14"))
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "F9FF14").opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(hex: "F9FF14"))
                                .frame(width: geometry.size.width * CGFloat(achievement.progressPercentage), height: 6)
                        }
                    }
                    .frame(height: 6)
                    
                    Text("\(achievement.progress)/\(achievement.requirement)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                        .frame(width: 50, alignment: .trailing)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct StatsGrid: View {
    let player: PlayerModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("YOUR STATS")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(icon: "gamecontroller.fill", title: "Games", value: "\(player.gamesPlayed)", color: "F9FF14")
                StatCard(icon: "arrow.up.circle.fill", title: "Jumps", value: "\(player.totalJumps)", color: "00FF00")
                StatCard(icon: "star.fill", title: "Power-ups", value: "\(player.powerUpsCollected)", color: "FF6B00")
                StatCard(icon: "flame.fill", title: "Streak", value: "\(player.bestStreak)", color: "FF0000")
            }
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color(hex: color))
            
            Text(value)
                .font(.system(size: 22, weight: .black))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: color).opacity(0.3), lineWidth: 1)
                )
        )
    }
}

