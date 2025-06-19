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
    private let logActionTextLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 340, compressionResistancePriority: 340)
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    
    private var logDateAndDurationStack: UIStackView!
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
    
    private var dogNameToUnitNoteStackConstraint: GeneralLayoutConstraint!
    private var dogNameToContainerBottomConstraint: GeneralLayoutConstraint!
    private var logUnitAndNoteStackHeightConstraint: GeneralLayoutConstraint!
    private var logUnitAndNoteStackZeroHeightConstraint: GeneralLayoutConstraint!
    private var logUnitAndNoteStack: UIStackView!
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
        let logUnitIsHidden = logUnitString == nil
        logUnitLabel.isHidden = logUnitIsHidden
        
        logNoteLabel.text = {
            let trimmedNote = log.logNote.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedNote.isEmpty else { return nil }
            return "  \(trimmedNote)  "
        }()
        let logNoteIsHidden = logNoteLabel.text == nil
        
        let hasDurationText = !(logDurationLabel.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // default show all of these fields
        logUnitLogNoteTopConstraint.restore()
        logUnitLogNoteZeroHeightConstraint.deactivate()
        logUnitTrailingConstraint.restore()
        logUnitZeroWidthConstraint.deactivate()
        
        if logUnitIsHidden {
            // hide log unit label and compress space between log unit and log note
            logUnitTrailingConstraint.constant = 0
            logUnitZeroWidthConstraint.activate()
        }
        if logUnitIsHidden && logNoteIsHidden {
            // completely collapse log unit and log note because neither visible
            logUnitLogNoteTopConstraint.constant = 0
            logUnitLogNoteZeroHeightConstraint.activate()
        }
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    private let interContentSpacing: CGFloat = 7.5
    private let verticalInsetFromContainer: CGFloat = 12.5
    private let horizontalInsetFromContainer: CGFloat = 10.0
    private let logActionIconInset: CGFloat = 7.5
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(containerView)
        
        containerView.addSubview(logActionIconLabel)
        containerView.addSubview(dogNameLabel)
        containerView.addSubview(logActionTextLabel)
        
        logDateAndDurationStack = UIStackView(arrangedSubviews: [logStartToEndDateLabel, logDurationLabel])
        logDateAndDurationStack.axis = .vertical
        logDateAndDurationStack.alignment = .fill
        logDateAndDurationStack.distribution = .fillEqually
        logDateAndDurationStack.spacing = interContentSpacing
        containerView.addSubview(logDateAndDurationStack)

        logUnitAndNoteStack = UIStackView(arrangedSubviews: [logUnitLabel, logNoteLabel])
        logUnitAndNoteStack.axis = .horizontal
        logUnitAndNoteStack.alignment = .fill
        logUnitAndNoteStack.distribution = .fill
        logUnitAndNoteStack.spacing = interContentSpacing
        containerView.addSubview(logUnitAndNoteStack)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // containerView
        let containerViewTopConstraint = containerView.topAnchor.constraint(equalTo: contentView.topAnchor)
        let containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        let containerViewLeadingConstraint = containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Global.contentInset)
        let containerViewTrailingConstraint = containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Global.contentInset)
        
        // logActionIconLabel
        let logActionIconTopConstraint = logActionIconLabel.topAnchor.constraint(equalTo: dogNameLabel.topAnchor, constant: -logActionIconInset)
        let logActionIconBottomConstraint = logActionIconLabel.bottomAnchor.constraint(equalTo: dogNameLabel.bottomAnchor, constant: logActionIconInset)
        let logActionIconLeadingConstraint = logActionIconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: horizontalInsetFromContainer)
        let logActionIconSquareConstraint = logActionIconLabel.createSquareConstraint()
        
        // dogNameLabel
        let dogNameTopConstraint = dogNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: verticalInsetFromContainer)
        let dogNameLeadingConstraint = dogNameLabel.leadingAnchor.constraint(equalTo: logActionIconLabel.trailingAnchor, constant: interContentSpacing)

        // logActionTextLabel
        let logActionTextTopConstraint = logActionTextLabel.topAnchor.constraint(equalTo: dogNameLabel.topAnchor)
        let logActionTextBottomConstraint = logActionTextLabel.bottomAnchor.constraint(equalTo: dogNameLabel.bottomAnchor)
        let logActionTextLeadingConstraint = logActionTextLabel.leadingAnchor.constraint(equalTo: dogNameLabel.trailingAnchor, constant: interContentSpacing)
        
        // logTimeStack
        let logTimeStackTopConstraint = logTimeStack.topAnchor.constraint(equalTo: logActionTextLabel.topAnchor)
        let logTimeStackBottomConstraint = logTimeStack.bottomAnchor.constraint(equalTo: logActionTextLabel.bottomAnchor)
        let logTimeStackLeadingConstraint = logTimeStack.leadingAnchor.constraint(equalTo: logActionTextLabel.trailingAnchor, constant: interContentSpacing)
        let logStartToEndTrailingConstraint = logTimeStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -horizontalInsetFromContainer)

        // logUnitLabel & logNoteLabel
        logUnitLogNoteTopConstraint = GeneralLayoutConstraint(wrapping: logUnitLabel.topAnchor.constraint(equalTo: dogNameLabel.bottomAnchor, constant: interContentSpacing))
        logUnitLogNoteZeroHeightConstraint = GeneralLayoutConstraint(wrapping: logUnitLabel.heightAnchor.constraint(equalToConstant: 0))
        let logUnitLogNoteEqualHeightConstraint = logNoteLabel.heightAnchor.constraint(equalTo: logUnitLabel.heightAnchor)
        
        let logUnitBottomConstraint = logUnitLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -verticalInsetFromContainer)
        let logUnitLeadingConstraint = logUnitLabel.leadingAnchor.constraint(equalTo: dogNameLabel.leadingAnchor)
        logUnitTrailingConstraint = GeneralLayoutConstraint(wrapping: logUnitLabel.trailingAnchor.constraint(equalTo: logNoteLabel.leadingAnchor, constant: interContentSpacing))
        logUnitZeroWidthConstraint = GeneralLayoutConstraint(wrapping: logUnitLabel.widthAnchor.constraint(equalToConstant: 0))
        
        let logNoteTopConstraint = logNoteLabel.topAnchor.constraint(equalTo: logUnitLabel.bottomAnchor)
        let logNoteBottomConstraint = logNoteLabel.bottomAnchor.constraint(equalTo: logUnitLabel.bottomAnchor)
        let logNoteTrailingConstraint = logNoteLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -horizontalInsetFromContainer)
        
        NSLayoutConstraint.activate([
            containerViewTopConstraint, containerViewBottomConstraint, containerViewLeadingConstraint, containerViewTrailingConstraint,

            logActionIconTopConstraint, logActionIconBottomConstraint, logActionIconLeadingConstraint, logActionIconSquareConstraint,
            
            dogNameTopConstraint, dogNameLeadingConstraint,

            logActionTextTopConstraint, logActionTextBottomConstraint, logActionTextLeadingConstraint,

            logTimeStackTopConstraint, logTimeStackBottomConstraint, logTimeStackLeadingConstraint, logStartToEndTrailingConstraint,
            
            logUnitLogNoteTopConstraint.constraint, logUnitLogNoteZeroHeightConstraint.constraint, logUnitTrailingConstraint.constraint, logUnitLogNoteEqualHeightConstraint,
            
            logUnitBottomConstraint, logUnitLeadingConstraint,

            logNoteTopConstraint, logNoteBottomConstraint, logNoteTrailingConstraint
        ])
    }

}
