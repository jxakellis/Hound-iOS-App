//
//  DogsAddDogTriggerTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/10/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

final class DogsAddDogTriggerTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    let containerView: HoundView = {
        let view = HoundView()
        view.backgroundColor = UIColor.systemBackground
        view.applyStyle(.thinGrayBorder)
        return view
    }()
    
    private let logReactionsLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.primaryRegularLabel
        label.adjustsFontSizeToFitWidth = false
        label.numberOfLines = 0
        return label
    }()
    
    private let reminderResultLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.secondaryRegularLabel
        label.adjustsFontSizeToFitWidth = false
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var labelStack: HoundStackView = {
        let stack = HoundStackView(huggingPriority: 290, compressionResistancePriority: 290)
        stack.addArrangedSubview(logReactionsLabel)
        stack.addArrangedSubview(reminderResultLabel)
        stack.axis = .vertical
        stack.distribution = .equalSpacing
        stack.spacing = Constant.Constraint.Spacing.contentIntraVert
        stack.alignment = .leading
        return stack
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
        let precalcLogTextColor = logReactionsLabel.textColor
        logReactionsLabel.attributedTextClosure = {
            // NOTE: ANY VARIABLES WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS MUST BE PRECALCULATED. Code is re-run everytime the UITraitCollection is updated
            let message: NSMutableAttributedString = NSMutableAttributedString(
                string: "Any ",
                attributes: [.font: Constant.Visual.Font.primaryRegularLabel, .foregroundColor: precalcLogTextColor as Any])
            message.append(
                NSAttributedString(
                    string: forTrigger.triggerLogReactions.map({ $0.readableName(includeMatchingEmoji: false) }).joined(separator: ", ", endingSeparator: " or "),
                    attributes: [.font: Constant.Visual.Font.emphasizedPrimaryRegularLabel, .foregroundColor: precalcLogTextColor as Any]
                )
            )
            message.append(
                NSAttributedString(
                    string: " log",
                    attributes: [.font: Constant.Visual.Font.primaryRegularLabel, .foregroundColor: precalcLogTextColor as Any]
                )
            )
            return message
        }
        
        let precalcReminderTextColor = reminderResultLabel.textColor
        reminderResultLabel.attributedTextClosure = {
            // NOTE: ANY VARIABLES WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS MUST BE PRECALCULATED. Code is re-run everytime the UITraitCollection is updated
            let message: NSMutableAttributedString = NSMutableAttributedString(
                string: "Creates ",
                attributes: [.font: Constant.Visual.Font.secondaryRegularLabel, .foregroundColor: precalcReminderTextColor as Any])
            message.append(
                NSAttributedString(
                    string: forTrigger.triggerReminderResult.readableName,
                    attributes: [.font: Constant.Visual.Font.emphasizedSecondaryRegularLabel, .foregroundColor: precalcReminderTextColor as Any]
                )
            )
            message.append(
                NSAttributedString(
                    string: " for \(forTrigger.readableTime())",
                    attributes: [.font: Constant.Visual.Font.secondaryRegularLabel, .foregroundColor: precalcReminderTextColor as Any]
                )
            )
            return message
        }
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        
        containerView.addSubview(labelStack)
        containerView.addSubview(chevronImageView)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        containerView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top)
            // Use .high priority to avoid breaking during table view height estimation
            make.bottom.equalTo(contentView.snp.bottom).priority(.high)
            make.leading.equalTo(contentView.snp.leading).offset(Constant.Constraint.Spacing.absoluteHoriInset)
            make.trailing.equalTo(contentView.snp.trailing).inset(Constant.Constraint.Spacing.absoluteHoriInset)
        }
        
        labelStack.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(Constant.Constraint.Spacing.absoluteVertInset)
            make.leading.equalTo(containerView.snp.leading).offset(Constant.Constraint.Spacing.contentIntraHori)
            make.bottom.equalTo(containerView.snp.bottom).inset(Constant.Constraint.Spacing.absoluteVertInset)
        }
        
        chevronImageView.snp.makeConstraints { make in
            make.leading.equalTo(labelStack.snp.trailing).offset(Constant.Constraint.Spacing.contentIntraHori)
            make.trailing.equalTo(containerView.snp.trailing).inset(Constant.Constraint.Spacing.absoluteHoriInset)
            make.centerY.equalTo(containerView.snp.centerY)
            make.height.equalTo(contentView.snp.width)
                .multipliedBy(Constant.Constraint.Button.chevronHeightMultiplier)
                .priority(.high)
            make.height.lessThanOrEqualTo(Constant.Constraint.Button.chevronMaxHeight)
            make.width.equalTo(chevronImageView.snp.height)
                .multipliedBy(Constant.Constraint.Button.chevronAspectRatio)
        }
    }
}
