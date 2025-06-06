//
//  GeneralUIProtocol.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/10/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation

protocol GeneralUIProtocol {
    /// Open ended field to be used for extra information if needed in certain use cases
    var properties: [String: CompatibleDataTypeForJSON?] { get set }
}

protocol GeneralUIKitProtocol {
    func setupGeneratedViews()
    func addSubViews()
    func setupConstraints()
}
