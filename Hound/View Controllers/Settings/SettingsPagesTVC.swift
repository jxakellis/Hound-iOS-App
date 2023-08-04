//
//  SettingsTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/28/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum SettingsPages: String, CaseIterable {
    case account = "Account"
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
        case .account:
            return "SettingsAccountViewController"
        case .family:
            return "SettingsFamilyViewController"
        case .subscription:
            return "SettingsSubscriptionViewController"
        case .appearance:
            return "SettingsAppearanceViewController"
        case .notifications:
            return "SettingsNotificationsTableViewController"
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
        case .account:
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
        case .account:
            return UIImage(systemName: "person.crop.circle")
        case .family:
            return UIImage(systemName: "figure.and.child.holdinghands") ?? UIImage(systemName: "person.3")
        case .subscription:
            return UIImage(systemName: "creditcard")
        case .appearance:
            return UIImage(systemName: "textformat")
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
            return UIImage(systemName: "text.book.closed")
        }
    }
}

final class SettingsPagesTableViewCell: UITableViewCell {

    // MARK: - IB

    @IBOutlet private(set) weak var containerView: UIView! // swiftlint:disable:this private_outlet

    @IBOutlet private weak var pageImageButton: GeneralUIImageView!

    @IBOutlet private weak var pageTitleLabel: GeneralUILabel!

    @IBOutlet private weak var rightChevronImageView: UIImageView!

    // MARK: - Properties

    var page: SettingsPages?

    // MARK: - Functions

    func setup(forPage: SettingsPages) {
        self.page = forPage

        pageImageButton.image = forPage.image
        pageTitleLabel.text = forPage.rawValue
    }

}
