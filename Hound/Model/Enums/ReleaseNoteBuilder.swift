//
//  ReleaseNoteBuilder.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/28/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

struct ReleaseNoteItem {
    let title: String
    let description: String
}

struct ReleaseNotesBuilder {
    private var items: [ReleaseNoteItem] = []

    mutating func addFeature(title: String, description: String) {
        items.append(ReleaseNoteItem(title: title, description: description))
    }

    func buildAttributedString() -> NSAttributedString {
        let message = NSMutableAttributedString()

        for item in items {
            let titleAttr: [NSAttributedString.Key: Any] = [.font: Constant.Visual.Font.emphasizedPrimaryRegularLabel]
            let descAttr: [NSAttributedString.Key: Any] = [.font: Constant.Visual.Font.primaryRegularLabel]

            message.append(NSAttributedString(string: "\u{2022} \(item.title)\n", attributes: titleAttr))
            message.append(NSAttributedString(string: item.description, attributes: descAttr))
            message.append(NSAttributedString(string: "\n\n"))
        }
        return message
    }
}
