//
//  HoundUIProtocol.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/10/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import Foundation

protocol HoundUIProtocol {
    /// Open ended field to be used for extra information if needed in certain use cases
    var properties: JSONRequestBody { get set }
}

protocol HoundUIKitProtocol {
    func setupGeneratedViews()
    func addSubViews()
    func setupConstraints()
}
