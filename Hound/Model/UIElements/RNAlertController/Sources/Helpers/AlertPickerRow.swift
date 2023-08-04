//
//  AlertPickerRow.swift
//  RNAlertController
//
//  Created by Rayhan on 28/10/19.
//  Copyright © 2019 Rayhan Nabi. All rights reserved.
//

import Foundation

/// An object which identifies the row of a picker view.
public class AlertPickerRow: NSObject {

    /// Selected index starting from 0.
    public let index: Int

    /// Title for the row.
    public let title: String

    init(index: Int, title: String) {
        self.index = index
        self.title = title
    }
}
