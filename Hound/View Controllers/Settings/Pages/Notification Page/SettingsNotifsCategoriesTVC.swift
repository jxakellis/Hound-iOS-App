//
//  SettingsNotifsCategoriesTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/6/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsCategoriesTVC: GeneralUITableViewCell {
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(290), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(290), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(790), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(790), for: .vertical)
        label.text = "Notification Categories"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(280), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(280), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .vertical)
        label.text = "By default, Hound will send notifications about your account, family, logs, and reminders."
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12.5, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let chevonImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 300, compressionResistancePriority: 800)

        imageView.alpha = 0.75
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemGray4
        
        return imageView
    }()
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        contentView.addSubview(headerLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(chevonImageView)
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: 25),
            
            chevonImageView.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 5),
            chevonImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            chevonImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            chevonImageView.widthAnchor.constraint(equalTo: chevonImageView.heightAnchor, multiplier: 1/1.5),
            chevonImageView.widthAnchor.constraint(equalTo: headerLabel.heightAnchor, multiplier: 20/25),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 7.5),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            descriptionLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            
        ])
        
    }
}

