//
//  ProgressView.swift
//  Neon Jump
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI
import Charts

struct ProgressTabView: View {
    @StateObject private var viewModel = ProgressViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Achievements Section
                AchievementsSection(achievements: viewModel.achievements)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                
                // Stats Overview with Chart
                if #available(iOS 16.0, *) {
                    StatsChartSection(entries: viewModel.recentGames)
                        .padding(.horizontal, 20)
                }
                
                // Recent Games
                RecentGamesSection(entries: viewModel.recentGames)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
        }
        .onAppear {
            viewModel.loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("GameDataReset"))) { _ in
            viewModel.loadData()
        }
    }
}

struct AchievementsSection: View {
    let achievements: [Achievement]
    
    var unlockedCount: Int {
        achievements.filter { $0.isUnlocked }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("ACHIEVEMENTS")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                
                Spacer()
                
                Text("\(unlockedCount)/\(achievements.count)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(hex: "F9FF14"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(hex: "F9FF14").opacity(0.2))
                    )
            }
            
            // Achievement Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(achievements.prefix(12)) { achievement in
                    AchievementBadge(achievement: achievement)
                }
            }
            
            if achievements.count > 12 {
                Text("+ \(achievements.count - 12) more achievements")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct AchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(achievement.isUnlocked ? Color(hex: "F9FF14").opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 50, height: 50)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(achievement.isUnlocked ? Color(hex: "F9FF14") : .white.opacity(0.3))
            }
            
            Text(achievement.title)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(achievement.isUnlocked ? .white : .white.opacity(0.4))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(achievement.isUnlocked ? Color(hex: "F9FF14").opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
    }
}

@available(iOS 16.0, *)
struct StatsChartSection: View {
    let entries: [LeaderboardEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SCORE HISTORY")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
            
            if entries.isEmpty {
                Text("No games played yet")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            } else {
                Chart(Array(entries.prefix(10).enumerated()), id: \.element.id) { index, entry in
                    LineMark(
                        x: .value("Game", index + 1),
                        y: .value("Score", entry.score)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "F9FF14"), Color(hex: "F9FF14").opacity(0.6)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    
                    AreaMark(
                        x: .value("Game", index + 1),
                        y: .value("Score", entry.score)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "F9FF14").opacity(0.3), Color(hex: "F9FF14").opacity(0.0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .frame(height: 150)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct RecentGamesSection: View {
    let entries: [LeaderboardEntry]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("RECENT GAMES")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
            
            if entries.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "gamecontroller")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("No games played yet")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("Start playing to see your progress!")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.4))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(Array(entries.prefix(10).enumerated()), id: \.element.id) { index, entry in
                    RecentGameRow(entry: entry, rank: index + 1)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct RecentGameRow: View {
    let entry: LeaderboardEntry
    let rank: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank
            Text("#\(rank)")
                .font(.system(size: 16, weight: .black))
                .foregroundColor(rank <= 3 ? Color(hex: "F9FF14") : .white.opacity(0.6))
                .frame(width: 35)
            
            // Difficulty Badge
            HStack(spacing: 6) {
                Image(systemName: entry.difficulty.icon)
                    .font(.system(size: 12, weight: .bold))
                Circle()
                    .frame(width: 4, height: 4)
            }
            .foregroundColor(Color(hex: entry.difficulty.color))
            
            // Score
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.score) pts")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text("\(entry.jumps) jumps")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text(formattedDate(entry.date))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            Spacer()
            
            // Difficulty label
            Text(entry.difficulty.rawValue)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(hex: entry.difficulty.color))
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color(hex: entry.difficulty.color).opacity(0.2))
                )
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(rank <= 3 ? Color(hex: "F9FF14").opacity(0.05) : Color.white.opacity(0.03))
        )
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - ViewModel
import Combine

class ProgressViewModel: ObservableObject {
    @Published var achievements: [Achievement] = []
    @Published var recentGames: [LeaderboardEntry] = []
    
    private let dataService = GameDataService.shared
    
    func loadData() {
        let player = dataService.loadPlayerData()
        achievements = dataService.loadAchievements(player: player)
        recentGames = dataService.loadLeaderboard()
    }
}

