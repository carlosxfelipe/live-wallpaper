//
//  AboutView.swift
//  LiveWallpaper
//
//  Created by Carlos Felipe Araújo on 06/09/26.
//

import SwiftUI

struct AboutView: View {
    // Read version and build number directly from the app bundle
    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    }

    private var versionLabel: String {
        build.isEmpty || build == version ? "Versão \(version)" : "Versão \(version) (\(build))"
    }

    var body: some View {
        VStack(spacing: 0) {
            // ── App Icon ─────────────────────────────────────────────────────
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 80, height: 80)
                .padding(.top, 28)

            // ── App Name ─────────────────────────────────────────────────────
            Text("Live Wallpaper")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 12)

            // ── Version ──────────────────────────────────────────────────────
            Text(versionLabel)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.top, 4)

            Divider()
                .padding(.vertical, 16)

            // ── Author ───────────────────────────────────────────────────────
            Text("Desenvolvido por")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text("Carlos Felipe Araújo")
                .font(.footnote)
                .fontWeight(.bold)
                .padding(.top, 2)

            // ── GitHub Link ───────────────────────────────────────────────────
            Link(destination: URL(string: "https://github.com/carlosxfelipe")!) {
                Label("github.com/carlosxfelipe", systemImage: "link")
                    .font(.footnote)
            }
            .padding(.top, 6)
            .padding(.bottom, 24)
        }
        .frame(width: 260)
    }
}

#Preview {
    AboutView()
}
