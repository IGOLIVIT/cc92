//
//  GameBoardView.swift
//  Neon Jump
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI
import Charts

struct GameBoardView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var screenSize: CGSize = .zero
    @State private var showingGameOver = false
    @State private var isPaused = false
    @State private var showingPauseMenu = false
    @State private var showingDifficultySelect = false
    @State private var selectedDifficulty: GameDifficulty = .normal
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
            
            // Difficulty Select Overlay
            if showingDifficultySelect {
                difficultySelectOverlay
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
        VStack(spacing: 30) {
            Spacer()
            
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
            
            Spacer()
            
            // Play Button
            Button(action: {
                showingDifficultySelect = true
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
    
    // MARK: - Game View
    var gameView: some View {
        GeometryReader { geometry in
            ZStack {
                // Platforms
                ForEach(viewModel.platforms) { platform in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "F9FF14"))
                        .frame(width: platform.width, height: 10)
                        .position(platform.position)
                        .shadow(color: Color(hex: "F9FF14").opacity(0.6), radius: 8, x: 0, y: 0)
                }
                
                // Power-ups
                ForEach(viewModel.powerUps) { powerUp in
                    if !powerUp.isCollected {
                        PowerUpView(type: powerUp.type)
                            .position(powerUp.position)
                    }
                }
                
                // Player
                Circle()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)
                    .position(viewModel.playerPosition)
                    .shadow(color: .white.opacity(0.8), radius: 10, x: 0, y: 0)
                
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
                        
                        // Active Power-up
                        if let powerUp = viewModel.activePowerUp {
                            VStack(spacing: 4) {
                                Image(systemName: powerUpIcon(for: powerUp))
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(hex: "F9FF14"))
                                
                                Text(String(format: "%.1fs", viewModel.powerUpTimeRemaining))
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.5))
                            )
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Hold indicator
                    if viewModel.isHolding {
                        VStack {
                            Text("CHARGING...")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(Color(hex: "F9FF14"))
                            
                            ProgressView(value: min(Date().timeIntervalSince(viewModel.holdStartTime ?? Date()), 1.5), total: 1.5)
                                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: "F9FF14")))
                                .frame(width: 200)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.5))
                        )
                        .padding(.bottom, 100)
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !viewModel.isHolding && !isPaused {
                            viewModel.startHold()
                        }
                    }
                    .onEnded { _ in
                        if !isPaused {
                            viewModel.releaseHold()
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
            
            VStack(spacing: 30) {
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
            }
        }
    }
    
    // MARK: - Game Over View
    var gameOverView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Game Over Title
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
            
            // Stats
            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    Image(systemName: viewModel.selectedDifficulty.icon)
                        .font(.system(size: 16, weight: .bold))
                    Text(viewModel.selectedDifficulty.rawValue)
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundColor(Color(hex: viewModel.selectedDifficulty.color))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(hex: viewModel.selectedDifficulty.color).opacity(0.2))
                )
                
                StatRow(title: "Score", value: "\(viewModel.currentScore)")
                StatRow(title: "Jumps", value: "\(viewModel.jumpCount)")
                StatRow(title: "High Score", value: "\(viewModel.player.highScore)")
            }
            .padding(.vertical, 30)
            
            // Chart
            if #available(iOS 16.0, *) {
                chartView
                    .frame(height: 200)
                    .padding(.horizontal, 32)
            }
            
            Spacer()
            
            // Buttons
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
    
    // MARK: - Chart View (iOS 16+)
    @available(iOS 16.0, *)
    var chartView: some View {
        let entries = Array(viewModel.leaderboard.prefix(5))
        
        return VStack(alignment: .leading, spacing: 8) {
            Text("Recent Scores")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 32)
            
            if !entries.isEmpty {
                Chart(entries) { entry in
                    BarMark(
                        x: .value("Game", entry.date, unit: .minute),
                        y: .value("Score", entry.score)
                    )
                    .foregroundStyle(Color(hex: "F9FF14"))
                }
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisValueLabel()
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 32)
            }
        }
    }
    
    // Helper
    func powerUpIcon(for type: PowerUp.PowerUpType) -> String {
        switch type {
        case .doublePoints: return "star.fill"
        case .shield: return "shield.fill"
        case .slowMotion: return "clock.fill"
        }
    }
    
    // MARK: - Difficulty Select Overlay
    var difficultySelectOverlay: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 8) {
                    Text("SELECT DIFFICULTY")
                        .font(.system(size: 28, weight: .black))
                        .foregroundColor(Color(hex: "F9FF14"))
                    
                    Text("Choose your challenge level")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                VStack(spacing: 16) {
                    ForEach(GameDifficulty.allCases, id: \.self) { difficulty in
                        DifficultyButton(
                            difficulty: difficulty,
                            isSelected: selectedDifficulty == difficulty,
                            action: {
                                selectedDifficulty = difficulty
                            }
                        )
                    }
                }
                .padding(.horizontal, 32)
                
                // Start Button
                Button(action: {
                    showingDifficultySelect = false
                    showingGameOver = false
                    viewModel.selectedDifficulty = selectedDifficulty
                    viewModel.startGame(screenSize: screenSize)
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 20, weight: .bold))
                        Text("Start Game")
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
                .padding(.horizontal, 32)
                .padding(.top, 10)
                
                // Cancel Button
                Button(action: {
                    showingDifficultySelect = false
                }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(hex: "F9FF14").opacity(0.7))
                        .frame(height: 44)
                }
            }
        }
    }
}

struct DifficultyButton: View {
    let difficulty: GameDifficulty
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color(hex: difficulty.color).opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: difficulty.icon)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(Color(hex: difficulty.color))
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.rawValue)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("×\(String(format: "%.1f", difficulty.multiplier)) points")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "F9FF14"))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color(hex: difficulty.color).opacity(0.1) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color(hex: difficulty.color) : Color.white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                    )
            )
        }
    }
}

struct PowerUpView: View {
    let type: PowerUp.PowerUpType
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "F9FF14").opacity(0.3))
                .frame(width: 40, height: 40)
            
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "F9FF14"))
        }
        .shadow(color: Color(hex: "F9FF14").opacity(0.6), radius: 8, x: 0, y: 0)
    }
    
    var icon: String {
        switch type {
        case .doublePoints: return "star.fill"
        case .shield: return "shield.fill"
        case .slowMotion: return "clock.fill"
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(Color(hex: "F9FF14"))
        }
        .padding(.horizontal, 40)
    }
}

