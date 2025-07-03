//
//  GeneralUITableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/21/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class GeneralUITableViewController: UITableViewController, GeneralUIProtocol, GeneralUIKitProtocol {
    
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
            AppDelegate.generalLogger.warning("Attempting to re-invoke setupGeneratedViews for \(String(describing: type(of: self)))")
            return
        }
        didSetupConstraints = true
        return
    }
    
    // MARK: - Properties
    
    /// If true, upon viewIsAppearing and viewDidDisappear, the viewController will add or remove itself from the presentation manager's global presenter stack
    var eligibleForGlobalPresenter: Bool = false {
        didSet {
            if eligibleForGlobalPresenter == false {
                PresentationManager.removeGlobalPresenterFromStack(self)
            }
        }
    }
    
    var enableDummyHeaderView: Bool = false {
        didSet {
            if enableDummyHeaderView {
                let dummyTableTableHeaderViewHeight = 100.0
                // Adding a tableHeaderView prevents section headers from sticking and floating at the top of the page when we scroll up. This is because we are basically adding a large blank space to the top of the screen, allowing a space for the header to scroll into
                tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: dummyTableTableHeaderViewHeight))
                tableView.contentInset = UIEdgeInsets(top: -dummyTableTableHeaderViewHeight, left: 0, bottom: 0, right: 0)
            }
        }
    }
    
    var referenceContentOffsetY: CGFloat?
    
    // MARK: - Main
    
    convenience init() {
        self.init(style: .plain)
    }
    
    override func loadView() {
        super.loadView()
        applyDefaultSetup()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        if eligibleForGlobalPresenter {
            PresentationManager.addGlobalPresenterToStack(self)
        }
        
        if referenceContentOffsetY == nil {
            referenceContentOffsetY = tableView.contentOffset.y
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if eligibleForGlobalPresenter {
            PresentationManager.removeGlobalPresenterFromStack(self)
        }
    }
    
    // MARK: - Functions
    
    private func applyDefaultSetup() {
        self.tableView.contentMode = .scaleToFill
        self.tableView.showsHorizontalScrollIndicator = false
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        setupGeneratedViews()
    }
    
}
