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

final class SettingsPagesTVC: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    let containerView: GeneralUIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private let pageImageButton: GeneralUIImageView = {
        let imageView = GeneralUIImageView()
        
        imageView.image = UIImage(systemName: "xmark")
        imageView.tintColor = .systemBackground
        
        return imageView
    }()
    
    private let pageTitleLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.text = "Account"
        label.font = .systemFont(ofSize: 17.5, weight: .medium)
        label.textColor = .systemBackground
        return label
    }()
    
    private let chevonImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView()
        
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
        
        pageImageButton.image = forPage.image
        pageTitleLabel.text = forPage.rawValue
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        containerView.addSubview(pageImageButton)
        containerView.addSubview(pageTitleLabel)
        containerView.addSubview(chevonImageView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        NSLayoutConstraint.activate([
            pageImageButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 3.5),
            pageImageButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -3.5),
            pageImageButton.bottomAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor),
            pageImageButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 3.5),
            pageImageButton.widthAnchor.constraint(equalTo: pageImageButton.heightAnchor),
            pageImageButton.heightAnchor.constraint(equalToConstant: 32.5),
            
            chevonImageView.leadingAnchor.constraint(equalTo: pageTitleLabel.trailingAnchor, constant: 5),
            chevonImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -7.5),
            chevonImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevonImageView.widthAnchor.constraint(equalTo: chevonImageView.heightAnchor, multiplier: 1 / 1.5),
            chevonImageView.widthAnchor.constraint(equalTo: pageTitleLabel.heightAnchor, multiplier: 10 / 35),
            
            pageTitleLabel.topAnchor.constraint(equalTo: pageImageButton.topAnchor),
            pageTitleLabel.leadingAnchor.constraint(equalTo: pageImageButton.trailingAnchor, constant: 5),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
    }
}
