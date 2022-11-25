//
//  DropDownLogFilterTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/2/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class DropDownLogFilterTableViewCell: DropDownTableViewCell {
    
    // MARK: - Properties
    
    var dogId: Int?
    
    var logAction: LogAction?
    
    // MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Functions
    
    func setup(forDog dog: Dog?, forLogAction logAction: LogAction?) {
        adjustLeadingTrailing(newConstant: DropDownUIView.insetForLogFilter)
        
        self.dogId = dog?.dogId
        self.logAction = logAction
        
        // first: try dog log setup
        if let logAction = logAction {
            label.attributedText = NSAttributedString(string: logAction.rawValue, attributes: [.font: VisualConstant.FontConstant.filterByLogFont])
        }
        // second: try dog setup
        else if let dog = dog {
            label.attributedText = NSAttributedString(string: dog.dogName, attributes: [.font: VisualConstant.FontConstant.filterByDogFont])
        }
        // last: no dog or log action
        else {
            label.attributedText = NSAttributedString(string: "Clear Filter", attributes: [.font: VisualConstant.FontConstant.filterByDogFont])
        }
    }
}
