//
//  GradientWallpaperView.swift
//  LiveWallpaper
//
//  Created by Carlos Felipe Araújo on 06/09/26.
//

import SwiftUI

// MARK: - Direction

enum GradientDirection: String, CaseIterable, Identifiable {
    case horizontal = "Horizontal"
    case vertical = "Vertical"
    case diagonalDown = "Diagonal ↘"
    case diagonalUp = "Diagonal ↙"

    var id: String { rawValue }

    var startPoint: UnitPoint {
        switch self {
        case .horizontal: return .leading
        case .vertical: return .top
        case .diagonalDown: return .topLeading
        case .diagonalUp: return .topTrailing
        }
    }

    var endPoint: UnitPoint {
        switch self {
        case .horizontal: return .trailing
        case .vertical: return .bottom
        case .diagonalDown: return .bottomTrailing
        case .diagonalUp: return .bottomLeading
        }
    }

    var systemImage: String {
        switch self {
        case .horizontal: return "arrow.right"
        case .vertical: return "arrow.down"
        case .diagonalDown: return "arrow.down.right"
        case .diagonalUp: return "arrow.down.left"
        }
    }
}

// MARK: - View

struct GradientWallpaperView: View {
    let colors: [Color]
    let direction: GradientDirection

    var body: some View {
        LinearGradient(
            colors: colors.isEmpty ? [.black] : colors,
            startPoint: direction.startPoint,
            endPoint: direction.endPoint
        )
        .ignoresSafeArea()
    }
}

#Preview {
    GradientWallpaperView(
        colors: [.purple, .indigo, .blue],
        direction: .horizontal
    )
    .frame(width: 400, height: 300)
}
