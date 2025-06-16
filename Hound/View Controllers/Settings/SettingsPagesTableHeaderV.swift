//
//  SettingsPagesTableHeaderV.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/28/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsPagesTableHeaderV: GeneralUIView {
    
    // MARK: - Elements
    
    private let contentView: GeneralUIView = GeneralUIView()
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Options"
        label.font = .systemFont(ofSize: 25)
        return label
    }()
    
    // MARK: - Properties
    
    private static let topConstraint = 10.0
    private static let heightConstraint = 25.0
    private static let bottomConstraint = 10.0
    
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
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // headerLabel
        let headerTopConstraint = headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: SettingsPagesTableHeaderV.topConstraint)
        let headerBottomConstraint = headerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -SettingsPagesTableHeaderV.bottomConstraint)
        let headerLeadingConstraint = headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        let headerTrailingConstraint = headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        let headerHeightConstraint = headerLabel.heightAnchor.constraint(equalToConstant: SettingsPagesTableHeaderV.heightConstraint)
        
        NSLayoutConstraint.activate([
            headerTopConstraint, headerBottomConstraint,
            headerLeadingConstraint, headerTrailingConstraint,
            headerHeightConstraint
        ])
    }
}
