//
//  LogsTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/18/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogsTableViewCell: UITableViewCell {
    
    @IBOutlet private(set) weak var containerView: UIView! // swiftlint:disable:this private_outlet
    
    @IBOutlet private weak var logActionIconLabel: GeneralUILabel!
    @IBOutlet private weak var logActionIconTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logActionIconBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var dogNameLabel: GeneralUILabel!
    
    @IBOutlet private weak var logActionWithoutIconLabel: GeneralUILabel!
    
    @IBOutlet private weak var logStartToEndDateLabel: GeneralUILabel!
    @IBOutlet private weak var logStartToEndDateHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logDurationLabel: GeneralUILabel!
    private var logDurationBottomConstraintConstant: CGFloat?
    @IBOutlet private weak var logDurationBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logUnitLabel: GeneralUILabel!
    private var logUnitTrailingConstraintConstant: CGFloat?
    /// This constraint is used to help either show or hide logUnitLabel
    @IBOutlet private weak var logUnitTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logNoteLabel: GeneralUILabel!
    private var logNoteHeightConstraintConstant: CGFloat?
    @IBOutlet private weak var logNoteHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Functions
    
    private func findHeightConstraint(forLayoutConstraints layoutConstraints: [NSLayoutConstraint]) -> NSLayoutConstraint? {
        var heightLayoutConstraint: NSLayoutConstraint?
        layoutConstraints.forEach { layoutConstraint in
            if layoutConstraint.firstAttribute == .height && layoutConstraint.secondAttribute == .height {
                heightLayoutConstraint = layoutConstraint
            }
        }
        
        return heightLayoutConstraint
    }

    func setup(forParentDogName dogName: String, forLog log: Log) {
        // MARK: Save constants before modification
        // Cell can be re-used by the tableView, so the constraintConstants won't be null in that case and their original values saved
        logDurationBottomConstraintConstant = logDurationBottomConstraintConstant ?? logDurationBottomConstraint.constant
        logUnitTrailingConstraintConstant = logUnitTrailingConstraintConstant ?? logUnitTrailingConstraint.constant
        logNoteHeightConstraintConstant = logNoteHeightConstraintConstant ?? logNoteHeightConstraint.constant
        
        // MARK: logActionIconLabel
        logActionIconLabel.text = log.logAction.matchingEmoji
        // By default: 50.0 height & 30.0 font size
        let logActionIconLabelFontSize = (logActionIconTopConstraint.constant + (logStartToEndDateHeightConstraint.constant * 2.0) + logActionIconBottomConstraint.constant) * (40.0 / 50.0)
        if logActionIconLabelFontSize > 0.0 {
            logActionIconLabel.font = logActionIconLabel.font.withSize(logActionIconLabelFontSize)
        }
        
        // MARK: dogNameLabel
        // Pad label slightly so it visually lines up with other labels better
        dogNameLabel.text = " \(dogName)"
        // By default: 25.0 height & 25.0 font size
        let dogNameFontSize = (findHeightConstraint(forLayoutConstraints: dogNameLabel.constraints)?.constant ?? -1.0) * (25.0 / 25.0)
        if dogNameFontSize > 0.0 {
            dogNameLabel.font = dogNameLabel.font.withSize(dogNameFontSize)
        }
        
        // MARK: logActionWithoutIconLabel
        logActionWithoutIconLabel.text = log.logAction.displayActionName(logCustomActionName: log.logCustomActionName, includeMatchingEmoji: false)
        // By default: height = dogNameLabel & font size = dogNameLabel
        let logActionFontSize = dogNameFontSize
        if logActionFontSize > 0.0 {
            logActionWithoutIconLabel.font = logActionWithoutIconLabel.font.withSize(logActionFontSize)
        }

        // MARK: logStartToEndDateLabel
        let logStartDateFormatter = DateFormatter()
        // 7:53 AM
        logStartDateFormatter.setLocalizedDateFormatFromTemplate("hma")
        // logStartToEndDateLabel always displays the start date (8:15 AM) and can display the end date as well if its present (8:15 AM - 10:00 AM)
        logStartToEndDateLabel.text = logStartDateFormatter.string(from: log.logStartDate)
        
        if let logEndDate = log.logEndDate {
            let logEndDateFormatter = DateFormatter()
            // The end date could be on a different day or than the log start date
            
            if log.logStartDate.distance(to: logEndDate) < 60.0 * 60 * 24 {
                // logEndDate is the same day as logStartDate, so extra information is unnecessary
                // 7:53 AM
                logEndDateFormatter.setLocalizedDateFormatFromTemplate("hma")
            }
            else {
                // logEndDateSelected is not today
                let logEndDateYear = Calendar.current.component(.year, from: logEndDate)
                let currentYear = Calendar.current.component(.year, from: Date())
                
                // Jan 25 OR Jan 25, 23
                logEndDateFormatter.setLocalizedDateFormatFromTemplate(logEndDateYear == currentYear ? "MMMd" : "MMMdyy")
            }
            
            logStartToEndDateLabel.text = logStartToEndDateLabel.text?.appending(" - \(logEndDateFormatter.string(from: logEndDate))")
        }
        
        // By default: 20.0 height & 12.5 font size
        let logStartToEndDateFontSize = (findHeightConstraint(forLayoutConstraints: logStartToEndDateLabel.constraints)?.constant ?? -1.0) * (12.5 / 20.0)
        if logStartToEndDateFontSize > 0.0 {
            logStartToEndDateLabel.font = logStartToEndDateLabel.font.withSize(logStartToEndDateFontSize)
        }
        
        // MARK: logDurationLabel
        logDurationLabel.text = {
            // logDurationLabel should only have text if there is a duration to be displayed, i.e. there is a log start and end date present
            guard let logEndDate = log.logEndDate else {
                return nil
            }
            
            return log.logStartDate.distance(to: logEndDate).readable(capitalizeWords: false, abreviateWords: true)
        }()
        
        // By default: height = logStartToEndDateLabel & font size = logStartToEndDateLabel
        let logDurationFontSize = logStartToEndDateFontSize
        if logDurationFontSize > 0.0 {
            logDurationLabel.font = logDurationLabel.font.withSize(logDurationFontSize)
        }
        
        // MARK: logNoteLabel
        // Pad the string with a space on each side so it fits better with the background of the label
        logNoteLabel.text = "  \(log.logNote)  "
        
        // By default: 25.0 height & 12.5 font size
        let logNoteFontSize = (findHeightConstraint(forLayoutConstraints: logNoteLabel.constraints)?.constant ?? -1.0) * (12.5 / 25.0)
        if logNoteFontSize > 0.0 {
            logNoteLabel.font = logNoteLabel.font.withSize(logNoteFontSize)
        }
        logNoteLabel.isHidden = log.logNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        // No need to crunch logNoteLabel is is hidden. This is because logUnitLabel can expand horizontally over logNote (higher precedence), so logNoteLabel does no harm being left to invisibly take up unused space
 
        // MARK: logUnitLabel
        let logUnitString: String? = {
            guard let logUnit = log.logUnit, let logNumberOfLogUnits = log.logNumberOfLogUnits else {
                return nil
            }
            
            return logUnit.convertedMeasurementString(forLogNumberOfLogUnits: logNumberOfLogUnits, toTargetSystem: UserConfiguration.measurementSystem)
        }()
        logUnitLabel.text = {
            guard let logUnitString = logUnitString else {
                return nil
            }
            
            // Pad the string with a space on each side so it fits better with the background of the label
            return "  \(logUnitString)  "
        }()
        
        // By default: height = logNoteFontSize & font size = logNoteFontSize
        let logUnitFontSize = logNoteFontSize
        if logUnitFontSize > 0.0 {
            logUnitLabel.font = logUnitLabel.font.withSize(logUnitFontSize)
        }
        logUnitLabel.isHidden = logUnitString == nil
        logUnitTrailingConstraint.constant = logUnitString == nil ? 0.0 : 7.5
        
        // MARK: Set constraint to 0.0 if elements are hidden
        // By default, set these constraints to the values they should be
        logDurationBottomConstraint.constant = logDurationBottomConstraintConstant ?? logDurationBottomConstraint.constant
        logNoteHeightConstraint.constant = logNoteHeightConstraintConstant ?? logNoteHeightConstraint.constant
        
        // Then if any of the conditions are met to shrink them, do so. This avoids accidently having one condition shrink them, then another condition unshrink them.
        if logUnitLabel.isHidden == true && logNoteLabel.isHidden == true {
            // If logUnitLabel and logNoteLabel are both hidden, override their scaleFactors to 0.0, so that both of these hidden views no longer take up any space
            logDurationBottomConstraint.constant = 0.0
            logNoteHeightConstraint.constant = 0.0
        }
        if (logDurationLabel.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // There is nothing to display in the logDurationLabel, so it is an awkward unused space right now
            logDurationBottomConstraint.constant = 0.0
        }
    }
}
