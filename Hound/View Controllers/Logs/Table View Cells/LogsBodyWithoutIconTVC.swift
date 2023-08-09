//
//  LogsBodyWithoutIconTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/10/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogsBodyWithoutIconTableViewCell: UITableViewCell {

    // MARK: - IB

    @IBOutlet private(set) weak var containerView: UIView! // swiftlint:disable:this private_outlet

    @IBOutlet private weak var dogNameLabel: GeneralUILabel!
    @IBOutlet private weak var dogNameTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogNameLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogNameTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogNameHeightConstraint: NSLayoutConstraint!

    @IBOutlet private weak var logDateLabel: GeneralUILabel!
    @IBOutlet private weak var logDateTrailingConstraint: NSLayoutConstraint!

    @IBOutlet private weak var logActionLabel: GeneralUILabel!
    @IBOutlet private weak var logActionTrailingConstraint: NSLayoutConstraint!

    @IBOutlet private weak var familyMemberLabel: GeneralUILabel!
    @IBOutlet private weak var familyMemberTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logNoteLabel: GeneralUILabel!
    @IBOutlet private weak var logNoteBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logNoteHeightConstraint: NSLayoutConstraint!

    @IBOutlet private weak var rightChevronImageView: UIImageView!
    @IBOutlet private weak var rightChevronTrailingConstraint: NSLayoutConstraint!

    // MARK: - Functions

    func setup(forParentDogName dogName: String, forLog log: Log) {
        let fontSize: CGFloat = 17.5
        let sizeRatio = UserConfiguration.logsInterfaceScale.currentScaleFactor
        let shouldHideLogNote = log.logNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty

        // Dog Name
        dogNameLabel.text = dogName
        dogNameLabel.font = dogNameLabel.font.withSize(fontSize * sizeRatio)
        dogNameTopConstraint.constant = 5.0 * sizeRatio
        dogNameLeadingConstraint.constant = 7.5 * sizeRatio
        dogNameTrailingConstraint.constant = 7.5 * sizeRatio
        dogNameHeightConstraint.constant = 25.0 * sizeRatio

        // Log Date
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Calendar.localCalendar.locale
        // Specifies no style.
        dateFormatter.dateStyle = .none
        // Specifies a short style, typically numeric only, such as “11/23/37” or “3:30 PM”.
        dateFormatter.timeStyle = .short
        logDateLabel.text = dateFormatter.string(from: log.logDate)
        logDateLabel.font = logDateLabel.font.withSize(fontSize * sizeRatio)
        logDateTrailingConstraint.constant = 7.5 * sizeRatio

        // Log Action
        logActionLabel.text = log.logAction.displayActionName(logCustomActionName: log.logCustomActionName)
        logActionLabel.font = logActionLabel.font.withSize(fontSize * sizeRatio)
        logActionTrailingConstraint.constant = 7.5 * sizeRatio
        
        familyMemberLabel.text = FamilyInformation.familyMembers.first(where: { familyMember in
            return familyMember.userId == log.userId
        })?.displayInitials ?? ""
        familyMemberLabel.font = familyMemberLabel.font.withSize(fontSize * sizeRatio)
        familyMemberTrailingConstraint.constant = 5.0 * sizeRatio

        // Log Note
        logNoteLabel.text = log.logNote
        logNoteLabel.isHidden = shouldHideLogNote
        logNoteLabel.font = logNoteLabel.font.withSize(fontSize * sizeRatio)
        logNoteBottomConstraint.constant = 5.0 * sizeRatio
        logNoteHeightConstraint.constant = shouldHideLogNote
        ? 0.0
        : 20 * sizeRatio

        // Right Chevron Constant
        rightChevronTrailingConstraint.constant = 7.5 * sizeRatio
    }

}
