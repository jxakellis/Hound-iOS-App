//
//  SettingsNotifsTableHeaderV.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/30/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class PageSheetHeaderFooterView: GeneralUIHeaderFooterView {
    
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
            // when table view is calculating the height of this view, it might assign a UIView-Encapsulated-Layout-Height which is invalid (too big or too small) for pageSheetHeaderView. This would cause a unresolvable constraints error, causing one of them to break. However, since this is temporary when it calculates the height, we can avoid this .defaultHigh constraint that temporarily turns off
            pageSheetHeaderView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Spacing.contentTallIntraVert).withPriority(.defaultHigh),
            pageSheetHeaderView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pageSheetHeaderView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
}
