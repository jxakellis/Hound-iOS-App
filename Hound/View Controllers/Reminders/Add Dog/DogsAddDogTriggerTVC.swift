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
        label.numberOfLines = 0
        return label
    }()
    
    private let reminderResultLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.secondaryRegularLabel
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
            let logs = forTrigger.triggerLogReactions.map { $0.readableName(includeMatchingEmoji: true) }
            let logNames = logs.joined(separator: ", ", endingSeparator: " or ")
            
            // Build the appropriate phrase depending on trigger conditions.
            let text: String
            if forTrigger.triggerManualCondition && forTrigger.triggerAlarmCreatedCondition {
                text = "Whenever a \(logNames) log is added"
            }
            else if forTrigger.triggerManualCondition {
                text = "Whenever someone adds a \(logNames) log"
            }
            else if forTrigger.triggerAlarmCreatedCondition {
                text = "Whenever an alarm adds a \(logNames) log"
            }
            else {
                text = "Whenever a \(logNames) log is added"
            }
            
            // Find ranges for emphasis styling (log names)
            let attributed = NSMutableAttributedString(string: text, attributes: [
                .font: Constant.Visual.Font.primaryRegularLabel,
                .foregroundColor: precalcLogTextColor as Any
            ])
            
            // Find and emphasize log names within the text
            if let range = attributed.string.range(of: logNames) {
                let nsRange = NSRange(range, in: attributed.string)
                attributed.addAttributes([
                    .font: Constant.Visual.Font.emphasizedPrimaryRegularLabel,
                    .foregroundColor: precalcLogTextColor as Any
                ], range: nsRange)
            }
            return attributed
        }
        
        let precalcReminderTextColor = reminderResultLabel.textColor
        reminderResultLabel.attributedTextClosure = {
            // NOTE: ANY VARIABLES WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS MUST BE PRECALCULATED. Code is re-run everytime the UITraitCollection is updated
            let message: NSMutableAttributedString = NSMutableAttributedString(
                string: "Create ",
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
