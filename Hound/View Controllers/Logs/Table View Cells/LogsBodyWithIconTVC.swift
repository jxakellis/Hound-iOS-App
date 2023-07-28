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
    
    @IBOutlet weak var containerView: UIView! // swiftlint:disable:this private_outlet
    
    // We make dogIconButton a ScaledImageUIButton instead of a UIImageView so we can use shouldRounCorners
    @IBOutlet private weak var dogIconButton: ScaledImageUIButton!
    @IBOutlet private weak var dogIconLeadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogIconTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogIconTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var dogIconBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logDateLabel: ScaledUILabel!
    @IBOutlet private weak var logDateTopConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logDateTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logDateHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logActionLabel: ScaledUILabel!
    @IBOutlet private weak var logActionTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var logNoteLabel: ScaledUILabel!
    @IBOutlet private weak var logNoteBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var logNoteHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var rightChevronImageView: UIImageView!
    @IBOutlet private weak var rightChevronTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var rightChevronWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Functions
    
    func setup(forParentDogIcon parentDogIcon: UIImage, forLog log: Log) {
        self.selectionStyle = .none
        
        let fontSize = VisualConstant.FontConstant.unweightedLogLabel.pointSize
        let sizeRatio = UserConfiguration.logsInterfaceScale.currentScaleFactor
        let shouldHideLogNote = log.logNote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // Dog Icon
        dogIconButton.setImage(parentDogIcon, for: .normal)
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
        logDateHeightConstraint.constant = shouldHideLogNote
        ? 30.0 * sizeRatio
        : 20.0 * sizeRatio
        
        // Log Action
        logActionLabel.text = log.logAction.displayActionName(logCustomActionName: log.logCustomActionName, isShowingAbreviatedCustomActionName: true)
        logActionLabel.font = logActionLabel.font.withSize(fontSize * sizeRatio)
        // Log Action Constant
        logActionTrailingConstraint.constant = 5.0 * sizeRatio
        
        // Log Note
        logNoteLabel.text = log.logNote
        logNoteLabel.isHidden = shouldHideLogNote
        logNoteLabel.font = logNoteLabel.font.withSize(fontSize * sizeRatio)
        // Log Note Constant
        logNoteBottomConstraint.constant = 5.0 * sizeRatio
        logNoteHeightConstraint.constant = shouldHideLogNote
        ? 0.0
        : 15.0 * sizeRatio
        
        // Right Chevron Constant
        rightChevronTrailingConstraint.constant = 7.5 * sizeRatio
        rightChevronWidthConstraint.constant = 10.0 * sizeRatio
    }
    
}
