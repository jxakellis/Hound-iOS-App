//
//  SettingsNotificationsTableHeaderView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/30/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsNotificationsTableHeaderView: UIView {

    // MARK: - IB
    
    @IBOutlet private var contentView: UIView!
    
    @IBOutlet private weak var headerLabel: GeneralUILabel!
    @IBOutlet private weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    private static let topConstraint = 0.0
    private static let heightConstraint = 40.0
    private static let bottomConstraint = 0.0
    
    static var cellHeight: Double {
        return topConstraint + heightConstraint + bottomConstraint
    }
    
    // MARK: - Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeSubviews()
    }
    
    /// Setup components of the view that don't depend upon data provided by an external source
    private func initializeSubviews() {
        _ = UINib(nibName: "SettingsNotificationsTableHeaderView", bundle: nil).instantiate(withOwner: self)
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    // MARK: - Functions
    
    func setup(forTitle: String) {
        headerLabel.text = forTitle
        headerTopConstraint.constant = SettingsNotificationsTableHeaderView.topConstraint
        headerHeightConstraint.constant = SettingsNotificationsTableHeaderView.heightConstraint
        headerBottomConstraint.constant = SettingsNotificationsTableHeaderView.bottomConstraint
    }

}
