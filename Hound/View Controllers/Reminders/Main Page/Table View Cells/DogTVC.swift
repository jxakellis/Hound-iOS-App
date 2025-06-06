//
//  DogsMainScreenTableViewCellDogDescription.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/11/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsDogTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    let containerView: UIView = {
        let view = UIView()
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBlue
        return view
    }()
    
    
    private let dogIconImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "whitePawWithHands")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.shouldRoundCorners = true
        return imageView
    }()
    
    private var dogIconLeadingConstraintConstant: CGFloat?
    @IBOutlet private weak var dogIconLeadingConstraint: NSLayoutConstraint!
    private var dogIconTrailingConstraintConstant: CGFloat?
    @IBOutlet private weak var dogIconTrailingConstraint: NSLayoutConstraint!
    private var dogIconTopConstraintConstant: CGFloat?
    @IBOutlet private weak var dogIconTopConstraint: NSLayoutConstraint!
    private var dogIconBottomConstraintConstant: CGFloat?
    @IBOutlet private weak var dogIconBottomConstraint: NSLayoutConstraint!
    private var dogIconWidthConstraintConstant: CGFloat?
    @IBOutlet private weak var dogIconWidthConstraint: NSLayoutConstraint!
    
    private let dogNameLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(280), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(280), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .vertical)
        label.text = "Bella"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 47.5)
        label.textColor = .systemBackground
        return label
    }()
    
    // MARK: - Additional UI Elements
    
    private let imageView__2Cv_gS_fE5: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.alpha = 0.75
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(UILayoutPriority(290), for: .horizontal)
        imageView.setContentHuggingPriority(UILayoutPriority(290), for: .vertical)
        imageView.setContentCompressionResistancePriority(UILayoutPriority(790), for: .horizontal)
        imageView.setContentCompressionResistancePriority(UILayoutPriority(790), for: .vertical)
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .systemBackground
        return imageView
    }()
    
    // MARK: - Properties
    
    var dog: Dog?
    
    // MARK: - Main
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupGeneratedViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGeneratedViews()
    }
    
    // MARK: - Functions
    
    // Function used externally to setup dog
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
    
}

extension DogsDogTableViewCell {
    func setupGeneratedViews() {
        contentView.backgroundColor = .clear
        
        addSubViews()
        setupConstraints()
    }
    
    func addSubViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(dogIconImageView)
        containerView.addSubview(imageView__2Cv_gS_fE5)
        containerView.addSubview(dogNameLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            dogIconImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12.5),
            dogIconImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12.5),
            dogIconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12.5),
            dogIconImageView.widthAnchor.constraint(equalToConstant: 55),
            dogIconImageView.widthAnchor.constraint(equalTo: dogIconImageView.heightAnchor, multiplier: 1/1),
            
            imageView__2Cv_gS_fE5.leadingAnchor.constraint(equalTo: dogNameLabel.trailingAnchor, constant: 15),
            imageView__2Cv_gS_fE5.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -15),
            imageView__2Cv_gS_fE5.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            imageView__2Cv_gS_fE5.widthAnchor.constraint(equalTo: imageView__2Cv_gS_fE5.heightAnchor, multiplier: 1/1.5),
            imageView__2Cv_gS_fE5.widthAnchor.constraint(equalTo: dogNameLabel.heightAnchor, multiplier: 20/55),
            
            dogNameLabel.leadingAnchor.constraint(equalTo: dogIconImageView.trailingAnchor, constant: 12.5),
            dogNameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            dogNameLabel.heightAnchor.constraint(equalToConstant: 55),
            
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
        ])
        
    }
}
