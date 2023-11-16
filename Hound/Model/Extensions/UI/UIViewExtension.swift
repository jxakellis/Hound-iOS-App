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
    func dismissKeyboardOnTap(delegate: UIGestureRecognizerDelegate) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(self.dismissKeyboard)
        )

        tap.delegate = delegate
        tap.cancelsTouchesInView = false
        
        self.addGestureRecognizer(tap)
    }

    /// Invokes endEditing(true). This method looks at the current view and its subview hierarchy for the text field that is currently the first responder. If it finds one, it asks that text field to resign as first responder. If the force parameter is set to true, the text field is never even asked; it is forced to resign.
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }

    enum SetRoundedCorners {
        case none
        case top
        case bottom
        case all
    }
    func roundCorners(setCorners: SetRoundedCorners) {
        switch setCorners {
        case .none:
            self.layer.maskedCorners = []
        case .top:
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .bottom:
            self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .all:
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        }

        self.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius
        self.layer.cornerCurve = .continuous
    }

    enum AddRoundedCorners {
        case top
        case bottom
        case all
    }
    func roundCorners(addCorners: AddRoundedCorners) {
        switch addCorners {
        case .top:
            self.layer.maskedCorners.insert([.layerMinXMinYCorner, .layerMaxXMinYCorner])
        case .bottom:
            self.layer.maskedCorners.insert([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        case .all:
            self.layer.maskedCorners.insert([.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        }

        self.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius
        self.layer.cornerCurve = .continuous
    }

    var closestParentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
