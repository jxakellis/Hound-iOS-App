//
//  GeneralUIHeaderFooterView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/25/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

class GeneralUIHeaderFooterView: UITableViewHeaderFooterView, GeneralUIProtocol, GeneralUIKitProtocol {
    
    // MARK: - GeneralUIProtocol
    
    var properties: [String: CompatibleDataTypeForJSON?] = [:]
    
    // MARK: - GeneralUIProtocol
    
    private var didSetupGeneratedViews = false
    internal func setupGeneratedViews() {
        guard !didSetupGeneratedViews else {
            AppDelegate.generalLogger.warning("Attempting to re-invoke setupGeneratedViews for \(String(describing: type(of: self)))")
            return
        }
        didSetupGeneratedViews = true
        
        applyDefaultSetup()
        
        addSubViews()
        setupConstraints()
    }
    
    private var didAddSubViews = false
    internal func addSubViews() {
        guard !didAddSubViews else {
            AppDelegate.generalLogger.warning("Attempting to re-invoke setupGeneratedViews for \(String(describing: type(of: self)))")
            return
        }
        didAddSubViews = true
        return
    }
    
    private var didSetupConstraints = false
    internal func setupConstraints() {
        guard !didSetupConstraints else {
            AppDelegate.generalLogger.warning("Attemptng to re-invoke setupGeneratedViews for \(String(describing: type(of: self)))")
            return
        }
        didSetupConstraints = true
        return
    }
    
    // MARK: - Main
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupGeneratedViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        fatalError("XIB is not supported")
    }
    
    // MARK: - Functions
    
    private func applyDefaultSetup() {
    }
    
}
