//
//  IntroductionView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/24/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

/// Modular introduction view with header, description, and content slot.
/// Designed for reuse across pages.
final class IntroductionView: GeneralUIView {
    
    // MARK: - Elements
    
    let backgroundImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 300, compressionResistancePriority: 300)
        imageView.image = UIImage(named: "darkGreenForestWithMountainsFamilyWalkingDog")
        return imageView
    }()
    
    let whiteBackgroundView: GeneralUIView = {
        let view = GeneralUIView(huggingPriority: 290, compressionResistancePriority: 290)
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    let pageHeaderLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.textAlignment = .center
        label.font = VisualConstant.FontConstant.primaryHeaderLabel
        return label
    }()
    
    let pageDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        label.textColor = .secondaryLabel
        return label
    }()
    
    let contentView: GeneralUIView = {
        let view = GeneralUIView(huggingPriority: 260, compressionResistancePriority: 260)
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
            pageHeaderLabel.leadingAnchor.constraint(equalTo: whiteBackgroundView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            pageHeaderLabel.trailingAnchor.constraint(equalTo: whiteBackgroundView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset),
            pageHeaderLabel.createMaxHeight( ConstraintConstant.Text.headerLabelMaxHeight),
            pageHeaderLabel.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: ConstraintConstant.Text.headerLabelHeightMultipler).withPriority(.defaultHigh)
        ])
        
        // pageDescriptionLabel
        NSLayoutConstraint.activate([
            pageDescriptionLabel.topAnchor.constraint(equalTo: pageHeaderLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVertSpacing),
            pageDescriptionLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            pageDescriptionLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset)
        ])
        
        // contentView
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: pageDescriptionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.headerVertSpacingToSection),
            contentView.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            contentView.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset),
            contentView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -ConstraintConstant.Spacing.contentAbsVertInset)
        ])
    }
}
