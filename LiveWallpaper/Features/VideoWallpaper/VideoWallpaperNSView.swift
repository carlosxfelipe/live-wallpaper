//
//  VideoWallpaperNSView.swift
//  LiveWallpaper
//
//  Created by Carlos Felipe Araújo on 06/09/26.
//

import AppKit
import AVFoundation

/// NSView whose backing layer IS the AVPlayerLayer — the only approach
/// that renders reliably at the CGWindowLevelForKey(.desktopWindow) level.
final class VideoWallpaperNSView: NSView {
    private let avPlayer: AVPlayer

    // MARK: - Init

    /// Accepts a pre-configured, already-playing AVPlayer.
    init(player: AVPlayer, frame: NSRect) {
        avPlayer = player
        super.init(frame: frame)
        wantsLayer = true // triggers makeBackingLayer()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }

    // MARK: - Core: backing layer = AVPlayerLayer

    override func makeBackingLayer() -> CALayer {
        let playerLayer = AVPlayerLayer(player: avPlayer)
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.backgroundColor = CGColor.black
        return playerLayer
    }

    // Keep the player layer filling the view when the window resizes
    override func layout() {
        super.layout()
        guard let playerLayer = layer as? AVPlayerLayer else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        playerLayer.frame = bounds
        CATransaction.commit()
    }
}
