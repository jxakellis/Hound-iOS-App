//
//  SettingsNotifsTableHeaderV.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/30/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsNotifsTableHeaderV: GeneralUIView {
    
    // MARK: - Elements
    
    private let contentView: GeneralUIView = GeneralUIView()
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Notifications"
        label.font = .systemFont(ofSize: 35)
        return label
    }()
    
    // MARK: - Additional UI Elements
    private let backButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 260, compressionResistancePriority: 260)
        
        button.tintColor = .label
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        
        button.shouldRoundCorners = true
        button.shouldDismissParentViewController = true
        return button
    }()
    
    // MARK: - Properties
    
    private static let topConstraint = 0.0
    private static let heightConstraint = 40.0
    private static let bottomConstraint = 0.0
    
    static var cellHeight: Double {
        topConstraint + heightConstraint + bottomConstraint
    }
    
    // MARK: - Setup
    
    func setup(forTitle: String) {
        headerLabel.text = forTitle
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        contentView.frame = bounds
        addSubview(contentView)
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(backButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: SettingsNotifsTableHeaderV.topConstraint),
            headerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: SettingsNotifsTableHeaderV.bottomConstraint),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.heightAnchor.constraint(equalToConstant: SettingsNotifsTableHeaderV.heightConstraint),
            
            backButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: -10),
            backButton.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 10),
            backButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor),
            backButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 50 / 414),
            backButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 25),
            backButton.heightAnchor.constraint(lessThanOrEqualToConstant: 75)
            
        ])
        
    }
}
