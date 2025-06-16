//
//  SettingsFamilyHeadTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/5/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsFamilyHeadTVC: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    let containerView: GeneralUIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private let displayFullNameLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        label.textColor = .systemBackground
        return label
    }()
    
    private let iconView: GeneralUIImageView = {
        let iconView = GeneralUIImageView()
        
        iconView.image = UIImage(systemName: "crown")
        iconView.tintColor = .systemBackground
        
        return iconView
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsFamilyHeadTVC"
    
    // MARK: - Setup
    
    func setup(forDisplayFullName displayFullName: String) {
        displayFullNameLabel.text = displayFullName
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(displayFullNameLabel)
        
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // iconView
        let iconTop = iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 5)
        let iconBottom = iconView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5)
        let iconLeading = iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5)
        let iconWidth = iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor)
        let iconHeight = iconView.heightAnchor.constraint(equalToConstant: 50)
        
        // displayFullNameLabel
        let nameTop = displayFullNameLabel.topAnchor.constraint(equalTo: iconView.topAnchor)
        let nameBottom = displayFullNameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -5)
        let nameLeading = displayFullNameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 5)
        let nameTrailing = displayFullNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
        
        // containerView
        let containerTop = containerView.topAnchor.constraint(equalTo: contentView.topAnchor)
        let containerBottom = containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        let containerLeading = containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        let containerTrailing = containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        
        NSLayoutConstraint.activate([
            iconTop, iconBottom, iconLeading, iconWidth, iconHeight,
            nameTop, nameBottom, nameLeading, nameTrailing,
            containerTop, containerBottom, containerLeading, containerTrailing
        ])
    }

}
