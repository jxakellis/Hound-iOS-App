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

    @IBOutlet private(set) weak var containerView: UIView! // swiftlint:disable:this private_outlet

    @IBOutlet private weak var dogIconImageView: GeneralUIImageView!
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

    @IBOutlet private weak var dogNameLabel: GeneralUILabel!

    // MARK: - Properties

    var dog: Dog?

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
