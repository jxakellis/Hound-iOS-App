//
//  DogsAddDogTriggerTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/10/25.
//  Copyright © 2025 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

final class DogsAddDogTriggerTVC: HoundTableViewCell, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return infoItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LogInfoBubbleCVC.reuseIdentifier, for: indexPath) as? LogInfoBubbleCVC else {
            return UICollectionViewCell()
        }
        cell.setup(text: infoItems[indexPath.item])
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let inset = layout?.sectionInset ?? .zero
        let maxWidth = collectionView.bounds.width - inset.left - inset.right
        cell.setMaxWidth(maxWidth)
        return cell
    }
    
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
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
        return label
    }()
    
    private let reminderResultLabel: HoundLabel = {
        let label = HoundLabel()
        label.font = Constant.Visual.Font.secondaryRegularLabel
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = false
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
    
    private lazy var infoBubbleCollectionView: UICollectionView = {
        let layout = HoundLeftAlignedCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = Constant.Constraint.Spacing.contentIntraHori
        layout.minimumLineSpacing = Constant.Constraint.Spacing.contentIntraVert
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        let collectionView = HoundIntrinsicCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(LogInfoBubbleCVC.self, forCellWithReuseIdentifier: LogInfoBubbleCVC.reuseIdentifier)
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.delegate = self
        
        return collectionView
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "DogsAddDogTriggerTVC"
    
    private var infoItems: [String] = []
    
    // MARK: - Setup
    
    func setup(trigger: Trigger) {
        logReactionsLabel.attributedText = {
            let logs = trigger.triggerLogReactions.map { $0.readableName(includeMatchingEmoji: true) }
            let logNames = logs.joined(separator: ", ", endingSeparator: " or ")
            
            // Build the appropriate phrase depending on trigger conditions.
            let text: String
            if trigger.triggerManualCondition && trigger.triggerAlarmCreatedCondition {
                text = "Whenever a \(logNames) log is added"
            }
            else if trigger.triggerManualCondition {
                text = "Whenever someone adds a \(logNames) log"
            }
            else if trigger.triggerAlarmCreatedCondition {
                text = "Whenever an alarm adds a \(logNames) log"
            }
            else {
                text = "Whenever a \(logNames) log is added"
            }
            
            // Find ranges for emphasis styling (log names)
            let attributed = NSMutableAttributedString(string: text, attributes: [.font: Constant.Visual.Font.primaryRegularLabel])
            
            // Find and emphasize log names within the text
            if let range = attributed.string.range(of: logNames) {
                let nsRange = NSRange(range, in: attributed.string)
                attributed.addAttributes([.font: Constant.Visual.Font.emphasizedPrimaryRegularLabel], range: nsRange)
            }
            return attributed
        }()
        
        reminderResultLabel.attributedText = {
            let message: NSMutableAttributedString = NSMutableAttributedString(
                string: "Create ",
                attributes: [.font: Constant.Visual.Font.secondaryRegularLabel])
            message.append(
                NSAttributedString(
                    string: trigger.triggerReminderResult.readableName,
                    attributes: [.font: Constant.Visual.Font.emphasizedSecondaryRegularLabel]
                )
            )
            message.append(
                NSAttributedString(
                    string: " for \(trigger.readableTime())",
                    attributes: [.font: Constant.Visual.Font.secondaryRegularLabel]
                )
            )
            return message
        }()
        
        let previousInfoItems = infoItems
        infoItems = []
        
        let weekAgo = Calendar.user.date(byAdding: .weekOfYear, value: -1, to: Date()) ?? Date()
        let recent = trigger.triggerActivations.map({ $0.activationDate }).filter({ $0 >= weekAgo }).sorted()
        
        if let last = recent.last {
            let timeString = last.houndFormatted(.formatStyle(date: .omitted, time: .shortened), displayTimeZone: UserConfiguration.timeZone)
            let text: String
            if Calendar.user.isDateInToday(last) {
                text = "Last activated at \(timeString)"
            }
            else if Calendar.user.isDateInYesterday(last) {
                text = "Last activated yesterday at \(timeString)"
            }
            else {
                let day = last.houndFormatted(.template("EEEE"), displayTimeZone: UserConfiguration.timeZone)
                text = "Last activated \(day) at \(timeString)"
            }
            infoItems.append(text)
            if recent.count > 1 {
                infoItems.append("Activated \(recent.count) times in the past week")
            }
        }
        if previousInfoItems != infoItems {
            infoBubbleCollectionView.reloadData()
            remakeInfoBubbleConstraints()
            findParentTableViewAndRelayoutCells()
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
        containerView.addSubview(infoBubbleCollectionView)
        containerView.addSubview(chevronImageView)
    }
    
    private func remakeInfoBubbleConstraints() {
        labelStack.snp.removeConstraints()
        infoBubbleCollectionView.snp.removeConstraints()
        infoBubbleCollectionView.isHidden = infoItems.isEmpty
        
        labelStack.snp.makeConstraints { make in
            make.top.equalTo(containerView.snp.top).offset(Constant.Constraint.Spacing.absoluteVertInset)
            make.leading.equalTo(containerView.snp.leading).offset(Constant.Constraint.Spacing.contentIntraHori)
            if infoItems.isEmpty {
                make.bottom.equalTo(containerView.snp.bottom).inset(Constant.Constraint.Spacing.absoluteVertInset)
            }
        }
        
        if !infoItems.isEmpty {
            infoBubbleCollectionView.snp.makeConstraints { make in
                make.top.equalTo(labelStack.snp.bottom).offset(Constant.Constraint.Spacing.contentIntraVert)
                make.leading.equalTo(containerView.snp.leading).offset(Constant.Constraint.Spacing.absoluteHoriInset)
                make.trailing.equalTo(containerView.snp.trailing).inset(Constant.Constraint.Spacing.absoluteHoriInset)
                make.bottom.equalTo(containerView.snp.bottom).inset(Constant.Constraint.Spacing.absoluteVertInset)
            }
        }
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
        
        remakeInfoBubbleConstraints()
        
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
