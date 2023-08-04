//
//  ArrayExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 10/18/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

extension Array {
    func safeIndex(_ index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
