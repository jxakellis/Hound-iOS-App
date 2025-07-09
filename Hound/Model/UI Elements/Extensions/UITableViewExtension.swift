//
//  UITableViewExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/8/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UITableView {
    /// Reloads all sections with the provided animation. If the number of
    /// sections changes, performs a cross dissolve on the entire table to avoid
    /// update crashes. Optionally animates layout changes for the supplied view
    /// so surrounding UI updates smoothly alongside the table.
    func reloadDataAnimated(animatingLayoutOf layoutView: UIView? = nil) {
        let previousSectionCount = self.numberOfSections
        let newSectionCount = self.dataSource?.numberOfSections?(in: self) ?? previousSectionCount

        if previousSectionCount > newSectionCount {
            UIView.transition(with: layoutView ?? self,
                              duration: VisualConstant.AnimationConstant.showMultipleElements,
                              options: .transitionCrossDissolve) {
                self.reloadData()
                layoutView?.setNeedsLayout()
                layoutView?.layoutIfNeeded()
            }
            return
        }
        else if previousSectionCount < newSectionCount {
            UIView.transition(with: layoutView ?? self,
                              duration: VisualConstant.AnimationConstant.hideMultipleElements,
                              options: .transitionCrossDissolve) {
                self.reloadData()
                layoutView?.setNeedsLayout()
                layoutView?.layoutIfNeeded()
            }
            return
        }

        guard previousSectionCount > 0 else {
            self.reloadData()
            UIView.animate(withDuration: VisualConstant.AnimationConstant.showMultipleElements) {
                layoutView?.setNeedsLayout()
                layoutView?.layoutIfNeeded()
            }
            return
        }

        let indexSet = IndexSet(integersIn: 0 ..< previousSectionCount)
        self.reloadSections(indexSet, with: .fade)

        UIView.animate(withDuration: VisualConstant.AnimationConstant.showMultipleElements) {
            layoutView?.setNeedsLayout()
            layoutView?.layoutIfNeeded()
        }
    }
}
