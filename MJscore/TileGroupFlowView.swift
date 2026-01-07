//
//  TileGroupFlowView.swift
//  MJscore
//
//  Created by Codex on 2025/12/20.
//

import SwiftUI

enum TileGroupStyle {
    case closed
    case open
    case concealed
}

struct TileGroup {
    let tiles: [String]
    let style: TileGroupStyle
}

struct TileGroupFlowView: View {
    let groups: [TileGroup]
    let winningTileIndex: Int?
    let highlightDora: Bool
    let doraTiles: Set<String>
    let tileSize: CGSize
    let tileSpacing: CGFloat
    let groupSpacing: CGFloat

    var body: some View {
        let indexedGroups = groupedTiles()
        return FlowLayout(spacing: groupSpacing) {
            ForEach(indexedGroups.indices, id: \.self) { groupIndex in
                let group = indexedGroups[groupIndex]
                HStack(spacing: tileSpacing) {
                    ForEach(group.tiles.indices, id: \.self) { tileIndex in
                        let entry = group.tiles[tileIndex]
                        let isWinning = winningTileIndex == entry.index
                        let isDora = highlightDora && doraTiles.contains(entry.tile)

                        tileView(
                            tile: entry.tile,
                            isWinning: isWinning,
                            style: group.style,
                            isFirst: tileIndex == 0,
                            isMiddle: tileIndex == 1 || tileIndex == 2,
                            isDora: isDora
                        )
                    }
                }
            }
        }
    }

    private func tileView(
        tile: String,
        isWinning: Bool,
        style: TileGroupStyle,
        isFirst: Bool,
        isMiddle: Bool,
        isDora: Bool
    ) -> some View {
        let view: AnyView
        if style == .concealed && isMiddle {
            view = AnyView(
                TileBackView(size: tileSize)
            )
        } else {
            view = AnyView(
                TileImageView(
                    tile: tile,
                    isWinning: isWinning,
                    highlightDora: isDora,
                    tileSize: tileSize
                )
            )
        }

        if style == .open && isFirst {
            return AnyView(
                view
                    .rotationEffect(.degrees(90))
                    .frame(width: tileSize.height, height: tileSize.width)
            )
        }

        return view
    }

    private func groupedTiles() -> [(tiles: [(tile: String, index: Int)], style: TileGroupStyle)] {
        var results: [(tiles: [(tile: String, index: Int)], style: TileGroupStyle)] = []
        var currentIndex = 0
        for group in groups {
            var indexedGroup: [(tile: String, index: Int)] = []
            for tile in group.tiles {
                indexedGroup.append((tile, currentIndex))
                currentIndex += 1
            }
            results.append((tiles: indexedGroup, style: group.style))
        }
        return results
    }
}

private struct TileBackView: View {
    let size: CGSize

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color(red: 0.85, green: 0.84, blue: 0.8))
            .frame(width: size.width, height: size.height)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(red: 0.7, green: 0.66, blue: 0.58), lineWidth: 1)
            )
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxRowWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                maxRowWidth = max(maxRowWidth, x - spacing)
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }

        maxRowWidth = max(maxRowWidth, x - spacing)
        let totalHeight = y + rowHeight
        let finalWidth = maxWidth == .infinity ? maxRowWidth : maxWidth
        return CGSize(width: finalWidth, height: totalHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }

            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
