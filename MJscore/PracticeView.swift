//
//  PracticeView.swift
//  MJscore
//
//  Created by Codex on 2025/12/20.
//

import SwiftUI
import Combine
import UIKit

struct PracticeView: View {
    let menu: PracticeMenu

    @EnvironmentObject private var coordinator: NavigationCoordinator
    @EnvironmentObject private var highScoreStore: HighScoreStore
    @EnvironmentObject private var appSettings: AppSettings
    @StateObject private var manager: PracticeManager
    @State private var input = ""
    @State private var resultSymbol: String?
    @State private var reviewQuestion: PracticeQuestion?
    @State private var remainingTime = 10
    @State private var didSaveScore = false
    @State private var isTimerActive = true
    @State private var isCountdownActive = true
    @State private var countdownValue = 3
    @State private var countdownID = UUID()
    @State private var interstitialManager = InterstitialAdManager()
    @State private var didAttemptInterstitial = false
    @State private var didStartInitialCountdown = false
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(menu: PracticeMenu, difficulty: PracticeDifficulty) {
        self.menu = menu
        _manager = StateObject(wrappedValue: PracticeManager(menu: menu, difficulty: difficulty))
        let limit = difficulty == .hard ? 10 : 15
        _remainingTime = State(initialValue: limit)
    }

    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.93, blue: 0.86)
                .ignoresSafeArea()

            VStack(spacing: 12) {
                HStack {
                    Button {
                        coordinator.path = [.home]
                    } label: {
                        Image(systemName: "house")
                            .font(.system(size: 18, weight: .bold))
                    }

                    Spacer()

                    Text(menu.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(red: 0.22, green: 0.15, blue: 0.1))

                    Spacer()

                    TimerBadge(remainingTime: remainingTime)
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)

                if let question = manager.currentQuestion {
                    QuestionInfoView(
                        question: question,
                        index: manager.currentQuestionIndex + 1,
                        total: manager.totalQuestions,
                        difficulty: manager.difficulty
                    )
                        .padding(.horizontal, 20)

                    HandView(
                        hand: question.hand,
                        winningTileIndex: question.winningTileIndex,
                        highlightDora: manager.difficulty == .easy,
                        doraTiles: Set(actualDoraTiles(from: question.doraIndicators))
                    )
                        .padding(.horizontal, 20)
                } else {
                    Spacer()
                }

                InputDisplayView(text: input)
                    .padding(.horizontal, 20)

                KeypadView(
                    onInput: appendInput,
                    onDelete: deleteInput,
                    onClear: clearInput
                )
                .padding(.horizontal, 16)
                .disabled(isCountdownActive || manager.isFinished || reviewQuestion != nil)

                Button {
                    submitAnswer()
                } label: {
                    Text("回答")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(red: 0.2, green: 0.45, blue: 0.62))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .disabled(isCountdownActive || manager.isFinished || reviewQuestion != nil)
            }

            if let symbol = resultSymbol {
                ResultSymbolView(symbol: symbol)
            }

            if manager.isFinished {
                ResultOverlay(
                    result: manager.result(),
                    onRetry: {
                        input = ""
                        didSaveScore = false
                        reviewQuestion = nil
                        didAttemptInterstitial = false
                        manager.reset()
                        didStartInitialCountdown = true
                        startCountdown()
                    },
                    onBackToMenu: {
                        didSaveScore = false
                        reviewQuestion = nil
                        didAttemptInterstitial = false
                        coordinator.path = [.home, .selection]
                    }
                )
            }

            if let review = reviewQuestion {
                ReviewResultView(
                    question: review,
                    onNext: {
                        reviewQuestion = nil
                        manager.moveNext()
                    }
                )
            }

            if isCountdownActive {
                CountdownOverlay(value: countdownValue)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            SoundPlayer.shared.stopBGM()
            if appSettings.isPracticeBGMEnabled {
                SoundPlayer.shared.playPracticeBGM()
            } else {
                SoundPlayer.shared.stopPracticeBGM()
            }
            interstitialManager.load()
            if !didStartInitialCountdown && !manager.isFinished {
                didStartInitialCountdown = true
                startCountdown()
            }
        }
        .onReceive(timer) { _ in
            handleTimerTick()
        }
        .onChange(of: manager.currentQuestionIndex) { _, _ in
            remainingTime = timeLimit
            isTimerActive = true
            input = ""
        }
        .onChange(of: manager.isFinished) { _, finished in
            if finished && !didSaveScore {
                highScoreStore.updateHighScore(
                    for: menu.type,
                    difficulty: manager.difficulty,
                    score: manager.correctCount
                )
                didSaveScore = true
            }
            if finished && !didAttemptInterstitial {
                didAttemptInterstitial = true
                showInterstitialIfNeeded()
            }
        }
        .onChange(of: appSettings.isPracticeBGMEnabled) { _, enabled in
            if enabled {
                SoundPlayer.shared.playPracticeBGM()
            } else {
                SoundPlayer.shared.stopPracticeBGM()
            }
        }
        .onDisappear {
            SoundPlayer.shared.stopPracticeBGM()
        }
    }

    private func submitAnswer() {
        guard !isCountdownActive, !input.isEmpty, !manager.isFinished, let question = manager.currentQuestion else { return }
        isTimerActive = false
        let isCorrect = manager.checkAnswer(input)
        resultSymbol = isCorrect ? "○" : "×"
        input = ""

        if isCorrect {
            manager.markCorrect()
            SoundPlayer.shared.playCorrect()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                resultSymbol = nil
                manager.moveNext()
            }
        } else {
            handleIncorrect(question: question)
        }
    }

    private func handleTimerTick() {
        guard isTimerActive, !isCountdownActive, !manager.isFinished, reviewQuestion == nil, manager.currentQuestion != nil else { return }
        guard remainingTime > 0 else { return }
        remainingTime -= 1
        if remainingTime == 0, let question = manager.currentQuestion {
            resultSymbol = "×"
            input = ""
            isTimerActive = false
            handleIncorrect(question: question)
        }
    }

    private func handleIncorrect(question: PracticeQuestion) {
        SoundPlayer.shared.playWrong()
        reviewQuestion = question
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            resultSymbol = nil
        }
    }

    private var timeLimit: Int {
        manager.difficulty == .hard ? 10 : 15
    }

    private func startCountdown() {
        isCountdownActive = true
        isTimerActive = false
        countdownValue = 3
        remainingTime = timeLimit
        let id = UUID()
        countdownID = id
        tickCountdown(id: id)
    }

    private func tickCountdown(id: UUID) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard countdownID == id else { return }
            if countdownValue > 1 {
                countdownValue -= 1
                tickCountdown(id: id)
            } else {
                countdownValue = 0
                isCountdownActive = false
                isTimerActive = true
            }
        }
    }

    private func showInterstitialIfNeeded() {
        let shouldShow = Int.random(in: 0..<100) < 35
        guard shouldShow, let root = rootViewController() else { return }
        interstitialManager.show(from: root)
        interstitialManager.load()
    }

    private func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
    }

    private func appendInput(_ value: String) {
        if input.contains("all") {
            return
        }
        if value == "all" {
            if input.contains("/") {
                return
            }
            input += value
            return
        }
        if value == "/" {
            if input.contains("/") || input.contains("all") {
                return
            }
            input += value
            return
        }
        input += value
    }

    private func deleteInput() {
        guard !input.isEmpty else { return }
        input.removeLast()
    }

    private func clearInput() {
        input = ""
    }
}

private struct QuestionInfoView: View {
    let question: PracticeQuestion
    let index: Int
    let total: Int
    let difficulty: PracticeDifficulty

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(question.roundInfo)  問題\(index)/\(total)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 0.22, green: 0.15, blue: 0.1))
                Spacer()
                Text(question.isDealer ? "親" : "子")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 0.22, green: 0.15, blue: 0.1))
            }

            HStack(spacing: 10) {
                InfoChip(title: question.isRiichi ? "リーチあり" : "リーチなし")
                InfoChip(title: question.winType.rawValue)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top) {
                    Text("ドラ表示牌: \(question.doraIndicators.joined(separator: " "))")
                    if question.isRiichi {
                        Spacer()
                        Text("裏ドラ表示牌: \(question.uraDoraIndicators.joined(separator: " "))")
                    }
                }
                Text("役: \(question.yaku.joined(separator: " "))")
            }
            .font(.system(size: 14))
            .foregroundStyle(Color(red: 0.28, green: 0.2, blue: 0.14))
        }
        .padding(12)
        .background(Color(red: 0.99, green: 0.97, blue: 0.93))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct TimerBadge: View {
    let remainingTime: Int

    var body: some View {
        Text("\(remainingTime)")
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 32, height: 32)
            .background(remainingTime <= 3 ? Color(red: 0.7, green: 0.2, blue: 0.2) : Color(red: 0.3, green: 0.5, blue: 0.4))
            .clipShape(Circle())
    }
}

private struct CountdownOverlay: View {
    let value: Int

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
            Text("\(value)")
                .font(.system(size: 88, weight: .heavy))
                .foregroundStyle(.white)
        }
    }
}

private func actualDoraTiles(from indicators: [String]) -> [String] {
    indicators.map(actualDoraTile(from:))
}

private func actualDoraTile(from indicator: String) -> String {
    guard indicator.count >= 2 else { return indicator }
    let suit = indicator.suffix(1)
    let numberString = String(indicator.dropLast())
    guard let number = Int(numberString) else { return indicator }

    switch suit {
    case "m", "p", "s":
        let next = number == 9 ? 1 : number + 1
        return "\(next)\(suit)"
    case "z":
        switch number {
        case 1: return "2z"
        case 2: return "3z"
        case 3: return "4z"
        case 4: return "1z"
        case 5: return "6z"
        case 6: return "7z"
        case 7: return "5z"
        default: return indicator
        }
    default:
        return indicator
    }
}

private struct InfoChip: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(Color(red: 0.22, green: 0.15, blue: 0.1))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color(red: 0.85, green: 0.78, blue: 0.66))
            .clipShape(Capsule())
    }
}

private struct HandView: View {
    let hand: Hand
    let winningTileIndex: Int
    let highlightDora: Bool
    let doraTiles: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TileGroupFlowView(
                groups: displayGroups,
                winningTileIndex: winningTileIndex,
                highlightDora: highlightDora,
                doraTiles: doraTiles,
                tileSize: CGSize(width: 34, height: 42),
                tileSpacing: 0,
                groupSpacing: 8
            )
        }
        .padding(12)
        .background(Color(red: 0.99, green: 0.97, blue: 0.93))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var displayGroups: [TileGroup] {
        let closed = hand.groups.map { TileGroup(tiles: $0, style: .closed) }
        let opened = hand.openGroups.map { TileGroup(tiles: $0, style: .open) }
        let concealed = hand.concealedKans.map { TileGroup(tiles: $0, style: .concealed) }
        return closed + opened + concealed
    }
}

private struct InputDisplayView: View {
    let text: String

    var body: some View {
        HStack {
            Text(text.isEmpty ? "入力してください" : text)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(text.isEmpty ? Color.gray : Color.black)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct KeypadView: View {
    let onInput: (String) -> Void
    let onDelete: () -> Void
    let onClear: () -> Void

    private let keys: [[String]] = [
        ["7", "8", "9"],
        ["4", "5", "6"],
        ["1", "2", "3"],
        ["00", "0", "/"]
    ]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        KeypadButton(title: key) {
                            SoundPlayer.shared.playInput()
                            onInput(key)
                        }
                    }
                }
            }

            HStack(spacing: 10) {
                KeypadButton(title: "all", color: Color(red: 0.36, green: 0.5, blue: 0.6)) {
                    SoundPlayer.shared.playInput()
                    onInput("all")
                }
                KeypadButton(title: "消去", color: Color(red: 0.6, green: 0.38, blue: 0.26)) {
                    SoundPlayer.shared.playInput()
                    onDelete()
                }
                KeypadButton(title: "クリア", color: Color(red: 0.6, green: 0.2, blue: 0.2)) {
                    SoundPlayer.shared.playInput()
                    onClear()
                }
            }
        }
    }
}

private struct KeypadButton: View {
    let title: String
    var color: Color = Color(red: 0.36, green: 0.5, blue: 0.6)
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

private struct ResultSymbolView: View {
    let symbol: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
            Text(symbol)
                .font(.system(size: 96, weight: .heavy))
                .foregroundStyle(symbol == "○" ? Color.green : Color.red)
        }
        .transition(.opacity)
    }
}

private struct ResultOverlay: View {
    let result: PracticeResult
    let onRetry: () -> Void
    let onBackToMenu: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("成績")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(red: 0.22, green: 0.15, blue: 0.1))

                Text("\(result.totalQuestions)問中 \(result.correctCount)問 正解")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color(red: 0.22, green: 0.15, blue: 0.1))

                HStack(spacing: 12) {
                    Button(action: onRetry) {
                        Text("再挑戦")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.2, green: 0.52, blue: 0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    Button(action: onBackToMenu) {
                        Text("練習メニューに戻る")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.5, green: 0.35, blue: 0.22))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    NavigationStack {
        PracticeView(menu: PracticeMenu.allMenus[0], difficulty: .easy)
            .environmentObject(NavigationCoordinator())
            .environmentObject(HighScoreStore())
            .environmentObject(AppSettings())
    }
}
