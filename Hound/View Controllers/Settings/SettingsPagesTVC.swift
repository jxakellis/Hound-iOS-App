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

final class SettingsPagesTableViewCell: UITableViewCell {
    
    // MARK: - Elements
    
    let containerView: UIView = {
        let view = UIView()
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
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
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(280), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(280), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .vertical)
        label.text = "Account"
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    // MARK: - Main
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupGeneratedViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGeneratedViews()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGeneratedViews()
    }
    
    // MARK: - Functions
    
    func setup(forPage: SettingsPages) {
        self.page = forPage
        
        pageImageButton.image = forPage.image
        pageTitleLabel.text = forPage.rawValue
    }
    
}

extension SettingsPagesTableViewCell {
    private func setupGeneratedViews() {
        addSubViews()
        setupConstraints()
    }
    
    private func addSubViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(pageImageButton)
        containerView.addSubview(pageTitleLabel)
        containerView.addSubview(chevonImageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pageImageButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 3.5),
            pageImageButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -3.5),
            pageImageButton.bottomAnchor.constraint(equalTo: pageTitleLabel.bottomAnchor),
            pageImageButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 3.5),
            pageImageButton.widthAnchor.constraint(equalTo: pageImageButton.heightAnchor, multiplier: 1/1),
            pageImageButton.heightAnchor.constraint(equalToConstant: 32.5),
            
            chevonImageView.leadingAnchor.constraint(equalTo: pageTitleLabel.trailingAnchor, constant: 5),
            chevonImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -7.5),
            chevonImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevonImageView.widthAnchor.constraint(equalTo: chevonImageView.heightAnchor, multiplier: 1/1.5),
            chevonImageView.widthAnchor.constraint(equalTo: pageTitleLabel.heightAnchor, multiplier: 10/35),
            
            pageTitleLabel.topAnchor.constraint(equalTo: pageImageButton.topAnchor),
            pageTitleLabel.leadingAnchor.constraint(equalTo: pageImageButton.trailingAnchor, constant: 5),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
        
    }
}
