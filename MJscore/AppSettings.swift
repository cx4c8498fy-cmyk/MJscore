//
//  AppSettings.swift
//  MJscore
//
//  Created by Codex on 2025/12/20.
//

import Foundation
import Combine

final class AppSettings: ObservableObject {
    @Published var isPracticeBGMEnabled: Bool {
        didSet {
            defaults.set(isPracticeBGMEnabled, forKey: practiceBGMKey)
        }
    }
    @Published var selectedMenuBGM: MenuBGM {
        didSet {
            defaults.set(selectedMenuBGM.rawValue, forKey: menuBGMKey)
        }
    }

    private let defaults = UserDefaults.standard
    private let practiceBGMKey = "practice_bgm_enabled"
    private let menuBGMKey = "menu_bgm_selected"

    init() {
        if defaults.object(forKey: practiceBGMKey) == nil {
            isPracticeBGMEnabled = true
        } else {
            isPracticeBGMEnabled = defaults.bool(forKey: practiceBGMKey)
        }
        if let raw = defaults.string(forKey: menuBGMKey),
           let bgm = MenuBGM(rawValue: raw) {
            selectedMenuBGM = bgm
        } else {
            selectedMenuBGM = .bgm1
        }
    }
}

enum MenuBGM: String, CaseIterable {
    case bgm1 = "bgm"
    case bgm2 = "bgm2"

    var displayName: String {
        switch self {
        case .bgm1:
            return "BGM-1"
        case .bgm2:
            return "BGM-2"
        }
    }
}
