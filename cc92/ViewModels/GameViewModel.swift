//
//  GameViewModel.swift
//  Neon Jump
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var player: PlayerModel
    @Published var platforms: [Platform] = []
    @Published var powerUps: [PowerUp] = []
    @Published var playerPosition: CGPoint = .zero
    @Published var isGameActive = false
    @Published var currentScore = 0
    @Published var jumpCount = 0
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var activePowerUp: PowerUp.PowerUpType?
    @Published var powerUpTimeRemaining: Double = 0
    
    var selectedDifficulty: GameDifficulty = .normal
    private var gameTimer: Timer?
    private var powerUpTimer: Timer?
    private let dataService = GameDataService.shared
    
    var velocity: CGFloat = 0
    var isHolding = false
    var holdStartTime: Date?
    
    init() {
        self.player = dataService.loadPlayerData()
        self.leaderboard = dataService.loadLeaderboard()
    }
    
    func startGame(screenSize: CGSize) {
        isGameActive = true
        currentScore = 0
        jumpCount = 0
        velocity = 0
        playerPosition = CGPoint(x: screenSize.width / 2, y: screenSize.height - 150)
        activePowerUp = nil
        powerUpTimeRemaining = 0
        
        setupPlatforms(screenSize: screenSize)
        startGameLoop()
    }
    
    func pauseGame() {
        gameTimer?.invalidate()
        powerUpTimer?.invalidate()
    }
    
    func resumeGame() {
        startGameLoop()
        if activePowerUp != nil {
            startPowerUpTimer()
        }
    }
    
    func endGame() {
        isGameActive = false
        gameTimer?.invalidate()
        powerUpTimer?.invalidate()
        
        // Update player stats
        player.gamesPlayed += 1
        player.totalJumps += jumpCount
        if currentScore > player.highScore {
            player.highScore = currentScore
        }
        
        // Save data
        dataService.savePlayerData(player)
        
        // Add to leaderboard
        let entry = LeaderboardEntry(score: currentScore, jumps: jumpCount, difficulty: selectedDifficulty)
        dataService.saveLeaderboardEntry(entry)
        leaderboard = dataService.loadLeaderboard()
    }
    
    func startHold() {
        guard isGameActive else { return }
        isHolding = true
        holdStartTime = Date()
    }
    
    func releaseHold() {
        guard isGameActive, isHolding else { return }
        isHolding = false
        
        if let startTime = holdStartTime {
            let holdDuration = Date().timeIntervalSince(startTime)
            let jumpPower = min(holdDuration * 800, 1200) // Max jump power
            velocity = -CGFloat(jumpPower)
            jumpCount += 1
        }
        holdStartTime = nil
    }
    
    func collectPowerUp(_ powerUp: PowerUp) {
        guard !powerUp.isCollected else { return }
        
        if let index = powerUps.firstIndex(where: { $0.id == powerUp.id }) {
            powerUps[index].isCollected = true
            activePowerUp = powerUp.type
            powerUpTimeRemaining = 5.0 // 5 seconds
            player.powerUpsCollected += 1
            
            startPowerUpTimer()
        }
    }
    
    private func startPowerUpTimer() {
        powerUpTimer?.invalidate()
        powerUpTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.powerUpTimeRemaining -= 0.1
            if self.powerUpTimeRemaining <= 0 {
                self.activePowerUp = nil
                self.powerUpTimer?.invalidate()
            }
        }
    }
    
    private func setupPlatforms(screenSize: CGSize) {
        platforms.removeAll()
        powerUps.removeAll()
        
        let platformCount = 8
        let verticalSpacing = screenSize.height / CGFloat(platformCount)
        
        for i in 0..<platformCount {
            let y = screenSize.height - CGFloat(i) * verticalSpacing
            let x = CGFloat.random(in: 50...(screenSize.width - 150))
            let width = CGFloat.random(in: 80...140)
            
            platforms.append(Platform(position: CGPoint(x: x, y: y), width: width))
            
            // Add power-ups randomly
            if Bool.random() && i > 2 {
                let powerUpX = x + width / 2
                let powerUpY = y - 40
                let type = PowerUp.PowerUpType.allCases.randomElement()!
                powerUps.append(PowerUp(position: CGPoint(x: powerUpX, y: powerUpY), type: type))
            }
        }
    }
    
    private func startGameLoop() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
    }
    
    private func updateGame() {
        guard isGameActive else { return }
        
        // Apply gravity
        let gravity: CGFloat = activePowerUp == .slowMotion ? 20 : 35
        velocity += gravity
        playerPosition.y += velocity * 0.016
        
        // Check platform collisions
        if velocity > 0 { // Only when falling
            for platform in platforms where platform.isActive {
                let platformRect = CGRect(x: platform.position.x, y: platform.position.y - 5,
                                        width: platform.width, height: 10)
                let playerRect = CGRect(x: playerPosition.x - 15, y: playerPosition.y - 15,
                                      width: 30, height: 30)
                
                if playerRect.intersects(platformRect) && playerPosition.y <= platform.position.y {
                    velocity = -600 // Bounce
                    jumpCount += 1
                    
                    let basePoints = activePowerUp == .doublePoints ? 20 : 10
                    let points = Int(Double(basePoints) * selectedDifficulty.multiplier)
                    currentScore += points
                }
            }
        }
        
        // Check power-up collisions
        for powerUp in powerUps where !powerUp.isCollected {
            let distance = hypot(playerPosition.x - powerUp.position.x,
                               playerPosition.y - powerUp.position.y)
            if distance < 30 {
                collectPowerUp(powerUp)
            }
        }
        
        // Game over if player falls off screen
        if playerPosition.y > UIScreen.main.bounds.height + 100 {
            endGame()
        }
    }
    
    func resetGameData() {
        dataService.resetAllData()
        player = PlayerModel()
        leaderboard = []
    }
}

