//
//  SettingsFamilyHeadTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/5/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsFamilyHeadTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    // public so corners can be rounded
    let containerView: HoundView = {
        let view = HoundView()
        view.backgroundColor = UIColor.systemBlue
        return view
    }()
    
    private let iconView: HoundImageView = {
        let iconView = HoundImageView()
        
        iconView.image = UIImage(systemName: "crown")
        iconView.tintColor = UIColor.systemBackground
        
        return iconView
    }()
    
    private let displayFullNameLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        label.textColor = UIColor.systemBackground
        return label
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
        
        let inset: CGFloat = 5
        let iconSize: CGFloat = 50
        
        // containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        // iconView
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: inset),
            iconView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -inset),
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: inset),
            iconView.createSquareAspectRatio(),
            iconView.heightAnchor.constraint(equalToConstant: iconSize)
        ])
        
        // displayFullNameLabel
        NSLayoutConstraint.activate([
            displayFullNameLabel.centerYAnchor.constraint(equalTo: iconView.centerYAnchor),
            displayFullNameLabel.heightAnchor.constraint(equalTo: iconView.heightAnchor),
            displayFullNameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: inset),
            displayFullNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -inset)
        ])
    }

}
