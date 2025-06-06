//
//  SettingsFamilyHeadTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/5/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsFamilyHeadTableViewCell: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    let containerView: UIView = {
        let view = UIView()
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private let displayFullNameLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.textColor = .systemBackground
        return label
    }()
    
    // MARK: - Additional UI Elements
    private let iconView: GeneralUIImageView = {
        let iconView = GeneralUIImageView()
        
        iconView.image = UIImage(systemName: "crown")
        iconView.tintColor = .systemBackground
        
        return iconView
    }()
    
    // MARK: - Functions
    
    func setup(forDisplayFullName displayFullName: String) {
        displayFullNameLabel.text = displayFullName
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(displayFullNameLabel)
        
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5),
            iconView.bottomAnchor.constraint(equalTo: displayFullNameLabel.bottomAnchor),
            iconView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5),
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor, multiplier: 1 / 1),
            iconView.heightAnchor.constraint(equalToConstant: 50),
            
            displayFullNameLabel.topAnchor.constraint(equalTo: iconView.topAnchor),
            displayFullNameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 5),
            displayFullNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            
        ])
        
    }
}
