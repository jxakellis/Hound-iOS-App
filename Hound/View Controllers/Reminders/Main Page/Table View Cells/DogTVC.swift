//
//  DogsMainScreenTableViewCellDogDescription.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/11/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    let containerExtraBackgroundView: HoundView = {
        // When the cell/containerView is rounded and there is a reminder below it, we dont want a weird lapse in color
        let view = HoundView()
        view.backgroundColor = UIColor.systemBackground
        view.isHidden = true
        return view
    }()
    
    let containerView: HoundView = {
        let view = HoundView()
        view.backgroundColor = UIColor.systemBlue
        return view
    }()
    
    private let houndPaw: HoundPawImageView = {
        let imageView = HoundPawImageView()
        
        imageView.shouldRoundCorners = true
        imageView.staticCornerRadius = nil
        
        return imageView
    }()
    
    private let dogNameLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.font = VisualConstant.FontConstant.megaHeaderLabel
        label.textColor = UIColor.systemBackground
        return label
    }()
    
    private let chevronImageView: HoundImageView = {
        let imageView = HoundImageView(huggingPriority: 290, compressionResistancePriority: 290)
        
        imageView.alpha = 0.75
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor.systemBackground
        
        return imageView
    }()
    
    private var dogNameToDogTriggersConstraint: GeneralLayoutConstraint!
    private var dogTriggersBottomConstraint: GeneralLayoutConstraint!
    private var dogTriggersRelativeHeightConstraint: NSLayoutConstraint!
    private var dogTriggersZeroHeightConstraint: NSLayoutConstraint!
    private let dogTriggersLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.backgroundColor = UIColor.systemBackground
        label.font = VisualConstant.FontConstant.emphasizedSecondaryRegularLabel
        label.textColor = UIColor.label
        label.shouldRoundCorners = true
        label.staticCornerRadius = nil
        return label
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "DogTVC"
    
    var dog: Dog?
    
    // MARK: - Setup
    
    func setup(forDog: Dog) {
        self.dog = forDog
        
        houndPaw.shouldRoundCorners = forDog.dogIcon != nil
        
        dogNameLabel.text = forDog.dogName
        dogTriggersLabel.text = "  \(forDog.dogTriggers.dogTriggers.count) triggers  "
        handleDogTriggersLabel()
    }
    
    // MARK: - Setup Elements
    
    private func handleDogTriggersLabel() {
        guard dogTriggersLabel.text != nil && dogTriggersLabel.text?.isEmpty == false else {
            dogTriggersLabel.isHidden = true
            dogNameToDogTriggersConstraint.constant = ConstraintConstant.Spacing.absoluteVertInset * 1.5
            dogTriggersBottomConstraint.constant = 0
            dogTriggersRelativeHeightConstraint.isActive = false
            dogTriggersZeroHeightConstraint.isActive = true
            return
        }
        
        dogTriggersLabel.isHidden = false
        dogNameToDogTriggersConstraint.constant = dogNameToDogTriggersConstraint.originalConstant
        dogTriggersBottomConstraint.constant = dogTriggersBottomConstraint.originalConstant
        dogTriggersZeroHeightConstraint.isActive = false
        dogTriggersRelativeHeightConstraint.isActive = true
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerExtraBackgroundView)
        contentView.addSubview(containerView)
        containerView.addSubview(houndPaw)
        containerView.addSubview(chevronImageView)
        containerView.addSubview(dogNameLabel)
        containerView.addSubview(dogTriggersLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            // when table view is calculating the height of this view, it might assign a UIView-Encapsulated-Layout-Height which is invalid (too big or too small) for pageSheetHeaderView. This would cause a unresolvable constraints error, causing one of them to break. However, since this is temporary when it calculates the height, we can avoid this .defaultHigh constraint that temporarily turns off
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).withPriority(.defaultHigh),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        // containerExtraBackgroundView
        NSLayoutConstraint.activate([
            containerExtraBackgroundView.topAnchor.constraint(equalTo: containerView.topAnchor),
            containerExtraBackgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            containerExtraBackgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            containerExtraBackgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // houndPaw
        NSLayoutConstraint.activate([
            houndPaw.topAnchor.constraint(equalTo: dogNameLabel.topAnchor, constant: -ConstraintConstant.Spacing.contentTightIntraHori),
            houndPaw.bottomAnchor.constraint(equalTo: dogNameLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentTightIntraHori),
            houndPaw.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori * 1.2),
            houndPaw.createSquareAspectRatio()
        ])
        
        // reminderActionTextLabel
        NSLayoutConstraint.activate([
            dogNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ConstraintConstant.Spacing.absoluteVertInset * 1.5),
            dogNameLabel.leadingAnchor.constraint(equalTo: houndPaw.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori * 1.2),
            dogNameLabel.createHeightMultiplier(ConstraintConstant.Text.megaHeaderLabelHeightMultipler, relativeToWidthOf: contentView),
            dogNameLabel.createMaxHeight(ConstraintConstant.Text.megaHeaderLabelMaxHeight)
        ])
        
        // chevronImageView
        NSLayoutConstraint.activate([
            chevronImageView.leadingAnchor.constraint(equalTo: dogNameLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.createAspectRatio(ConstraintConstant.Button.chevronAspectRatio),
            chevronImageView.createHeightMultiplier(ConstraintConstant.Button.chevronHeightMultiplier, relativeToWidthOf: contentView),
            chevronImageView.createMaxHeight(ConstraintConstant.Button.chevronMaxHeight)
        ])
        
        // dogTriggersLabel
        dogNameToDogTriggersConstraint = GeneralLayoutConstraint(dogNameLabel.bottomAnchor.constraint(equalTo: dogTriggersLabel.topAnchor, constant: -ConstraintConstant.Spacing.contentIntraVert))
        dogTriggersBottomConstraint = GeneralLayoutConstraint(dogTriggersLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset))
        dogTriggersRelativeHeightConstraint = dogTriggersLabel.heightAnchor.constraint(equalTo: dogNameLabel.heightAnchor, multiplier: 1.0 / 2.25)
        dogTriggersZeroHeightConstraint = dogTriggersLabel.heightAnchor.constraint(equalToConstant: 0)
        
        NSLayoutConstraint.activate([
            dogNameToDogTriggersConstraint.constraint,
            dogTriggersBottomConstraint.constraint,
            dogTriggersRelativeHeightConstraint,
            // don't active dogTriggersZeroHeightConstraint,
            dogTriggersLabel.leadingAnchor.constraint(equalTo: dogNameLabel.leadingAnchor),
            dogTriggersLabel.trailingAnchor.constraint(equalTo: dogNameLabel.trailingAnchor)
        ])
    }
    
}
