//
//  OptionView.swift
//  MJscore
//
//  Created by Codex on 2025/12/20.
//

import SwiftUI

struct OptionView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @EnvironmentObject private var highScoreStore: HighScoreStore
    @EnvironmentObject private var appSettings: AppSettings
    @State private var showingResetAlert = false

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.95, blue: 0.9)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                HStack {
                    Button {
                        SoundPlayer.shared.playClick()
                        coordinator.path = [.home]
                    } label: {
                        Image(systemName: "house")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color(red: 0.23, green: 0.16, blue: 0.1))
                    }
                    Spacer()
                    Text("オプション")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(Color(red: 0.23, green: 0.16, blue: 0.1))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)

                VStack(spacing: 16) {
                    Toggle(isOn: $appSettings.isPracticeBGMEnabled) {
                        Text("練習中BGM")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Color(red: 0.23, green: 0.16, blue: 0.1))
                    }
                    .toggleStyle(SwitchToggleStyle(tint: Color(red: 0.32, green: 0.58, blue: 0.42)))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 24)

                    MenuBGMSelector()

                    VStack(spacing: 16) {
                        Text("ハイスコア管理")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color(red: 0.3, green: 0.2, blue: 0.12))

                        Button {
                            SoundPlayer.shared.playClick()
                            showingResetAlert = true
                        } label: {
                            Text("ハイスコアを全てリセット")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(red: 0.6, green: 0.22, blue: 0.22))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .shadow(radius: 4, y: 2)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(.horizontal, 24)
                }

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("本当に削除しますか？", isPresented: $showingResetAlert) {
            Button("削除する", role: .destructive) {
                highScoreStore.resetAll()
            }
            Button("キャンセル", role: .cancel) {}
        }
    }
}

private struct MenuBGMSelector: View {
    @EnvironmentObject private var appSettings: AppSettings
    @EnvironmentObject private var highScoreStore: HighScoreStore

    private var isBGM2Unlocked: Bool {
        PracticeMenuType.comprehensive.isUnlocked(using: highScoreStore, difficulty: .easy)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("BGM選択")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(red: 0.3, green: 0.2, blue: 0.12))

            HStack(spacing: 12) {
                BGMChoiceButton(
                    title: MenuBGM.bgm1.displayName,
                    selected: appSettings.selectedMenuBGM == .bgm1,
                    locked: false
                ) {
                    appSettings.selectedMenuBGM = .bgm1
                    SoundPlayer.shared.playMenuBGM(named: MenuBGM.bgm1.rawValue)
                }

                BGMChoiceButton(
                    title: MenuBGM.bgm2.displayName,
                    selected: appSettings.selectedMenuBGM == .bgm2,
                    locked: !isBGM2Unlocked
                ) {
                    appSettings.selectedMenuBGM = .bgm2
                    SoundPlayer.shared.playMenuBGM(named: MenuBGM.bgm2.rawValue)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 24)
    }
}

private struct BGMChoiceButton: View {
    let title: String
    let selected: Bool
    let locked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                if locked {
                    Image(systemName: "lock.fill")
                }
            }
            .foregroundStyle(selected ? .white : Color(red: 0.35, green: 0.25, blue: 0.18))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(selected ? Color(red: 0.32, green: 0.48, blue: 0.38) : Color(red: 0.9, green: 0.86, blue: 0.8))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(locked ? 0.5 : 1)
        }
        .disabled(locked)
    }
}

#Preview {
    NavigationStack {
        OptionView()
            .environmentObject(NavigationCoordinator())
            .environmentObject(HighScoreStore())
            .environmentObject(AppSettings())
    }
}
