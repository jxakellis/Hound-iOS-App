//
//  DogsAddDogTriggerTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/10/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DogsAddDogTriggerTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    let containerView: HoundView = {
        let view = HoundView()
        view.backgroundColor = UIColor.systemBackground
        view.applyStyle(.thinGrayBorder)
        return view
    }()
    
    private let triggerMainLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.font = VisualConstant.FontConstant.primaryHeaderLabel
        return label
    }()
    
    private let triggerSubLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        return label
    }()
    
    private let chevronImageView: HoundImageView = {
        let imageView = HoundImageView(huggingPriority: 300, compressionResistancePriority: 300)

        imageView.alpha = 0.75
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor.systemGray4
        
        return imageView
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "DogsAddDogTriggerTVC"
    
    // MARK: - Setup
    
    func setup(forTrigger: Trigger) {
        triggerMainLabel.text = "Main"
        triggerSubLabel.text = "Sub"
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        
        containerView.addSubview(triggerMainLabel)
        containerView.addSubview(triggerSubLabel)
        containerView.addSubview(chevronImageView)
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
        
        // triggerMainLabel
        NSLayoutConstraint.activate([
            triggerMainLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ConstraintConstant.Spacing.absoluteVertInset),
            triggerMainLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori),
            triggerMainLabel.createHeightMultiplier(ConstraintConstant.Text.primaryHeaderLabelHeightMultipler, relativeToWidthOf: contentView),
            triggerMainLabel.createMaxHeight(ConstraintConstant.Text.primaryHeaderLabelMaxHeight)
        ])
        
        // chevronImageView
        NSLayoutConstraint.activate([
            chevronImageView.leadingAnchor.constraint(equalTo: triggerMainLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.createAspectRatio(ConstraintConstant.Button.chevronAspectRatio),
            chevronImageView.createHeightMultiplier(ConstraintConstant.Button.chevronHeightMultiplier, relativeToWidthOf: contentView),
            chevronImageView.createMaxHeight(ConstraintConstant.Button.chevronMaxHeight)
        ])
        
        // triggerSubLabel
        NSLayoutConstraint.activate([
            triggerSubLabel.topAnchor.constraint(equalTo: triggerMainLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentTightIntraVert),
            triggerSubLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset),
            triggerSubLabel.leadingAnchor.constraint(equalTo: triggerMainLabel.leadingAnchor),
            triggerSubLabel.trailingAnchor.constraint(equalTo: triggerMainLabel.trailingAnchor)
        ])
    }

}
