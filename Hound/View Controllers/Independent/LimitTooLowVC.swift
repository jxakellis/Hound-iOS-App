//
//  LimitTooLowViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/6/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LimitTooLowViewController: BluePawVC {
    
    // MARK: - Elements
    
    private let bigBackButton: HoundButton = {
        let button = HoundButton()
        
        button.setTitle("Back", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = Constant.VisualFont.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
         button.applyStyle(.labelBorder)
        
        button.shouldDismissParentViewController = true
        
        return button
    }()
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        backButton.isHidden = true
        headerLabel.text = "Hound+ Subscription Needed"
        descriptionLabel.text = "You're trying to join a Hound family with a limited number of family members! Please have the family head upgrade to a Hound+ subscription before attempting to join."
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(bigBackButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        // backButton
        NSLayoutConstraint.activate([
            bigBackButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 35),
            bigBackButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bigBackButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bigBackButton.createHeightMultiplier(Constant.Constraint.Button.wideHeightMultiplier, relativeToWidthOf: contentView),
            bigBackButton.createMaxHeight(Constant.Constraint.Button.wideMaxHeight)
        ])
    }
}
