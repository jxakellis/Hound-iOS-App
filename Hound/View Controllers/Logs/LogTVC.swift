//
//  LogTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

// TODO LOG SORTING this needs different time display modes.
// if its log start/end date, this its fine and stay regular
// if its last modified or created date, we should add an extra bubble at the bottom with the values so the sort makes sense. this would be a similar format to unit / note. this would probably say something to the effect of "Modified: 2:30PM" or "Created: 2:30PM".

// TODO LOG FAVORITING we need to make logUnit / logNote displays more modular at the bottom. they should ideally go side by side, but if one is too long, then it should be able to go to its own line. Further, if unit/note takes more than 1 line, they should be able to expand up to 3 lines vertically. i think the way to do this is a collection view.

// TODO LOG FAVORITING  add log favorite display. This should go to the RHS of the unit/note/alternative time displays and below the log start/end date/duration displays. Generally. its width should be adaptive. if there is no unit / note (or they are short), then it should just expand horizontally. howeverit should also be able to expand vertically. e.g. if it expands enough to push the unit/note into displaying into 2 lines, then it should also itself be able to display in two lines. it should prioritize growing horizontally, but if it grows too much horizontally, then it should grow vertically. If it does expand enough to push the unit/note into two lines, then it should also expand vertically to match the height of the unit/note. This is a bit tricky. What happens if by doing this (expanding itself to two lines to match the two lines of log unit/note, that log unit / note contract back to a single line? then thats tricky. need a way to manage this.

// UI VERIFIED 6/25/25
final class LogTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    /// Container view for all subviews
    let containerView: HoundView = {
        let view = HoundView()
        view.backgroundColor = UIColor.systemBackground
        return view
    }()
    
    /// Emoji icon indicating the log action
    private let logActionIconLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 350, compressionResistancePriority: 350)
        label.textAlignment = .center
        // same as ReminderTVC
        label.font = UIFont.systemFont(ofSize: 42.5, weight: .medium)
        return label
    }()
    
    /// Label for the dog’s name
    private let dogNameLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 340, compressionResistancePriority: 340)
        label.font = Constant.Visual.Font.emphasizedPrimaryRegularLabel
        return label
    }()
    
    /// Label describing the log action (without emoji)
    private lazy var logActionTextLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 330, compressionResistancePriority: 330)
        label.font = Constant.Visual.Font.primaryRegularLabel
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
        label.font = Constant.Visual.Font.secondaryRegularLabel
        return label
    }()
    
    /// Label showing the duration of the log (e.g., “1 hr”)
    private let logDurationLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.textAlignment = .right
        label.font = Constant.Visual.Font.secondaryRegularLabel
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
        stack.spacing = Constant.Constraint.Spacing.contentIntraHori
        return stack
    }()
    /// Label showing any units for the log (e.g., miles, kCal)
    private let logUnitLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.backgroundColor = UIColor.secondarySystemBackground
        label.font = Constant.Visual.Font.secondaryRegularLabel
        label.shouldRoundCorners = true
        label.staticCornerRadius = nil
        return label
    }()
    
    /// Label for any optional note on the log
    private let logNoteLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.backgroundColor = UIColor.secondarySystemBackground
        label.font = Constant.Visual.Font.secondaryRegularLabel
        label.shouldRoundCorners = true
        label.staticCornerRadius = nil
        return label
    }()
    
    // MARK: - Properties
    
    static let reuseIdentifier = "LogTVC"
    
    // MARK: - Setup
    
    /// Configure the cell’s labels and adjust dynamic constraints based on the provided Log
    func setup(parentDogName dogName: String, log: Log) {
        logActionIconLabel.text = log.logActionType.emoji
        
        // Pad label so it lines up with other labels
        dogNameLabel.text = " \(dogName)"
        
        logActionTextLabel.text = log.logActionType.convertToReadableName(customActionName: log.logCustomActionName, includeMatchingEmoji: false)
        
        // e.g., “7:53 AM”
        logStartToEndDateLabel.text = log.logStartDate.houndFormatted(.formatStyle(date: .omitted, time: .shortened), displayTimeZone: UserConfiguration.timeZone)
        
        if let logEndDate = log.logEndDate {
            let endString: String
            // dont use inSameDayAs, b/c take alarm at 11:59PM to 12:01AM, then we would show 11:59PM - Aug 5 (assuming 11:59PM on Aug 4)
            if log.logStartDate.distance(to: logEndDate) < 60 * 60 * 24 {
                // Same day: no need for date information
                endString = logEndDate.houndFormatted(.formatStyle(date: .omitted, time: .shortened), displayTimeZone: UserConfiguration.timeZone)
            }
            else {
                // Different day: show month + day (and year if not current)
                let logEndYear = Calendar.user.component(.year, from: logEndDate)
                let currentYear = Calendar.user.component(.year, from: Date())
                endString = logEndDate.houndFormatted(.template(logEndYear == currentYear ? "MMMd" : "MMMdyy"), displayTimeZone: UserConfiguration.timeZone)
            }
            logStartToEndDateLabel.text = logStartToEndDateLabel.text?.appending(" - \(endString)")
        }
        
        logDurationLabel.text = {
            guard let logEndDate = log.logEndDate else {
                return nil
            }
            return log.logStartDate.distance(to: logEndDate).readable(capitalizeWords: false, abbreviationLevel: .short, maxComponents: 2, enforceSequentialComponents: true)
        }()
        
        let logUnitString: String? = {
            guard let unitType = log.logUnitType, let numUnits = log.logNumberOfLogUnits else {
                return nil
            }
            return unitType.pluralReadableValueWithNumUnits(logNumberOfLogUnits: numUnits)
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
            // Use .high priority to avoid breaking during table view height estimation
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).withPriority(.defaultHigh),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])
        
        // logActionIconLabel
        NSLayoutConstraint.activate([
            logActionIconLabel.topAnchor.constraint(equalTo: dogNameLabel.topAnchor, constant: -Constant.Constraint.Spacing.contentTightIntraHori),
            logActionIconLabel.bottomAnchor.constraint(equalTo: dogNameLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentTightIntraHori),
            logActionIconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.contentTightIntraHori),
            logActionIconLabel.createSquareAspectRatio()
        ])
        
        // dogNameLabel
        NSLayoutConstraint.activate([
            dogNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            dogNameLabel.leadingAnchor.constraint(equalTo: logActionIconLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentTightIntraHori),
            dogNameLabel.createHeightMultiplier(Constant.Constraint.Text.primaryHeaderLabelHeightMultipler, relativeToWidthOf: contentView),
            dogNameLabel.createMaxHeight(Constant.Constraint.Text.primaryHeaderLabelMaxHeight)
        ])
        
        // logActionTextLabel
        NSLayoutConstraint.activate([
            logActionTextLabel.leadingAnchor.constraint(equalTo: dogNameLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentTightIntraHori),
            logActionTextLabel.topAnchor.constraint(equalTo: dogNameLabel.topAnchor),
            logActionTextLabel.heightAnchor.constraint(equalTo: dogNameLabel.heightAnchor)
        ])
        
        // logDateAndDurationStack
        NSLayoutConstraint.activate([
            logDateAndDurationStack.leadingAnchor.constraint(equalTo: logActionTextLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentTightIntraHori),
            logDateAndDurationStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            logDateAndDurationStack.topAnchor.constraint(equalTo: dogNameLabel.topAnchor),
            logDateAndDurationStack.bottomAnchor.constraint(equalTo: dogNameLabel.bottomAnchor)
        ])
        
        // logUnitAndNoteStack
        dogNameToUnitNoteStackConstraint = GeneralLayoutConstraint(dogNameLabel.bottomAnchor.constraint(equalTo: logUnitAndNoteStack.topAnchor, constant: -Constant.Constraint.Spacing.contentIntraVert))
        dogNameToContainerBottomConstraint = dogNameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset)
        
        logUnitAndNoteStackFullTrailingConstraint = logUnitAndNoteStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        logUnitAndNoteStackPartialTrailingConstraint = logUnitAndNoteStack.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        
        logUnitAndNoteStackHeightConstraint = logUnitLabel.heightAnchor.constraint(equalTo: logStartToEndDateLabel.heightAnchor)
        logUnitAndNoteStackBottomConstraint = logUnitAndNoteStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constant.Constraint.Spacing.contentIntraVert)
        
        handleLogUnitAndNoteStack()
        
        NSLayoutConstraint.activate([
            logUnitAndNoteStack.leadingAnchor.constraint(equalTo: dogNameLabel.leadingAnchor)
        ])
    }
    
}
