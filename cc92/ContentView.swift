//
//  ContentView.swift
//  Neon Jump
//
//  Created by IGOR on 17/11/2025.
//

import SwiftUI
import Charts
import Foundation

struct ContentView: View {
    
    @State private var selectedTab = 0

    
    @State var isFetched: Bool = false
    
    @AppStorage("isBlock") var isBlock: Bool = true
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                
                Color(hex: "050505")
                    .ignoresSafeArea()
                
                if isFetched == false {
                    
                    ProgressView()
                    
                } else if isFetched == true {
                    
                    if isBlock == true {
                        
                        VStack(spacing: 0) {
                            // Top Navigation Bar
                            HStack {
                                Spacer()
                                
                                Text(tabTitle)
                                    .font(.system(size: 24, weight: .black))
                                    .foregroundColor(Color(hex: "F9FF14"))
                                
                                Spacer()
                                
                                NavigationLink(destination: SettingsView()) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(Color(hex: "F9FF14"))
                                        .frame(width: 44, height: 44)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 10)
                            
                            // Content
                            TabView(selection: $selectedTab) {
                                ImprovedHomeTabView(selectedTab: $selectedTab)
                                    .tag(0)
                                
                                GamesTabView()
                                    .tag(1)
                                
                                ProgressTabView()
                                    .tag(2)
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            
                            // Custom Tab Bar
                            HStack(spacing: 0) {
                                TabButton(
                                    icon: "house.fill",
                                    title: "Home",
                                    isSelected: selectedTab == 0,
                                    action: { selectedTab = 0 }
                                )
                                
                                TabButton(
                                    icon: "gamecontroller.fill",
                                    title: "Games",
                                    isSelected: selectedTab == 1,
                                    action: { selectedTab = 1 }
                                )
                                
                                TabButton(
                                    icon: "chart.line.uptrend.xyaxis.circle.fill",
                                    title: "Progress",
                                    isSelected: selectedTab == 2,
                                    action: { selectedTab = 2 }
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                            .padding(.top, 10)
                            .background(Color(hex: "050505"))
                        }
                        
                    } else if isBlock == false {
                        
                        WebSystem()
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                
                makeServerRequest()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())

    }
    
    var tabTitle: String {
        switch selectedTab {
        case 0: return "HOME"
        case 1: return "GAMES"
        case 2: return "PROGRESS"
        default: return "HOME"
        }
    }
    
    private func makeServerRequest() {
        
        let dataManager = DataManagers()
        
        guard let url = URL(string: dataManager.server) else {
            self.isBlock = false
            self.isFetched = true
            return
        }
        
        print("🚀 Making request to: \(url.absoluteString)")
        print("🏠 Host: \(url.host ?? "unknown")")
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 5.0
        
        // Добавляем заголовки для имитации браузера
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1", forHTTPHeaderField: "User-Agent")
        request.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("ru-RU,ru;q=0.9,en;q=0.8", forHTTPHeaderField: "Accept-Language")
        request.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")
        
        print("📤 Request Headers: \(request.allHTTPHeaderFields ?? [:])")
        
        // Создаем URLSession без автоматических редиректов
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: RedirectHandler(), delegateQueue: nil)
        
        session.dataTask(with: request) { data, response, error in
            
            DispatchQueue.main.async {
                
                // Если есть любая ошибка (включая SSL) - блокируем
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    print("Server unavailable, showing block")
                    self.isBlock = true
                    self.isFetched = true
                    return
                }
                
                // Если получили ответ от сервера
                if let httpResponse = response as? HTTPURLResponse {
                    
                    print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                    print("📋 Response Headers: \(httpResponse.allHeaderFields)")
                    
                    // Логируем тело ответа для диагностики
                    if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                        print("📄 Response Body: \(responseBody.prefix(500))") // Первые 500 символов
                    }
                    
                    if httpResponse.statusCode == 200 {
                        // Проверяем, есть ли контент в ответе
                        let contentLength = httpResponse.value(forHTTPHeaderField: "Content-Length") ?? "0"
                        let hasContent = data?.count ?? 0 > 0
                        
                        if contentLength == "0" || !hasContent {
                            // Пустой ответ = "do nothing" от Keitaro
                            print("🚫 Empty response (do nothing): Showing block")
                            self.isBlock = true
                            self.isFetched = true
                        } else {
                            // Есть контент = успех
                            print("✅ Success with content: Showing WebView")
                            self.isBlock = false
                            self.isFetched = true
                        }
                        
                    } else if httpResponse.statusCode >= 300 && httpResponse.statusCode < 400 {
                        // Редиректы = успех (есть оффер)
                        print("✅ Redirect (code \(httpResponse.statusCode)): Showing WebView")
                        self.isBlock = false
                        self.isFetched = true
                        
                    } else {
                        // 404, 403, 500 и т.д. - блокируем
                        print("🚫 Error code \(httpResponse.statusCode): Showing block")
                        self.isBlock = true
                        self.isFetched = true
                    }
                    
                } else {
                    
                    // Нет HTTP ответа - блокируем
                    print("❌ No HTTP response: Showing block")
                    self.isBlock = true
                    self.isFetched = true
                }
            }
            
        }.resume()
    }
}

// MARK: - Games Tab
struct GamesTabView: View {
    @State private var showingNeonJump = false
    @State private var showingNeonDodge = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Jump Game Card
                GameCard(
                    title: "Jump",
                    description: "Tap and hold to charge your jump. Release to soar!",
                    icon: "arrow.up.circle.fill",
                    color: Color(hex: "F9FF14"),
                    action: { showingNeonJump = true }
                )
                
                // Dodge Game Card
                GameCard(
                    title: "Dodge",
                    description: "Drag to move. Avoid obstacles and collect stars!",
                    icon: "arrow.left.arrow.right.circle.fill",
                    color: Color.red.opacity(0.8),
                    action: { showingNeonDodge = true }
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 30)
            .padding(.bottom, 40)
        }
        .fullScreenCover(isPresented: $showingNeonJump) {
            GameBoardView()
        }
        .fullScreenCover(isPresented: $showingNeonDodge) {
            NeonDodgeView()
        }
    }
}

struct GameCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.2))
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: icon)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(color)
                    }
                    
                    Spacer()
                    
                    // Play Button
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(color)
                }
                
                // Title
                Text(title)
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
                
                // Description
                Text(description)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .lineSpacing(4)
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(color.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(color: color.opacity(0.2), radius: 10, x: 0, y: 5)
        }
    }
}

// MARK: - Home Tab
struct HomeTabView: View {
    @StateObject private var viewModel = GameViewModel()
    @Binding var selectedTab: Int
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Neon Circle Animation
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .stroke(Color(hex: "F9FF14").opacity(0.3 - Double(index) * 0.1), lineWidth: 3)
                        .frame(width: 120 + CGFloat(index) * 40, height: 120 + CGFloat(index) * 40)
                }
                
                Circle()
                    .fill(Color(hex: "F9FF14"))
                    .frame(width: 120, height: 120)
                    .shadow(color: Color(hex: "F9FF14").opacity(0.6), radius: 20, x: 0, y: 0)
                
                Image(systemName: "bolt.fill")
                    .font(.system(size: 50, weight: .bold))
                    .foregroundColor(Color(hex: "050505"))
            }
            
            // High Score Display
            VStack(spacing: 12) {
                Text("Your High Score")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("\(viewModel.player.highScore)")
                    .font(.system(size: 56, weight: .black))
                    .foregroundColor(Color(hex: "F9FF14"))
            }
            .padding(.vertical, 20)
            
            // Quick Stats
            HStack(spacing: 30) {
                QuickStatView(icon: "gamecontroller.fill", title: "Games", value: "\(viewModel.player.gamesPlayed)")
                
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1, height: 50)
                
                QuickStatView(icon: "arrow.up.circle.fill", title: "Jumps", value: "\(viewModel.player.totalJumps)")
                
                Rectangle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 1, height: 50)
                
                QuickStatView(icon: "star.fill", title: "Power-ups", value: "\(viewModel.player.powerUpsCollected)")
            }
            .padding()
            
            Spacer()
            
            // Play Button
            Button(action: {
                selectedTab = 1
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 24, weight: .bold))
                    
                    Text("Play Games")
                        .font(.system(size: 22, weight: .bold))
                }
                .foregroundColor(Color(hex: "050505"))
                .frame(maxWidth: .infinity)
                .frame(height: 64)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "F9FF14"))
                        .shadow(color: Color(hex: "F9FF14").opacity(0.5), radius: 20, x: 0, y: 8)
                )
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .onAppear {
            // Refresh stats when view appears
            viewModel.player = GameDataService.shared.loadPlayerData()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("GameDataReset"))) { _ in
            viewModel.player = GameDataService.shared.loadPlayerData()
        }
    }
}

// MARK: - Leaderboard Tab
struct LeaderboardTabView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            if viewModel.leaderboard.isEmpty {
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 60, weight: .bold))
                        .foregroundColor(Color(hex: "F9FF14").opacity(0.5))
                    
                    Text("No Scores Yet")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Start playing to see your scores here!")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        // Top 3 Podium
                        if viewModel.leaderboard.count >= 1 {
                            PodiumView(entries: Array(viewModel.leaderboard.prefix(3)))
                                .padding(.vertical, 20)
                        }
                        
                        // All Scores List
                        VStack(spacing: 12) {
                            ForEach(Array(viewModel.leaderboard.enumerated()), id: \.element.id) { index, entry in
                                LeaderboardRow(
                                    rank: index + 1,
                                    entry: entry,
                                    isTopThree: index < 3
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Chart (iOS 16+)
                        if #available(iOS 16.0, *), viewModel.leaderboard.count > 1 {
                            leaderboardChart
                                .padding(.top, 30)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            viewModel.loadLeaderboard()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("GameDataReset"))) { _ in
            viewModel.loadLeaderboard()
        }
    }
    
    @available(iOS 16.0, *)
    var leaderboardChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Score Progression")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
            
            Chart(Array(viewModel.leaderboard.prefix(10).enumerated()), id: \.element.id) { index, entry in
                LineMark(
                    x: .value("Game", index + 1),
                    y: .value("Score", entry.score)
                )
                .foregroundStyle(Color(hex: "F9FF14"))
                .lineStyle(StrokeStyle(lineWidth: 3))
                
                PointMark(
                    x: .value("Game", index + 1),
                    y: .value("Score", entry.score)
                )
                .foregroundStyle(Color(hex: "F9FF14"))
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
        }
    }
}

// MARK: - Supporting Views
struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(isSelected ? Color(hex: "F9FF14") : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

struct QuickStatView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "F9FF14"))
            
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

struct PodiumView: View {
    let entries: [LeaderboardEntry]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            // 2nd Place
            if entries.count > 1 {
                PodiumPlace(entry: entries[1], rank: 2, height: 100)
            }
            
            // 1st Place
            if entries.count > 0 {
                PodiumPlace(entry: entries[0], rank: 1, height: 140)
            }
            
            // 3rd Place
            if entries.count > 2 {
                PodiumPlace(entry: entries[2], rank: 3, height: 80)
            }
        }
        .padding(.horizontal, 20)
    }
}

struct PodiumPlace: View {
    let entry: LeaderboardEntry
    let rank: Int
    let height: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            // Trophy
            ZStack {
                Circle()
                    .fill(rankColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(rankColor)
            }
            
            // Score
            Text("\(entry.score)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            // Pedestal
            VStack {
                Spacer()
                
                Text("\(rank)")
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(Color(hex: "050505"))
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(rankColor)
            )
        }
    }
    
    var rankColor: Color {
        switch rank {
        case 1: return Color(hex: "F9FF14")
        case 2: return Color.gray
        case 3: return Color.orange.opacity(0.7)
        default: return Color.white
        }
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let entry: LeaderboardEntry
    let isTopThree: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank
            Text("\(rank)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(isTopThree ? Color(hex: "F9FF14") : .white.opacity(0.6))
                .frame(width: 30)
            
            // Icon
            Image(systemName: isTopThree ? "star.fill" : "circle.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isTopThree ? Color(hex: "F9FF14") : .white.opacity(0.3))
            
            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.score) points")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                Text("\(entry.jumps) jumps • \(formattedDate(entry.date))")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isTopThree ? Color(hex: "F9FF14").opacity(0.1) : Color.white.opacity(0.05))
        )
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Leaderboard ViewModel
import Combine

class LeaderboardViewModel: ObservableObject {
    @Published var leaderboard: [LeaderboardEntry] = []
    
    private let dataService = GameDataService.shared
    
    init() {
        loadLeaderboard()
    }
    
    func loadLeaderboard() {
        leaderboard = dataService.loadLeaderboard()
    }
}
