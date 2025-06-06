//
//  SettingsFamilyMemberTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/5/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsFamilyMemberTableViewCell: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    let containerView: UIView = {
        let view = UIView()
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let displayFullNameLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(280), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(280), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .vertical)
        label.text = "Joe Smith"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17.5, weight: .medium)
        return label
    }()
    
    private let chevonImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 285, compressionResistancePriority: 785)
        
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemGray4
        
        return imageView
    }()
    
    // MARK: - Additional UI Elements
    private let iconView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 290, compressionResistancePriority: 790)

        imageView.image = UIImage(systemName: "person.fill")
        imageView.tintColor = .label
        
        return imageView
    }()
    // TODO have gpt link up these cosntraints
    @IBOutlet private weak var rightChevronLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightChevronTrailingConstraint: NSLayoutConstraint!
    
    // MARK: - Functions
    
    func setup(forDisplayFullName displayFullName: String) {
        displayFullNameLabel.text = displayFullName
        
        // if the user is not the family head, that means the cell should not be selectable nor should we show the chevron that indicates selectability
        isUserInteractionEnabled = UserInformation.isUserFamilyHead
        chevonImageView.isHidden = !UserInformation.isUserFamilyHead
        
        rightChevronLeadingConstraint.constant = UserInformation.isUserFamilyHead ? 5.0 : 0.0
        rightChevronTrailingConstraint.constant = UserInformation.isUserFamilyHead ? 7.5 : 0.0
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        contentView.backgroundColor = .secondarySystemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(chevonImageView)
        containerView.addSubview(displayFullNameLabel)
        
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            iconView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            iconView.bottomAnchor.constraint(equalTo: displayFullNameLabel.bottomAnchor),
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor, multiplier: 1 / 1),
            iconView.heightAnchor.constraint(equalToConstant: 30),
            
            chevonImageView.leadingAnchor.constraint(equalTo: displayFullNameLabel.trailingAnchor, constant: 5),
            chevonImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -7.5),
            chevonImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevonImageView.widthAnchor.constraint(equalTo: chevonImageView.heightAnchor, multiplier: 1 / 1.5),
            chevonImageView.widthAnchor.constraint(equalTo: iconView.heightAnchor, multiplier: 20 / 35),
            
            displayFullNameLabel.topAnchor.constraint(equalTo: iconView.topAnchor),
            displayFullNameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 5),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
            
        ])
        
    }
}
