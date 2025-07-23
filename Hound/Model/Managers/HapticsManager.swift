//
//  HapticsManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/22/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum HapticsManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard UserConfiguration.isHapticsEnabled else { return }
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    static func selectionChanged() {
        guard UserConfiguration.isHapticsEnabled else { return }
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard UserConfiguration.isHapticsEnabled else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
}
