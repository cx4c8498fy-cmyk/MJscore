//
//  BannerAdView.swift
//  MJscore
//
//  Created by Codex on 2025/12/20.
//

import SwiftUI

#if canImport(GoogleMobileAds)
import GoogleMobileAds

struct BannerAdView: UIViewRepresentable {
    private let adUnitID = "ca-app-pub-9158687989284001/5780666984"

    func makeUIView(context: Context) -> BannerView {
        let bannerView = BannerView(adSize: AdSizeBanner)
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController
        bannerView.load(Request())
        return bannerView
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
    }
}
#else
struct BannerAdView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.2))
            .overlay(
                Text("Banner Ad")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.gray)
            )
            .padding(.horizontal, 16)
    }
}
#endif
