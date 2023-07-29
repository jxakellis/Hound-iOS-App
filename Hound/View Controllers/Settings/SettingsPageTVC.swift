//
//  SettingsTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/28/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum SettingsPages: String, CaseIterable {
    case personalInformation = "Personal Information"
    case family = "Family"
    case subscription = "Subscription"
    case appearance = "Appearance"
    case notifications = "Notifications"
    case website = "Website"
    case contact = "Contact"
    case eula = "EULA"
    case privacyPolicy = "Privacy Policy"
    case termsAndConditions = "Terms and Conditions"
    
    var segueIdentifier: String? {
        switch self {
        case .personalInformation:
            return "SettingsPersonalInformationViewController"
        case .family:
            return "SettingsFamilyViewController"
        case .subscription:
            return "SettingsSubscriptionViewController"
        case .appearance:
            return "SettingsAppearanceViewController"
        case .notifications:
            return "SettingsNotificationsViewController"
        case .website:
            return nil
        case .contact:
            return nil
        case .eula:
            return nil
        case .privacyPolicy:
            return nil
        case .termsAndConditions:
            return nil
        }
    }
    
    var url: URL? {
        switch self {
        case .personalInformation:
            return nil
        case .family:
            return nil
        case .subscription:
            return nil
        case .appearance:
            return nil
        case .notifications:
            return nil
        case .website:
            return URL(string: "https://www.houndorganizer.com")
        case .contact:
            return URL(string: "https://www.houndorganizer.com/contact")
        case .eula:
            return URL(string: "https://www.houndorganizer.com/eula")
        case .privacyPolicy:
            return URL(string: "https://www.houndorganizer.com/privacy")
        case .termsAndConditions:
            return URL(string: "https://www.houndorganizer.com/terms")
        }
    }
    
    var image: UIImage? {
        switch self {
        case .personalInformation:
            return UIImage(systemName: "person.crop.circle")
        case .family:
            return UIImage(systemName: "figure.and.child.holdinghands")
        case .subscription:
            return UIImage(systemName: "creditcard")
        case .appearance:
            return UIImage(systemName: "paintpalette")
        case .notifications:
            return UIImage(systemName: "iphone.radiowaves.left.and.right")
        case .website:
            return UIImage(systemName: "globe")
        case .contact:
            return UIImage(systemName: "envelope")
        case .eula:
            return UIImage(systemName: "doc.plaintext")
        case .privacyPolicy:
            return UIImage(systemName: "shield")
        case .termsAndConditions:
            return UIImage(systemName: "eye")
        }
    }
}

final class SettingsPageTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private(set) weak var containerView: UIView! // swiftlint:disable:this private_outlet
    
    @IBOutlet private weak var pageImageButton: GeneralUIButton!
    // 2.5
    // @IBOutlet private weak var pageImageLeadingConstraint: NSLayoutConstraint!
    // 5.0
    // @IBOutlet private weak var pageImageTrailingConstraint: NSLayoutConstraint!
    // 2.5
    // @IBOutlet private weak var pageImageTopConstraint: NSLayoutConstraint!
    // 2.5
    // @IBOutlet private weak var pageImageBottomConstraint: NSLayoutConstraint!
    // 35.0
    // @IBOutlet private weak var pageImageHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var pageTitleLabel: GeneralUILabel!
    // 5.0
    // @IBOutlet private weak var pageTitleTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var rightChevronImageView: UIImageView!
    // 7.5
    // @IBOutlet private weak var rightChevronTrailingConstraint: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var page: SettingsPages?
    
    // MARK: - Functions
    
    func setup(forPage: SettingsPages) {
        self.page = forPage
        
        // let fontSize = VisualConstant.FontConstant.unweightedSettingsPageLabel.pointSize
        // let sizeRatio = UserConfiguration.logsInterfaceScale.currentScaleFactor
        
        if let image = forPage.image {
            pageImageButton.setImage(image, for: .normal)
        }
        // pageImageTopConstraint.constant = 2.5 * sizeRatio
        // pageImageBottomConstraint.constant = 2.5 * sizeRatio
        // pageImageLeadingConstraint.constant = 2.5 * sizeRatio
        // pageImageTrailingConstraint.constant = 5.0 * sizeRatio
        // pageImageHeightConstraint.constant = 35.0 * sizeRatio
        
        pageTitleLabel.text = forPage.rawValue
        // pageTitleLabel.font = pageTitleLabel.font.withSize(fontSize * sizeRatio)
        // pageTitleTrailingConstraint.constant = 5.0 * sizeRatio
        
        // rightChevronTrailingConstraint.constant = 7.5 * sizeRatio
    }
    
}
