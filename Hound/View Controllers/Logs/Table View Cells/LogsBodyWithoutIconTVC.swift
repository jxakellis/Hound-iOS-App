//
//  LogsBodyWithoutIconTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/10/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogsBodyWithoutIconTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var dogNameLabel: ScaledUILabel!
    @IBOutlet private weak var dogNameTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogNameBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogNameLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogNameTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogNameHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logDateLabel: ScaledUILabel!
    @IBOutlet private weak var logDateTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logActionLabel: ScaledUILabel!
    @IBOutlet private weak var logActionTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var familyMemberNameLabel: ScaledUILabel!
    @IBOutlet private weak var familyMemberTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logNoteLabel: ScaledUILabel!
    @IBOutlet private weak var logNoteBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logNoteHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var rightChevronImageView: UIImageView!
    @IBOutlet private weak var rightChevronTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightChevronWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Functions
    
    func setup(forParentDogName dogName: String, forLog log: Log) {
        
        let fontSize = VisualConstant.FontConstant.logCellFontSize
        let sizeRatio = UserConfiguration.logsInterfaceScale.currentScaleFactor
        let shouldHideLogNote = log.logNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // Dog Name
        dogNameLabel.text = dogName
        dogNameLabel.font = dogNameLabel.font.withSize(fontSize * sizeRatio)
        // Dog Name Constant
        dogNameTopConstraint.constant = 5.0 * sizeRatio
        dogNameBottomConstraint.constant = shouldHideLogNote ? 0.0 : 0.0 * sizeRatio
        dogNameLeadingConstraint.constant = 7.5 * sizeRatio
        dogNameTrailingConstraint.constant = 7.5 * sizeRatio
        dogNameHeightConstraint.constant = 20.0 * sizeRatio
        
        // Log Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.localCalendar.locale)
        logDateLabel.text = dateFormatter.string(from: log.logDate)
        logDateLabel.font = logDateLabel.font.withSize(fontSize * sizeRatio)
        // Log Date Constant
        logDateTrailingConstraint.constant = 7.5 * sizeRatio
        
        // Log Action
        logActionLabel.text = log.logAction.displayActionName(logCustomActionName: log.logCustomActionName, isShowingAbreviatedCustomActionName: true)
        logActionLabel.font = logActionLabel.font.withSize(fontSize * sizeRatio)
        // Log Action Constant
        logActionTrailingConstraint.constant = 7.5 * sizeRatio
        
        // Family Member
        familyMemberNameLabel.text = FamilyInformation.findFamilyMember(forUserId: log.userId)?.displayFirstName ?? VisualConstant.TextConstant.unknownText
        familyMemberNameLabel.font = familyMemberNameLabel.font.withSize(fontSize * sizeRatio)
        // Family Member Constant
        familyMemberTrailingConstraint.constant = 7.5 * sizeRatio
        
        // Log Note
        logNoteLabel.text = log.logNote
        logNoteLabel.isHidden = shouldHideLogNote
        logNoteLabel.font = logNoteLabel.font.withSize(fontSize * sizeRatio)
        // Log Note Constant
        logNoteBottomConstraint.constant = 5.0 * sizeRatio
        logNoteHeightConstraint.constant = shouldHideLogNote ? 0.0 : 15.0 * sizeRatio
        
        // Right Chevron Constant
        rightChevronTrailingConstraint.constant = 7.5 * sizeRatio
        rightChevronWidthConstraint.constant = 15.0 * sizeRatio
    }
    
}
