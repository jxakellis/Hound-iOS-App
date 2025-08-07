//
//  HoundTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/6/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

class HoundTableViewCell: UITableViewCell, HoundUIProtocol, HoundUIKitProtocol {
    
    // MARK: - HoundUIProtocol
    
    var properties: JSONRequestBody = [:]
    
    // MARK: - HoundUIProtocol
    
    private var didSetupGeneratedViews = false
    internal func setupGeneratedViews() {
        guard !didSetupGeneratedViews else {
            HoundLogger.general.warning("SomeHoundView.setupGeneratedViews: Attempting to re-invoke setupGeneratedViews for \(String(describing: type(of: self)))")
            return
        }
        didSetupGeneratedViews = true
        
        addSubViews()
        setupConstraints()
    }
    
    private var didAddSubViews = false
    internal func addSubViews() {
        guard !didAddSubViews else {
            HoundLogger.general.warning("SomeHoundView.addSubViews: Attempting to re-invoke addSubViews for \(String(describing: type(of: self)))")
            return
        }
        didAddSubViews = true
        return
    }
    
    private var didSetupConstraints = false
    internal func setupConstraints() {
        guard !didSetupConstraints else {
            HoundLogger.general.warning("SomeHoundView.setupConstraints: Attempting to re-invoke setupConstraints for \(String(describing: type(of: self)))")
            return
        }
        didSetupConstraints = true
        return
    }
    
    // MARK: - Properties
    
    /// The closest parent `UITableView` in the view hierarchy, if any.
    var closestTableView: UITableView? {
        var view: UIView? = self.superview
        while let current = view {
            if let tableView = current as? UITableView {
                return tableView
            }
            view = current.superview
        }
        return nil
    }
    
    // MARK: - Main
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        applyDefaultSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fatalError("XIB is not supported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkForOversizedFrame()
    }
    
    // MARK: - Functions
    
    private func applyDefaultSetup() {
        selectionStyle = .none
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        selectedBackgroundView?.backgroundColor = UIColor.clear
        
        setupGeneratedViews()
    }
    
    /// Recalculates the cell's height within its containing table view.
    func updateTableViewHeight() {
        setNeedsLayout()
        layoutIfNeeded()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let tableView = self.closestTableView, self.window != nil else { return }
            
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
}
