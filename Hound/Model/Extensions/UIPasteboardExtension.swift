//
//  UIPasteboardExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/3/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UIPasteboard {
    /// Assigns UIPasteboard.general.string to string then shows a banner to confirm to the user that the specified information was copied.
    func setPasteboard(string: String) {
        UIPasteboard.general.string = string

        PresentationManager.enqueueBanner(title: Constant.Visual.BannerText.copiedToClipboardTitle, subtitle: Constant.Visual.BannerText.copiedToClipboardSubtitle, style: .success)
    }
}
