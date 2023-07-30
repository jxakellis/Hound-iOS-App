//
//  SettingsPagesTableHeaderView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/28/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsPagesTableHeaderView: UIView {
    
    // MARK: - IB
    
    @IBOutlet private var contentView: UIView!
    
    @IBOutlet private weak var headerLabel: GeneralUILabel!
    @IBOutlet private weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    private static let topConstraint = 10.0
    private static let heightConstraint = 25.0
    private static let bottomConstraint = 10.0
    
    static var cellHeight: Double {
        return topConstraint + heightConstraint + bottomConstraint
    }
    
    // MARK: - Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initalizeSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initalizeSubviews()
    }
    
    /// Setup components of the view that don't depend upon data provided by an external source
    private func initalizeSubviews() {
        _ = UINib(nibName: "SettingsPagesTableHeaderView", bundle: nil).instantiate(withOwner: self)
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    // MARK: - Functions
    
    func setup(forTitle: String) {
        headerLabel.text = forTitle
        headerTopConstraint.constant = SettingsPagesTableHeaderView.topConstraint
        headerHeightConstraint.constant = SettingsPagesTableHeaderView.heightConstraint
        headerBottomConstraint.constant = SettingsPagesTableHeaderView.bottomConstraint
    }
}
