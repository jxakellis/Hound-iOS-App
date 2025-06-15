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
    
    let containerView: UIView = {
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
        label.font = .systemFont(ofSize: 47.5)
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
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        containerView.addSubview(dogIconImageView)
        containerView.addSubview(chevonImageView)
        containerView.addSubview(dogNameLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        dogIconLeadingConstraint = dogIconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: dogIconEdgeConstraintConstant)
        dogIconTrailingConstraint = dogNameLabel.leadingAnchor.constraint(equalTo: dogIconImageView.trailingAnchor, constant: dogIconEdgeConstraintConstant)
        dogIconTopConstraint = dogIconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: dogIconEdgeConstraintConstant)
        dogIconBottomConstraint = containerView.bottomAnchor.constraint(equalTo: dogIconImageView.bottomAnchor, constant: dogIconEdgeConstraintConstant)
        dogIconWidthConstraint = dogIconImageView.widthAnchor.constraint(equalToConstant: dogIconWidthConstraintConstant)
        
        NSLayoutConstraint.activate([
            dogIconTopConstraint,
            dogIconBottomConstraint,
            dogIconLeadingConstraint,
            dogIconWidthConstraint,
            dogIconImageView.widthAnchor.constraint(equalTo: dogIconImageView.heightAnchor),
            
            chevonImageView.leadingAnchor.constraint(equalTo: dogNameLabel.trailingAnchor, constant: 15),
            chevonImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            chevonImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevonImageView.widthAnchor.constraint(equalTo: chevonImageView.heightAnchor, multiplier: 1 / 1.5),
            chevonImageView.widthAnchor.constraint(equalTo: dogNameLabel.heightAnchor, multiplier: 20 / 55),
            
            dogNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            dogNameLabel.heightAnchor.constraint(equalToConstant: 55),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
            
        ])
        
    }
}
