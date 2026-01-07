//
//  HighScoreStore.swift
//  MJscore
//
//  Created by Codex on 2025/12/20.
//

import Foundation
import Combine

final class HighScoreStore: ObservableObject {
    @Published private(set) var scores: [String: Int] = [:]
    private let defaults = UserDefaults.standard

    init() {
        load()
    }

    func highScore(for type: PracticeMenuType, difficulty: PracticeDifficulty) -> Int {
        scores[type.scoreKey(difficulty: difficulty)] ?? 0
    }

    func updateHighScore(for type: PracticeMenuType, difficulty: PracticeDifficulty, score: Int) {
        let key = type.scoreKey(difficulty: difficulty)
        let current = scores[key] ?? 0
        if score > current {
            scores[key] = score
            defaults.set(score, forKey: key)
        }
    }

    func resetAll() {
        for key in scores.keys {
            defaults.removeObject(forKey: key)
        }
        scores = [:]
    }

    private func load() {
        var loaded: [String: Int] = [:]
        for type in PracticeMenuType.allCases {
            for difficulty in PracticeDifficulty.allCases {
                let key = type.scoreKey(difficulty: difficulty)
                let value = defaults.integer(forKey: key)
                if value > 0 {
                    loaded[key] = value
                }
            }
        }
        scores = loaded
    }
}
