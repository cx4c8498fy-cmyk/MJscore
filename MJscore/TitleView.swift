//
//  TitleView.swift
//  MJscore
//
//  Created by Codex on 2025/12/20.
//

import SwiftUI

struct TitleView: View {
    @StateObject private var coordinator = NavigationCoordinator()
    @StateObject private var highScoreStore = HighScoreStore()
    @StateObject private var appSettings = AppSettings()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.98, green: 0.94, blue: 0.86), Color(red: 0.92, green: 0.88, blue: 0.80)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 28) {
                    Text("麻雀点数\nトレーニング")
                        .font(.system(size: 36, weight: .bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color(red: 0.28, green: 0.18, blue: 0.1))

                    Button {
                        coordinator.path.append(.home)
                    } label: {
                        Text("スタート")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: 240)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.76, green: 0.33, blue: 0.2))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(radius: 6, y: 3)
                    }
                }
                .padding(.horizontal, 24)
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .home:
                    ContentView()
                case .selection:
                    PracticeSelectionView()
                case .options:
                    OptionView()
                case .practice(let type, let difficulty):
                    let menu = PracticeMenu.allMenus.first(where: { $0.type == type })
                        ?? PracticeMenu(type: type, isUnlocked: true)
                    PracticeView(menu: menu, difficulty: difficulty)
                }
            }
        }
        .environmentObject(coordinator)
        .environmentObject(highScoreStore)
        .environmentObject(appSettings)
        .onAppear {
            SoundPlayer.shared.playMenuBGM(named: appSettings.selectedMenuBGM.rawValue)
        }
        .onChange(of: appSettings.selectedMenuBGM) { _, value in
            SoundPlayer.shared.playMenuBGM(named: value.rawValue)
        }
    }
}

#Preview {
    TitleView()
}
