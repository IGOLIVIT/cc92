//
//  GameDataService.swift
//  Neon Jump
//
//  Created by IGOR on 17/11/2025.
//

import Foundation

class GameDataService {
    static let shared = GameDataService()
    
    private let playerKey = "playerData"
    private let leaderboardKey = "leaderboardData"
    private let achievementsKey = "achievementsData"
    
    private init() {}
    
    // MARK: - Achievements
    func getAchievements() -> [Achievement] {
        return [
            Achievement(id: "first_game", title: "First Steps", description: "Play your first game", icon: "star.fill", requirement: 1, isUnlocked: false, progress: 0),
            Achievement(id: "score_100", title: "Century", description: "Score 100 points", icon: "100.circle.fill", requirement: 100, isUnlocked: false, progress: 0),
            Achievement(id: "score_500", title: "Half Way", description: "Score 500 points", icon: "500.circle.fill", requirement: 500, isUnlocked: false, progress: 0),
            Achievement(id: "score_1000", title: "Champion", description: "Score 1000 points", icon: "trophy.fill", requirement: 1000, isUnlocked: false, progress: 0),
            Achievement(id: "games_10", title: "Getting Started", description: "Play 10 games", icon: "gamecontroller.fill", requirement: 10, isUnlocked: false, progress: 0),
            Achievement(id: "games_50", title: "Dedicated", description: "Play 50 games", icon: "flame.fill", requirement: 50, isUnlocked: false, progress: 0),
            Achievement(id: "games_100", title: "Addicted", description: "Play 100 games", icon: "bolt.fill", requirement: 100, isUnlocked: false, progress: 0),
            Achievement(id: "jumps_100", title: "Jumper", description: "Make 100 jumps", icon: "arrow.up.circle.fill", requirement: 100, isUnlocked: false, progress: 0),
            Achievement(id: "jumps_500", title: "Leap Master", description: "Make 500 jumps", icon: "arrow.up.square.fill", requirement: 500, isUnlocked: false, progress: 0),
            Achievement(id: "jumps_1000", title: "Sky Walker", description: "Make 1000 jumps", icon: "cloud.fill", requirement: 1000, isUnlocked: false, progress: 0),
            Achievement(id: "powerups_10", title: "Collector", description: "Collect 10 power-ups", icon: "star.circle.fill", requirement: 10, isUnlocked: false, progress: 0),
            Achievement(id: "powerups_50", title: "Hoarder", description: "Collect 50 power-ups", icon: "sparkles", requirement: 50, isUnlocked: false, progress: 0),
            Achievement(id: "streak_3", title: "On Fire", description: "3 day streak", icon: "flame.circle.fill", requirement: 3, isUnlocked: false, progress: 0),
            Achievement(id: "streak_7", title: "Dedicated", description: "7 day streak", icon: "calendar.circle.fill", requirement: 7, isUnlocked: false, progress: 0),
            Achievement(id: "level_5", title: "Rising Star", description: "Reach level 5", icon: "arrow.up.right.circle.fill", requirement: 5, isUnlocked: false, progress: 0),
            Achievement(id: "level_10", title: "Pro Player", description: "Reach level 10", icon: "crown.fill", requirement: 10, isUnlocked: false, progress: 0)
        ]
    }
    
    func loadAchievements(player: PlayerModel) -> [Achievement] {
        var achievements = getAchievements()
        
        // Update progress
        for index in achievements.indices {
            let achievement = achievements[index]
            
            switch achievement.id {
            case "first_game":
                achievements[index].progress = player.gamesPlayed
            case "score_100", "score_500", "score_1000":
                achievements[index].progress = player.highScore
            case "games_10", "games_50", "games_100":
                achievements[index].progress = player.gamesPlayed
            case "jumps_100", "jumps_500", "jumps_1000":
                achievements[index].progress = player.totalJumps
            case "powerups_10", "powerups_50":
                achievements[index].progress = player.powerUpsCollected
            case "streak_3", "streak_7":
                achievements[index].progress = player.bestStreak
            case "level_5", "level_10":
                achievements[index].progress = player.level
            default:
                break
            }
            
            achievements[index].isUnlocked = player.unlockedAchievements.contains(achievement.id) || achievements[index].progress >= achievement.requirement
        }
        
        return achievements
    }
    
    func getDailyChallenge() -> DailyChallenge {
        let challenges = [
            DailyChallenge(title: "Score Master", description: "Score 200 points in one game", requirement: 200, reward: 50, icon: "target"),
            DailyChallenge(title: "Jump Champion", description: "Make 50 jumps in one game", requirement: 50, reward: 30, icon: "arrow.up.circle.fill"),
            DailyChallenge(title: "Power Hunter", description: "Collect 5 power-ups in one game", requirement: 5, reward: 40, icon: "star.fill"),
            DailyChallenge(title: "Survivor", description: "Survive 60 seconds in Dodge", requirement: 60, reward: 35, icon: "clock.fill"),
            DailyChallenge(title: "Perfectionist", description: "Complete a game with 100+ score", requirement: 100, reward: 25, icon: "checkmark.circle.fill")
        ]
        
        let dayIndex = Calendar.current.ordinality(of: .day, in: .era, for: Date())!
        return challenges[dayIndex % challenges.count]
    }
    
    // MARK: - Player Data
    func savePlayerData(_ player: PlayerModel) {
        if let encoded = try? JSONEncoder().encode(player) {
            UserDefaults.standard.set(encoded, forKey: playerKey)
        }
    }
    
    func loadPlayerData() -> PlayerModel {
        if let data = UserDefaults.standard.data(forKey: playerKey),
           let player = try? JSONDecoder().decode(PlayerModel.self, from: data) {
            return player
        }
        return PlayerModel()
    }
    
    // MARK: - Leaderboard
    func saveLeaderboardEntry(_ entry: LeaderboardEntry) {
        var entries = loadLeaderboard()
        entries.append(entry)
        entries.sort { $0.score > $1.score }
        entries = Array(entries.prefix(10)) // Keep top 10
        
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: leaderboardKey)
        }
    }
    
    func loadLeaderboard() -> [LeaderboardEntry] {
        if let data = UserDefaults.standard.data(forKey: leaderboardKey),
           let entries = try? JSONDecoder().decode([LeaderboardEntry].self, from: data) {
            return entries
        }
        return []
    }
    
    // MARK: - Reset
    func resetAllData() {
        UserDefaults.standard.removeObject(forKey: playerKey)
        UserDefaults.standard.removeObject(forKey: leaderboardKey)
    }
}

