//
//  UIViewExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/20/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Once called, any future taps to the view will call dismissKeyboard
    func setupDismissKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.dismissKeyboard)
        )
        
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
    
    /// Invokes endEditing(true)
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
}
