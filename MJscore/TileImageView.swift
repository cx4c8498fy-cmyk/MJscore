//
//  TileImageView.swift
//  MJscore
//
//  Created by Codex on 2025/12/20.
//

import SwiftUI
import UIKit

struct TileImageView: View {
    let tile: String
    let isWinning: Bool
    let highlightDora: Bool
    let tileSize: CGSize

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 6)
                .fill(highlightDora ? Color(red: 0.95, green: 0.86, blue: 0.78) : Color.white)

            if let image = tileUIImage(for: tile) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding(4)
            } else {
                Text(tile)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.black)
            }

            RoundedRectangle(cornerRadius: 6)
                .stroke(isWinning ? Color(red: 0.85, green: 0.45, blue: 0.2) : Color(red: 0.75, green: 0.68, blue: 0.56), lineWidth: isWinning ? 2 : 1)

            if isWinning {
                Text("当たり")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(Color(red: 0.85, green: 0.45, blue: 0.2))
                    .clipShape(Capsule())
                    .offset(x: 4, y: -6)
            }
        }
        .frame(width: tileSize.width, height: tileSize.height)
    }
}

private func tileUIImage(for tile: String) -> UIImage? {
    let sanitized = tile.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !sanitized.isEmpty else { return nil }
    let assetName = "tile_\(sanitized)"
    return UIImage(named: assetName)
}
