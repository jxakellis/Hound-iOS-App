//
//  LogsFilterUIInteractionDelegate.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/21/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit


final class LogsFilterUIInteractionDelegate: NSObject, UIGestureRecognizerDelegate {

    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
