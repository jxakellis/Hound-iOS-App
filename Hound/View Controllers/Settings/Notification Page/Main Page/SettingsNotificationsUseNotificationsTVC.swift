//
//  SettingsNotificationsUseNotificationsTableViewCell.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsNotificationsUseNotificationsTableViewCellDelegate: AnyObject {
    func didToggleIsNotificationEnabled()
}

class SettingsNotificationsUseNotificationsTableViewCell: UITableViewCell {
    
    // MARK: - IB
    
    @IBOutlet private weak var isNotificationEnabledSwitch: UISwitch!
    
    @IBAction private func didToggleIsNotificationEnabled(_ sender: Any) {
        let beforeUpdateIsNotificationEnabled = UserConfiguration.isNotificationEnabled
        
        UNUserNotificationCenter.current().getNotificationSettings { (permission) in
            // needed as  UNUserNotificationCenter.current().getNotificationSettings on other thread
            DispatchQueue.main.async {
                switch permission.authorizationStatus {
                case .authorized:
                    // even if we get .authorized, they doesn't mean the user wants to enabled notifications. the user could have authorized notifications months ago and now gone to this page to tap the switch, flipping it from on to off.
                    UserConfiguration.isNotificationEnabled.toggle()
                    
                    // the switch has been manually flicked by the user to invoke this, so don't call synchronizeValues as that would cause the switch to be animated for a second time
                    self.synchronizeUseNotificationsDescriptionLabel()
                    self.delegate.didToggleIsNotificationEnabled()
                    
                    let body = [KeyConstant.userConfigurationIsNotificationEnabled.rawValue: UserConfiguration.isNotificationEnabled]
                    
                    UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
                        guard requestWasSuccessful else {
                            // if we couldn't update this value, then revert to previous values
                            UserConfiguration.isNotificationEnabled = beforeUpdateIsNotificationEnabled
                            self.synchronizeValues(animated: true)
                            self.delegate.didToggleIsNotificationEnabled()
                            return
                        }
                    }
                case .denied:
                    // nothing to update (as permissions denied) so we don't tell the server anything
                    
                    // Permission is denied, so we want to flip the switch back to its proper off position
                    let switchDisableTimer = Timer(fire: Date().addingTimeInterval(0.25), interval: -1, repeats: false) { _ in
                        self.synchronizeValues(animated: true)
                    }
                    
                    RunLoop.main.add(switchDisableTimer, forMode: .common)
                    
                    // Attempt to re-direct the user to their iPhone's settings for Hound, so they can enable notifications
                    if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url)
                    }
                    // If we can't redirect the user, then just user a generic pop-up
                    else {
                        PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.notificationsDisabledTitle, forSubtitle: VisualConstant.BannerTextConstant.notificationsDisabledSubtitle, forStyle: .danger)
                    }
                case .notDetermined:
                    // don't advise the user if they want to turn on notifications. we already know that the user wants to turn on notification because they just toggle a switch to turn them on
                    NotificationManager.requestNotificationAuthorization(shouldAdviseUserBeforeRequestingNotifications: false) {
                        // the request get notifications is complete
                        self.synchronizeValues(animated: true)
                        self.delegate.didToggleIsNotificationEnabled()
                    }
                case .provisional:
                    AppDelegate.generalLogger.fault(".provisional")
                case .ephemeral:
                    AppDelegate.generalLogger.fault(".ephemeral")
                @unknown default:
                    AppDelegate.generalLogger.fault("@unknown notification authorization status")
                }
            }
        }
        
    }
    
    @IBOutlet private weak var useNotificationsDescriptionLabel: ScaledUILabel!
    
    // MARK: - Properties
    
    weak var delegate: SettingsNotificationsUseNotificationsTableViewCellDelegate!
    
    // MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        synchronizeValues(animated: false)
    }
    
    // MARK: - Functions
    
    /// Updates the displayed values to reflect the values stored.
    func synchronizeValues(animated: Bool) {
        isNotificationEnabledSwitch.setOn(UserConfiguration.isNotificationEnabled, animated: animated)
        
        synchronizeUseNotificationsDescriptionLabel()
    }
    
    private func synchronizeUseNotificationsDescriptionLabel() {
        let dogCount = MainTabBarController.mainTabBarController?.dogManager.dogs.count ?? 1
        let description = NSMutableAttributedString(
            string: "Notifications help you stay up to date about both the status of your dog\(dogCount <= 1 ? "" : "s") and Hound family. ",
            attributes: [NSMutableAttributedString.Key.font: VisualConstant.FontConstant.secondaryLabelColorFeatureDescriptionLabel])
        
        if UserConfiguration.isNotificationEnabled == false {
            description.append(NSMutableAttributedString(
                string: "You can't modify the settings below until you enable notifications.",
                attributes: [NSMutableAttributedString.Key.font: VisualConstant.FontConstant.emphasizedSecondaryLabelColorFeatureDescriptionLabel]))
        }
        
        useNotificationsDescriptionLabel.attributedText = description
    }
}
