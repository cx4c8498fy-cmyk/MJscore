//
//  PracticeResult.swift
//  MJscore
//
//  Created by Codex on 2025/12/20.
//

import Foundation

struct PracticeResult {
    let totalQuestions: Int
    let correctCount: Int

    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctCount) / Double(totalQuestions)
    }
}
