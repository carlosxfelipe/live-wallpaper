//
//  GradientEditorView.swift
//  LiveWallpaper
//
//  Created by Carlos Felipe Araújo on 06/09/26.
//

import SwiftUI

struct GradientEditorView: View {
    @Environment(WallpaperWindowManager.self) private var manager

    @State private var colors: [Color] = [
        Color(hex: "6C63FF"),
        Color(hex: "EC4899"),
    ]
    @State private var direction: GradientDirection = .horizontal
    @State private var isApplied = false

    // MARK: - Body

    var body: some View {
        Form {
            // ── Preview ──────────────────────────────────────────────────────
            Section {
                LinearGradient(
                    colors: colors.isEmpty ? [.black] : colors,
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
            Section {
                ForEach(Array(colors.enumerated()), id: \.offset) { index, _ in
                    HStack {
                        ColorPicker("Cor \(index + 1)", selection: Binding(
                            get: { colors[index] },
                            set: { colors[index] = $0; isApplied = false }
                        ))

                        if colors.count > 2 {
                            Spacer()
                            Button(role: .destructive) {
                                _ = withAnimation { colors.remove(at: index) }
                                isApplied = false
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .symbolRenderingMode(.hierarchical)
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if colors.count < 6 {
                    Button {
                        withAnimation { colors.append(randomColor()) }
                        isApplied = false
                    } label: {
                        Label("Adicionar Cor", systemImage: "plus")
                    }
                }

            } header: {
                Text("Cores")
            } footer: {
                Text("Mínimo 2, máximo 6 cores.")
                    .foregroundStyle(.secondary)
            }

            // ── Apply ────────────────────────────────────────────
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
        manager.apply(mode: .gradient(colors: colors, direction: direction))
        withAnimation(.spring(response: 0.3)) { isApplied = true }
    }

    private func randomColor() -> Color {
        let palette: [Color] = [
            Color(hex: "F43F5E"), Color(hex: "FB923C"), Color(hex: "FACC15"),
            Color(hex: "4ADE80"), Color(hex: "22D3EE"), Color(hex: "818CF8"),
        ]
        return palette.randomElement() ?? .purple
    }
}

#Preview {
    GradientEditorView()
        .environment(WallpaperWindowManager.shared)
        .frame(width: 400)
}
