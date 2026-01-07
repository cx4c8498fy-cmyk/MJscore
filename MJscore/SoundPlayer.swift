//
//  SoundPlayer.swift
//  MJscore
//
//  Created by Codex on 2025/12/20.
//

import AVFoundation

@MainActor
final class SoundPlayer: NSObject, AVAudioPlayerDelegate {
    static let shared = SoundPlayer()
    private var activePlayers: [AVAudioPlayer] = []
    private var menuPlayer: AVAudioPlayer?
    private var practicePlayer: AVAudioPlayer?
    private var currentMenuBGMName: String?

    private override init() {
        super.init()
    }

    func playCorrect() {
        play(soundFile: "correct")
    }

    func playClick() {
        play(soundFile: "click")
    }

    func playWrong() {
        play(soundFile: "buzzer")
    }

    func playInput() {
        play(soundFile: "input")
    }

    func playBGM() {
        playMenuBGM(named: "bgm")
    }

    func playMenuBGM(named name: String) {
        if let current = currentMenuBGMName, current == name, let player = menuPlayer {
            if !player.isPlaying {
                player.play()
            }
            return
        }
        if menuPlayer != nil {
            menuPlayer?.stop()
            menuPlayer = nil
        }
        guard let url = Self.resolveURL(for: name, extensions: ["mp3", "wav"]) else {
            print("SoundPlayer: Missing sound file: \(name)")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
            menuPlayer = player
            currentMenuBGMName = name
        } catch {
            print("SoundPlayer: Failed to play sound bgm: \(error)")
        }
    }

    func stopBGM() {
        menuPlayer?.stop()
        menuPlayer = nil
        currentMenuBGMName = nil
    }

    func playPracticeBGM() {
        if let player = practicePlayer {
            if !player.isPlaying {
                player.play()
            }
            return
        }
        guard let url = Self.resolveURL(for: "bgm_practice", extensions: ["mp3", "wav"]) else {
            print("SoundPlayer: Missing sound file: bgm_practice")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
            practicePlayer = player
        } catch {
            print("SoundPlayer: Failed to play sound bgm_practice: \(error)")
        }
    }

    func stopPracticeBGM() {
        practicePlayer?.stop()
        practicePlayer = nil
    }

    private func play(soundFile: String) {
        guard let url = Self.resolveURL(for: soundFile) else {
            print("SoundPlayer: Missing sound file: \(soundFile)")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            player.prepareToPlay()
            player.play()
            activePlayers.append(player)
        } catch {
            print("SoundPlayer: Failed to play sound \(soundFile): \(error)")
        }
    }

    private static func resolveURL(for name: String) -> URL? {
        resolveURL(for: name, extensions: ["wav"])
    }

    private static func resolveURL(for name: String, extensions: [String]) -> URL? {
        let bundle = Bundle.main
        for ext in extensions {
            if let url = bundle.url(forResource: name, withExtension: ext, subdirectory: "sounds") {
                return url
            }
            if let url = bundle.url(forResource: name, withExtension: ext, subdirectory: "Sounds") {
                return url
            }
            if let url = bundle.url(forResource: name, withExtension: ext) {
                return url
            }
        }
        return nil
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        activePlayers.removeAll { $0 === player }
    }
}
