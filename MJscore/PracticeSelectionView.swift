//
//  PracticeSelectionView.swift
//  MJscore
//
//  Created by Codex on 2025/12/20.
//

import SwiftUI

struct PracticeSelectionView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @EnvironmentObject private var highScoreStore: HighScoreStore
    @EnvironmentObject private var appSettings: AppSettings
    @State private var showingInfo = false
    @State private var selectedDifficulty: PracticeDifficulty = .easy

    private let menus = PracticeMenu.allMenus
    private let easyColor = Color(red: 0.32, green: 0.58, blue: 0.42)
    private let hardColor = Color(red: 0.6, green: 0.18, blue: 0.28)

    var body: some View {
        ZStack {
            Color(red: 0.97, green: 0.94, blue: 0.88)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    DifficultyToggleView(
                        selected: $selectedDifficulty,
                        accentColor: themeColor
                    )
                        .padding(.bottom, 4)

                    ForEach(menus) { menu in
                        let isUnlocked = menu.type.isUnlocked(using: highScoreStore, difficulty: selectedDifficulty)
                        let score = highScoreStore.highScore(for: menu.type, difficulty: selectedDifficulty)
                        let total = menu.type.questionCount(for: selectedDifficulty)
                        let isPerfect = score >= total && total > 0
                        Button {
                            SoundPlayer.shared.playClick()
                            coordinator.path.append(.practice(menu.type, selectedDifficulty))
                        } label: {
                            PracticeMenuButton(
                                title: menu.name,
                                scoreText: "\(score)/\(total)",
                                locked: !isUnlocked,
                                isPerfect: isPerfect,
                                color: themeColor
                            )
                        }
                        .disabled(!isUnlocked)
                        .opacity(isUnlocked ? 1 : 0.45)
                        .brightness(isUnlocked ? 0 : -0.12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
        }
        .safeAreaInset(edge: .bottom) {
            BannerAdView()
                .frame(height: 50)
                .padding(.bottom, 4)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    SoundPlayer.shared.playClick()
                    coordinator.path = [.home]
                } label: {
                    Image(systemName: "house")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    SoundPlayer.shared.playClick()
                    showingInfo = true
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .sheet(isPresented: $showingInfo) {
            PracticeInfoView()
        }
        .onAppear {
            SoundPlayer.shared.playMenuBGM(named: appSettings.selectedMenuBGM.rawValue)
        }
        .onChange(of: appSettings.selectedMenuBGM) { _, value in
            SoundPlayer.shared.playMenuBGM(named: value.rawValue)
        }
    }

    private var themeColor: Color {
        selectedDifficulty == .easy ? easyColor : hardColor
    }
}

private struct PracticeMenuButton: View {
    let title: String
    let scoreText: String
    let locked: Bool
    let isPerfect: Bool
    let color: Color

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            Spacer()
            Text(scoreText)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white.opacity(0.85))
            if locked {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isPerfect ? Color(red: 0.88, green: 0.72, blue: 0.22) : Color.clear, lineWidth: 2)
        )
        .shadow(radius: isPerfect ? 6 : 3, y: 2)
        .overlay(alignment: .topTrailing) {
            if isPerfect {
                Image(systemName: "crown.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(red: 0.9, green: 0.75, blue: 0.25))
                    .padding(.trailing, 12)
                    .padding(.top, 8)
            }
        }
    }
}

private struct DifficultyToggleView: View {
    @Binding var selected: PracticeDifficulty
    let accentColor: Color

    var body: some View {
        HStack(spacing: 12) {
            DifficultyButton(title: "易", isSelected: selected == .easy, accentColor: accentColor) {
                selected = .easy
            }
            DifficultyButton(title: "難", isSelected: selected == .hard, accentColor: accentColor) {
                selected = .hard
            }
        }
        .padding(8)
        .background(Color(red: 0.9, green: 0.85, blue: 0.78))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct DifficultyButton: View {
    let title: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(isSelected ? .white : Color(red: 0.35, green: 0.25, blue: 0.18))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(isSelected ? accentColor : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

private struct PracticeInfoView: View {
    var body: some View {
        NavigationStack {
            List {
                Text("喰い下がり：あり")
                Text("切り上げ満貫：あり")
                Text("数え役満：あり")
                Text("連風牌（東東など）：2符")
                Text("平和ツモの符：20符固定")
            }
            .navigationTitle("インフォメーション")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationStack {
        PracticeSelectionView()
            .environmentObject(NavigationCoordinator())
            .environmentObject(HighScoreStore())
    }
}
