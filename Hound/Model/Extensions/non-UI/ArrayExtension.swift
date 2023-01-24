//
//  ArrayExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 10/18/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import Foundation

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }

        return self[index]
    }
}
