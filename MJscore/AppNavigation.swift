//
//  AppNavigation.swift
//  MJscore
//
//  Created by Codex on 2025/12/20.
//

import SwiftUI
import Combine

enum AppRoute: Hashable {
    case home
    case selection
    case options
    case practice(PracticeMenuType, PracticeDifficulty)
}

final class NavigationCoordinator: ObservableObject {
    @Published var path: [AppRoute] = []
}
