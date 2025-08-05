//
//  HoundDropDownManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/23/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol HoundDropDownManagerDelegate: AnyObject {
    func willShowDropDown(_ identifier: any HoundDropDownType, animated: Bool)
}

/// Manages multiple `HoundDropDown` instances so callers don't repeat setup code.
/// Each dropdown is referenced by a unique string identifier.
final class HoundDropDownManager<T: HoundDropDownType> {
    typealias Identifier = T
    
    /// Internal representation of a registered drop down
    private struct Entry {
        weak var label: HoundLabel?
        var dropDown: HoundDropDown<T>?
        var direction: HoundDropDownDirection
        var autoscroll: HoundDropDownAutoscroll
    }
    
    // MARK: - Properties
    
    private unowned let rootView: UIView
    private let dataSource: HoundDropDownDataSource
    private unowned let delegate: HoundDropDownManagerDelegate
    private let offset: CGFloat
    
    // Preserve the registration order so drop downs are stacked correctly
    private var order: [Identifier] = []
    private var entries: [Identifier: Entry] = [:]
    
    // MARK: - Main
    
    init(rootView: UIView, dataSource: HoundDropDownDataSource, delegate: HoundDropDownManagerDelegate, offset: CGFloat = Constant.Constraint.Spacing.contentTightIntraVert) {
        self.rootView = rootView
        self.dataSource = dataSource
        self.delegate = delegate
        self.offset = offset
    }
    
    // MARK: - Functions
    
    /// Register a label that will trigger/show a dropdown with the identifier.
    func register(
        identifier: Identifier,
        label: HoundLabel,
        direction: HoundDropDownDirection = .down,
        autoscroll: HoundDropDownAutoscroll = .never
    ) {
        if entries[identifier] == nil {
            order.append(identifier)
        }
        entries[identifier] = Entry(
            label: label,
            dropDown: entries[identifier]?.dropDown,
            direction: direction,
            autoscroll: autoscroll
        )
    }
    
    /// Returns the managed dropdown for identifier if it exists
    func dropDown(for identifier: Identifier) -> HoundDropDown<T>? {
        return entries[identifier]?.dropDown
    }
    
    func label(for identifier: Identifier) -> HoundLabel? {
        return entries[identifier]?.label
    }
    
    /// Show the drop down corresponding to `identifier`.
    /// If a drop down hasn't been created yet one will be lazily instantiated.
    func show(identifier: Identifier, numberOfRowsToShow numberOfRows: CGFloat, animated: Bool) {
        guard let label = entries[identifier]?.label else { return }
        var entry = entries[identifier] ?? Entry(label: label, dropDown: nil, direction: .down, autoscroll: .never)
        
        let referenceFrame = label.superview?.convert(label.frame, to: rootView) ?? label.frame
        
        if entry.dropDown == nil {
            let drop = HoundDropDown<T>()
            drop.setupDropDown(
                identifier: identifier,
                dataSource: dataSource,
                viewPositionReference: referenceFrame,
                offset: offset,
                direction: entry.direction,
                autoscrollBehavior: entry.autoscroll,
            )
            entry.dropDown = drop
            entries[identifier] = entry
        }
        else {
            entry.dropDown?.updateReferenceFrame(referenceFrame)
        }
        
        reorderDropDowns()
        entry.dropDown?.showDropDown(numberOfRowsToShow: numberOfRows, animated: animated, direction: entry.direction)
    }
    
    /// Hide the dropdown for identifier if it is currently showing
    func hide(identifier: Identifier, animated: Bool) {
        entries[identifier]?.dropDown?.hideDropDown(animated: animated)
    }
    
    /// Remove and re-add drop downs so they appear stacked using registration order
    private func reorderDropDowns() {
        let dropDowns = order.compactMap { entries[$0]?.dropDown }
        dropDowns.forEach { $0.removeFromSuperview() }
        for dropDown in dropDowns.reversed() { rootView.addSubview(dropDown) }
    }
    
    func showHideDropDownGesture(identifier: Identifier, delegate: UIGestureRecognizerDelegate) -> UITapGestureRecognizer {
        let gesture = UITapGestureRecognizer(
            target: self,
            action: #selector(HoundDropDownManager.didTapLabel(sender:))
        )
        gesture.name = identifier.rawValue
        gesture.self.delegate = delegate
        gesture.cancelsTouchesInView = false
        return gesture
    }
    
    @objc private func didTapLabel(sender: UITapGestureRecognizer) {
        guard let name = sender.name, let identifier = Identifier(rawValue: name) else {
            HoundLogger.general.warning("HoundDropDownManager.tappedDropDownLabel: No drop down found for identifier \(String(describing: sender.name))")
            return
        }
        
        guard let dropDown = dropDown(for: identifier) else {
            delegate.willShowDropDown(identifier, animated: true)
            return
        }
        
        if !dropDown.isDown {
            delegate.willShowDropDown(identifier, animated: true)
        }
        else {
            dropDown.hideDropDown(animated: true)
        }
    }
    
    @discardableResult
    func hideDropDownIfNotTapped(sender: UITapGestureRecognizer) -> [HoundDropDown<T>] {
        guard let senderView = sender.view else { return [] }
        
        let point = sender.location(in: senderView)
        guard let touched = senderView.hitTest(point, with: nil) else { return [] }
        
        var dropDownsHidden: [HoundDropDown<T>] = []
        for (_, entry) in entries {
            guard let dd = entry.dropDown, let label = entry.label else { continue }
            
            if !touched.isDescendant(of: label) && !touched.isDescendant(of: dd) {
                dd.hideDropDown(animated: true)
                dropDownsHidden.append(dd)
            }
        }
        return dropDownsHidden
    }
}
