//
//  FamilyLimitTooLowViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/6/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

class FamilyLimitTooLowViewController: GeneralUIViewController {
    
    // MARK: - IB
    
    private let pawWithHands: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(UILayoutPriority(290), for: .horizontal)
        imageView.setContentHuggingPriority(UILayoutPriority(290), for: .vertical)
        imageView.setContentCompressionResistancePriority(UILayoutPriority(790), for: .horizontal)
        imageView.setContentCompressionResistancePriority(UILayoutPriority(790), for: .vertical)
        imageView.image = UIImage(named: "whitePawWithHands")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Additional UI Elements
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(280), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(280), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .vertical)
        label.text = "Hound+ Subscription Needed"
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 35, weight: .semibold)
        label.textColor = .systemBackground
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(270), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(270), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(770), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(770), for: .vertical)
        label.text = "You're trying to join a Hound family with a limited number of family members! Please have the family head upgrade to a Hound+ subscription before attempting to join."
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        label.textColor = .secondarySystemBackground
        return label
    }()
    
    private let backButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.backgroundColor = .systemBackground
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        button.setTitle("Back", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabelTextColor = .label
        button.buttonBackgroundColor = .systemBackground
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        button.shouldDismissParentViewController = true
        
        return button
    }()
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGeneratedViews()
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
    
}

extension FamilyLimitTooLowViewController {
    func setupGeneratedViews() {
        view.backgroundColor = .systemBlue
        
        addSubViews()
        setupConstraints()
    }
    
    func addSubViews() {
        view.addSubview(pawWithHands)
        view.addSubview(headerLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(backButton)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            pawWithHands.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pawWithHands.widthAnchor.constraint(equalTo: pawWithHands.heightAnchor, multiplier: 1/1),
            pawWithHands.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 4/10),
            
            backButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 35),
            backButton.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor, multiplier: 1/0.16),
            
            headerLabel.topAnchor.constraint(equalTo: pawWithHands.bottomAnchor, constant: 20),
            headerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            headerLabel.trailingAnchor.constraint(equalTo: backButton.trailingAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            headerLabel.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            headerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12.5),
            descriptionLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor),
            
        ])
        
    }
}
