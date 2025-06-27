//
//  SettingsNotifsTableHeaderV.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/30/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SettingsNotifsTableHeaderView: GeneralUIHeaderFooterView {
    
    // MARK: - Elements
    
    private let pageSheetHeaderView = PageSheetHeaderView()
    
    // MARK: - Setup
    
    func setup(forTitle: String) {
        pageSheetHeaderView.pageHeaderLabel.text = forTitle
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
            pageSheetHeaderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Spacing.headerVertSpacingToSection),
            pageSheetHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pageSheetHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
}
