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
    
    // public so corners can be rounded
    let containerView: GeneralUIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private let iconView: GeneralUIImageView = {
        let iconView = GeneralUIImageView()
        
        iconView.image = UIImage(systemName: "crown")
        iconView.tintColor = .systemBackground
        
        return iconView
    }()
    
    private let displayFullNameLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        label.textColor = .systemBackground
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
            iconView.createSquareConstraint(),
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
