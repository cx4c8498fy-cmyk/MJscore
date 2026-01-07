//
//  Hand.swift
//  MJscore
//
//  Created by Codex on 2025/12/20.
//

import Foundation

struct Hand: Codable {
    let groups: [[String]]
    let openGroups: [[String]]
    let concealedKans: [[String]]

    var tiles: [String] {
        groups.flatMap { $0 }
    }

    var openTiles: [String] {
        openGroups.flatMap { $0 }
    }

    init(groups: [[String]], openGroups: [[String]] = [], concealedKans: [[String]] = []) {
        self.groups = groups
        self.openGroups = openGroups
        self.concealedKans = concealedKans
    }

    var hasKan: Bool {
        groups.contains { $0.count == 4 }
            || openGroups.contains { $0.count == 4 }
            || concealedKans.contains { $0.count == 4 }
    }

    func mapped(_ transform: (String) -> String) -> Hand {
        Hand(
            groups: groups.map { $0.map(transform) },
            openGroups: openGroups.map { $0.map(transform) },
            concealedKans: concealedKans.map { $0.map(transform) }
        )
    }
}
