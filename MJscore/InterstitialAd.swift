//
//  InterstitialAd.swift
//  MJscore
//
//  Created by Codex on 2025/12/20.
//

import Foundation
import UIKit

#if canImport(GoogleMobileAds)
import GoogleMobileAds

final class InterstitialAdManager: NSObject {
    private var interstitial: GoogleMobileAds.InterstitialAd?

    func load() {
        let request = GoogleMobileAds.Request()
        GoogleMobileAds.InterstitialAd.load(
            with: "ca-app-pub-9158687989284001/7124364783",
            request: request
        ) { [weak self] ad, _ in
            self?.interstitial = ad
        }
    }

    func show(from rootViewController: UIViewController) {
        interstitial?.present(from: rootViewController)
    }
}
#else
final class InterstitialAdManager {
    func load() {}
    func show(from rootViewController: UIViewController) {}
}
#endif
