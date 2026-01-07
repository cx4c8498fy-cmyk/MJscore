//
//  PracticeMenu.swift
//  MJscore
//
//  Created by Codex on 2025/12/20.
//

import Foundation

enum PracticeMenuType: String, CaseIterable {
    case tanyao_c_ron = "断么九　子　ロン"
    case tanyao_c_tmo = "断么九　子　ツモ"
    case tanyao_c = "断么九　子"
    case tanyao_p_ron = "断么九　親　ロン"
    case tanyao_p_tmo = "断么九　親　ツモ"
    case tanyao_p = "断么九　親"
    case tanyao = "断么九"
    case toitoi_c_ron = "対々和　子　ロン"
    case toitoi_c_tmo = "対々和　子　ツモ"
    case toitoi_c = "対々和　子"
    case toitoi_p_ron = "対々和　親　ロン"
    case toitoi_p_tmo = "対々和　親　ツモ"
    case toitoi_p = "対々和　親"
    case toitoi = "対々和"
    case pinfu_c_ron = "平和　子　ロン"
    case pinfu_c_tmo = "平和　子　ツモ"
    case pinfu_c = "平和　子"
    case pinfu_p_ron = "平和　親　ロン"
    case pinfu_p_tmo = "平和　親　ツモ"
    case pinfu_p = "平和　親"
    case pinfu = "平和"
    case chiitoi_c_ron = "七対子　子　ロン"
    case chiitoi_c_tmo = "七対子　子　ツモ"
    case chiitoi_c = "七対子　子"
    case chiitoi_p_ron = "七対子　親　ロン"
    case chiitoi_p_tmo = "七対子　親　ツモ"
    case chiitoi_p = "七対子　親"
    case chiitoi = "七対子"
    case comprehensive = "総合問題"

    var practiceFilename: String {
        switch self {
        case .tanyao_c_ron:
            return "tanyao_c_ron"
        case .tanyao_c_tmo:
            return "tanyao_c_tmo"
        case .tanyao_c:
            return "tanyao_c"
        case .tanyao_p_ron:
            return "tanyao_p_ron"
        case .tanyao_p_tmo:
            return "tanyao_p_tmo"
        case .tanyao_p:
            return "tanyao_p"
        case .tanyao:
            return "tanyao"
        case .toitoi_c_ron:
            return "toitoi_c_ron"
        case .toitoi_c_tmo:
            return "toitoi_c_tmo"
        case .toitoi_c:
            return "toitoi_c"
        case .toitoi_p_ron:
            return "toitoi_p_ron"
        case .toitoi_p_tmo:
            return "toitoi_p_tmo"
        case .toitoi_p:
            return "toitoi_p"
        case .toitoi:
            return "toitoi"
        case .pinfu_c_ron:
            return "pinfu_c_ron"
        case .pinfu_c_tmo:
            return "pinfu_c_tmo"
        case .pinfu_c:
            return "pinfu_c"
        case .pinfu_p_ron:
            return "pinfu_p_ron"
        case .pinfu_p_tmo:
            return "pinfu_p_tmo"
        case .pinfu_p:
            return "pinfu_p"
        case .pinfu:
            return "pinfu"
        case .chiitoi_c_ron:
            return "chiitoi_c_ron"
        case .chiitoi_c_tmo:
            return "chiitoi_c_tmo"
        case .chiitoi_c:
            return "chiitoi_c"
        case .chiitoi_p_ron:
            return "chiitoi_p_ron"
        case .chiitoi_p_tmo:
            return "chiitoi_p_tmo"
        case .chiitoi_p:
            return "chiitoi_p"
        case .chiitoi:
            return "chiitoi"
        case .comprehensive:
            return "comprehensive"
        }
    }

    var sourceFilenames: [String] {
        switch self {
        case .tanyao_c:
            return ["tanyao_c_ron", "tanyao_c_tmo"]
        case .tanyao_p:
            return ["tanyao_p_ron", "tanyao_p_tmo"]
        case .tanyao:
            return ["tanyao_c_ron", "tanyao_c_tmo", "tanyao_p_ron", "tanyao_p_tmo"]
        case .toitoi_c:
            return ["toitoi_c_ron", "toitoi_c_tmo"]
        case .toitoi_p:
            return ["toitoi_p_ron", "toitoi_p_tmo"]
        case .toitoi:
            return ["toitoi_c_ron", "toitoi_c_tmo", "toitoi_p_ron", "toitoi_p_tmo"]
        case .pinfu_c:
            return ["pinfu_c_ron", "pinfu_c_tmo"]
        case .pinfu_p:
            return ["pinfu_p_ron", "pinfu_p_tmo"]
        case .pinfu:
            return ["pinfu_c_ron", "pinfu_c_tmo", "pinfu_p_ron", "pinfu_p_tmo"]
        case .chiitoi_c:
            return ["chiitoi_c_ron", "chiitoi_c_tmo"]
        case .chiitoi_p:
            return ["chiitoi_p_ron", "chiitoi_p_tmo"]
        case .chiitoi:
            return ["chiitoi_c_ron", "chiitoi_c_tmo", "chiitoi_p_ron", "chiitoi_p_tmo"]
        case .comprehensive:
            return [
                "tanyao_c_ron", "tanyao_c_tmo", "tanyao_p_ron", "tanyao_p_tmo",
                "toitoi_c_ron", "toitoi_c_tmo", "toitoi_p_ron", "toitoi_p_tmo",
                "pinfu_c_ron", "pinfu_c_tmo", "pinfu_p_ron", "pinfu_p_tmo",
                "chiitoi_c_ron", "chiitoi_c_tmo", "chiitoi_p_ron", "chiitoi_p_tmo"
            ]
        default:
            return [practiceFilename]
        }
    }

    func scoreKey(difficulty: PracticeDifficulty) -> String {
        "score_\(practiceFilename)_\(difficulty.rawValue)"
    }

    func isUnlocked(using store: HighScoreStore, difficulty: PracticeDifficulty) -> Bool {
        let requiredScore: (PracticeMenuType) -> Int = { $0.questionCount(for: difficulty) }
        switch self {
        case .tanyao_c:
            return store.highScore(for: .tanyao_c_ron, difficulty: difficulty) >= requiredScore(.tanyao_c_ron)
                && store.highScore(for: .tanyao_c_tmo, difficulty: difficulty) >= requiredScore(.tanyao_c_tmo)
        case .tanyao_p:
            return store.highScore(for: .tanyao_p_ron, difficulty: difficulty) >= requiredScore(.tanyao_p_ron)
                && store.highScore(for: .tanyao_p_tmo, difficulty: difficulty) >= requiredScore(.tanyao_p_tmo)
        case .tanyao:
            return store.highScore(for: .tanyao_c, difficulty: difficulty) >= requiredScore(.tanyao_c)
                && store.highScore(for: .tanyao_p, difficulty: difficulty) >= requiredScore(.tanyao_p)
        case .toitoi_c:
            return store.highScore(for: .toitoi_c_ron, difficulty: difficulty) >= requiredScore(.toitoi_c_ron)
                && store.highScore(for: .toitoi_c_tmo, difficulty: difficulty) >= requiredScore(.toitoi_c_tmo)
        case .toitoi_p:
            return store.highScore(for: .toitoi_p_ron, difficulty: difficulty) >= requiredScore(.toitoi_p_ron)
                && store.highScore(for: .toitoi_p_tmo, difficulty: difficulty) >= requiredScore(.toitoi_p_tmo)
        case .toitoi:
            return store.highScore(for: .toitoi_c, difficulty: difficulty) >= requiredScore(.toitoi_c)
                && store.highScore(for: .toitoi_p, difficulty: difficulty) >= requiredScore(.toitoi_p)
        case .pinfu_c:
            return store.highScore(for: .pinfu_c_ron, difficulty: difficulty) >= requiredScore(.pinfu_c_ron)
                && store.highScore(for: .pinfu_c_tmo, difficulty: difficulty) >= requiredScore(.pinfu_c_tmo)
        case .pinfu_p:
            return store.highScore(for: .pinfu_p_ron, difficulty: difficulty) >= requiredScore(.pinfu_p_ron)
                && store.highScore(for: .pinfu_p_tmo, difficulty: difficulty) >= requiredScore(.pinfu_p_tmo)
        case .pinfu:
            return store.highScore(for: .pinfu_c, difficulty: difficulty) >= requiredScore(.pinfu_c)
                && store.highScore(for: .pinfu_p, difficulty: difficulty) >= requiredScore(.pinfu_p)
        case .chiitoi_c:
            return store.highScore(for: .chiitoi_c_ron, difficulty: difficulty) >= requiredScore(.chiitoi_c_ron)
                && store.highScore(for: .chiitoi_c_tmo, difficulty: difficulty) >= requiredScore(.chiitoi_c_tmo)
        case .chiitoi_p:
            return store.highScore(for: .chiitoi_p_ron, difficulty: difficulty) >= requiredScore(.chiitoi_p_ron)
                && store.highScore(for: .chiitoi_p_tmo, difficulty: difficulty) >= requiredScore(.chiitoi_p_tmo)
        case .chiitoi:
            return store.highScore(for: .chiitoi_c, difficulty: difficulty) >= requiredScore(.chiitoi_c)
                && store.highScore(for: .chiitoi_p, difficulty: difficulty) >= requiredScore(.chiitoi_p)
        case .comprehensive:
            return PracticeMenuType.allCases
                .filter { $0 != .comprehensive }
                .allSatisfy { store.highScore(for: $0, difficulty: difficulty) >= $0.questionCount(for: difficulty) }
        default:
            return true
        }
    }

    func questionCount(for difficulty: PracticeDifficulty) -> Int {
        switch self {
        case .tanyao_c_ron, .tanyao_c_tmo, .tanyao_p_ron, .tanyao_p_tmo,
             .toitoi_c_ron, .toitoi_c_tmo, .toitoi_p_ron, .toitoi_p_tmo,
             .pinfu_c_ron, .pinfu_c_tmo, .pinfu_p_ron, .pinfu_p_tmo,
             .chiitoi_c_ron, .chiitoi_c_tmo, .chiitoi_p_ron, .chiitoi_p_tmo:
            return difficulty == .hard ? 15 : 10
        case .tanyao_c, .tanyao_p, .toitoi_c, .toitoi_p, .pinfu_c, .pinfu_p, .chiitoi_c, .chiitoi_p:
            return difficulty == .hard ? 20 : 15
        case .tanyao, .toitoi, .pinfu, .chiitoi:
            return difficulty == .hard ? 25 : 20
        case .comprehensive:
            return difficulty == .hard ? 40 : 30
        }
    }
}

struct PracticeMenu: Identifiable, Equatable {
    let id = UUID()
    let type: PracticeMenuType
    let isUnlocked: Bool

    var name: String { type.rawValue }

    static let allMenus: [PracticeMenu] = [
        PracticeMenu(type: .pinfu_c_ron, isUnlocked: true),
        PracticeMenu(type: .pinfu_c_tmo, isUnlocked: true),
        PracticeMenu(type: .pinfu_c, isUnlocked: true),
        PracticeMenu(type: .pinfu_p_ron, isUnlocked: true),
        PracticeMenu(type: .pinfu_p_tmo, isUnlocked: true),
        PracticeMenu(type: .pinfu_p, isUnlocked: true),
        PracticeMenu(type: .pinfu, isUnlocked: true),
        PracticeMenu(type: .chiitoi_c_ron, isUnlocked: true),
        PracticeMenu(type: .chiitoi_c_tmo, isUnlocked: true),
        PracticeMenu(type: .chiitoi_c, isUnlocked: true),
        PracticeMenu(type: .chiitoi_p_ron, isUnlocked: true),
        PracticeMenu(type: .chiitoi_p_tmo, isUnlocked: true),
        PracticeMenu(type: .chiitoi_p, isUnlocked: true),
        PracticeMenu(type: .chiitoi, isUnlocked: true),
        PracticeMenu(type: .tanyao_c_ron, isUnlocked: true),
        PracticeMenu(type: .tanyao_c_tmo, isUnlocked: true),
        PracticeMenu(type: .tanyao_c, isUnlocked: true),
        PracticeMenu(type: .tanyao_p_ron, isUnlocked: true),
        PracticeMenu(type: .tanyao_p_tmo, isUnlocked: true),
        PracticeMenu(type: .tanyao_p, isUnlocked: true),
        PracticeMenu(type: .tanyao, isUnlocked: true),
        PracticeMenu(type: .toitoi_c_ron, isUnlocked: true),
        PracticeMenu(type: .toitoi_c_tmo, isUnlocked: true),
        PracticeMenu(type: .toitoi_c, isUnlocked: true),
        PracticeMenu(type: .toitoi_p_ron, isUnlocked: true),
        PracticeMenu(type: .toitoi_p_tmo, isUnlocked: true),
        PracticeMenu(type: .toitoi_p, isUnlocked: true),
        PracticeMenu(type: .toitoi, isUnlocked: true),
        PracticeMenu(type: .comprehensive, isUnlocked: true)
    ]
}
