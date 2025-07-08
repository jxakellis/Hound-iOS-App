//
//  AppVersionOutdatedVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/31/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

class AppVersionOutdatedVC: BluePawVC {
    
    // MARK: - Elements
    
    private let openAppStoreButton: HoundButton = {
        let button = HoundButton()
        
        button.setTitle("Open App Store", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
         button.applyStyle(.labelBorder)
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        headerLabel.text = "New Hound Update Available"
        descriptionLabel.text = "It looks like you're using an outdated version of Hound. Update now for the latest features and improvements!"
    }

    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.systemBlue
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        view.addSubview(openAppStoreButton)
        
        openAppStoreButton.addTarget(self, action: #selector(didTapOpenAppStore), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // openAppStoreButton
        NSLayoutConstraint.activate([
            openAppStoreButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            openAppStoreButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            openAppStoreButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            openAppStoreButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: view),
            openAppStoreButton.createMaxHeight(ConstraintConstant.Button.wideMaxHeight)
        ])
    }

}
