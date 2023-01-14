//
//  LogsBodyWithIconTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogsBodyWithIconTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var dogIconImageView: UIImageView!
    @IBOutlet private weak var dogIconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogIconTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogIconHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logDateLabel: ScaledUILabel!
    @IBOutlet private weak var logDateTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logDateBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logDateTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logDateHeightConstraint: NSLayoutConstraint!
    
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
    
    func setup(forParentDogIcon parentDogIcon: UIImage, forLog log: Log) {
        
        let familyMemberThatLogged = FamilyInformation.findFamilyMember(forUserId: log.userId)
        familyMemberNameLabel.text = familyMemberThatLogged?.displayFirstName ?? VisualConstant.TextConstant.unknownText
        
        let fontSize = VisualConstant.FontConstant.noWeightLogUILabel.pointSize
        let sizeRatio = UserConfiguration.logsInterfaceScale.currentScaleFactor
        let shouldHideLogNote = log.logNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // Dog Icon
        dogIconImageView.image = parentDogIcon
        let dogIconImageViewHeight = 30.0 * sizeRatio
        dogIconImageView.layer.masksToBounds = VisualConstant.LayerConstant.defaultMasksToBounds
        dogIconImageView.layer.cornerRadius = dogIconImageViewHeight / 2
        // Dog Icon Constant
        dogIconLeadingConstraint.constant = 2.5 * sizeRatio
        dogIconTrailingConstraint.constant = 2.5 * sizeRatio
        dogIconHeightConstraint.constant = dogIconImageViewHeight
        
        // Log Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.localCalendar.locale)
        logDateLabel.text = dateFormatter.string(from: log.logDate)
        logDateLabel.font = logDateLabel.font.withSize(fontSize * sizeRatio)
        // Log Date Constant
        logDateTopConstraint.constant = 5.0 * sizeRatio
        logDateBottomConstraint.constant = shouldHideLogNote ? 0.0 : 0.0 * sizeRatio
        logDateTrailingConstraint.constant = 7.5 * sizeRatio
        logDateHeightConstraint.constant = 20.0 * sizeRatio
        
        // Log Action
        logActionLabel.text = log.logAction.displayActionName(logCustomActionName: log.logCustomActionName, isShowingAbreviatedCustomActionName: true)
        logActionLabel.font = logActionLabel.font.withSize(fontSize * sizeRatio)
        // Log Action Constant
        logActionTrailingConstraint.constant = 7.5 * sizeRatio
        
        // Family Member
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
        
        // The leading constrant for the dogIcon should be the same regardless of whether its on top or on bottom. Therefore, we can use dogIconLeadingConstraint.constant as the expected constant on the top and bottom of dogIcon.
        let neededDogIconHeight = dogIconLeadingConstraint.constant + dogIconLeadingConstraint.constant + dogIconHeightConstraint.constant
        let actualCellHeight = logDateTopConstraint.constant + logDateHeightConstraint.constant + logDateBottomConstraint.constant + logNoteHeightConstraint.constant + logNoteBottomConstraint.constant
        if neededDogIconHeight > actualCellHeight {
            let extraHeightNeeded = neededDogIconHeight - actualCellHeight
            logDateTopConstraint.constant += (extraHeightNeeded / 2)
            logNoteBottomConstraint.constant += (extraHeightNeeded / 2)
        }
    }
    
}
