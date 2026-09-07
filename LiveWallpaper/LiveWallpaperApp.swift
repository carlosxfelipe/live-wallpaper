//
//  LiveWallpaperApp.swift
//  LiveWallpaper
//
//  Created by Carlos Felipe Araújo on 06/09/26.
//

import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationWillFinishLaunching(_: Notification) {
        // Safely hide the app from the Dock before the UI finishes launching
        NSApp.setActivationPolicy(.accessory)
    }
}

@main
struct LiveWallpaperApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var manager = WallpaperWindowManager.shared
    @State private var caffeinateManager = CaffeinateManager.shared

    var body: some Scene {
        // ── Main window ──────────────────────────────────────────────────────
        Window("Live Wallpaper", id: "main") {
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
                Button(action: { manager.remove() }) {
                    Label("Parar Wallpaper", systemImage: "stop.circle")
                }
            } else {
                Label("Nenhum wallpaper ativo", systemImage: "circle.dotted")
            }
            Divider()
            Toggle(isOn: $caffeinateManager.isCaffeinated) {
                Label("Cafeinado", systemImage: "cup.and.saucer.fill")
            }
            Divider()
            OpenPanelMenuButton()
            AboutMenuButton()
            Divider()
            Button(action: { NSApplication.shared.terminate(nil) }) {
                Label("Sair", systemImage: "power")
            }
        }
        .menuBarExtraStyle(.menu)
    }
}

// ── Helpers to access openWindow inside a Commands/MenuBar context ───────────

private struct AboutMenuButton: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button(action: {
            openWindow(id: "about")
            NSApp.activate(ignoringOtherApps: true)
        }) {
            Label("Sobre", systemImage: "info.circle")
        }
    }
}

private struct OpenPanelMenuButton: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button(action: {
            openWindow(id: "main")
            NSApp.activate(ignoringOtherApps: true)
        }) {
            Label("Abrir Painel", systemImage: "macwindow")
        }
    }
}
