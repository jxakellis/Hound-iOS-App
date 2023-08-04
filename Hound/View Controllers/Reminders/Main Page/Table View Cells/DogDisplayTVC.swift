//
//  DogsMainScreenTableViewCellDogDescription.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/11/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsDogDisplayTableViewCell: UITableViewCell {

    // MARK: - IB

    @IBOutlet private(set) weak var containerView: UIView! // swiftlint:disable:this private_outlet

    @IBOutlet private weak var dogIconImageView: GeneralUIImageView!

    @IBOutlet private weak var dogIconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogIconTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogIconTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogIconBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogIconWidthConstraint: NSLayoutConstraint!

    @IBOutlet private weak var dogNameLabel: GeneralUILabel!

    @IBOutlet private weak var dogNameHeightConstraint: NSLayoutConstraint!

    @IBOutlet private weak var rightChevronLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightChevronTrailingConstraint: NSLayoutConstraint!

    // MARK: - Properties

    var dog: Dog?

    // MARK: - Functions

    // Function used externally to setup dog
    func setup(forDog: Dog) {
        self.dog = forDog

        // Size Ratio Scaling

        let sizeRatio = UserConfiguration.remindersInterfaceScale.currentScaleFactor

        dogIconImageView.image = forDog.dogIcon ?? (
                UITraitCollection.current.userInterfaceStyle == .dark
                ? ClassConstant.DogConstant.blackPawWithHands
                : ClassConstant.DogConstant.whitePawWithHands)
        dogIconImageView.shouldRoundCorners = forDog.dogIcon != nil

        let dogIconWidth = forDog.dogIcon == nil
        ? 55.0 * sizeRatio
        : 60.0 * sizeRatio
        dogIconWidthConstraint.constant = dogIconWidth
        let leadingTrailingTopBottomConstraintConstant = forDog.dogIcon == nil
        ? 12.5 * sizeRatio
        : 10.0 * sizeRatio
        dogIconLeadingConstraint.constant = leadingTrailingTopBottomConstraintConstant
        dogIconTrailingConstraint.constant = leadingTrailingTopBottomConstraintConstant
        dogIconTopConstraint.constant = leadingTrailingTopBottomConstraintConstant
        dogIconBottomConstraint.constant = leadingTrailingTopBottomConstraintConstant

        // Dog Name Label Configuration
        dogNameLabel.shouldAdjustMinimumScaleFactor = true
        dogNameLabel.text = forDog.dogName
        dogNameLabel.font = dogNameLabel.font.withSize(47.5 * sizeRatio)
        dogNameHeightConstraint.constant = 55.0 * sizeRatio

        // Right Chevron Configuration
        rightChevronLeadingConstraint.constant = 10.0 * sizeRatio
        rightChevronTrailingConstraint.constant = 15.0 * sizeRatio
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
