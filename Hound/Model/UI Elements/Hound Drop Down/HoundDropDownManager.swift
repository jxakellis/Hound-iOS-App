//
//  HoundDropDownManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/23/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol HoundDropDownManagerDelegate: AnyObject {
    func willShowDropDown(_ identifier: String, animated: Bool)
}

/// Manages multiple `HoundDropDown` instances so callers don't repeat setup code.
/// Each dropdown is referenced by a unique string identifier.
final class HoundDropDownManager {

    /// Internal representation of a registered drop down
    private struct Entry {
        weak var label: HoundLabel?
        var dropDown: HoundDropDown?
    }

    private unowned let rootView: UIView
    private let dataSource: HoundDropDownDataSource
    private unowned let delegate: HoundDropDownManagerDelegate
    private let rowHeight: CGFloat
    private let offset: CGFloat

    // Preserve the registration order so drop downs are stacked correctly
    private var order: [String] = []
    private var entries: [String: Entry] = [:]

    init(rootView: UIView, dataSource: HoundDropDownDataSource, delegate: HoundDropDownManagerDelegate, rowHeight: CGFloat = HoundDropDown.rowHeightForHoundLabel, offset: CGFloat = Constant.Constraint.Spacing.contentTightIntraVert) {
        self.rootView = rootView
        self.dataSource = dataSource
        self.delegate = delegate
        self.rowHeight = rowHeight
        self.offset = offset
    }

    /// Register a label that will trigger/show a dropdown with the identifier.
    func register(identifier: String, label: HoundLabel) {
        if entries[identifier] == nil {
            order.append(identifier)
        }
        entries[identifier] = Entry(label: label, dropDown: entries[identifier]?.dropDown)
    }

    /// Returns the managed dropdown for identifier if it exists
    func dropDown(for identifier: String) -> HoundDropDown? {
        return entries[identifier]?.dropDown
    }
    
    func label(for identifier: String) -> HoundLabel? {
        return entries[identifier]?.label
    }

    /// Show the drop down corresponding to `identifier`.
    /// If a drop down hasn't been created yet one will be lazily instantiated.
    func show(identifier: String, numberOfRowsToShow numberOfRows: CGFloat, animated: Bool) {
        guard let label = entries[identifier]?.label else { return }
        var entry = entries[identifier] ?? Entry(label: label, dropDown: nil)

        let referenceFrame = label.superview?.convert(label.frame, to: rootView) ?? label.frame

        if entry.dropDown == nil {
            let drop = HoundDropDown()
            drop.setupDropDown(
                forHoundDropDownIdentifier: identifier,
                forDataSource: dataSource,
                forViewPositionReference: referenceFrame,
                forOffset: offset,
                forRowHeight: rowHeight
            )
            entry.dropDown = drop
            entries[identifier] = entry
        }

        reorderDropDowns()
        entry.dropDown?.showDropDown(numberOfRowsToShow: numberOfRows, animated: animated)
    }

    /// Hide the dropdown for identifier if it is currently showing
    func hide(identifier: String, animated: Bool) {
        entries[identifier]?.dropDown?.hideDropDown(animated: animated)
    }

    /// Remove and re-add drop downs so they appear stacked using registration order
    private func reorderDropDowns() {
        let dropDowns = order.compactMap { entries[$0]?.dropDown }
        dropDowns.forEach { $0.removeFromSuperview() }
        for dropDown in dropDowns.reversed() { rootView.addSubview(dropDown) }
    }
    
    @objc func didTapLabel(sender: UITapGestureRecognizer) {
        guard let name = sender.name, let dropDown = dropDown(for: name) else {
            HoundLogger.general.warning("HoundDropDownManager.tappedDropDownLabel: No drop down found for identifier \(String(describing: sender.name))")
            return
        }
        
        if !dropDown.isDown {
            delegate.willShowDropDown(name, animated: true)
        }
        else {
            dropDown.hideDropDown(animated: true)
        }
    }
    
    @objc func hideDropDownIfNotTapped(sender: UITapGestureRecognizer) {
        guard let senderView = sender.view else { return }
        
        let point = sender.location(in: senderView)
        guard let touched = senderView.hitTest(point, with: nil) else { return }
        
        for (identifier, entry) in entries {
            guard let dd = entry.dropDown, let label = entry.label else { continue }
            
            if !touched.isDescendant(of: label) && !touched.isDescendant(of: dd) {
                dd.hideDropDown(animated: true)
            }
        }
    }
}
