//
//  AppVersionOutdatedViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/31/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

// TODO VERIFY UI
class AppVersionOutdatedViewController: GeneralUIViewController {
    
    // MARK: - Elements
    
    private let pawWithHands: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 290, compressionResistancePriority: 290)

        imageView.image = UIImage(named: "whitePawWithHands")
        
        return imageView
    }()
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.text = "New Hound Update Available"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.primaryHeaderLabel
        label.textColor = .systemBackground
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "It looks like you're using an outdated version of Hound. Update now for the latest features and improvements!"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        label.textColor = .secondarySystemBackground
        return label
    }()
    
    private let openAppStoreButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.setTitle("Open App Store", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        
        return button
    }()
    
    @objc private func didTapOpenAppStore(_ sender: Any) {
        // Open the page for hound on the user's device, don't include a localized url (e.g. with the /us/) so it localizes to a users zone
        guard let url = URL(string: "https://apps.apple.com/app/hound-family-dog-organizer/id1564604025") else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    // MARK: - Main
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        self.pawWithHands.image = UITraitCollection.current.userInterfaceStyle == .dark
        ? ClassConstant.DogConstant.blackPawWithHands
        : ClassConstant.DogConstant.whitePawWithHands
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // UI has changed its appearance to dark/light mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.pawWithHands.image = UITraitCollection.current.userInterfaceStyle == .dark
            ? ClassConstant.DogConstant.blackPawWithHands
            : ClassConstant.DogConstant.whitePawWithHands
        }
    }

    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBlue
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        view.addSubview(pawWithHands)
        view.addSubview(headerLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(openAppStoreButton)
        
        openAppStoreButton.addTarget(self, action: #selector(didTapOpenAppStore), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // pawWithHands
        let pawWithHandsCenterX = pawWithHands.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let pawWithHandsWidth = pawWithHands.widthAnchor.constraint(equalTo: pawWithHands.heightAnchor)
        let pawWithHandsWidthRelative = pawWithHands.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 4.0 / 10.0)
        
        // headerLabel
        let headerLabelTop = headerLabel.topAnchor.constraint(equalTo: pawWithHands.bottomAnchor, constant: 20)
        let headerLabelLeading = headerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset)
        let headerLabelTrailing = headerLabel.trailingAnchor.constraint(equalTo: openAppStoreButton.trailingAnchor)
        let headerLabelTrailingSafe = headerLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset)
        let headerLabelTrailingDesc = headerLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor)
        let headerLabelCenterY = headerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
        // descriptionLabel
        let descriptionLabelTop = descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12.5)
        let descriptionLabelLeading = descriptionLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor)
        
        // openAppStoreButton
        let openAppStoreButtonTop = openAppStoreButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 35)
        let openAppStoreButtonLeading = openAppStoreButton.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor)
        let openAppStoreButtonWidth = openAppStoreButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: view)
        
        NSLayoutConstraint.activate([
            // pawWithHands
            pawWithHandsCenterX,
            pawWithHandsWidth,
            pawWithHandsWidthRelative,
            
            // headerLabel
            headerLabelTop,
            headerLabelLeading,
            headerLabelTrailing,
            headerLabelTrailingSafe,
            headerLabelTrailingDesc,
            headerLabelCenterY,
            
            // descriptionLabel
            descriptionLabelTop,
            descriptionLabelLeading,
            
            // openAppStoreButton
            openAppStoreButtonTop,
            openAppStoreButtonLeading,
            openAppStoreButtonWidth
        ])
    }

}
