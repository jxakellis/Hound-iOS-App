//
//  UIScrollViewExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/8/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UIScrollView {
    func onlyScrollIfBigger() {
        // Only bounce if content is larger
        self.alwaysBounceVertical = false
        // Allow bounce if scrollable
        self.bounces = true
        // Default: scrolling is enabled if needed
        self.isScrollEnabled = true
    }
}
