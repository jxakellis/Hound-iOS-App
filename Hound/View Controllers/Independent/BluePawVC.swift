//
//  BluePawVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/24/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

class BluePawVC: HoundViewController {

    // MARK: - Elements
    
    private let houndPaw: HoundPawImageView = {
        let imageView = HoundPawImageView(huggingPriority: 340, compressionResistancePriority: 340)
        
        return imageView
    }()
    
    let headerLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 330, compressionResistancePriority: 330)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        label.font = Constant.Visual.Font.primaryHeaderLabel
        label.textColor = UIColor.systemBackground
        return label
    }()
    
    let descriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 320, compressionResistancePriority: 320)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        label.font = Constant.Visual.Font.tertiaryHeaderLabel
        label.textColor = UIColor.secondarySystemBackground
        return label
    }()
    
    let backButton: HoundButton = {
        let button = HoundButton(huggingPriority: 350, compressionResistancePriority: 350)
        
        button.tintColor = UIColor.systemBackground
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = UIColor.systemBlue
        
        button.shouldDismissParentViewController = true
        return button
    }()

    let contentView: HoundView = {
        let view = HoundView(huggingPriority: 310, compressionResistancePriority: 310)
        
        return view
    }()
    
    // MARK: - Main
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }

    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.systemBlue
        
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        view.addSubview(houndPaw)
        view.addSubview(headerLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(backButton)
        view.addSubview(contentView)
    }

    override func setupConstraints() {
        super.setupConstraints()
        
        // backButton
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            backButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteCircleHoriInset),
            backButton.createHeightMultiplier(Constant.Constraint.Button.circleHeightMultiplier, relativeToWidthOf: view),
            backButton.createMaxHeight(Constant.Constraint.Button.circleMaxHeight),
            backButton.createSquareAspectRatio()
        ])

        // pawWithHands
        NSLayoutConstraint.activate([
            houndPaw.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            houndPaw.createSquareAspectRatio(),
            houndPaw.createHeightMultiplier(Constant.Constraint.Text.pawHeightMultiplier, relativeToWidthOf: view),
            houndPaw.createMaxHeight(Constant.Constraint.Text.pawMaxHeight)
        ])

        // headerLabel
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: houndPaw.bottomAnchor, constant: 20),
            headerLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            headerLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])

        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 12.5),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])

        // contentView
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            contentView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            contentView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset)
        ])
    }

}
