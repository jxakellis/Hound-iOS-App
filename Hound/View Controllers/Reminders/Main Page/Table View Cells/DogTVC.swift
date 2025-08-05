//
//  DogsMainScreenTableViewCellDogDescription.swift
//  Hound
//
//  Created by Jonathan Xakellis on 1/11/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import SnapKit
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
        let imageView = HoundPawImageView(huggingPriority: 290, compressionResistancePriority: 290)
        
        imageView.shouldRoundCorners = true
        imageView.staticCornerRadius = nil
        
        return imageView
    }()
    
    private let dogNameLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 295, compressionResistancePriority: 295)
        label.font = Constant.Visual.Font.megaHeaderLabel
        label.textColor = UIColor.systemBackground
        return label
    }()
    
    private let chevronImageView: HoundImageView = {
        let imageView = HoundImageView(huggingPriority: 300, compressionResistancePriority: 300)
        
        imageView.alpha = 0.75
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = UIColor.systemBackground
        
        return imageView
    }()
    
    private let dogTriggersLabel: HoundLabel = {
        let label = HoundLabel()
        label.backgroundColor = UIColor.systemBackground
        label.font = Constant.Visual.Font.emphasizedSecondaryRegularLabel
        label.textColor = UIColor.label
        
        label.shouldInsetText = true
        label.shouldRoundCorners = true
        label.staticCornerRadius = nil
        return label
    }()
    
    private lazy var labelStack: HoundStackView = {
        let stack = HoundStackView(huggingPriority: 294, compressionResistancePriority: 294)
        stack.addArrangedSubview(dogNameLabel)
        stack.addArrangedSubview(dogTriggersLabel)
        stack.axis = .vertical
        stack.distribution = .fillProportionally
        stack.alignment = .fill
        stack.spacing = Constant.Constraint.Spacing.contentTightIntraVert
        return stack
    }()
        
    // MARK: - Properties
    
    static let reuseIdentifier = "DogTVC"
    
    var dog: Dog?
    
    // MARK: - Setup
    
    func setup(dog: Dog) {
        self.dog = dog
        
        houndPaw.shouldRoundCorners = dog.dogIcon != nil
        
        dogNameLabel.text = dog.dogName
        if dog.dogTriggers.dogTriggers.isEmpty {
            dogTriggersLabel.text = "No automations ✨"
        }
        else {
            dogTriggersLabel.text = "\(dog.dogTriggers.dogTriggers.count) automation\(dog.dogTriggers.dogTriggers.count > 1 ? "s" : "") ✨"
        }
    }
    
    // MARK: - Setup Elements
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerExtraBackgroundView)
        contentView.addSubview(containerView)
        containerView.addSubview(houndPaw)
        containerView.addSubview(chevronImageView)
        containerView.addSubview(labelStack)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        containerView.snp.makeConstraints { make in
            // Use .high priority to avoid breaking during table view height estimation
            make.verticalEdges.equalTo(contentView.snp.verticalEdges).priority(.high)
            make.horizontalEdges.equalTo(contentView.snp.horizontalEdges).inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
        
        containerExtraBackgroundView.snp.makeConstraints { make in
            make.edges.equalTo(containerView.snp.edges)
        }
        
        houndPaw.snp.makeConstraints { make in
            make.height.equalTo(dogNameLabel.snp.height).offset(Constant.Constraint.Spacing.contentTightIntraHori * 2.0)
            make.centerY.equalTo(dogNameLabel.snp.centerY)
            make.leading.equalTo(containerView.snp.leading).offset(Constant.Constraint.Spacing.contentIntraHori)
            make.width.equalTo(houndPaw.snp.height)
        }
        
        dogNameLabel.snp.makeConstraints { make in
            make.height.equalTo(contentView.snp.width).multipliedBy(Constant.Constraint.Text.megaHeaderLabelHeightMultipler).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Text.megaHeaderLabelMaxHeight)
        }
        
        labelStack.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(Constant.Constraint.Spacing.absoluteVertInset * 2.0)
            make.bottom.equalTo(containerView.snp.bottom).inset(Constant.Constraint.Spacing.absoluteVertInset)
            make.leading.equalTo(houndPaw.snp.trailing).offset(Constant.Constraint.Spacing.contentIntraHori)
        }
        
        chevronImageView.snp.makeConstraints { make in
            make.leading.equalTo(labelStack.snp.trailing).offset(Constant.Constraint.Spacing.contentIntraHori)
            make.trailing.equalTo(containerView.snp.trailing).inset(Constant.Constraint.Spacing.absoluteHoriInset)
            make.centerY.equalTo(containerView.snp.centerY)
            make.height.equalTo(contentView.snp.width).multipliedBy(Constant.Constraint.Button.chevronHeightMultiplier).priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Button.chevronMaxHeight)
            make.width.equalTo(chevronImageView.snp.height).multipliedBy(Constant.Constraint.Button.chevronAspectRatio)
        }
    }
    
}
