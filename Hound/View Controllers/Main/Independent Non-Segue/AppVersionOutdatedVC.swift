//
//  AppVersionOutdatedViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/31/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

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
        label.font = .systemFont(ofSize: 35, weight: .semibold)
        label.textColor = .systemBackground
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "It looks like you're using an outdated version of Hound. Update now for the latest features and improvements!"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20)
        label.textColor = .secondarySystemBackground
        return label
    }()
    
    private let openAppStoreButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.setTitle("Open App Store", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
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
        NSLayoutConstraint.activate([
            pawWithHands.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pawWithHands.widthAnchor.constraint(equalTo: pawWithHands.heightAnchor),
            pawWithHands.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 4 / 10),
            
            openAppStoreButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 35),
            openAppStoreButton.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            openAppStoreButton.widthAnchor.constraint(equalTo: openAppStoreButton.heightAnchor, multiplier: 1 / 0.16),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12.5),
            descriptionLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            
            headerLabel.topAnchor.constraint(equalTo: pawWithHands.bottomAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: openAppStoreButton.trailingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            headerLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            
        ])
        
    }
}
