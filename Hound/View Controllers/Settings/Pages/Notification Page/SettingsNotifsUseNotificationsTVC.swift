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

final class SettingsNotifsUseNotificationsTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    private let headerLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Use Notifications"
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private let isNotificationEnabledSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 260, compressionResistancePriority: 260)
        
        uiSwitch.isOn = UserConfiguration.isNotificationEnabled
        
        return uiSwitch
    }()
    
    private let descriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 240, compressionResistancePriority: 240)
        label.text = "Notifications help you stay up to date about the status of your dogs, reminders, and Hound family. "
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryColorDescLabel
        label.textColor = .secondaryLabel
        return label
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
                    self.delegate?.didToggleIsNotificationEnabled()
                    
                    let body = [KeyConstant.userConfigurationIsNotificationEnabled.rawValue: UserConfiguration.isNotificationEnabled]
                    
                    UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
                        guard responseStatus != .failureResponse else {
                            // Revert local values to previous state due to an error
                            UserConfiguration.isNotificationEnabled = beforeUpdateIsNotificationEnabled
                            self.synchronizeValues(animated: true)
                            self.delegate?.didToggleIsNotificationEnabled()
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
                        self.delegate?.didToggleIsNotificationEnabled()
                    }
                case .provisional:
                    HoundLogger.general.fault(".provisional")
                case .ephemeral:
                    HoundLogger.general.fault(".ephemeral")
                @unknown default:
                    HoundLogger.general.fault("@unknown notification authorization status")
                }
            }
        }
        
    }
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsNotifsUseNotificationsTVC"
    
    private weak var delegate: SettingsNotifsUseNotificationsTVCDelegate?
    
    // MARK: - Main
    
    override func prepareForReuse() {
        super.prepareForReuse()
        synchronizeValues(animated: false)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        synchronizeValues(animated: false)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: SettingsNotifsUseNotificationsTVCDelegate) {
        self.delegate = forDelegate
    }
    
    // MARK: - Functions
    
    /// Updates the displayed values to reflect the values stored.
    private func synchronizeValues(animated: Bool) {
        isNotificationEnabledSwitch.setOn(UserConfiguration.isNotificationEnabled, animated: animated)
        
        synchronizeUseNotificationsDescriptionLabel()
    }
    
    private func synchronizeUseNotificationsDescriptionLabel() {
        let dogCount = DogManager.globalDogManager?.dogs.count ?? 1
        
        let precalculatedDynamicNotificationsText = "Notifications help you stay up to date about both the status of your dog\(dogCount <= 1 ? "" : "s") and Hound family. "
        let precalculatedDynamicTextColor = descriptionLabel.textColor
        let precaulculatedDynamicIsNotificationsEnabled = UserConfiguration.isNotificationEnabled == false
        
        descriptionLabel.attributedTextClosure = {
            // NOTE: ANY NON-STATIC VARIABLES, WHICH CAN CHANGE BASED UPON EXTERNAL FACTORS, MUST BE PRECALCULATED. This code is run everytime the UITraitCollection is updated. Therefore, all of this code is recalculated. If we have dynamic variable inside, the text, font, color... could change to something unexpected when the user simply updates their app to light/dark mode
            let message = NSMutableAttributedString(
                string: precalculatedDynamicNotificationsText,
                attributes: [.font: VisualConstant.FontConstant.secondaryColorDescLabel, .foregroundColor: precalculatedDynamicTextColor as Any]
            )
            
            if precaulculatedDynamicIsNotificationsEnabled {
                message.append(NSMutableAttributedString(
                    string: "You can't modify the settings below until you enable notifications.",
                    attributes: [.font: VisualConstant.FontConstant.emphasizedSecondaryColorDescLabel, .foregroundColor: precalculatedDynamicTextColor as Any])
                )
            }
            
            return message
        }
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(isNotificationEnabledSwitch)
        contentView.addSubview(descriptionLabel)
        
        isNotificationEnabledSwitch.addTarget(self, action: #selector(didToggleIsNotificationEnabled), for: .valueChanged)
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        // headerLabel
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Spacing.absoluteVertInset),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            headerLabel.createMaxHeight(ConstraintConstant.Text.sectionLabelMaxHeight),
            headerLabel.createHeightMultiplier(ConstraintConstant.Text.sectionLabelHeightMultipler, relativeToWidthOf: contentView)
        ])

        // isNotificationEnabledSwitch
        NSLayoutConstraint.activate([
            isNotificationEnabledSwitch.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            isNotificationEnabledSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: ConstraintConstant.Spacing.contentIntraHori),
            isNotificationEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset * 2.0)
        ])

        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVert),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset)
        ])
    }

}
