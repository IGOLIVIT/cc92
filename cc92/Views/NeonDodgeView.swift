//
//  NeonDodgeView.swift
//  Neon Jump
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI
import Charts

struct NeonDodgeView: View {
    @StateObject private var viewModel = NeonDodgeViewModel()
    @State private var screenSize: CGSize = .zero
    @State private var showingGameOver = false
    @State private var isPaused = false
    @State private var showingPauseMenu = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "050505")
                .ignoresSafeArea()
            
            if viewModel.isGameActive {
                gameView
            } else if showingGameOver {
                gameOverView
            } else {
                startView
            }
            
            // Pause Menu Overlay
            if showingPauseMenu && viewModel.isGameActive {
                pauseMenuOverlay
            }
        }
        .onAppear {
            screenSize = UIScreen.main.bounds.size
        }
        .onChange(of: viewModel.isGameActive) { newValue in
            if !newValue && viewModel.currentScore > 0 {
                showingGameOver = true
                isPaused = false
                showingPauseMenu = false
            }
        }
    }
    
    // MARK: - Start View
    var startView: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Top padding
                Color.clear.frame(height: 40)
                
                // Title removed for App Store compliance
                
                // High Score
                VStack(spacing: 8) {
                    Text("High Score")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("\(viewModel.player.highScore)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(Color(hex: "F9FF14"))
                }
                .padding(.vertical, 20)
                
                // Instructions
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.left.arrow.right")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "F9FF14"))
                        
                        Text("Drag to move left & right")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "square.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.red.opacity(0.8))
                        
                        Text("Avoid the falling obstacles")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 40)
                
                // Extra spacing
                Color.clear.frame(height: 20)
                
                // Play Button
                Button(action: {
                    showingGameOver = false
                    viewModel.startGame(screenSize: screenSize)
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 24, weight: .bold))
                        Text("Start Game")
                            .font(.system(size: 20, weight: .bold))
                    }
                    .foregroundColor(Color(hex: "050505"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "F9FF14"))
                            .shadow(color: Color(hex: "F9FF14").opacity(0.5), radius: 15, x: 0, y: 5)
                    )
                }
                .padding(.horizontal, 32)
                
                // Back Button
                Button(action: {
                    dismiss()
                }) {
                    Text("Back to Menu")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "F9FF14").opacity(0.7))
                        .frame(height: 44)
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Game View
    var gameView: some View {
        GeometryReader { geometry in
            ZStack {
                // Obstacles
                ForEach(viewModel.obstacles) { obstacle in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red.opacity(0.8))
                        .frame(width: obstacle.width, height: obstacle.height)
                        .position(obstacle.position)
                        .shadow(color: .red.opacity(0.6), radius: 8, x: 0, y: 0)
                }
                
                // Collectibles
                ForEach(viewModel.collectibles) { collectible in
                    if !collectible.isCollected {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "F9FF14").opacity(0.3))
                                .frame(width: 30, height: 30)
                            
                            Image(systemName: "star.fill")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "F9FF14"))
                        }
                        .position(collectible.position)
                        .shadow(color: Color(hex: "F9FF14").opacity(0.6), radius: 8, x: 0, y: 0)
                    }
                }
                
                // Player
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "F9FF14"))
                    .frame(width: 40, height: 40)
                    .position(viewModel.playerPosition)
                    .shadow(color: Color(hex: "F9FF14").opacity(0.8), radius: 10, x: 0, y: 0)
                
                // HUD
                VStack {
                    HStack {
                        // Score
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SCORE")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white.opacity(0.7))
                            Text("\(viewModel.currentScore)")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "F9FF14"))
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.5))
                        )
                        
                        Spacer()
                        
                        // Pause Button
                        Button(action: {
                            viewModel.pauseGame()
                            isPaused = true
                            showingPauseMenu = true
                        }) {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(Color(hex: "F9FF14"))
                                .frame(width: 44, height: 44)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.5))
                                )
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if !isPaused {
                            viewModel.updatePlayerPosition(x: value.location.x, screenWidth: geometry.size.width)
                        }
                    }
            )
        }
    }
    
    // MARK: - Pause Menu
    var pauseMenuOverlay: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Top padding
                    Color.clear.frame(height: 100)
                    
                    Text("PAUSED")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(Color(hex: "F9FF14"))
                    
                    VStack(spacing: 16) {
                        // Resume Button
                        Button(action: {
                            showingPauseMenu = false
                            isPaused = false
                            viewModel.resumeGame()
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 20, weight: .bold))
                                Text("Resume")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(Color(hex: "050505"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "F9FF14"))
                            )
                        }
                        
                        // Restart Button
                        Button(action: {
                            showingPauseMenu = false
                            isPaused = false
                            viewModel.startGame(screenSize: screenSize)
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 20, weight: .bold))
                                Text("Restart")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.1))
                            )
                        }
                        
                        // Quit Button
                        Button(action: {
                            viewModel.endGame()
                            showingPauseMenu = false
                            isPaused = false
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 20, weight: .bold))
                                Text("Quit")
                                    .font(.system(size: 18, weight: .bold))
                            }
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.red.opacity(0.1))
                            )
                        }
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    // MARK: - Game Over View
    var gameOverView: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Top padding
                Color.clear.frame(height: 40)
                
                VStack(spacing: 8) {
                    Text("GAME OVER")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(Color(hex: "F9FF14"))
                    
                    if viewModel.currentScore > viewModel.player.highScore - viewModel.currentScore {
                        Text("New High Score!")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color(hex: "F9FF14").opacity(0.8))
                    }
                }
                
                VStack(spacing: 20) {
                    StatRow(title: "Score", value: "\(viewModel.currentScore)")
                    StatRow(title: "Survived", value: "\(Int(viewModel.survivalTime))s")
                    StatRow(title: "High Score", value: "\(viewModel.player.highScore)")
                }
                .padding(.vertical, 30)
                
                VStack(spacing: 16) {
                    Button(action: {
                        showingGameOver = false
                        viewModel.startGame(screenSize: screenSize)
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 20, weight: .bold))
                            Text("Play Again")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(Color(hex: "050505"))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "F9FF14"))
                                .shadow(color: Color(hex: "F9FF14").opacity(0.5), radius: 15, x: 0, y: 5)
                        )
                    }
                    
                    Button(action: {
                        showingGameOver = false
                        dismiss()
                    }) {
                        Text("Back to Menu")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "F9FF14").opacity(0.7))
                            .frame(height: 44)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Neon Dodge Models
struct Obstacle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var width: CGFloat
    var height: CGFloat
    var speed: CGFloat
}

struct Collectible: Identifiable {
    let id = UUID()
    var position: CGPoint
    var isCollected: Bool = false
}

// MARK: - Neon Dodge ViewModel
import Combine

class NeonDodgeViewModel: ObservableObject {
    @Published var player: PlayerModel
    @Published var obstacles: [Obstacle] = []
    @Published var collectibles: [Collectible] = []
    @Published var playerPosition: CGPoint = .zero
    @Published var isGameActive = false
    @Published var currentScore = 0
    @Published var survivalTime: Double = 0
    
    private var gameTimer: Timer?
    private var spawnTimer: Timer?
    private var scoreTimer: Timer?
    private var startTime: Date?
    private let dataService = GameDataService.shared
    
    init() {
        self.player = dataService.loadPlayerData()
    }
    
    func startGame(screenSize: CGSize) {
        isGameActive = true
        currentScore = 0
        survivalTime = 0
        obstacles.removeAll()
        collectibles.removeAll()
        playerPosition = CGPoint(x: screenSize.width / 2, y: screenSize.height - 100)
        startTime = Date()
        
        startGameLoop()
        startSpawnTimer(screenSize: screenSize)
        startScoreTimer()
    }
    
    func pauseGame() {
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
        scoreTimer?.invalidate()
    }
    
    func resumeGame() {
        startGameLoop()
        startSpawnTimer(screenSize: UIScreen.main.bounds.size)
        startScoreTimer()
    }
    
    func endGame() {
        isGameActive = false
        gameTimer?.invalidate()
        spawnTimer?.invalidate()
        scoreTimer?.invalidate()
        
        player.gamesPlayed += 1
        if currentScore > player.highScore {
            player.highScore = currentScore
        }
        
        dataService.savePlayerData(player)
    }
    
    func updatePlayerPosition(x: CGFloat, screenWidth: CGFloat) {
        let clampedX = max(20, min(screenWidth - 20, x))
        playerPosition.x = clampedX
    }
    
    private func startGameLoop() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { [weak self] _ in
            self?.updateGame()
        }
    }
    
    private func startSpawnTimer(screenSize: CGSize) {
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.spawnObstacle(screenSize: screenSize)
            
            if Bool.random() && Bool.random() {
                self?.spawnCollectible(screenSize: screenSize)
            }
        }
    }
    
    private func startScoreTimer() {
        scoreTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.survivalTime = Date().timeIntervalSince(startTime)
        }
    }
    
    private func updateGame() {
        guard isGameActive else { return }
        
        // Move obstacles down
        for index in obstacles.indices {
            obstacles[index].position.y += obstacles[index].speed
        }
        
        // Move collectibles down
        for index in collectibles.indices {
            if !collectibles[index].isCollected {
                collectibles[index].position.y += 3
            }
        }
        
        // Remove off-screen obstacles
        obstacles.removeAll { $0.position.y > UIScreen.main.bounds.height + 50 }
        collectibles.removeAll { $0.position.y > UIScreen.main.bounds.height + 50 }
        
        // Check collisions
        checkCollisions()
    }
    
    private func checkCollisions() {
        let playerRect = CGRect(x: playerPosition.x - 20, y: playerPosition.y - 20, width: 40, height: 40)
        
        // Check obstacle collisions
        for obstacle in obstacles {
            let obstacleRect = CGRect(x: obstacle.position.x - obstacle.width / 2,
                                     y: obstacle.position.y - obstacle.height / 2,
                                     width: obstacle.width,
                                     height: obstacle.height)
            
            if playerRect.intersects(obstacleRect) {
                endGame()
                return
            }
        }
        
        // Check collectible collisions
        for index in collectibles.indices {
            if !collectibles[index].isCollected {
                let distance = hypot(playerPosition.x - collectibles[index].position.x,
                                   playerPosition.y - collectibles[index].position.y)
                if distance < 35 {
                    collectibles[index].isCollected = true
                    currentScore += 50
                }
            }
        }
    }
    
    private func spawnObstacle(screenSize: CGSize) {
        let width = CGFloat.random(in: 60...120)
        let x = CGFloat.random(in: width / 2...(screenSize.width - width / 2))
        let speed = CGFloat.random(in: 4...8)
        
        let obstacle = Obstacle(
            position: CGPoint(x: x, y: -30),
            width: width,
            height: 30,
            speed: speed
        )
        
        obstacles.append(obstacle)
        currentScore += 1
    }
    
    private func spawnCollectible(screenSize: CGSize) {
        let x = CGFloat.random(in: 30...(screenSize.width - 30))
        let collectible = Collectible(position: CGPoint(x: x, y: -30))
        collectibles.append(collectible)
    }
}

