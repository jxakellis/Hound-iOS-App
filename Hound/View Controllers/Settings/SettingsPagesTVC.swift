//
//  SettingsTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/28/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum SettingsPages: String, CaseIterable {
    case account = "Account"
    case family = "Family"
    case subscription = "Subscription"
    case appearance = "Appearance"
    case notifications = "Notifications"
    case website = "Website"
    case feedback = "Feedback"
    case support = "Support"
    case eula = "EULA"
    case privacyPolicy = "Privacy Policy"
    case termsAndConditions = "Terms and Conditions"
    
    var url: URL? {
        switch self {
        case .account:
            return nil
        case .family:
            return nil
        case .subscription:
            return nil
        case .appearance:
            return nil
        case .notifications:
            return nil
        case .website:
            return URL(string: "https://www.houndorganizer.com")
        case .feedback:
            return nil
        case .support:
            return URL(string: "https://www.houndorganizer.com/contact")
        case .eula:
            return URL(string: "https://www.houndorganizer.com/eula")
        case .privacyPolicy:
            return URL(string: "https://www.houndorganizer.com/privacy")
        case .termsAndConditions:
            return URL(string: "https://www.houndorganizer.com/terms")
        }
    }
    
    var image: UIImage? {
        switch self {
        case .account:
            return UIImage(systemName: "person.crop.circle")
        case .family:
            return UIImage(systemName: "figure.and.child.holdinghands") ?? UIImage(systemName: "person.3")
        case .subscription:
            return UIImage(systemName: "creditcard")
        case .appearance:
            return UIImage(systemName: "textformat")
        case .notifications:
            return UIImage(systemName: "iphone.radiowaves.left.and.right")
        case .website:
            return UIImage(systemName: "globe")
        case .feedback:
            return UIImage(systemName: "square.and.pencil")
        case .support:
            return UIImage(systemName: "envelope")
        case .eula:
            return UIImage(systemName: "doc.plaintext")
        case .privacyPolicy:
            return UIImage(systemName: "shield")
        case .termsAndConditions:
            return UIImage(systemName: "text.book.closed")
        }
    }
}

final class SettingsPagesTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    let containerView: HoundView = {
        let view = HoundView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private let pageImageView: HoundImageView = {
        let imageView = HoundImageView()
        
        imageView.tintColor = .systemBackground
        
        return imageView
    }()
    
    private let headerLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        label.textColor = .systemBackground
        return label
    }()
    
    private let chevonImageView: HoundImageView = {
        let imageView = HoundImageView()
        
        imageView.alpha = 0.75
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemBackground
        
        return imageView
    }()
    
    // MARK: - Properties
    
    var page: SettingsPages?
    
    static let reuseIdentifier = "SettingsPagesTVC"
    
    // MARK: - Setup
    
    func setup(forPage: SettingsPages) {
        self.page = forPage
        
        pageImageView.image = forPage.image
        headerLabel.text = forPage.rawValue
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        containerView.addSubview(pageImageView)
        containerView.addSubview(headerLabel)
        containerView.addSubview(chevonImageView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        let pageImageViewInset: CGFloat = 5.0
        // pageImageView inset relative to headerLabel inset
        let pageViewRelativeVertInset = -ConstraintConstant.Spacing.absoluteVertInset + pageImageViewInset

        // containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])

        // pageImageView
        NSLayoutConstraint.activate([
            pageImageView.topAnchor.constraint(equalTo: headerLabel.topAnchor, constant: pageViewRelativeVertInset),
            pageImageView.bottomAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: -pageViewRelativeVertInset),
            pageImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: pageImageViewInset),
            pageImageView.createAspectRatio(1.0)
        ])

        // headerLabel
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Spacing.absoluteVertInset),
            headerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset),
            headerLabel.leadingAnchor.constraint(equalTo: pageImageView.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori),
            headerLabel.createMaxHeight(ConstraintConstant.Text.sectionLabelMaxHeight),
            headerLabel.createHeightMultiplier(ConstraintConstant.Text.sectionLabelHeightMultipler, relativeToWidthOf: contentView)
        ])
        
        // chevonImageView
        NSLayoutConstraint.activate([
            chevonImageView.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori),
            chevonImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            chevonImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevonImageView.createAspectRatio(ConstraintConstant.Button.chevronAspectRatio),
            chevonImageView.heightAnchor.constraint(equalTo: headerLabel.heightAnchor, multiplier: 0.75)
        ])
    }

}
