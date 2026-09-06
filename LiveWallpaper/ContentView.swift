//
//  ContentView.swift
//  LiveWallpaper
//
//  Created by Carlos Felipe Araújo on 06/09/26.
//

import SwiftUI

struct ContentView: View {
    @Environment(WallpaperWindowManager.self) private var manager
    @State private var selectedTab: Tab = .gradient

    enum Tab: String, CaseIterable, Identifiable {
        case gradient = "Degradê"
        case video = "Vídeo"
        var id: String { rawValue }
        var icon: String {
            switch self {
            case .gradient: return "paintpalette"
            case .video: return "film.stack"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── Status bar ───────────────────────────────────────────────────
            HStack(spacing: 6) {
                Circle()
                    .fill(manager.isWallpaperActive ? Color.green : Color.secondary.opacity(0.4))
                    .frame(width: 8, height: 8)
                Text(manager.isWallpaperActive ? "Wallpaper ativo" : "Nenhum wallpaper ativo")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.bar)

            Divider()

            // ── Tab content ──────────────────────────────────────────────────
            TabView(selection: $selectedTab) {
                GradientEditorView()
                    .tabItem {
                        Label(Tab.gradient.rawValue, systemImage: Tab.gradient.icon)
                    }
                    .tag(Tab.gradient)

                VideoEditorView()
                    .tabItem {
                        Label(Tab.video.rawValue, systemImage: Tab.video.icon)
                    }
                    .tag(Tab.video)
            }
        }
        .frame(width: 400)
    }
}

#Preview {
    ContentView()
        .environment(WallpaperWindowManager.shared)
}
