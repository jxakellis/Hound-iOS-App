//
//  DogsMainScreenTableViewCellDogDescription.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/11/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsDogTableViewCell: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    let containerView: UIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBlue
        return view
    }()
    
    private var dogIconLeadingConstraintConstant: CGFloat?
    private weak var dogIconLeadingConstraint: NSLayoutConstraint!
    private var dogIconTrailingConstraintConstant: CGFloat?
    private weak var dogIconTrailingConstraint: NSLayoutConstraint!
    private var dogIconTopConstraintConstant: CGFloat?
    private weak var dogIconTopConstraint: NSLayoutConstraint!
    private var dogIconBottomConstraintConstant: CGFloat?
    private weak var dogIconBottomConstraint: NSLayoutConstraint!
    private var dogIconWidthConstraintConstant: CGFloat?
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
    
    static let reuseIdentifier = "DogsDogTableViewCell"
    
    var dog: Dog?
    
    // MARK: - Functions
    
    func setup(forDog: Dog) {
        self.dog = forDog
        
        // Cell can be re-used by the tableView, so the constraintConstants won't be nil in that case and their original values saved
        dogIconLeadingConstraintConstant = dogIconLeadingConstraintConstant ?? dogIconLeadingConstraint.constant
        dogIconTrailingConstraintConstant = dogIconTrailingConstraintConstant ?? dogIconTrailingConstraint.constant
        dogIconTopConstraintConstant = dogIconTopConstraintConstant ?? dogIconTopConstraint.constant
        dogIconBottomConstraintConstant = dogIconBottomConstraintConstant ?? dogIconBottomConstraint.constant
        dogIconWidthConstraintConstant = dogIconWidthConstraintConstant ?? dogIconWidthConstraint.constant
        
        dogIconImageView.image = forDog.dogIcon ?? (
            UITraitCollection.current.userInterfaceStyle == .dark
            ? ClassConstant.DogConstant.blackPawWithHands
            : ClassConstant.DogConstant.whitePawWithHands)
        dogIconImageView.shouldRoundCorners = forDog.dogIcon != nil
        
        // Make the dogIconImageView 5.0 wider if it has a dogIcon and not the placeholder
        dogIconWidthConstraint.constant = (dogIconWidthConstraintConstant ?? dogIconWidthConstraint.constant) + (forDog.dogIcon == nil ? 0.0 : 5.0)
        
        // Counteract the expansion on the dogIconImageView with a contraction of these
        let constraintAdjustment = forDog.dogIcon == nil ? 0 : 2.5
        dogIconLeadingConstraint.constant = (dogIconLeadingConstraintConstant ?? dogIconLeadingConstraint.constant) - constraintAdjustment
        dogIconTrailingConstraint.constant = (dogIconTrailingConstraintConstant ?? dogIconTrailingConstraint.constant) - constraintAdjustment
        dogIconTopConstraint.constant = (dogIconTopConstraintConstant ?? dogIconTopConstraint.constant) - constraintAdjustment
        dogIconBottomConstraint.constant = (dogIconBottomConstraintConstant ?? dogIconBottomConstraint.constant) - constraintAdjustment
        
        // Dog Name Label Configuration
        dogNameLabel.text = forDog.dogName
    }
    
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
        contentView.addSubview(containerView)
        containerView.addSubview(dogIconImageView)
        containerView.addSubview(chevonImageView)
        containerView.addSubview(dogNameLabel)
    }
    
    override func setupConstraints() {
        dogIconLeadingConstraint = dogIconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12.5)
        dogIconTrailingConstraint = dogNameLabel.leadingAnchor.constraint(equalTo: dogIconImageView.trailingAnchor, constant: 12.5)
        dogIconTopConstraint = dogIconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12.5)
        dogIconBottomConstraint = dogIconImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12.5)
        dogIconWidthConstraint = dogIconImageView.widthAnchor.constraint(equalToConstant: 55)
        
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
