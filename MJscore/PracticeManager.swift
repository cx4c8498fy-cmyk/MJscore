//
//  PracticeManager.swift
//  MJscore
//
//  Created by Codex on 2025/12/20.
//

import Foundation
import Combine

enum WinType: String, Codable {
    case ron = "ロン"
    case tsumo = "ツモ"
}

enum PracticeDifficulty: String, CaseIterable {
    case easy = "易"
    case hard = "難"
}

struct PracticeQuestion: Identifiable, Codable {
    let id = UUID()
    let roundInfo: String
    let isDealer: Bool
    let isRiichi: Bool
    let doraIndicators: [String]
    let uraDoraIndicators: [String]
    let winType: WinType
    let hand: Hand
    let winningTileIndex: Int
    let yaku: [String]
    let han: Int
    let fu: Int
    let correctAnswer: String

    private enum CodingKeys: String, CodingKey {
        case roundInfo
        case isDealer
        case isRiichi
        case doraIndicators
        case uraDoraIndicators
        case winType
        case hand
        case winningTileIndex
        case yaku
        case han
        case fu
        case correctAnswer
        case concealedKans
    }

    init(
        roundInfo: String,
        isDealer: Bool,
        isRiichi: Bool,
        doraIndicators: [String],
        uraDoraIndicators: [String],
        winType: WinType,
        hand: Hand,
        winningTileIndex: Int,
        yaku: [String],
        han: Int,
        fu: Int,
        correctAnswer: String
    ) {
        self.roundInfo = roundInfo
        self.isDealer = isDealer
        self.isRiichi = isRiichi
        self.doraIndicators = doraIndicators
        self.uraDoraIndicators = uraDoraIndicators
        self.winType = winType
        self.hand = hand
        self.winningTileIndex = winningTileIndex
        self.yaku = yaku
        self.han = han
        self.fu = fu
        self.correctAnswer = correctAnswer
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        roundInfo = try container.decode(String.self, forKey: .roundInfo)
        isDealer = try container.decode(Bool.self, forKey: .isDealer)
        isRiichi = try container.decode(Bool.self, forKey: .isRiichi)
        doraIndicators = try container.decode([String].self, forKey: .doraIndicators)
        uraDoraIndicators = try container.decode([String].self, forKey: .uraDoraIndicators)
        winType = try container.decode(WinType.self, forKey: .winType)
        let decodedHand = try container.decode(Hand.self, forKey: .hand)
        let topLevelConcealed = try container.decodeIfPresent([[String]].self, forKey: .concealedKans) ?? []
        if decodedHand.concealedKans.isEmpty && !topLevelConcealed.isEmpty {
            hand = Hand(
                groups: decodedHand.groups,
                openGroups: decodedHand.openGroups,
                concealedKans: topLevelConcealed
            )
        } else {
            hand = decodedHand
        }
        winningTileIndex = try container.decode(Int.self, forKey: .winningTileIndex)
        yaku = try container.decode([String].self, forKey: .yaku)
        han = try container.decode(Int.self, forKey: .han)
        fu = try container.decode(Int.self, forKey: .fu)
        correctAnswer = try container.decode(String.self, forKey: .correctAnswer)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(roundInfo, forKey: .roundInfo)
        try container.encode(isDealer, forKey: .isDealer)
        try container.encode(isRiichi, forKey: .isRiichi)
        try container.encode(doraIndicators, forKey: .doraIndicators)
        try container.encode(uraDoraIndicators, forKey: .uraDoraIndicators)
        try container.encode(winType, forKey: .winType)
        try container.encode(hand, forKey: .hand)
        try container.encode(winningTileIndex, forKey: .winningTileIndex)
        try container.encode(yaku, forKey: .yaku)
        try container.encode(han, forKey: .han)
        try container.encode(fu, forKey: .fu)
        try container.encode(correctAnswer, forKey: .correctAnswer)
    }
}

final class PracticeManager: ObservableObject {
    @Published private(set) var currentQuestionIndex = 0
    @Published private(set) var correctCount = 0
    @Published private(set) var isFinished = false
    @Published private(set) var currentQuestion: PracticeQuestion?

    let menu: PracticeMenu
    let difficulty: PracticeDifficulty
    let totalQuestions: Int
    private var questions: [PracticeQuestion] = []
    private let calculator = ScoreCalculator()

    init(menu: PracticeMenu, difficulty: PracticeDifficulty) {
        self.menu = menu
        self.difficulty = difficulty
        self.totalQuestions = menu.type.questionCount(for: difficulty)
        reset()
    }

    func reset() {
        currentQuestionIndex = 0
        correctCount = 0
        isFinished = false
        questions = generateQuestions(for: menu)
        currentQuestion = questions.first
    }

    func checkAnswer(_ input: String) -> Bool {
        guard let question = currentQuestion else { return false }
        let normalizedInput = normalize(answer: input)
        let normalizedCorrect = normalize(answer: calculator.scoreString(for: question))
        return normalizedInput == normalizedCorrect
    }

    func markCorrect() {
        correctCount += 1
    }

    func result() -> PracticeResult {
        PracticeResult(totalQuestions: totalQuestions, correctCount: correctCount)
    }

    func moveNext() {
        let nextIndex = currentQuestionIndex + 1
        if nextIndex >= totalQuestions {
            isFinished = true
            currentQuestion = nil
            return
        }
        currentQuestionIndex = nextIndex
        currentQuestion = questions[nextIndex]
    }

    private func normalize(answer: String) -> String {
        answer
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "　", with: "")
    }

    private func generateQuestions(for menu: PracticeMenu) -> [PracticeQuestion] {
        let samples = loadQuestions(for: menu.type)
        let filtered = filterQuestionsByDifficulty(samples)
        guard !filtered.isEmpty else { return [] }
        var generated: [PracticeQuestion] = []
        let uniqueAnswers = Set(filtered.map { $0.correctAnswer })
        var lastAnswer: String?
        for _ in 0..<totalQuestions {
            var selected: PracticeQuestion?
            if uniqueAnswers.count <= 1 {
                selected = filtered.randomElement()
            } else {
                for _ in 0..<6 {
                    if let candidate = filtered.randomElement() {
                        if candidate.correctAnswer != lastAnswer {
                            selected = candidate
                            break
                        }
                    }
                }
            }
            if selected == nil {
                selected = filtered.randomElement()
            }
            if let question = selected {
                generated.append(question)
                lastAnswer = question.correctAnswer
            }
        }
        return generated
    }

    private func filterQuestionsByDifficulty(_ questions: [PracticeQuestion]) -> [PracticeQuestion] {
        switch difficulty {
        case .easy:
            return questions.filter { !$0.hand.hasKan }
        case .hard:
            return questions
        }
    }

    private func loadQuestions(for type: PracticeMenuType) -> [PracticeQuestion] {
        let urls = practiceJSONURLs(for: type.sourceFilenames)
        guard !urls.isEmpty else {
            return []
        }

        let decoder = JSONDecoder()
        var aggregated: [PracticeQuestion] = []

        for url in urls {
            guard let data = try? Data(contentsOf: url) else {
                continue
            }
            if let questions = try? decoder.decode([PracticeQuestion].self, from: data) {
                let shuffled = questions.map { applyShuffleIfNeeded(to: $0) }
                aggregated.append(contentsOf: shuffled)
            }
        }

        return aggregated
    }

    private func applyShuffleIfNeeded(to question: PracticeQuestion) -> PracticeQuestion {
        if question.yaku.contains("緑一色") {
            return question
        }
        let shuffle = Int.random(in: 0...2)
        let zShuffle = Int.random(in: 0...2)
        if shuffle == 0 && zShuffle == 0 {
            return question
        }

        let transform: (String) -> String = { tile in
            guard tile.count >= 2 else { return tile }
            let suit = tile.suffix(1)
            let number = tile.dropLast()
            let mappedSuit: Substring

            switch shuffle {
            case 1:
                if suit == "p" { mappedSuit = "m" }
                else if suit == "m" { mappedSuit = "s" }
                else if suit == "s" { mappedSuit = "p" }
                else { mappedSuit = suit }
            case 2:
                if suit == "p" { mappedSuit = "s" }
                else if suit == "m" { mappedSuit = "p" }
                else if suit == "s" { mappedSuit = "m" }
                else { mappedSuit = suit }
            default:
                mappedSuit = suit
            }
            if suit == "z", number == "5" || number == "6" || number == "7" {
                return "\(self.mappedZ(number: number, zShuffle: zShuffle))z"
            }

            return "\(number)\(mappedSuit)"
        }

        return PracticeQuestion(
            roundInfo: question.roundInfo,
            isDealer: question.isDealer,
            isRiichi: question.isRiichi,
            doraIndicators: question.doraIndicators.map(transform),
            uraDoraIndicators: question.uraDoraIndicators.map(transform),
            winType: question.winType,
            hand: question.hand.mapped(transform),
            winningTileIndex: question.winningTileIndex,
            yaku: question.yaku.map { self.mappedYaku($0, zShuffle: zShuffle) },
            han: question.han,
            fu: question.fu,
            correctAnswer: question.correctAnswer
        )
    }

    private func mappedZ(number: Substring, zShuffle: Int) -> String {
        switch zShuffle {
        case 1:
            if number == "5" { return "6" }
            if number == "6" { return "7" }
            if number == "7" { return "5" }
        case 2:
            if number == "5" { return "7" }
            if number == "6" { return "5" }
            if number == "7" { return "6" }
        default:
            break
        }
        return String(number)
    }

    private func mappedYaku(_ yaku: String, zShuffle: Int) -> String {
        switch zShuffle {
        case 1:
            if yaku == "ハク" { return "ハツ" }
            if yaku == "ハツ" { return "チュン" }
            if yaku == "チュン" { return "ハク" }
        case 2:
            if yaku == "ハク" { return "チュン" }
            if yaku == "ハツ" { return "ハク" }
            if yaku == "チュン" { return "ハツ" }
        default:
            break
        }
        return yaku
    }


    private func practiceJSONURLs(for filenames: [String]) -> [URL] {
        let custom = documentPracticeURLs()
        let bundle = Bundle.main
        if let urls = bundle.urls(forResourcesWithExtension: "json", subdirectory: "Practices"),
           !urls.isEmpty {
            let filtered = urls.filter { filenames.contains($0.deletingPathExtension().lastPathComponent) }
            return (custom + filtered).sorted { $0.lastPathComponent < $1.lastPathComponent }
        }

        let fallback = bundle.urls(forResourcesWithExtension: "json", subdirectory: nil) ?? []
        let bundleFiltered = fallback.filter { filenames.contains($0.deletingPathExtension().lastPathComponent) }
        return (custom + bundleFiltered).sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    private func documentPracticeURLs() -> [URL] {
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }
        let practicesURL = documentsURL.appendingPathComponent("Practices", isDirectory: true)
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: practicesURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        return files.filter { $0.pathExtension.lowercased() == "json" }
    }
}
