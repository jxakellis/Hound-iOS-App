//
//  SettingsFamilyMemberTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/5/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsFamilyMemberTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
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
    
    private let rightChevronImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(UILayoutPriority(285), for: .horizontal)
        imageView.setContentHuggingPriority(UILayoutPriority(285), for: .vertical)
        imageView.setContentCompressionResistancePriority(UILayoutPriority(785), for: .horizontal)
        imageView.setContentCompressionResistancePriority(UILayoutPriority(785), for: .vertical)
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemGray4
        return imageView
    }()
    
    // MARK: - Additional UI Elements
    private let iconView: GeneralUIImageView = {
        let imageView = GeneralUIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(UILayoutPriority(290), for: .horizontal)
        imageView.setContentHuggingPriority(UILayoutPriority(290), for: .vertical)
        imageView.setContentCompressionResistancePriority(UILayoutPriority(790), for: .horizontal)
        imageView.setContentCompressionResistancePriority(UILayoutPriority(790), for: .vertical)
        imageView.image = UIImage(systemName: "person.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .label
        return imageView
    }()
    // TODO have gpt link up these cosntraints
    @IBOutlet private weak var rightChevronLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightChevronTrailingConstraint: NSLayoutConstraint!
    
    // MARK: - Main
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupGeneratedViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGeneratedViews()
    }
    
    // MARK: - Functions
    
    func setup(forDisplayFullName displayFullName: String) {
        displayFullNameLabel.text = displayFullName
        
        // if the user is not the family head, that means the cell should not be selectable nor should we show the chevron that indicates selectability
        isUserInteractionEnabled = UserInformation.isUserFamilyHead
        rightChevronImageView.isHidden = !UserInformation.isUserFamilyHead
        
        rightChevronLeadingConstraint.constant = UserInformation.isUserFamilyHead ? 5.0 : 0.0
        rightChevronTrailingConstraint.constant = UserInformation.isUserFamilyHead ? 7.5 : 0.0
    }
    
}

extension SettingsFamilyMemberTableViewCell {
    func setupGeneratedViews() {
        contentView.backgroundColor = .secondarySystemBackground
        
        addSubViews()
        setupConstraints()
    }
    
    func addSubViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(iconView)
        containerView.addSubview(rightChevronImageView)
        containerView.addSubview(displayFullNameLabel)
        
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            iconView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            iconView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            iconView.bottomAnchor.constraint(equalTo: displayFullNameLabel.bottomAnchor),
            iconView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor, multiplier: 1/1),
            iconView.heightAnchor.constraint(equalToConstant: 30),
            
            rightChevronImageView.leadingAnchor.constraint(equalTo: displayFullNameLabel.trailingAnchor, constant: 5),
            rightChevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -7.5),
            rightChevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            rightChevronImageView.widthAnchor.constraint(equalTo: rightChevronImageView.heightAnchor, multiplier: 1/1.5),
            rightChevronImageView.widthAnchor.constraint(equalTo: iconView.heightAnchor, multiplier: 20/35),
            
            displayFullNameLabel.topAnchor.constraint(equalTo: iconView.topAnchor),
            displayFullNameLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 5),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
        ])
        
    }
}
