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
                .onAppear {
                    // Close the system color panel so it doesn't reopen from the previous session.
                    NSColorPanel.shared.close()
                }
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 400, height: 560)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .appInfo) {
                AboutMenuButton()
            }
            CommandMenu("Wallpaper") {
                Button("Parar Wallpaper") { manager.remove() }
                    .keyboardShortcut("w", modifiers: [.command, .shift])
                    .disabled(!manager.isWallpaperActive)
            }
        }

        // ── About window ─────────────────────────────────────────────────────
        Window("Sobre o Live Wallpaper", id: "about") {
            AboutView()
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .restorationBehavior(.disabled)

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

// ── Helper to access openWindow inside a Commands context ────────────────────
private struct AboutMenuButton: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button("Sobre o Live Wallpaper") {
            openWindow(id: "about")
        }
    }
}
