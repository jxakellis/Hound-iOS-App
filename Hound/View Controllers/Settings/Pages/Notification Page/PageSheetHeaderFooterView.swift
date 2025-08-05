//
//  SettingsNotifsTableHeaderV.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/30/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class PageSheetHeaderFooterView: HoundHeaderFooterView {
    
    // MARK: - Elements
    
    private let pageSheetHeaderView = HoundPageSheetHeaderView()
    
    // MARK: - Setup
    
    func setup(title: String) {
        pageSheetHeaderView.pageHeaderLabel.text = title
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(pageSheetHeaderView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        NSLayoutConstraint.activate([
            pageSheetHeaderView.topAnchor.constraint(equalTo: contentView.topAnchor),
            // Use .high priority to avoid breaking during table view height estimation
            pageSheetHeaderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constant.Constraint.Spacing.contentTallIntraVert).withPriority(.defaultHigh),
            pageSheetHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pageSheetHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
}
