//
//  GradientEditorView.swift
//  LiveWallpaper
//
//  Created by Carlos Felipe Araújo on 06/09/26.
//

import SwiftUI

struct GradientEditorView: View {
    @Environment(WallpaperWindowManager.self) private var manager

    @State private var color1: Color = .init(hex: "6C63FF")
    @State private var color2: Color = .init(hex: "EC4899")
    @State private var direction: GradientDirection = .horizontal
    @State private var isApplied = false

    // MARK: - Body

    var body: some View {
        Form {
            // ── Preview ──────────────────────────────────────────────────────
            Section {
                LinearGradient(
                    colors: [color1, color2],
                    startPoint: direction.startPoint,
                    endPoint: direction.endPoint
                )
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            }

            // ── Direction ────────────────────────────────────────────────────
            Section("Direção") {
                Picker("Direção", selection: $direction) {
                    ForEach(GradientDirection.allCases) { dir in
                        Label(dir.rawValue, systemImage: dir.systemImage).tag(dir)
                    }
                }
                .pickerStyle(.radioGroup)
                .onChange(of: direction) { isApplied = false }
            }

            // ── Colors ───────────────────────────────────────────────────────
            Section("Cores") {
                ColorPicker("Cor 1", selection: $color1)
                    .onChange(of: color1) { isApplied = false }
                ColorPicker("Cor 2", selection: $color2)
                    .onChange(of: color2) { isApplied = false }
            }

            // ── Apply ────────────────────────────────────────────────────────
            Section {
                HStack {
                    if manager.isWallpaperActive {
                        Button("Remover", role: .destructive) {
                            manager.remove()
                            isApplied = false
                        }
                    }
                    Spacer()
                    Button(isApplied ? "Aplicado!" : "Aplicar Wallpaper") {
                        applyWallpaper()
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - Actions

    private func applyWallpaper() {
        manager.apply(mode: .gradient(colors: [color1, color2], direction: direction))
        withAnimation(.spring(response: 0.3)) { isApplied = true }
    }
}

#Preview {
    GradientEditorView()
        .environment(WallpaperWindowManager.shared)
        .frame(width: 400)
}
