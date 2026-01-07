//
//  ContentView.swift
//  MJscore
//
//  Created by 久世晃暢 on 2025/12/20.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @EnvironmentObject private var highScoreStore: HighScoreStore
    @EnvironmentObject private var appSettings: AppSettings

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("麻雀点数計算\nトレーニング")
                .font(.system(size: 32, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color(red: 0.23, green: 0.16, blue: 0.1))

            VStack(spacing: 16) {
                Button {
                    SoundPlayer.shared.playClick()
                    coordinator.path.append(.selection)
                } label: {
                    HomeButtonLabel(title: "練習モード", color: Color(red: 0.3, green: 0.55, blue: 0.45))
                }

                Button {
                    SoundPlayer.shared.playClick()
                    coordinator.path.append(.options)
                } label: {
                    HomeButtonLabel(title: "オプション", color: Color(red: 0.56, green: 0.42, blue: 0.32))
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.98, green: 0.95, blue: 0.9))
        .safeAreaInset(edge: .bottom) {
            BannerAdView()
                .frame(height: 50)
                .padding(.bottom, 4)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            SoundPlayer.shared.playMenuBGM(named: appSettings.selectedMenuBGM.rawValue)
        }
        .onChange(of: appSettings.selectedMenuBGM) { _, value in
            SoundPlayer.shared.playMenuBGM(named: value.rawValue)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(NavigationCoordinator())
        .environmentObject(HighScoreStore())
}

private struct HomeButtonLabel: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(radius: 4, y: 3)
    }
}
