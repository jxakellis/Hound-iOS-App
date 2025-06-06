//
//  SettingsNotifsUseNotificationsTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsNotifsUseNotificationsTVCDelegate: AnyObject {
    func didToggleIsNotificationEnabled()
}

final class SettingsNotifsUseNotificationsTVC: UITableViewCell {
    
    // MARK: - Elements
    
    private let isNotificationEnabledSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.contentMode = .scaleToFill
        uiSwitch.setContentHuggingPriority(UILayoutPriority(260), for: .horizontal)
        uiSwitch.setContentHuggingPriority(UILayoutPriority(260), for: .vertical)
        uiSwitch.setContentCompressionResistancePriority(UILayoutPriority(760), for: .horizontal)
        uiSwitch.setContentCompressionResistancePriority(UILayoutPriority(760), for: .vertical)
        uiSwitch.contentHorizontalAlignment = .center
        uiSwitch.contentVerticalAlignment = .center
        uiSwitch.isOn = UserConfiguration.isNotificationEnabled
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        uiSwitch.onTintColor = .systemBlue
        
        return uiSwitch
    }()
    
    
    @objc private func didToggleIsNotificationEnabled(_ sender: Any) {
        let beforeUpdateIsNotificationEnabled = UserConfiguration.isNotificationEnabled
        
        UNUserNotificationCenter.current().getNotificationSettings { permission in
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
                    
                    UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
                        guard responseStatus != .failureResponse else {
                            // Revert local values to previous state due to an error
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
                    guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else {
                        // If we can't redirect the user, then just user a generic pop-up
                        PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.notificationsDisabledTitle, forSubtitle: VisualConstant.BannerTextConstant.notificationsDisabledSubtitle, forStyle: .danger)
                        return
                    }
                    
                    UIApplication.shared.open(url)
                case .notDetermined:
                    // don't advise the user if they want to turn on notifications. we already know that the user wants to turn on notification because they just toggle a switch to turn them on
                    NotificationPermissionsManager.requestNotificationAuthorization(shouldAdviseUserBeforeRequestingNotifications: false) {
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
    
    private let useNotificationsDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(240), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(240), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(740), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(740), for: .vertical)
        label.text = "Notifications help you stay up to date about the status of your dogs, reminders, and Hound family. "
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12.5, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Additional UI Elements
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.text = "Use Notifications"
        label.textAlignment = .natural
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    // MARK: - Properties
    
    weak var delegate: SettingsNotifsUseNotificationsTVCDelegate!
    
    // MARK: - Main
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupGeneratedViews()
        synchronizeValues(animated: false)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGeneratedViews()
        synchronizeValues(animated: false)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGeneratedViews()
        synchronizeValues(animated: false)
    }
    
    // MARK: - Functions
    
    /// Updates the displayed values to reflect the values stored.
    func synchronizeValues(animated: Bool) {
        isNotificationEnabledSwitch.setOn(UserConfiguration.isNotificationEnabled, animated: animated)
        
        synchronizeUseNotificationsDescriptionLabel()
    }
    
    private func synchronizeUseNotificationsDescriptionLabel() {
        let dogCount = DogManager.globalDogManager?.dogs.count ?? 1
        
        let precalculatedDynamicNotificationsText = "Notifications help you stay up to date about both the status of your dog\(dogCount <= 1 ? "" : "s") and Hound family. "
        let precalculatedDynamicTextColor = useNotificationsDescriptionLabel.textColor
        let precaulculatedDynamicIsNotificationsEnabled = UserConfiguration.isNotificationEnabled == false
        
        useNotificationsDescriptionLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            let message = NSMutableAttributedString(
                string: precalculatedDynamicNotificationsText,
                attributes: [.font: VisualConstant.FontConstant.secondaryLabelColorFeatureDescriptionLabel, .foregroundColor: precalculatedDynamicTextColor as Any]
            )
            
            if precaulculatedDynamicIsNotificationsEnabled {
                message.append(NSMutableAttributedString(
                    string: "You can't modify the settings below until you enable notifications.",
                    attributes: [.font: VisualConstant.FontConstant.emphasizedSecondaryLabelColorFeatureDescriptionLabel, .foregroundColor: precalculatedDynamicTextColor as Any])
                )
            }
            
            return message
        }
    }
}

extension SettingsNotifsUseNotificationsTVC {
    private func setupGeneratedViews() {
        addSubViews()
        setupConstraints()
    }
    
    private func addSubViews() {
        contentView.addSubview(headerLabel)
        contentView.addSubview(isNotificationEnabledSwitch)
        contentView.addSubview(useNotificationsDescriptionLabel)
        
        isNotificationEnabledSwitch.addTarget(self, action: #selector(didToggleIsNotificationEnabled), for: .valueChanged)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            headerLabel.centerYAnchor.constraint(equalTo: isNotificationEnabledSwitch.centerYAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: 25),
            
            useNotificationsDescriptionLabel.topAnchor.constraint(equalTo: isNotificationEnabledSwitch.bottomAnchor, constant: 7.5),
            useNotificationsDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            useNotificationsDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            useNotificationsDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            isNotificationEnabledSwitch.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            isNotificationEnabledSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 10),
            isNotificationEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            
        ])
        
    }
}
