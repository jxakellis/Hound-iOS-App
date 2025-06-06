//
//  SettingsPagesTableHeaderView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/28/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsPagesTableHeaderView: GeneralUIView {

    // MARK: - Elements

    private let contentView: GeneralUIView = GeneralUIView()

    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.text = "Options"
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
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

    // MARK: - Functions

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
        contentView.addSubview(headerLabel)
    }

    override func setupConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: SettingsPagesTableHeaderView.topConstraint),
            headerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -SettingsPagesTableHeaderView.bottomConstraint),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            headerLabel.heightAnchor.constraint(equalToConstant: SettingsPagesTableHeaderView.heightConstraint)
        
        ])
        
    }
}
