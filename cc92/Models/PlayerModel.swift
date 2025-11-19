//
//  PlayerModel.swift
//  Neon Jump
//
//  Created by IGOR on 17/11/2025.
//

import Foundation

struct PlayerModel: Codable {
    var highScore: Int
    var totalJumps: Int
    var gamesPlayed: Int
    var powerUpsCollected: Int
    var currentScore: Int
    var level: Int
    var experience: Int
    var unlockedAchievements: [String]
    var dailyChallengeCompleted: Bool
    var lastChallengeDate: Date?
    var bestStreak: Int
    var currentStreak: Int
    
    init() {
        self.highScore = 0
        self.totalJumps = 0
        self.gamesPlayed = 0
        self.powerUpsCollected = 0
        self.currentScore = 0
        self.level = 1
        self.experience = 0
        self.unlockedAchievements = []
        self.dailyChallengeCompleted = false
        self.lastChallengeDate = nil
        self.bestStreak = 0
        self.currentStreak = 0
    }
    
    var experienceForNextLevel: Int {
        return level * 100
    }
    
    var progressToNextLevel: Double {
        return Double(experience) / Double(experienceForNextLevel)
    }
}

struct Achievement: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let requirement: Int
    var isUnlocked: Bool
    var progress: Int
    
    var progressPercentage: Double {
        return min(Double(progress) / Double(requirement), 1.0)
    }
}

struct DailyChallenge: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let requirement: Int
    let reward: Int
    let icon: String
}

enum GameDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    case extreme = "Extreme"
    
    var multiplier: Double {
        switch self {
        case .easy: return 0.5
        case .normal: return 1.0
        case .hard: return 1.5
        case .extreme: return 2.0
        }
    }
    
    var color: String {
        switch self {
        case .easy: return "00FF00"
        case .normal: return "F9FF14"
        case .hard: return "FF6B00"
        case .extreme: return "FF0000"
        }
    }
    
    var icon: String {
        switch self {
        case .easy: return "leaf.fill"
        case .normal: return "flame.fill"
        case .hard: return "bolt.fill"
        case .extreme: return "exclamationmark.triangle.fill"
        }
    }
}

struct PowerUp: Identifiable {
    let id = UUID()
    var position: CGPoint
    var type: PowerUpType
    var isCollected: Bool = false
    
    enum PowerUpType: CaseIterable {
        case doublePoints
        case shield
        case slowMotion
        
        var icon: String {
            switch self {
            case .doublePoints: return "star.fill"
            case .shield: return "shield.fill"
            case .slowMotion: return "clock.fill"
            }
        }
    }
}

struct Platform: Identifiable {
    let id = UUID()
    var position: CGPoint
    var width: CGFloat
    var isActive: Bool = true
}

struct LeaderboardEntry: Identifiable, Codable {
    let id: UUID
    let score: Int
    let date: Date
    let jumps: Int
    let difficulty: GameDifficulty
    
    init(score: Int, jumps: Int, difficulty: GameDifficulty = .normal) {
        self.id = UUID()
        self.score = score
        self.date = Date()
        self.jumps = jumps
        self.difficulty = difficulty
    }
}

