//
//  MJscoreApp.swift
//  MJscore
//
//  Created by 久世晃暢 on 2025/12/20.
//

import SwiftUI
import AppTrackingTransparency

@main
struct MJscoreApp: App {
    @State private var didRequestATT = false

    var body: some Scene {
        WindowGroup {
            TitleView()
                .onAppear {
                    if !didRequestATT {
                        didRequestATT = true
                        ATTrackingManager.requestTrackingAuthorization { _ in }
                    }
                }
        }
    }
}
