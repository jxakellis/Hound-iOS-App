//
//  UIViewExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/20/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UIView {
    
    /// Once called, any future taps to the view will call dismissKeyboard.
    func setupDismissKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.dismissKeyboard)
        )
        
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
    
    /// Invokes endEditing(true). This method looks at the current view and its subview hierarchy for the text field that is currently the first responder. If it finds one, it asks that text field to resign as first responder. If the force parameter is set to true, the text field is never even asked; it is forced to resign.
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
}
