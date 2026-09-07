//
//  CaffeinateManager.swift
//  LiveWallpaper
//
//  Created by Carlos Felipe Araújo on 07/09/26.
//

import Foundation
import Observation

@Observable
@MainActor
final class CaffeinateManager {
    static let shared = CaffeinateManager()

    var isCaffeinated = false {
        didSet {
            if isCaffeinated {
                startCaffeinate()
            } else {
                stopCaffeinate()
            }
        }
    }

    private var activityToken: NSObjectProtocol?

    private init() {}

    private func startCaffeinate() {
        guard activityToken == nil else { return }
        // Previne que o sistema ou o display durmam
        activityToken = ProcessInfo.processInfo.beginActivity(
            options: [.userInitiated, .idleSystemSleepDisabled, .idleDisplaySleepDisabled],
            reason: "LiveWallpaper Caffeinated Mode"
        )
    }

    private func stopCaffeinate() {
        if let token = activityToken {
            ProcessInfo.processInfo.endActivity(token)
            activityToken = nil
        }
    }
}
