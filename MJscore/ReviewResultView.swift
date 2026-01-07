//
//  ReviewResultView.swift
//  MJscore
//
//  Created by Codex on 2025/12/20.
//

import SwiftUI

struct ReviewResultView: View {
    let question: PracticeQuestion
    let onNext: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Text("復習")
                    .font(.system(size: 22, weight: .bold))

                VStack(alignment: .leading, spacing: 8) {
                    Text("手牌")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(red: 0.35, green: 0.25, blue: 0.18))

                    TileGroupFlowView(
                        groups: displayGroups,
                        winningTileIndex: question.winningTileIndex,
                        highlightDora: false,
                        doraTiles: [],
                        tileSize: CGSize(width: 30, height: 38),
                        tileSpacing: 0,
                        groupSpacing: 8
                    )
                }
                .padding(12)
                .background(Color(red: 0.98, green: 0.96, blue: 0.92))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(spacing: 6) {
                    Text("役: \(question.yaku.joined(separator: " "))")
                    Text("翻/符: \(question.han)翻 \(question.fu)符")
                    HStack(spacing: 8) {
                        Text(question.isDealer ? "親" : "子")
                        Text("点数: \(question.correctAnswer)")
                    }
                }
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Color(red: 0.25, green: 0.18, blue: 0.12))

                Button(action: onNext) {
                    Text("次の問題へ")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.2, green: 0.45, blue: 0.62))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .padding(.horizontal, 24)
        }
    }

    private var displayGroups: [TileGroup] {
        let closed = question.hand.groups.map { TileGroup(tiles: $0, style: .closed) }
        let opened = question.hand.openGroups.map { TileGroup(tiles: $0, style: .open) }
        let concealed = question.hand.concealedKans.map { TileGroup(tiles: $0, style: .concealed) }
        return closed + opened + concealed
    }
}

#Preview {
    ReviewResultView(
        question: PracticeQuestion(
            roundInfo: "東1局",
            isDealer: false,
            isRiichi: true,
            doraIndicators: ["5m"],
            uraDoraIndicators: ["3p"],
            winType: .ron,
            hand: Hand(
                groups: [["2m", "3m", "4m"], ["2p", "3p", "4p"], ["6s", "7s", "8s"], ["5m", "5m"], ["6p", "6p", "6p"]]
            ),
            winningTileIndex: 13,
            yaku: ["リーチ", "タンヤオ", "ドラ1"],
            han: 3,
            fu: 40,
            correctAnswer: "5200"
        ),
        onNext: {}
    )
}
