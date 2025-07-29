//
//  SettingsNotifsAlarmsLoudNotificationsTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsAlarmsLoudNotificationsTVC: HoundTableViewCell {
    
    // MARK: - Elements
    
    private let headerLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Loud Alarms"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private lazy var isLoudNotificationEnabledSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 255, compressionResistancePriority: 255)
        uiSwitch.isOn = UserConfiguration.isNotificationEnabled
        uiSwitch.addTarget(self, action: #selector(didToggleIsLoudNotificationEnabled), for: .valueChanged)
        return uiSwitch
    }()
    
    private let descriptionLabel: HoundLabel = {
        let label = HoundLabel()
        label.numberOfLines = 0
        label.font = Constant.Visual.Font.secondaryColorDescLabel
        label.textColor = UIColor.secondaryLabel
        let precalculatedDynamicTextColor = label.textColor
        
        label.attributedText = {
            let message = NSMutableAttributedString(
                string: "Alarms will ring and repeatedly vibrate despite your phone being silenced, locked, or in focus mode. ",
                attributes: [.font: Constant.Visual.Font.secondaryColorDescLabel]
            )
            
            message.append(NSAttributedString(
                string: "If Hound is terminated, Loud Alarms will not work properly.",
                attributes: [.font: Constant.Visual.Font.emphasizedSecondaryColorDescLabel])
            )
            
            return message
        }()
        return label
    }()
    
    @objc private func didToggleIsLoudNotificationEnabled(_ sender: Any) {
        let beforeUpdateIsLoudNotificationEnabled = UserConfiguration.isLoudNotificationEnabled
        
        UserConfiguration.isLoudNotificationEnabled = isLoudNotificationEnabledSwitch.isOn
        
        let body: JSONRequestBody = [Constant.Key.userConfigurationIsLoudNotificationEnabled.rawValue: .bool(UserConfiguration.isLoudNotificationEnabled)]
        
        UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                // Revert local values to previous state due to an error
                UserConfiguration.isLoudNotificationEnabled = beforeUpdateIsLoudNotificationEnabled
                self.synchronizeValues(animated: true)
                return
            }
        }
    }
    
    // MARK: - Properties
    
    static let reuseIdentifier = "SettingsNotifsAlarmsLoudNotificationsTVC"
    
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
        isLoudNotificationEnabledSwitch.isEnabled = UserConfiguration.isNotificationEnabled
        
        isLoudNotificationEnabledSwitch.setOn(UserConfiguration.isLoudNotificationEnabled, animated: animated)
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(isLoudNotificationEnabledSwitch)
        contentView.addSubview(descriptionLabel)
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

        // isLoudNotificationEnabledSwitch
        NSLayoutConstraint.activate([
            isLoudNotificationEnabledSwitch.centerYAnchor.constraint(equalTo: headerLabel.centerYAnchor),
            isLoudNotificationEnabledSwitch.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentIntraHori),
            isLoudNotificationEnabledSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset * 2.0)
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
