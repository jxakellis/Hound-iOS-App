//
//  SettingsNotifsCategoriesLogTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsCategoriesLogTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    private let headerLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Log"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private lazy var isLogNotificationEnabledSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 255, compressionResistancePriority: 255)
        uiSwitch.isOn = true
        uiSwitch.addTarget(self, action: #selector(didToggleIsLogNotificationEnabled), for: .valueChanged)
        return uiSwitch
    }()
    
    private lazy var disabledTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(showDisabledBanner))
        gesture.cancelsTouchesInView = false
        return gesture
    }()
    
    private let descriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 230, compressionResistancePriority: 230)
        label.text = "Receive notifications about your family's logs. Examples include: a user creating a log."
        label.numberOfLines = 0
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        label.textColor = UIColor.secondaryLabel
        return label
    }()
    
    @objc private func didToggleIsLogNotificationEnabled(_ sender: Any) {
        let beforeUpdatesLogNotificationEnabled = UserConfiguration.isLogNotificationEnabled
        
        UserConfiguration.isLogNotificationEnabled = isLogNotificationEnabledSwitch.isOn
        
        let body: JSONRequestBody = [Constant.Key.userConfigurationIsLogNotificationEnabled.rawValue: .bool(UserConfiguration.isLogNotificationEnabled)]
        
        UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                // Revert local values to previous state due to an error
                UserConfiguration.isLogNotificationEnabled = beforeUpdatesLogNotificationEnabled
                self.synchronizeValues(animated: true)
                return
            }
        }
    }
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsNotifsCategoriesLogTVC"
    
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
    
    // MARK: - Functions
    
    /// Updates the displayed values to reflect the values stored.
    private func synchronizeValues(animated: Bool) {
        isLogNotificationEnabledSwitch.isEnabled = UserConfiguration.isNotificationEnabled
        
        isLogNotificationEnabledSwitch.setOn(UserConfiguration.isLogNotificationEnabled, animated: animated)
    }
    
    @objc private func showDisabledBanner(_ sender: Any) {
        guard UserConfiguration.isNotificationEnabled == false else { return }
        PresentationManager.enqueueBanner(
            forTitle: Constant.Visual.BannerText.noEditNotificationSettingsTitle,
            forSubtitle: Constant.Visual.BannerText.noEditNotificationSettingsSubtitle,
            forStyle: .warning
        )
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(isLogNotificationEnabledSwitch)
        contentView.addSubview(descriptionLabel)
        contentView.addGestureRecognizer(disabledTapGesture)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // headerLabel
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constant.Constraint.Spacing.absoluteVertInset),
            headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            headerLabel.createMaxHeight(Constant.Constraint.Text.sectionLabelMaxHeight),
            headerLabel.createHeightMultiplier(Constant.Constraint.Text.sectionLabelHeightMultipler, relativeToWidthOf: contentView)
        ])
        
        // isLogNotificationEnabledSwitch
        NSLayoutConstraint.activate([
            isLogNotificationEnabledSwitch.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            isLogNotificationEnabledSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentIntraHori),
            isLogNotificationEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset * 2.0)
        ])
        
        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset)
        ])
    }
    
}
