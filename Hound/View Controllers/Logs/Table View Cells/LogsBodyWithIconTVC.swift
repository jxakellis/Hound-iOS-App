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

    @IBOutlet private weak var logDateLabel: GeneralUILabel!
    @IBOutlet private weak var logDateTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logDateTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logDateHeightConstraint: NSLayoutConstraint!

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
        logDateLabel.text = dateFormatter.string(from: log.logDate)
        logDateLabel.font = logDateLabel.font.withSize(fontSize * sizeRatio)
        logDateTopConstraint.constant = 5.0 * sizeRatio
        logDateTrailingConstraint.constant = 7.5 * sizeRatio
        logDateHeightConstraint.constant = 25.0 * sizeRatio

        // Log Action
        logActionLabel.text = log.logAction.displayActionName(logCustomActionName: log.logCustomActionName)
        logActionLabel.font = logActionLabel.font.withSize(fontSize * sizeRatio)
        // Log Action Constant
        logActionTrailingConstraint.constant = 5.0 * sizeRatio

        // Log Note
        logNoteLabel.text = {
            var string = ""
            
            if let adjustedPluralityStringString = LogUnit.convertedMeasurementString(forLogUnit: log.logUnit, forLogNumberOfLogUnits: log.logNumberOfLogUnits, toTargetSystem: UserConfiguration.measurementSystem) {
                // "1.5 cups"
                string.append(adjustedPluralityStringString)
            }
            
            // If we have a log note, add it to the string
            let logNote = log.logNote.trimmingCharacters(in: .whitespacesAndNewlines)
            if logNote.isEmpty == false {
                // We have already added information for log units
                if string.isEmpty == false {
                    // "1.5 cups; "
                    string.append("; ")
                }
                
                // "1.5 cups; some note"
                // or "some note"
                string.append(logNote)
            }
            
            return string
        }()
        let shouldHideLogNote = logNoteLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
        logNoteLabel.isHidden = shouldHideLogNote
        logNoteLabel.font = logNoteLabel.font.withSize(fontSize * sizeRatio)
        // Log Note Constant
        logNoteBottomConstraint.constant = 5.0 * sizeRatio
        logNoteHeightConstraint.constant = shouldHideLogNote
        ? 0.0
        : 20.0 * sizeRatio

        // Right Chevron Constant
        rightChevronTrailingConstraint.constant = 7.5 * sizeRatio
    }

}
