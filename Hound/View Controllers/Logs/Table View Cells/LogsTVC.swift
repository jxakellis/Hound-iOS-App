//
//  LogsTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogsTVC: GeneralUITableViewCell {
    
    // MARK: - Elements
    
    /// Container view for all subviews
    let containerView: GeneralUIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    /// Emoji icon indicating the log action
    private let logActionIconLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 370, compressionResistancePriority: 370)
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 40, weight: .medium)
        label.isRoundingToCircle = true
        label.shouldRoundCorners = true
        return label
    }()
    
    /// Label for the dog’s name
    private let dogNameLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 350, compressionResistancePriority: 350)
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    /// Label describing the log action (without emoji)
    private let logActionWithoutIconLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 340, compressionResistancePriority: 340)
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    /// Label showing the start (and optional end) time of the log
    private let logStartToEndDateLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 390, compressionResistancePriority: 390)
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    /// Label showing the duration of the log (e.g., “1 hr”)
    private let logDurationLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 380, compressionResistancePriority: 380)
        label.textAlignment = .right
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    /// Label showing any units for the log (e.g., miles, kCal)
    private let logUnitLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.backgroundColor = .secondarySystemBackground
        label.font = .systemFont(ofSize: 12.5)
        label.shouldRoundCorners = true
        return label
    }()
    
    /// Label for any optional note on the log
    private let logNoteLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.backgroundColor = .secondarySystemBackground
        label.font = .systemFont(ofSize: 12.5)
        label.shouldRoundCorners = true
        return label
    }()
    
    /// Constraint to collapse/expand the gap from duration label to the action icon
    private var logDurationBottomConstraint: NSLayoutConstraint!
    /// Constraint to show/hide the trailing space for unit label
    private var logUnitTrailingConstraint: NSLayoutConstraint!
    /// Constraint to collapse/expand the height of the note label
    private var logNoteHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    static let reuseIdentifier = "LogsTVC"
    
    /// Stored default constants so we can restore them when cell is reused
    private let logDurationBottomConstraintConstant: CGFloat = -5
    private let logUnitTrailingConstraintConstant: CGFloat = -7.5
    private let logNoteHeightConstraintConstant: CGFloat = 25
    
    // MARK: - Setup
    
    /// Configure the cell’s labels and adjust dynamic constraints based on the provided Log
    func setup(forParentDogName dogName: String, forLog log: Log) {
        // Restore default constants if first time
        logDurationBottomConstraint.constant = logDurationBottomConstraintConstant
        logUnitTrailingConstraint.constant = logUnitTrailingConstraintConstant
        logNoteHeightConstraint.constant = logNoteHeightConstraintConstant
        
        logActionIconLabel.text = log.logActionType.emoji
        
        // Pad label so it lines up with other labels
        dogNameLabel.text = " \(dogName)"
        
        logActionWithoutIconLabel.text = log.logActionType.convertToReadableName(customActionName: log.logCustomActionName, includeMatchingEmoji: false)
        
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
        logUnitLabel.isHidden = (logUnitString == nil)
        logUnitTrailingConstraint.constant = logUnitLabel.isHidden ? 0.0 : logUnitTrailingConstraintConstant
        
        logNoteLabel.text = {
            let trimmedNote = log.logNote.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedNote.isEmpty else { return nil }
            return "  \(trimmedNote)  "
        }()
        logNoteLabel.isHidden = (logNoteLabel.text == nil)
        logNoteHeightConstraint.constant = logNoteLabel.isHidden ? 0.0 : logNoteHeightConstraintConstant
        
        let hasDurationText = !(logDurationLabel.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if !hasDurationText {
            // No duration to show: collapse the bottom gap from duration to icon
            logDurationBottomConstraint.constant = 0.0
        }
        
        if logUnitLabel.isHidden && logNoteLabel.isHidden {
            // If both unit and note are hidden, collapse the space under duration entirely
            logDurationBottomConstraint.constant = 0.0
            logNoteHeightConstraint.constant = 0.0
        }
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        
        containerView.addSubview(logActionIconLabel)
        containerView.addSubview(dogNameLabel)
        containerView.addSubview(logActionWithoutIconLabel)
        containerView.addSubview(logStartToEndDateLabel)
        containerView.addSubview(logDurationLabel)
        containerView.addSubview(logUnitLabel)
        containerView.addSubview(logNoteLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // containerView
        let containerViewTopConstraint = containerView.topAnchor.constraint(equalTo: contentView.topAnchor)
        let containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        let containerViewLeadingConstraint = containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Global.contentInset)
        let containerViewTrailingConstraint = containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Global.contentInset)

        // logActionIconLabel
        let logActionIconLeadingConstraint = logActionIconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5)
        let logActionIconSquareConstraint = logActionIconLabel.widthAnchor.constraint(equalTo: logActionIconLabel.heightAnchor)

        // logStartToEndDateLabel
        // TODO Visually Inspect: Removed conflicting top constraint to containerView.
        // Original:
        // logStartToEndDateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 7.5)
        // logStartToEndDateLabel.topAnchor.constraint(equalTo: logActionIconLabel.topAnchor, constant: 5)
        // Decision: keep only the one relative to logActionIconLabel
        let logStartToEndTopConstraint = logStartToEndDateLabel.topAnchor.constraint(equalTo: logActionIconLabel.topAnchor, constant: 5)
        let logStartToEndLeadingConstraint = logStartToEndDateLabel.leadingAnchor.constraint(equalTo: logActionWithoutIconLabel.trailingAnchor, constant: 7.5)
        let logStartToEndTrailingConstraint = logStartToEndDateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10)
        let logStartToEndHeightConstraint = logStartToEndDateLabel.heightAnchor.constraint(equalToConstant: 22.5)

        // logDurationLabel
        logDurationBottomConstraint = logDurationLabel.bottomAnchor.constraint(equalTo: logActionIconLabel.bottomAnchor, constant: logDurationBottomConstraintConstant)
        let logDurationTopConstraint = logDurationLabel.topAnchor.constraint(equalTo: logStartToEndDateLabel.bottomAnchor)
        let logDurationLeadingConstraint = logDurationLabel.leadingAnchor.constraint(equalTo: logStartToEndDateLabel.leadingAnchor)
        let logDurationTrailingConstraint = logDurationLabel.trailingAnchor.constraint(equalTo: logStartToEndDateLabel.trailingAnchor)
        let logDurationHeightConstraint = logDurationLabel.heightAnchor.constraint(equalTo: logStartToEndDateLabel.heightAnchor)

        // logUnitLabel
        logUnitTrailingConstraint = logUnitLabel.trailingAnchor.constraint(equalTo: logStartToEndDateLabel.trailingAnchor, constant: logUnitTrailingConstraintConstant)
        let logUnitBottomConstraint = logUnitLabel.bottomAnchor.constraint(equalTo: logNoteLabel.bottomAnchor)
        let logUnitLeadingConstraint = logUnitLabel.leadingAnchor.constraint(equalTo: dogNameLabel.leadingAnchor)

        // logNoteLabel
        logNoteHeightConstraint = logNoteLabel.heightAnchor.constraint(equalToConstant: logNoteHeightConstraintConstant)
        let logNoteTopConstraint = logNoteLabel.topAnchor.constraint(equalTo: logDurationLabel.bottomAnchor, constant: 5)
        let logNoteAltTopConstraint = logNoteLabel.topAnchor.constraint(equalTo: logUnitLabel.topAnchor)
        let logNoteBottomConstraint = logNoteLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -7.5)
        let logNoteLeadingConstraint = logNoteLabel.leadingAnchor.constraint(equalTo: logUnitLabel.trailingAnchor, constant: 7.5)
        let logNoteTrailingConstraint = logNoteLabel.trailingAnchor.constraint(equalTo: logStartToEndDateLabel.trailingAnchor)

        // dogNameLabel
        let dogNameTopConstraint = dogNameLabel.topAnchor.constraint(equalTo: logStartToEndDateLabel.topAnchor, constant: 7.5)
        let dogNameBottomConstraint = dogNameLabel.bottomAnchor.constraint(equalTo: logActionWithoutIconLabel.bottomAnchor)
        let dogNameLeadingConstraint = dogNameLabel.leadingAnchor.constraint(equalTo: logActionIconLabel.trailingAnchor, constant: 5)
        let dogNameCenterYConstraint = dogNameLabel.centerYAnchor.constraint(equalTo: logStartToEndDateLabel.bottomAnchor)

        // logActionWithoutIconLabel
        let actionWithoutIconTopConstraint = logActionWithoutIconLabel.topAnchor.constraint(equalTo: dogNameLabel.topAnchor)
        let actionWithoutIconLeadingConstraint = logActionWithoutIconLabel.leadingAnchor.constraint(equalTo: dogNameLabel.trailingAnchor, constant: 10)

        NSLayoutConstraint.activate([
            containerViewTopConstraint, containerViewBottomConstraint, containerViewLeadingConstraint, containerViewTrailingConstraint,

            logActionIconLeadingConstraint, logActionIconSquareConstraint,

            logStartToEndTopConstraint, logStartToEndLeadingConstraint, logStartToEndTrailingConstraint, logStartToEndHeightConstraint,

            logDurationTopConstraint, logDurationBottomConstraint, logDurationLeadingConstraint, logDurationTrailingConstraint, logDurationHeightConstraint,

            logUnitBottomConstraint, logUnitTrailingConstraint, logUnitLeadingConstraint,

            logNoteTopConstraint, logNoteAltTopConstraint, logNoteBottomConstraint, logNoteLeadingConstraint, logNoteTrailingConstraint, logNoteHeightConstraint,

            dogNameTopConstraint, dogNameBottomConstraint, dogNameLeadingConstraint, dogNameCenterYConstraint,

            actionWithoutIconTopConstraint, actionWithoutIconLeadingConstraint
        ])
    }

}
