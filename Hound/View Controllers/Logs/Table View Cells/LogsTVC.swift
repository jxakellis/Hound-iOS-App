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
    @IBOutlet var logActionIconLeadingConstraint: GeneralLayoutConstraint!
    @IBOutlet var logActionIconTrailingConstraint: GeneralLayoutConstraint!
    @IBOutlet var logActionIconTopConstraint: GeneralLayoutConstraint!
    @IBOutlet var logActionIconBottomConstraint: GeneralLayoutConstraint!
    
    @IBOutlet private weak var dogNameLabel: GeneralUILabel!
    @IBOutlet var dogNameTrailingConstraint: GeneralLayoutConstraint!
    @IBOutlet var dogNameTopConstraint: GeneralLayoutConstraint!
    @IBOutlet var dogNameBottomConstraint: GeneralLayoutConstraint!
    
    @IBOutlet private weak var logActionWithoutIconLabel: GeneralUILabel!

    @IBOutlet private weak var logStartToEndDateLabel: GeneralUILabel!
    
    @IBOutlet private weak var logDurationLabel: GeneralUILabel!
    
    @IBOutlet private weak var logUnitLabel: GeneralUILabel!
    /// This constraint is used to help either show or hide logUnitLabel
    @IBOutlet private weak var logUnitTrailingConstraint: GeneralLayoutConstraint!
    
    @IBOutlet private weak var logNoteLabel: GeneralUILabel!
    @IBOutlet private weak var logNoteHeightConstraint: GeneralLayoutConstraint!
    @IBOutlet private weak var logNoteBottomConstraint: GeneralLayoutConstraint!
    
    @IBOutlet private weak var logFamilyMemberLabel: GeneralUILabel!
    
    // MARK: - Functions
    
    private func findHeightConstraint(forLayoutConstraints layoutConstraints: [NSLayoutConstraint]) -> GeneralLayoutConstraint? {
        var heightGeneralLayoutConstraint: GeneralLayoutConstraint?
        layoutConstraints.forEach { layoutConstraint in
            guard heightGeneralLayoutConstraint == nil else {
                return
            }
            
            guard let generalLayoutConstraint = layoutConstraint as? GeneralLayoutConstraint else {
                return
            }
            
            if generalLayoutConstraint.firstAttribute == .height && generalLayoutConstraint.secondAttribute == .height {
                heightGeneralLayoutConstraint = generalLayoutConstraint
            }
        }
        
        return heightGeneralLayoutConstraint
    }

    func setup(forParentDogName dogName: String, forLog log: Log) {
        let scaleFactor = UserConfiguration.logsInterfaceScale.currentScaleFactor
        
        // logActionIconLabel
        logActionIconLabel.text = log.logAction.matchingEmoji
        logActionIconLeadingConstraint.scaleFactor = scaleFactor
        logActionIconTrailingConstraint.scaleFactor = scaleFactor
        print(.constant)
        // TODO NOW adjust font size of logactionlabel based upon
        
        // dogNameLabel
        dogNameLabel.text = dogName
        // By default: 25.0 height & 25.0 font size
        let dogNameFontSize = (findHeightConstraint(forLayoutConstraints: dogNameLabel.constraints)?.constant ?? -1.0) * (25.0/25.0)
        if dogNameFontSize > 0.0 {
            dogNameLabel.font = dogNameLabel.font.withSize(dogNameFontSize)
        }
        
        // logActionWithoutIconLabel
        logActionWithoutIconLabel.text = log.logAction.displayActionName(logCustomActionName: log.logCustomActionName, includeMatchingEmoji: false)
        // By default: height = dogNameLabel & font size = dogNameLabel
        let logActionFontSize = dogNameFontSize
        if logActionFontSize > 0.0 {
            logActionWithoutIconLabel.font = logActionWithoutIconLabel.font.withSize(logActionFontSize)
        }

        // logStartToEndDateLabel
        let dateFormatter = DateFormatter()
        // 7:53 AM
        dateFormatter.setLocalizedDateFormatFromTemplate("hma")
        // logStartToEndDateLabel always displays the start date (8:15 AM) and can display the end date as well if its present (8:15 AM - 10:00 AM)
        logStartToEndDateLabel.text = dateFormatter.string(from: log.logStartDate)
        if let logEndDate = log.logEndDate {
            logStartToEndDateLabel.text = logStartToEndDateLabel.text?.appending(" - \(dateFormatter.string(from: logEndDate))")
        }
        // By default: 20.0 height & 10.0 font size
        let logStartToEndDateFontSize = (findHeightConstraint(forLayoutConstraints: logStartToEndDateLabel.constraints)?.constant ?? -1.0) * (10.0/20.0)
        if logStartToEndDateFontSize > 0.0 {
            logStartToEndDateLabel.font = logStartToEndDateLabel.font.withSize(logStartToEndDateFontSize)
        }
        
        // logStartToEndDateLabel
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
        
        // logNoteLabel
        logNoteLabel.text = log.logNote
        // By default: 25.0 height & 12.5 font size
        let logNoteFontSize = (findHeightConstraint(forLayoutConstraints: logNoteLabel.constraints)?.constant ?? -1.0) * (12.5/25.0)
        if logNoteFontSize > 0.0 {
            logNoteLabel.font = logNoteLabel.font.withSize(logNoteFontSize)
        }
        logNoteLabel.isHidden = log.logNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        // No need to crunch logNoteLabel is is hidden. This is because logUnitLabel can expand horizontally over logNote (higher precedence), so logNoteLabel does no harm being left to invisibly take up unused space
 
        // logUnitLabel
        let logUnitString: String? = {
            guard let logUnit = log.logUnit, let logNumberOfLogUnits = log.logNumberOfLogUnits else {
                return nil
            }
            
            return logUnit.convertedMeasurementString(forLogNumberOfLogUnits: logNumberOfLogUnits, toTargetSystem: UserConfiguration.measurementSystem)
        }()
        logUnitLabel.text = logUnitString
        // By default: height = logNoteFontSize & font size = logNoteFontSize
        let logUnitFontSize = logNoteFontSize
        if logUnitFontSize > 0.0 {
            logUnitLabel.font = logUnitLabel.font.withSize(logUnitFontSize)
        }
        if logUnitString != nil {
            // We want to show logUnitLabel
            logUnitLabel.isHidden = false
            // Disable the width constraint so it can get as wide as it needs
            
            // logUnitWidthConstraint.isActive = false
        }
        else {
            // We want to hide logUnitLabel
            logUnitLabel.isHidden = true
            // Enable the width constraint so it can compress the label, and override the scaleFactor of the width to 0 so the width is scaled to 0
            // logUnitWidthConstraint.isActive = true
            // logUnitWidthConstraint.scaleFactor = 0.0
            // Override the scaleFactor of the trailing constraint to 0, so that logNote can fully align to the left now that logUnit is gone
            logUnitTrailingConstraint.scaleFactor = 0.0
        }
        
        // logUnitLabel & logNoteLabel
        if logUnitLabel.isHidden == true && logNoteLabel.isHidden == true {
            // If logUnitLabel and logNoteLabel are both hidden, override their scaleFactors to 0.0, so that both of these hidden views no longer take up any space
            logNoteHeightConstraint.scaleFactor = 0.0
            logNoteBottomConstraint.scaleFactor = 0.0
        }
        
        // familyMemberLabel
        logFamilyMemberLabel.text = FamilyInformation.findFamilyMember(forUserId: log.userId)?.displayFullName ?? VisualConstant.TextConstant.unknownName
        // By default: 20.0 height & 12.5 font size
        let logFamilyMemberFontSize = (findHeightConstraint(forLayoutConstraints: logFamilyMemberLabel.constraints)?.constant ?? -1.0) * (12.5/20.0)
        if logFamilyMemberFontSize > 0.0 {
            logFamilyMemberLabel.font = logFamilyMemberLabel.font.withSize(logFamilyMemberFontSize)
        }
    }
}
