//
//  DogsMainScreenTableViewCellDogDescription.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/11/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsDogTVC: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    let containerExtraBackgroundView: GeneralUIView = {
        // When the cell/containerView is rounded and there is a reminder below it, we dont want a weird lapse in color
        let view = GeneralUIView()
        view.backgroundColor = .systemBackground
        view.isHidden = true
        return view
    }()
    
    let containerView: GeneralUIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private let dogIconEdgeConstraintConstant = 12.5
    private weak var dogIconLeadingConstraint: NSLayoutConstraint!
    private weak var dogIconTrailingConstraint: NSLayoutConstraint!
    private weak var dogIconTopConstraint: NSLayoutConstraint!
    private weak var dogIconBottomConstraint: NSLayoutConstraint!
    private let dogIconWidthConstraintConstant: CGFloat = 55
    private weak var dogIconWidthConstraint: NSLayoutConstraint!
    private let dogIconImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView()
        
        imageView.image = UIImage(named: "whitePawWithHands")
        imageView.shouldRoundCorners = true
        
        return imageView
    }()
    
    private let dogNameLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.font = .systemFont(ofSize: 47.5, weight: .bold)
        label.textColor = .systemBackground
        return label
    }()
    
    private let chevonImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 290, compressionResistancePriority: 290)

        imageView.alpha = 0.75
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemBackground
        
        return imageView
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "DogsDogTVC"
    
    var dog: Dog?
    
    // MARK: - Setup
    
    func setup(forDog: Dog) {
        self.dog = forDog
        
        dogIconImageView.image = forDog.dogIcon ?? (
            UITraitCollection.current.userInterfaceStyle == .dark
            ? ClassConstant.DogConstant.blackPawWithHands
            : ClassConstant.DogConstant.whitePawWithHands)
        dogIconImageView.shouldRoundCorners = forDog.dogIcon != nil
        
        // Make the dogIconImageView 5.0 wider if it has a dogIcon and not the placeholder
        dogIconWidthConstraint.constant = (dogIconWidthConstraint.constant) + (forDog.dogIcon == nil ? 0.0 : 5.0)
        
        // Counteract the expansion on the dogIconImageView with a contraction of these
        let constraintAdjustment = forDog.dogIcon == nil ? 0 : 2.5
        dogIconLeadingConstraint.constant = (dogIconEdgeConstraintConstant) - constraintAdjustment
        dogIconTrailingConstraint.constant = (dogIconEdgeConstraintConstant) - constraintAdjustment
        dogIconTopConstraint.constant = (dogIconEdgeConstraintConstant) - constraintAdjustment
        dogIconBottomConstraint.constant = (dogIconEdgeConstraintConstant) - constraintAdjustment
        
        // Dog Name Label Configuration
        dogNameLabel.text = forDog.dogName
    }
    
    // MARK: - Functions
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // UI has changed its appearance to dark/light mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            dogIconImageView.image = dog?.dogIcon ?? (
                UITraitCollection.current.userInterfaceStyle == .dark
                ? ClassConstant.DogConstant.blackPawWithHands
                : ClassConstant.DogConstant.whitePawWithHands)
        }
    }
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerExtraBackgroundView)
        contentView.addSubview(containerView)
        containerView.addSubview(dogIconImageView)
        containerView.addSubview(chevonImageView)
        containerView.addSubview(dogNameLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // dogIconImageView
        dogIconLeadingConstraint = dogIconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: dogIconEdgeConstraintConstant)
        dogIconTrailingConstraint = dogNameLabel.leadingAnchor.constraint(equalTo: dogIconImageView.trailingAnchor, constant: dogIconEdgeConstraintConstant)
        dogIconTopConstraint = dogIconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: dogIconEdgeConstraintConstant)
        dogIconBottomConstraint = containerView.bottomAnchor.constraint(equalTo: dogIconImageView.bottomAnchor, constant: dogIconEdgeConstraintConstant)
        dogIconWidthConstraint = dogIconImageView.widthAnchor.constraint(equalToConstant: dogIconWidthConstraintConstant)
        let dogIconAspectRatioConstraint = dogIconImageView.widthAnchor.constraint(equalTo: dogIconImageView.heightAnchor)
        dogIconAspectRatioConstraint.priority = .defaultHigh
        
        // dogNameLabel
        let dogNameLabelCenterY = dogNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        let dogNameLabelHeight = dogNameLabel.heightAnchor.constraint(equalToConstant: 55)
        
        // chevonImageView
        let chevonImageViewLeading = chevonImageView.leadingAnchor.constraint(equalTo: dogNameLabel.trailingAnchor, constant: 15)
        let chevonImageViewTrailing = chevonImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15)
        let chevonImageViewCenterY = chevonImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        let chevonImageViewWidthToHeight = chevonImageView.widthAnchor.constraint(equalTo: chevonImageView.heightAnchor, multiplier: 1 / 1.5)
        let chevonImageViewWidthToNameHeight = chevonImageView.widthAnchor.constraint(equalTo: dogNameLabel.heightAnchor, multiplier: 20 / 55)
        chevonImageViewWidthToNameHeight.priority = .defaultHigh
        
        // containerView
        let containerViewTop = containerView.topAnchor.constraint(equalTo: contentView.topAnchor)
        let containerViewBottom = containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        let containerViewLeading = containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset)
        let containerViewTrailing = containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        
        // containerExtraBackgroundView
        let containerExtraBackgroundViewTop = containerExtraBackgroundView.topAnchor.constraint(equalTo: containerView.centerYAnchor)
        let containerExtraBackgroundViewBottom = containerExtraBackgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        let containerExtraBackgroundViewLeading = containerExtraBackgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor)
        let containerExtraBackgroundViewTrailing = containerExtraBackgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        
        NSLayoutConstraint.activate([
            dogIconLeadingConstraint,
            dogIconTrailingConstraint,
            dogIconTopConstraint,
            dogIconBottomConstraint,
            dogIconWidthConstraint,
            dogIconAspectRatioConstraint,
            
            dogNameLabelCenterY,
            dogNameLabelHeight,
            
            chevonImageViewLeading,
            chevonImageViewTrailing,
            chevonImageViewCenterY,
            chevonImageViewWidthToHeight,
            chevonImageViewWidthToNameHeight,
            
            containerExtraBackgroundViewTop,
            containerExtraBackgroundViewBottom,
            containerExtraBackgroundViewLeading,
            containerExtraBackgroundViewTrailing,
            
            containerViewTop,
            containerViewBottom,
            containerViewLeading,
            containerViewTrailing
        ])
    }

}
