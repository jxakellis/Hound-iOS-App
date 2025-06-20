//
//  FamilyLimitTooLowViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/6/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

class FamilyLimitTooLowViewController: GeneralUIViewController {
    
    // MARK: - Elements
    
    private let pawWithHands: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 290, compressionResistancePriority: 290)

        imageView.image = UIImage(named: "whitePawWithHands")
        
        return imageView
    }()
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.text = "Hound+ Subscription Needed"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 35, weight: .semibold)
        label.textColor = .systemBackground
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.text = "You're trying to join a Hound family with a limited number of family members! Please have the family head upgrade to a Hound+ subscription before attempting to join."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20)
        label.textColor = .secondarySystemBackground
        return label
    }()
    
    private let backButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.setTitle("Back", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        
        button.shouldDismissParentViewController = true
        
        return button
    }()
    
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
        view.addSubview(backButton)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // pawWithHands
        let pawWithHandsCenterX = pawWithHands.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let pawWithHandsWidthToHeight = pawWithHands.widthAnchor.constraint(equalTo: pawWithHands.heightAnchor)
        let pawWithHandsWidth = pawWithHands.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.4)
        
        // headerLabel
        let headerLabelTop = headerLabel.topAnchor.constraint(equalTo: pawWithHands.bottomAnchor, constant: 20)
        let headerLabelLeading = headerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintConstant.Global.contentInset)
        let headerLabelTrailing = headerLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Global.contentInset)
        let headerLabelCenterY = headerLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
        // descriptionLabel
        let descriptionLabelTop = descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12.5)
        let descriptionLabelLeading = descriptionLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor)
        let descriptionLabelTrailing = descriptionLabel.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor)
        
        // backButton
        let backButtonTop = backButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 35)
        let backButtonLeading = backButton.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor)
        let backButtonWidthToHeight = backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor, multiplier: 1 / 0.16)
        
        NSLayoutConstraint.activate([
            pawWithHandsCenterX,
            pawWithHandsWidthToHeight,
            pawWithHandsWidth,
            
            headerLabelTop,
            headerLabelLeading,
            headerLabelTrailing,
            headerLabelCenterY,
            
            descriptionLabelTop,
            descriptionLabelLeading,
            descriptionLabelTrailing,
            
            backButtonTop,
            backButtonLeading,
            backButtonWidthToHeight
        ])
    }

}
