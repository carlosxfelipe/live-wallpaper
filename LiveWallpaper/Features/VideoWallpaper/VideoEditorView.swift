//
//  VideoEditorView.swift
//  LiveWallpaper
//
//  Created by Carlos Felipe Araújo on 06/09/26.
//

import AVKit
import SwiftUI

struct VideoEditorView: View {
    @Environment(WallpaperWindowManager.self) private var manager

    @State private var videoURL: URL? = nil
    @State private var player: AVPlayer? = nil
    @State private var isApplied = false
    @State private var isDragging = false
    @State private var showUnsupportedAlert = false

    // MARK: - Body

    var body: some View {
        Form {
            // ── Preview / Drop Zone ─────────────────────────────────────────
            Section {
                dropZoneOrPreview
                    .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
            }

            // ── File info ───────────────────────────────────────────────────
            if let url = videoURL {
                Section("Arquivo") {
                    LabeledContent("Nome") {
                        Text(url.lastPathComponent)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    LabeledContent("Tamanho") {
                        Text(fileSize(url: url))
                            .foregroundStyle(.secondary)
                    }
                    Button("Trocar Vídeo", action: pickVideo)
                }
            }

            // ── Apply ────────────────────────────────────────────────
            Section {
                HStack {
                    if manager.isWallpaperActive {
                        Button("Parar", role: .destructive) {
                            manager.remove()
                            isApplied = false
                        }
                    }
                    Spacer()
                    Button(isApplied ? "Aplicado!" : "Aplicar Wallpaper") {
                        applyWallpaper()
                    }
                    .disabled(videoURL == nil)
                    .keyboardShortcut(.defaultAction)
                }
            } footer: {
                VStack(alignment: .leading, spacing: 6) {
                    Text("O vídeo será reproduzido em loop sem áudio.")
                    Text("Nota: O macOS não suporta vídeos com codec AV1 nativamente. Se a tela ficar cinza, certifique-se de que o vídeo está no formato H.264 (avc1).")
                }
                .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .alert("Formato não suportado", isPresented: $showUnsupportedAlert) {
            Button("OK") {}
        } message: {
            Text("Escolha um arquivo de vídeo (MP4, MOV, M4V).")
        }
    }

    // MARK: - Drop Zone / Preview

    @ViewBuilder
    private var dropZoneOrPreview: some View {
        if let player {
            AVPlayerViewRepresentable(player: player)
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(alignment: .bottomTrailing) {
                    Label("Loop", systemImage: "repeat")
                        .font(.caption2.weight(.medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(8)
                }
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isDragging
                        ? Color.accentColor.opacity(0.08)
                        : Color.primary.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(
                                isDragging ? Color.accentColor : Color.primary.opacity(0.18),
                                style: StrokeStyle(lineWidth: 1.5, dash: isDragging ? [] : [6, 5])
                            )
                    )

                VStack(spacing: 10) {
                    Image(systemName: "film.stack")
                        .font(.system(size: 28))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)

                    VStack(spacing: 3) {
                        Text(isDragging ? "Solte aqui" : "Arraste um vídeo aqui")
                            .font(.subheadline.weight(.medium))
                        Button("Escolher Arquivo…", action: pickVideo)
                            .buttonStyle(.plain)
                            .font(.subheadline)
                            .foregroundStyle(Color.accentColor)
                    }
                }
                .padding(.vertical, 32)
            }
            .animation(.spring(response: 0.25), value: isDragging)
            .onDrop(of: [.fileURL], isTargeted: $isDragging, perform: handleDrop)
            .onTapGesture(perform: pickVideo)
            .onDisappear {
                player?.pause()
            }
        }
    }

    // MARK: - Helpers

    private func pickVideo() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.movie, .mpeg4Movie, .quickTimeMovie]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.prompt = "Escolher"
        if panel.runModal() == .OK, let url = panel.url {
            loadVideo(url: url)
        }
    }

    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        provider.loadItem(forTypeIdentifier: "public.file-url", options: nil) { item, _ in
            guard let data = item as? Data,
                  let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
            DispatchQueue.main.async {
                let valid = ["mp4", "mov", "m4v", "avi", "mkv"]
                if valid.contains(url.pathExtension.lowercased()) {
                    loadVideo(url: url)
                } else {
                    showUnsupportedAlert = true
                }
            }
        }
        return true
    }

    private func loadVideo(url: URL) {
        videoURL = url
        isApplied = false
        let item = AVPlayerItem(url: url)
        let p = AVPlayer(playerItem: item)
        p.isMuted = true
        p.actionAtItemEnd = .none
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item, queue: .main
        ) { _ in p.seek(to: .zero); p.play() }
        p.play()
        player = p
    }

    private func clearVideo() {
        player?.pause(); player = nil; videoURL = nil; isApplied = false
    }

    private func applyWallpaper() {
        guard let url = videoURL else { return }
        manager.apply(mode: .video(url: url))
        withAnimation(.spring(response: 0.3)) { isApplied = true }
    }

    private func fileSize(url: URL) -> String {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attrs[.size] as? Int64 else { return "–" }
        let f = ByteCountFormatter()
        f.allowedUnits = [.useMB, .useGB]; f.countStyle = .file
        return f.string(fromByteCount: size)
    }
}

#Preview {
    VideoEditorView()
        .environment(WallpaperWindowManager.shared)
        .frame(width: 400)
}

struct AVPlayerViewRepresentable: NSViewRepresentable {
    let player: AVPlayer

    func makeNSView(context _: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.player = player
        view.controlsStyle = .none
        view.videoGravity = .resizeAspectFill
        return view
    }

    func updateNSView(_ nsView: AVPlayerView, context _: Context) {
        nsView.player = player
    }
}
