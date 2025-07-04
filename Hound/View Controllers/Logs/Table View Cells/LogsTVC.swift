//
//  LogsTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

// UI VERIFIED 6/25/25
final class LogsTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    /// Container view for all subviews
    let containerView: HoundView = {
        let view = HoundView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    /// Emoji icon indicating the log action
    private let logActionIconLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 350, compressionResistancePriority: 350)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 42.5, weight: .medium)
        label.isRoundingToCircle = true
        label.shouldRoundCorners = true
        return label
    }()
    
    /// Label for the dog’s name
    private let dogNameLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 340, compressionResistancePriority: 340)
        label.font = VisualConstant.FontConstant.emphasizedPrimaryRegularLabel
        return label
    }()
    
    /// Label describing the log action (without emoji)
    private lazy var logActionTextLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 330, compressionResistancePriority: 330)
        label.font = VisualConstant.FontConstant.primaryRegularLabel
        return label
    }()
    
    private lazy var logDateAndDurationStack: HoundStackView = {
        let stack = HoundStackView(huggingPriority: 320, compressionResistancePriority: 320)
        stack.addArrangedSubview(logStartToEndDateLabel)
        stack.addArrangedSubview(logDurationLabel)
        stack.axis = .vertical
        stack.distribution = .fillEqually
        return stack
    }()
    /// Label showing the start (and optional end) time of the log
    private let logStartToEndDateLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 310, compressionResistancePriority: 310)
        label.textAlignment = .right
        label.font = VisualConstant.FontConstant.secondaryRegularLabel
        return label
    }()
    
    /// Label showing the duration of the log (e.g., “1 hr”)
    private let logDurationLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.textAlignment = .right
        label.font = VisualConstant.FontConstant.secondaryRegularLabel
        return label
    }()
    
    private var dogNameToUnitNoteStackConstraint: GeneralLayoutConstraint!
    private var logUnitAndNoteStackFullTrailingConstraint: NSLayoutConstraint!
    private var logUnitAndNoteStackPartialTrailingConstraint: NSLayoutConstraint!
    private var dogNameToContainerBottomConstraint: NSLayoutConstraint!
    private var logUnitAndNoteStackHeightConstraint: NSLayoutConstraint!
    private var logUnitAndNoteStackBottomConstraint: NSLayoutConstraint!
    private lazy var logUnitAndNoteStack: HoundStackView = {
        let stack = HoundStackView(huggingPriority: 290, compressionResistancePriority: 290)
        stack.addArrangedSubview(logUnitLabel)
        stack.addArrangedSubview(logNoteLabel)
        stack.axis = .horizontal
        stack.spacing = ConstraintConstant.Spacing.contentIntraHori
        return stack
    }()
    /// Label showing any units for the log (e.g., miles, kCal)
    private let logUnitLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.backgroundColor = .secondarySystemBackground
        label.font = VisualConstant.FontConstant.secondaryRegularLabel
        label.shouldRoundCorners = true
        return label
    }()
    
    /// Label for any optional note on the log
    private let logNoteLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.backgroundColor = .secondarySystemBackground
        label.font = VisualConstant.FontConstant.secondaryRegularLabel
        label.shouldRoundCorners = true
        return label
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "LogsTVC"
    
    // MARK: - Setup
    
    /// Configure the cell’s labels and adjust dynamic constraints based on the provided Log
    func setup(forParentDogName dogName: String, forLog log: Log) {
        logActionIconLabel.text = log.logActionType.emoji
        
        // Pad label so it lines up with other labels
        dogNameLabel.text = " \(dogName)"
        
        logActionTextLabel.text = log.logActionType.convertToReadableName(customActionName: log.logCustomActionName, includeMatchingEmoji: false)
        
        let logStartDateFormatter = DateFormatter()
        logStartDateFormatter.setLocalizedDateFormatFromTemplate("hma") // e.g., “7:53 AM”
        logStartToEndDateLabel.text = logStartDateFormatter.string(from: log.logStartDate)
        
        if let logEndDate = log.logEndDate {
            let logEndDateFormatter = DateFormatter()
            if log.logStartDate.distance(to: logEndDate) < 60 * 60 * 24 {
                // Same day: no need for date information
                logEndDateFormatter.setLocalizedDateFormatFromTemplate("hma")
            }
            else {
                // Different day: show month + day (and year if not current)
                let logEndYear = Calendar.current.component(.year, from: logEndDate)
                let currentYear = Calendar.current.component(.year, from: Date())
                logEndDateFormatter.setLocalizedDateFormatFromTemplate(logEndYear == currentYear ? "MMMd" : "MMMdyy")
            }
            logStartToEndDateLabel.text = logStartToEndDateLabel.text?.appending(" - \(logEndDateFormatter.string(from: logEndDate))")
        }
        
        logDurationLabel.text = {
            guard let logEndDate = log.logEndDate else {
                return nil
            }
            return log.logStartDate.distance(to: logEndDate).readable(capitalizeWords: false, abreviateWords: true)
        }()
        
        let logUnitString: String? = {
            guard let unitType = log.logUnitType, let numUnits = log.logNumberOfLogUnits else {
                return nil
            }
            return unitType.convertedMeasurementString(forLogNumberOfLogUnits: numUnits, toTargetSystem: UserConfiguration.measurementSystem)
        }()
        logUnitLabel.text = logUnitString.map { "  \($0)  " }
        logUnitLabel.isHidden = logUnitLabel.text == nil
        
        logNoteLabel.text = {
            let trimmedNote = log.logNote.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedNote.isEmpty else { return nil }
            return "  \(trimmedNote)  "
        }()
        logNoteLabel.isHidden = logNoteLabel.text == nil
        
        handleLogUnitAndNoteStack()
    }
    
    // MARK: - Setup Elements
    
    private func handleLogUnitAndNoteStack() {
        let shouldShowUnitNoteStack = logUnitLabel.text != nil || logNoteLabel.text != nil
        logUnitAndNoteStack.isHidden = !shouldShowUnitNoteStack
        
        if shouldShowUnitNoteStack {
            NSLayoutConstraint.deactivate([
                dogNameToContainerBottomConstraint
            ])
            dogNameToUnitNoteStackConstraint.constant = logDurationLabel.text == nil ? 0 : dogNameToUnitNoteStackConstraint.originalConstant
            NSLayoutConstraint.activate([
                dogNameToUnitNoteStackConstraint.constraint,
                logUnitAndNoteStackBottomConstraint,
                logUnitAndNoteStackHeightConstraint
            ])
            
            logUnitAndNoteStackFullTrailingConstraint.isActive = logNoteLabel.text != nil && logUnitLabel.text != nil
            logUnitAndNoteStackPartialTrailingConstraint.isActive = !logUnitAndNoteStackFullTrailingConstraint.isActive
        }
        else {
            NSLayoutConstraint.deactivate([
                dogNameToUnitNoteStackConstraint.constraint,
                logUnitAndNoteStackBottomConstraint,
                logUnitAndNoteStackHeightConstraint,
                logUnitAndNoteStackFullTrailingConstraint,
                logUnitAndNoteStackPartialTrailingConstraint
            ])
            dogNameToContainerBottomConstraint.isActive = true
        }
    }
    
    private let logActionIconInset: CGFloat = 2.5
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        containerView.addSubview(logActionIconLabel)
        containerView.addSubview(dogNameLabel)
        containerView.addSubview(logActionTextLabel)
        containerView.addSubview(logDateAndDurationStack)
        containerView.addSubview(logUnitAndNoteStack)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        // containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).withPriority(.defaultHigh),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        // logActionIconLabel
        NSLayoutConstraint.activate([
            logActionIconLabel.topAnchor.constraint(equalTo: dogNameLabel.topAnchor, constant: -ConstraintConstant.Spacing.contentTightIntraHori),
            logActionIconLabel.bottomAnchor.constraint(equalTo: dogNameLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentTightIntraHori),
            logActionIconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentTightIntraHori),
            logActionIconLabel.createSquareAspectRatio()
        ])
        
        // dogNameLabel
        NSLayoutConstraint.activate([
            dogNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ConstraintConstant.Spacing.absoluteVerticalInset),
            dogNameLabel.leadingAnchor.constraint(equalTo: logActionIconLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentTightIntraHori),
            dogNameLabel.createHeightMultiplier(ConstraintConstant.Text.headerLabelHeightMultipler, relativeToWidthOf: contentView),
            dogNameLabel.createMaxHeight(ConstraintConstant.Text.headerLabelMaxHeight)
        ])
        
        // logActionTextLabel
        NSLayoutConstraint.activate([
            logActionTextLabel.leadingAnchor.constraint(equalTo: dogNameLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentTightIntraHori),
            logActionTextLabel.topAnchor.constraint(equalTo: dogNameLabel.topAnchor),
            logActionTextLabel.heightAnchor.constraint(equalTo: dogNameLabel.heightAnchor)
        ])
        
        // logDateAndDurationStack
        NSLayoutConstraint.activate([
            logDateAndDurationStack.leadingAnchor.constraint(equalTo: logActionTextLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentTightIntraHori),
            logDateAndDurationStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            logDateAndDurationStack.topAnchor.constraint(equalTo: dogNameLabel.topAnchor),
            logDateAndDurationStack.bottomAnchor.constraint(equalTo: dogNameLabel.bottomAnchor)
        ])
        
        // logUnitAndNoteStack
        dogNameToUnitNoteStackConstraint = GeneralLayoutConstraint(dogNameLabel.bottomAnchor.constraint(equalTo: logUnitAndNoteStack.topAnchor, constant: -ConstraintConstant.Spacing.contentIntraVert))
        dogNameToContainerBottomConstraint = dogNameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVerticalInset)
        
        logUnitAndNoteStackFullTrailingConstraint = logUnitAndNoteStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        logUnitAndNoteStackPartialTrailingConstraint = logUnitAndNoteStack.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        
        logUnitAndNoteStackHeightConstraint = logUnitLabel.heightAnchor.constraint(equalTo: logStartToEndDateLabel.heightAnchor)
        logUnitAndNoteStackBottomConstraint = logUnitAndNoteStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Spacing.contentIntraVert)
        
        handleLogUnitAndNoteStack()
        
        NSLayoutConstraint.activate([
            logUnitAndNoteStack.leadingAnchor.constraint(equalTo: dogNameLabel.leadingAnchor)
        ])
    }
    
}
