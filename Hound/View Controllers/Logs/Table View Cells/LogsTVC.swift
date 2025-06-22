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
        label.font = VisualConstant.FontConstant.sectionHeaderLabel
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
    private var logUnitAndNoteStackFullTrailingConstraint: NSLayoutConstraint!
    private var logUnitAndNoteStackMaxTrailingConstraint: NSLayoutConstraint!
    private var dogNameToContainerBottomConstraint: NSLayoutConstraint!
    private var logUnitAndNoteStackHeightConstraint: NSLayoutConstraint!
    private var logUnitAndNoteStackBottomConstraint: NSLayoutConstraint!
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
        let logDurationIsHidden = logDurationLabel.text == nil
        
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
        logNoteLabel.isHidden = logNoteIsHidden
    
        let shouldShowUnitNoteStack = !(logUnitIsHidden && logNoteIsHidden)
        logUnitAndNoteStack.isHidden = !shouldShowUnitNoteStack
        
        if logDurationIsHidden {
            dogNameToUnitNoteStackConstraint.constant = 0
        }
        else {
            dogNameToUnitNoteStackConstraint.restore()
        }
        dogNameToUnitNoteStackConstraint.isActive = shouldShowUnitNoteStack
        
        logUnitAndNoteStackHeightConstraint.isActive = shouldShowUnitNoteStack
        logUnitAndNoteStackBottomConstraint.isActive = shouldShowUnitNoteStack
        
        dogNameToContainerBottomConstraint.isActive = !shouldShowUnitNoteStack
        
        logUnitAndNoteStackFullTrailingConstraint.isActive = !logNoteIsHidden
        logUnitAndNoteStackMaxTrailingConstraint.isActive = logNoteIsHidden
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectedBackgroundView?.backgroundColor = .clear
        
        super.setupGeneratedViews()
    }
    
    private let interContentSpacing: CGFloat = 5.0
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
        logDateAndDurationStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(logDateAndDurationStack)

        logUnitAndNoteStack = UIStackView(arrangedSubviews: [logUnitLabel, logNoteLabel])
        logUnitAndNoteStack.axis = .horizontal
        logUnitAndNoteStack.alignment = .fill
        logUnitAndNoteStack.distribution = .fill // stack height is driven by contents
        logUnitAndNoteStack.spacing = interContentSpacing
        logUnitAndNoteStack.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(logUnitAndNoteStack)
    }

    override func setupConstraints() {
        super.setupConstraints()
        // containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Global.contentHoriInset),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Global.contentHoriInset)
        ])
        // logActionIconLabel
        NSLayoutConstraint.activate([
            logActionIconLabel.topAnchor.constraint(equalTo: dogNameLabel.topAnchor, constant: -(verticalInsetFromContainer - logActionIconInset)),
            logActionIconLabel.bottomAnchor.constraint(equalTo: dogNameLabel.bottomAnchor, constant: verticalInsetFromContainer - logActionIconInset),
            logActionIconLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: horizontalInsetFromContainer - logActionIconInset),
            logActionIconLabel.createSquareConstraint()
        ])
        // dogNameLabel
        NSLayoutConstraint.activate([
            dogNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: verticalInsetFromContainer),
            dogNameLabel.leadingAnchor.constraint(equalTo: logActionIconLabel.trailingAnchor, constant: interContentSpacing - logActionIconInset)
        ])
        // logActionTextLabel
        NSLayoutConstraint.activate([
            logActionTextLabel.leadingAnchor.constraint(equalTo: dogNameLabel.trailingAnchor, constant: interContentSpacing),
            logActionTextLabel.topAnchor.constraint(equalTo: dogNameLabel.topAnchor),
            logActionTextLabel.heightAnchor.constraint(equalTo: dogNameLabel.heightAnchor)
        ])
        // logDateAndDurationStack
        NSLayoutConstraint.activate([
            logDateAndDurationStack.leadingAnchor.constraint(equalTo: logActionTextLabel.trailingAnchor, constant: interContentSpacing),
            logDateAndDurationStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -horizontalInsetFromContainer),
            logDateAndDurationStack.topAnchor.constraint(equalTo: dogNameLabel.topAnchor),
            logDateAndDurationStack.bottomAnchor.constraint(equalTo: dogNameLabel.bottomAnchor)
        ])
        // logUnitAndNoteStack
        dogNameToUnitNoteStackConstraint = GeneralLayoutConstraint(wrapping: dogNameLabel.bottomAnchor.constraint(equalTo: logUnitAndNoteStack.topAnchor, constant: -interContentSpacing))
        dogNameToContainerBottomConstraint = dogNameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -verticalInsetFromContainer)
        dogNameToContainerBottomConstraint.isActive = false

        logUnitAndNoteStackFullTrailingConstraint = logUnitAndNoteStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -horizontalInsetFromContainer)
        logUnitAndNoteStackMaxTrailingConstraint = logUnitAndNoteStack.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -horizontalInsetFromContainer)
        logUnitAndNoteStackMaxTrailingConstraint.isActive = false
        // can't constraint stack directly without an error, so make its element inside constraint logUnitLabel
        logUnitAndNoteStackHeightConstraint = logUnitLabel.heightAnchor.constraint(equalTo: logStartToEndDateLabel.heightAnchor)
        logUnitAndNoteStackBottomConstraint = logUnitAndNoteStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -verticalInsetFromContainer)
        NSLayoutConstraint.activate([
            dogNameToUnitNoteStackConstraint.constraint,
            // dont activate dogNameToContainerBottomConstraint
            logUnitAndNoteStackHeightConstraint,
            logUnitAndNoteStackFullTrailingConstraint,
            // dont activate logUnitAndNoteStackMaxTrailingConstraint
            logUnitAndNoteStackBottomConstraint,
            logUnitAndNoteStack.leadingAnchor.constraint(equalTo: dogNameLabel.leadingAnchor)
        ])
    }

}
