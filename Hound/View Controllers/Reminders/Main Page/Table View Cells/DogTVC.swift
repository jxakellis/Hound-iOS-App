//
//  DogsMainScreenTableViewCellDogDescription.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/11/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsDogTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    let containerExtraBackgroundView: HoundView = {
        // When the cell/containerView is rounded and there is a reminder below it, we dont want a weird lapse in color
        let view = HoundView()
        view.backgroundColor = .systemBackground
        view.isHidden = true
        return view
    }()
    
    let containerView: HoundView = {
        let view = HoundView()
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
    private let houndPaw: HoundPawImageView = {
        let imageView = HoundPawImageView()
        
        imageView.shouldRoundCorners = true
        imageView.staticCornerRadius = nil
        
        return imageView
    }()
    
    private let dogNameLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.font = .systemFont(ofSize: 47.5, weight: .bold)
        label.textColor = .systemBackground
        return label
    }()
    
    private let chevonImageView: HoundImageView = {
        let imageView = HoundImageView(huggingPriority: 290, compressionResistancePriority: 290)

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
        
        houndPaw.shouldRoundCorners = forDog.dogIcon != nil
        
        // Make the houndPaw 5.0 wider if it has a dogIcon and not the placeholder
        dogIconWidthConstraint.constant = (dogIconWidthConstraint.constant) + (forDog.dogIcon == nil ? 0.0 : 5.0)
        
        // Counteract the expansion on the houndPaw with a contraction of these
        let constraintAdjustment = forDog.dogIcon == nil ? 0 : 2.5
        dogIconLeadingConstraint.constant = (dogIconEdgeConstraintConstant) - constraintAdjustment
        dogIconTrailingConstraint.constant = (dogIconEdgeConstraintConstant) - constraintAdjustment
        dogIconTopConstraint.constant = (dogIconEdgeConstraintConstant) - constraintAdjustment
        dogIconBottomConstraint.constant = (dogIconEdgeConstraintConstant) - constraintAdjustment
        
        // Dog Name Label Configuration
        dogNameLabel.text = forDog.dogName
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerExtraBackgroundView)
        contentView.addSubview(containerView)
        containerView.addSubview(houndPaw)
        containerView.addSubview(chevonImageView)
        containerView.addSubview(dogNameLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // houndPaw
        dogIconLeadingConstraint = houndPaw.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: dogIconEdgeConstraintConstant)
        dogIconTrailingConstraint = dogNameLabel.leadingAnchor.constraint(equalTo: houndPaw.trailingAnchor, constant: dogIconEdgeConstraintConstant)
        dogIconTopConstraint = houndPaw.topAnchor.constraint(equalTo: containerView.topAnchor, constant: dogIconEdgeConstraintConstant)
        dogIconBottomConstraint = containerView.bottomAnchor.constraint(equalTo: houndPaw.bottomAnchor, constant: dogIconEdgeConstraintConstant)
        dogIconWidthConstraint = houndPaw.widthAnchor.constraint(equalToConstant: dogIconWidthConstraintConstant)
        let dogIconAspectRatioConstraint = houndPaw.widthAnchor.constraint(equalTo: houndPaw.heightAnchor)
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
