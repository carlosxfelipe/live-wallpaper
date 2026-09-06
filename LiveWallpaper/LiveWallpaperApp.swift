//
//  LiveWallpaperApp.swift
//  LiveWallpaper
//
//  Created by Carlos Felipe Araújo on 06/09/26.
//

import AppKit
import SwiftUI

@main
struct LiveWallpaperApp: App {
    @State private var manager = WallpaperWindowManager.shared

    var body: some Scene {
        // ── Main window ──────────────────────────────────────────────────────
        WindowGroup {
            ContentView()
                .environment(manager)
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 400, height: 560)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandMenu("Wallpaper") {
                Button("Parar Wallpaper") { manager.remove() }
                    .keyboardShortcut("w", modifiers: [.command, .shift])
                    .disabled(!manager.isWallpaperActive)
            }
        }

        // ── Menu bar extra ───────────────────────────────────────────────────
        MenuBarExtra(
            "Live Wallpaper",
            systemImage: manager.isWallpaperActive ? "waveform.badge.plus" : "waveform"
        ) {
            if manager.isWallpaperActive {
                Label("Wallpaper ativo", systemImage: "checkmark.circle.fill")
                Button("Parar Wallpaper") { manager.remove() }
            } else {
                Label("Nenhum wallpaper ativo", systemImage: "circle.dotted")
            }
            Divider()
            Button("Abrir Painel") { NSApp.activate(ignoringOtherApps: true) }
            Divider()
            Button("Sair") { NSApplication.shared.terminate(nil) }
        }
        .menuBarExtraStyle(.menu)
    }
}
