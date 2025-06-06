//
//  LogsTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogsTableViewCell: GeneralUITableViewCell {
    
    // MARK: - Properties
    
    /// Container view for all subviews
    let containerView: UIView = {
        let view = UIView()
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    /// Emoji icon indicating the log action
    private let logActionIconLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(370), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(370), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(870), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(870), for: .vertical)
        label.text = "🍗"
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 40, weight: .medium)
        label.isRoundingToCircle = true
        label.shouldRoundCorners = true
        return label
    }()
    
    /// Label for the dog’s name
    private let dogNameLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(350), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(350), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(850), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(850), for: .vertical)
        label.text = "Bella"
        label.lineBreakMode = .byTruncatingTail
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    /// Label describing the log action (without emoji)
    private let logActionWithoutIconLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(340), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(340), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(840), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(840), for: .vertical)
        label.text = "Feed"
        label.lineBreakMode = .byTruncatingTail
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    /// Label showing the start (and optional end) time of the log
    private let logStartToEndDateLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(390), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(390), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(890), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(890), for: .vertical)
        label.text = "9:00 AM - 10:00 AM"
        label.textAlignment = .right
        label.lineBreakMode = .byTruncatingTail
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    /// Label showing the duration of the log (e.g., “1 hr”)
    private let logDurationLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(380), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(380), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(880), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(880), for: .vertical)
        label.text = "1 hr"
        label.textAlignment = .right
        label.lineBreakMode = .byTruncatingTail
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    /// Label showing any units for the log (e.g., miles, kCal)
    private let logUnitLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(300), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(300), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(800), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(800), for: .vertical)
        label.text = "3.2 miles  "
        label.lineBreakMode = .byTruncatingTail
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .secondarySystemBackground
        label.font = .systemFont(ofSize: 12.5)
        label.shouldRoundCorners = true
        return label
    }()
    
    /// Label for any optional note on the log
    private let logNoteLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(280), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(280), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .vertical)
        label.text = "  Had a great walk"
        label.lineBreakMode = .byTruncatingTail
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    /// Stored default constants so we can restore them when cell is reused
    private var defaultDurationBottomConstant: CGFloat = -5
    private var defaultUnitTrailingConstant: CGFloat = -7.5
    private var defaultNoteHeightConstant: CGFloat = 25
    
    // MARK: - Functions
    
    /// Configure the cell’s labels and adjust dynamic constraints based on the provided Log
    func setup(forParentDogName dogName: String, forLog log: Log) {
        // Restore default constants if first time
        logDurationBottomConstraint.constant = defaultDurationBottomConstant
        logUnitTrailingConstraint.constant = defaultUnitTrailingConstant
        logNoteHeightConstraint.constant = defaultNoteHeightConstant
        
        // MARK: logActionIconLabel
        logActionIconLabel.text = log.logActionType.emoji
        
        // MARK: dogNameLabel
        // Pad label so it lines up with other labels
        dogNameLabel.text = " \(dogName)"
        
        // MARK: logActionWithoutIconLabel
        logActionWithoutIconLabel.text = log.logActionType.convertToReadableName(customActionName: log.logCustomActionName, includeMatchingEmoji: false)
        
        // MARK: logStartToEndDateLabel
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
        
        // MARK: logDurationLabel
        logDurationLabel.text = {
            guard let logEndDate = log.logEndDate else {
                return nil
            }
            return log.logStartDate.distance(to: logEndDate).readable(capitalizeWords: false, abreviateWords: true)
        }()
        
        // MARK: logUnitLabel
        let logUnitString: String? = {
            guard let unitType = log.logUnitType, let numUnits = log.logNumberOfLogUnits else {
                return nil
            }
            return unitType.convertedMeasurementString(forLogNumberOfLogUnits: numUnits, toTargetSystem: UserConfiguration.measurementSystem)
        }()
        logUnitLabel.text = logUnitString.map { "  \($0)  " }
        logUnitLabel.isHidden = (logUnitString == nil)
        logUnitTrailingConstraint.constant = logUnitLabel.isHidden ? 0.0 : defaultUnitTrailingConstant
        
        // MARK: logNoteLabel
        logNoteLabel.text = {
            let trimmedNote = log.logNote.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedNote.isEmpty else { return nil }
            return "  \(trimmedNote)  "
        }()
        logNoteLabel.isHidden = (logNoteLabel.text == nil)
        logNoteHeightConstraint.constant = logNoteLabel.isHidden ? 0.0 : defaultNoteHeightConstant
        
        // MARK: Adjust spacing if duration or note are missing
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
        // MARK: ContainerView constraints
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
        
        // MARK: logActionIconLabel constraints
        NSLayoutConstraint.activate([
            logActionIconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 5),
            logActionIconLabel.widthAnchor.constraint(equalTo: logActionIconLabel.heightAnchor, multiplier: 1.0)
        ])
        
        // MARK: logStartToEndDateLabel constraints
        NSLayoutConstraint.activate([
            logStartToEndDateLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 7.5),
            logStartToEndDateLabel.topAnchor.constraint(equalTo: logActionIconLabel.topAnchor, constant: 5),
            logStartToEndDateLabel.leadingAnchor.constraint(equalTo: logActionWithoutIconLabel.trailingAnchor, constant: 7.5),
            logStartToEndDateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            logStartToEndDateLabel.heightAnchor.constraint(equalToConstant: 22.5)
        ])
        
        // Keep logStartToEndDateLabel.trailing == logDurationLabel.trailing for horizontal alignment
        let durationTrailingMatch = logStartToEndDateLabel.trailingAnchor.constraint(equalTo: logDurationLabel.trailingAnchor)
        durationTrailingMatch.isActive = true
        
        // MARK: logDurationLabel constraints (store bottom constraint for dynamic updates)
        let durationTop = logDurationLabel.topAnchor.constraint(equalTo: logStartToEndDateLabel.bottomAnchor)
        let durationBottom = logDurationLabel.bottomAnchor.constraint(equalTo: logActionIconLabel.bottomAnchor, constant: defaultDurationBottomConstant)
        let durationLeading = logDurationLabel.leadingAnchor.constraint(equalTo: logStartToEndDateLabel.leadingAnchor)
        let durationHeight = logDurationLabel.heightAnchor.constraint(equalTo: logStartToEndDateLabel.heightAnchor)
        
        durationTop.isActive = true
        durationLeading.isActive = true
        durationHeight.isActive = true
        
        // Store this for dynamic collapsing
        logDurationBottomConstraint = durationBottom
        logDurationBottomConstraint.isActive = true
        
        // MARK: logUnitLabel constraints (store trailing constraint for dynamic updates)
        let unitBottom = logUnitLabel.bottomAnchor.constraint(equalTo: logNoteLabel.bottomAnchor)
        let unitLeading = logUnitLabel.leadingAnchor.constraint(equalTo: dogNameLabel.leadingAnchor)
        let unitTrailing = logUnitLabel.trailingAnchor.constraint(equalTo: logStartToEndDateLabel.trailingAnchor, constant: defaultUnitTrailingConstant)
        
        unitBottom.isActive = true
        unitLeading.isActive = true
        
        // Store for dynamic show/hide
        logUnitTrailingConstraint = unitTrailing
        logUnitTrailingConstraint.isActive = true
        
        // MARK: logNoteLabel constraints (store height constraint for dynamic updates)
        let noteTopToDuration = logNoteLabel.topAnchor.constraint(equalTo: logDurationLabel.bottomAnchor, constant: 5)
        let noteTopToUnit = logNoteLabel.topAnchor.constraint(equalTo: logUnitLabel.topAnchor)
        let noteBottom = logNoteLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -7.5)
        let noteLeading = logNoteLabel.leadingAnchor.constraint(equalTo: logUnitLabel.trailingAnchor, constant: 7.5)
        let noteTrailing = logNoteLabel.trailingAnchor.constraint(equalTo: logStartToEndDateLabel.trailingAnchor)
        
        noteTopToDuration.isActive = true
        noteTopToUnit.isActive = true
        noteBottom.isActive = true
        noteLeading.isActive = true
        noteTrailing.isActive = true
        
        // Store for dynamic collapsing
        logNoteHeightConstraint = logNoteLabel.heightAnchor.constraint(equalToConstant: defaultNoteHeightConstant)
        logNoteHeightConstraint.isActive = true
        
        // MARK: dogNameLabel constraints
        NSLayoutConstraint.activate([
            dogNameLabel.topAnchor.constraint(equalTo: logStartToEndDateLabel.topAnchor, constant: 7.5),
            dogNameLabel.bottomAnchor.constraint(equalTo: logActionWithoutIconLabel.bottomAnchor),
            dogNameLabel.leadingAnchor.constraint(equalTo: logActionIconLabel.trailingAnchor, constant: 5),
            dogNameLabel.centerYAnchor.constraint(equalTo: logStartToEndDateLabel.bottomAnchor)
        ])
        
        // MARK: logActionWithoutIconLabel constraints
        NSLayoutConstraint.activate([
            logActionWithoutIconLabel.topAnchor.constraint(equalTo: dogNameLabel.topAnchor),
            logActionWithoutIconLabel.leadingAnchor.constraint(equalTo: dogNameLabel.trailingAnchor, constant: 10)
        ])
    }
}
