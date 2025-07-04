//
//  HoundIntroductionView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/24/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

/// Modular introduction view with header, description, and content slot.
/// Designed for reuse across pages.
final class HoundIntroductionView: HoundView {
    
    // MARK: - Elements
    
    let backgroundImageView: HoundImageView = {
        let imageView = HoundImageView(huggingPriority: 300, compressionResistancePriority: 300)
        imageView.image = UIImage(named: "darkGreenForestWithMountainsFamilyWalkingDog")
        return imageView
    }()
    
    let whiteBackgroundView: HoundView = {
        let view = HoundView(huggingPriority: 290, compressionResistancePriority: 290)
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    let pageHeaderLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.textAlignment = .center
        label.font = VisualConstant.FontConstant.primaryHeaderLabel
        return label
    }()
    
    let pageDescriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        label.textColor = .secondaryLabel
        return label
    }()
    
    let contentView: HoundView = {
        let view = HoundView(huggingPriority: 260, compressionResistancePriority: 260)
        return view
    }()
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        self.backgroundColor = .systemBackground
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        self.addSubview(backgroundImageView)
        self.addSubview(whiteBackgroundView)
        self.addSubview(pageHeaderLabel)
        self.addSubview(pageDescriptionLabel)
        self.addSubview(contentView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        let overlap: CGFloat = 25.0
        
        // backgroundImageView
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(lessThanOrEqualTo: self.topAnchor),
            backgroundImageView.bottomAnchor.constraint(lessThanOrEqualTo: self.centerYAnchor).withPriority(.defaultHigh),
            backgroundImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundImageView.createSquareAspectRatio()
        ])
        
        // whiteBackgroundView
        NSLayoutConstraint.activate([
            whiteBackgroundView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -overlap),
            whiteBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            whiteBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            whiteBackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        
        // pageHeaderLabel
        NSLayoutConstraint.activate([
            pageHeaderLabel.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: overlap),
            pageHeaderLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            pageHeaderLabel.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            pageHeaderLabel.createMaxHeight( ConstraintConstant.Text.headerLabelMaxHeight),
            pageHeaderLabel.createHeightMultiplier(ConstraintConstant.Text.headerLabelHeightMultipler, relativeToWidthOf: self)
        ])
        
        // pageDescriptionLabel
        NSLayoutConstraint.activate([
            pageDescriptionLabel.topAnchor.constraint(equalTo: pageHeaderLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            pageDescriptionLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            pageDescriptionLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        // contentView
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: pageDescriptionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            contentView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            contentView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            contentView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVerticalInset)
        ])
    }
}
