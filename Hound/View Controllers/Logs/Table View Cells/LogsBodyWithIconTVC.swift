//
//  LogsBodyWithIconTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/20/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogsBodyWithIconTableViewCell: UITableViewCell {

    // MARK: - IB

    @IBOutlet private(set) weak var containerView: UIView! // swiftlint:disable:this private_outlet

    @IBOutlet private weak var dogIconImageView: GeneralUIImageView!
    @IBOutlet private weak var dogIconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogIconTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogIconTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogIconBottomConstraint: NSLayoutConstraint!

    @IBOutlet private weak var logStartDateLabel: GeneralUILabel!
    @IBOutlet private weak var logStartDateTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logStartDateTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logStartDateHeightConstraint: NSLayoutConstraint!

    @IBOutlet private weak var logActionLabel: GeneralUILabel!
    @IBOutlet private weak var logActionTrailingConstraint: NSLayoutConstraint!

    @IBOutlet private weak var logNoteLabel: GeneralUILabel!
    @IBOutlet private weak var logNoteBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logNoteHeightConstraint: NSLayoutConstraint!

    @IBOutlet private weak var rightChevronImageView: UIImageView!
    @IBOutlet private weak var rightChevronTrailingConstraint: NSLayoutConstraint!

    // MARK: - Functions

    func setup(forParentDogIcon parentDogIcon: UIImage, forLog log: Log) {
        let fontSize: CGFloat = 17.5
        let sizeRatio = UserConfiguration.logsInterfaceScale.currentScaleFactor

        // Dog Icon
        dogIconImageView.image = parentDogIcon
        dogIconLeadingConstraint.constant = 2.5 * sizeRatio
        dogIconTrailingConstraint.constant = 5.0 * sizeRatio
        dogIconTopConstraint.constant = 2.5 * sizeRatio
        dogIconBottomConstraint.constant = 2.5 * sizeRatio

        // Log Date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Calendar.localCalendar.locale
        // Specifies no style.
        dateFormatter.dateStyle = .none
        // Specifies a short style, typically numeric only, such as “11/23/37” or “3:30 PM”.
        dateFormatter.timeStyle = .short
        logStartDateLabel.text = dateFormatter.string(from: log.logStartDate)
        logStartDateLabel.font = logStartDateLabel.font.withSize(fontSize * sizeRatio)
        logStartDateTopConstraint.constant = 5.0 * sizeRatio
        logStartDateTrailingConstraint.constant = 7.5 * sizeRatio
        logStartDateHeightConstraint.constant = 25.0 * sizeRatio

        // Log Action
        logActionLabel.text = log.logAction.displayActionName(logCustomActionName: log.logCustomActionName)
        logActionLabel.font = logActionLabel.font.withSize(fontSize * sizeRatio)
        // Log Action Constant
        logActionTrailingConstraint.constant = 5.0 * sizeRatio

        // Log Note
        let logUnitFont = UIFont.systemFont(ofSize: fontSize * sizeRatio, weight: .semibold)
        let logNoteFont = UIFont.systemFont(ofSize: fontSize * sizeRatio, weight: .regular)
        let logUnit: String? = {
            guard let logUnit = log.logUnit, let logNumberOfLogUnits = log.logNumberOfLogUnits else {
                return nil
            }
            
            return LogUnit.convertedMeasurementString(forLogUnit: logUnit, forLogNumberOfLogUnits: logNumberOfLogUnits, toTargetSystem: UserConfiguration.measurementSystem)
        }()
        let logNote = log.logNote.trimmingCharacters(in: .whitespacesAndNewlines)
        
        logNoteLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            
            // Start with a blank message
            let message: NSMutableAttributedString = NSMutableAttributedString(
                string: "",
                attributes: [
                    .font: logUnitFont,
                    .foregroundColor: UIColor.secondaryLabel
                ])
            
            // If we have a non-empty logUnit, then we want to add it our message
            if let logUnit = logUnit, logUnit.isEmpty == false {
                // "1.5 cups"
                message.append(NSAttributedString(
                    string: logUnit,
                    attributes: [
                        // If we have a logNote, then we need to differentiate it from the logNote. we do this by font
                        .font: logNote.isEmpty ? logNoteFont : logUnitFont,
                        .foregroundColor: UIColor.secondaryLabel
                    ])
                )
            }
            
            // If we have a log note, add it to the string
            if logNote.isEmpty == false {
                // We have already added information for log units
                if message.string.isEmpty == false {
                    // "1.5 cups; "
                    message.append(NSAttributedString(
                        string: "; ",
                        attributes: [
                            // If we have a logNote, then we need to differentiate it from the logNote. we do this by font
                            .font: logNote.isEmpty ? logNoteFont : logUnitFont,
                            .foregroundColor: UIColor.secondaryLabel
                        ])
                    )
                }
                
                // "1.5 cups; some note"
                // or "some note"
                message.append(NSAttributedString(
                    string: logNote,
                    attributes: [
                        .font: logNoteFont,
                        .foregroundColor: UIColor.secondaryLabel
                    ])
                )
            }
            
            return message
        }
        let shouldHideLogNote = logNoteLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        logNoteLabel.isHidden = shouldHideLogNote
        logNoteBottomConstraint.constant = 5.0 * sizeRatio
        logNoteHeightConstraint.constant = shouldHideLogNote
        ? 0.0
        : 20 * sizeRatio

        // Right Chevron Constant
        rightChevronTrailingConstraint.constant = 7.5 * sizeRatio
    }

}
