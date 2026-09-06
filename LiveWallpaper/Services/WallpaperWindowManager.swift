//
//  WallpaperWindowManager.swift
//  LiveWallpaper
//
//  Created by Carlos Felipe Araújo on 06/09/26.
//

import AppKit
import AVKit
import Observation
import SwiftUI

@Observable
@MainActor
final class WallpaperWindowManager {
    static let shared = WallpaperWindowManager()

    var mode: WallpaperMode = .gradient(colors: [.purple, .indigo], direction: .horizontal)
    var isWallpaperActive = false

    private var wallpaperWindows: [NSWindow] = []
    // Strong references to prevent ARC from deallocating players
    private var activePlayers: [AVPlayer] = []

    private init() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.remove()
        }
    }

    // MARK: - Public

    func apply(mode: WallpaperMode) {
        self.mode = mode
        removeWallpaperWindows()
        for screen in NSScreen.screens {
            let window = makeWallpaperWindow(for: screen, mode: mode)
            window.orderFront(nil)
            wallpaperWindows.append(window)
        }
        isWallpaperActive = true

        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                if self.isWallpaperActive { self.apply(mode: self.mode) }
            }
        }
    }

    func remove() {
        removeWallpaperWindows()
        isWallpaperActive = false
    }

    // MARK: - Private

    private func makeWallpaperWindow(for screen: NSScreen, mode: WallpaperMode) -> NSWindow {
        let window = NSWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false,
            screen: screen
        )
        window.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        window.isOpaque = true
        window.hasShadow = false
        window.ignoresMouseEvents = true
        window.setFrame(screen.frame, display: true)

        switch mode {
        case let .gradient(colors, direction):
            let host = NSHostingView(rootView:
                GradientWallpaperView(colors: colors, direction: direction)
            )
            host.frame = screen.frame
            window.contentView = host

        case let .video(url):
            let player = makeLoopingPlayer(url: url)
            activePlayers.append(player)

            let view = VideoWallpaperNSView(player: player, frame: screen.frame)
            window.contentView = view

            player.play()
        }

        return window
    }

    private func makeLoopingPlayer(url: URL) -> AVPlayer {
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        player.isMuted = true
        player.actionAtItemEnd = .none

        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak player] _ in
            player?.seek(to: .zero)
            player?.play()
        }

        return player
    }

    private func removeWallpaperWindows() {
        activePlayers.forEach { $0.pause() }
        activePlayers.removeAll()
        wallpaperWindows.forEach { $0.orderOut(nil) }
        wallpaperWindows.removeAll()
        NotificationCenter.default.removeObserver(
            self,
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }
}

// MARK: - Mode

enum WallpaperMode {
    case gradient(colors: [Color], direction: GradientDirection)
    case video(url: URL)
}
