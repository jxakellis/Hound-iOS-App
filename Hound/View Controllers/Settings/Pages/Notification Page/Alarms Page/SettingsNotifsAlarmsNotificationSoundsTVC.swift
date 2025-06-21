//
//  SettingsNotifsAlarmsNotificationSoundsTVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 11/24/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsNotifsAlarmsNotificationSoundsTVC: GeneralUITableViewCell, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    private let notificationSoundsTableView: GeneralUITableView = {
        let tableView = GeneralUITableView(huggingPriority: 260, compressionResistancePriority: 260)
        tableView.alwaysBounceVertical = true
        tableView.backgroundColor = .systemBackground
        tableView.separatorColor = .systemGray2
        tableView.borderWidth = 1
        tableView.borderColor = .label
        tableView.shouldAutomaticallyAdjustHeight = true
        tableView.shouldRoundCorners = true
        return tableView
    }()
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 290, compressionResistancePriority: 290)
        label.text = "Alarm Sound"
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.text = "Changes the sound your alarms play. Tap on one of them to hear what it sounds like!"
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 12.5, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // MARK: - Main
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    // MARK: - Setup
    
    private func setup() {
        notificationSoundsTableView.register(SettingsNotifsAlarmsNotificationSoundTVC.self, forCellReuseIdentifier: SettingsNotifsAlarmsNotificationSoundTVC.reuseIdentifier)
        notificationSoundsTableView.delegate = self
        notificationSoundsTableView.dataSource = self
        
        notificationSoundsTableView.isScrollEnabled = false
        
        // notificationSoundsTableView won't automatically size itself inside a cell. If you set rowHeight to automaticDimension and estimatedRowHeight to 42.0, the cell will always resize to 42.0, not adapting at all. translatesAutoresizingMaskIntoConstraints doesn't do anything either. Hard coding the cell's size in storyboard (top, bottom, height, and row height set) doesn't resolve this either.
        notificationSoundsTableView.rowHeight = SettingsNotifsAlarmsNotificationSoundTVC.cellHeight
        
        synchronizeValues(animated: false)
    }
    
    // MARK: - Functions
    
    /// Updates the displayed isEnabled to reflect the state of isNotificationEnabled stored.
    func synchronizeIsEnabled() {
        notificationSoundsTableView.isUserInteractionEnabled = UserConfiguration.isNotificationEnabled
    }
    
    /// Updates the displayed values to reflect the values stored.
    func synchronizeValues(animated: Bool) {
        synchronizeIsEnabled()
        
        // set all cells to unselected
        for cellRow in 0..<NotificationSound.allCases.count {
            let cellIndexPath = IndexPath(row: cellRow, section: 0)
            let cell = notificationSoundsTableView.cellForRow(at: cellIndexPath) as? SettingsNotifsAlarmsNotificationSoundTVC
            cell?.setCustomSelectedTableViewCell(false, animated: true)
        }
        
        // set user configuration notification sound cell to selected
        guard let currentNotificationSoundCellRow = NotificationSound.allCases.firstIndex(of: UserConfiguration.notificationSound) else {
            return
        }
        let currentNotificationSoundCellIndexPath = IndexPath(row: currentNotificationSoundCellRow, section: 0)
        let currentNotificationSoundCell = notificationSoundsTableView.cellForRow(at: currentNotificationSoundCellIndexPath) as? SettingsNotifsAlarmsNotificationSoundTVC
        currentNotificationSoundCell?.setCustomSelectedTableViewCell(true, animated: true)
    }
    
    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NotificationSound.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = notificationSoundsTableView.dequeueReusableCell(withIdentifier: SettingsNotifsAlarmsNotificationSoundTVC.reuseIdentifier, for: indexPath) as? SettingsNotifsAlarmsNotificationSoundTVC else {
            return GeneralUITableViewCell()
        }
        
        let notificationSound = NotificationSound.allCases[indexPath.row]
        
        cell.setup(forNotificationSound: notificationSound == NotificationSound.radar ? "Radar (Default)" : notificationSound.rawValue)
        cell.setCustomSelectedTableViewCell(notificationSound == UserConfiguration.notificationSound, animated: false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = notificationSoundsTableView.cellForRow(at: indexPath) as? SettingsNotifsAlarmsNotificationSoundTVC,
              let currentNotificationSoundIndex = NotificationSound.allCases.firstIndex(of: UserConfiguration.notificationSound) else {
            // we need the selected cell and current notification sound index before we proceed
            AudioManager.stopAudio()
            return
        }
        
        let selectedNotificationSound = NotificationSound.allCases[indexPath.row]
        
        guard selectedNotificationSound != UserConfiguration.notificationSound else {
            // cell selected is the same as the current sound saved, toggle the audio
            if AudioManager.isPlaying {
                AudioManager.stopAudio()
            }
            else {
                AudioManager.playAudio(forAudioPath: "\(UserConfiguration.notificationSound.rawValue.lowercased())")
            }
            
            return
        }
        
        // the new cell selected is different that the current sound saved
        
        // find the current notification sound cell and unselect it, as the user just selected a new one
        let currentNotificationSoundIndexPath = IndexPath(row: currentNotificationSoundIndex, section: 0)
        let currentNotificationSoundCell = notificationSoundsTableView.cellForRow(at: currentNotificationSoundIndexPath) as? SettingsNotifsAlarmsNotificationSoundTVC
        currentNotificationSoundCell?.setCustomSelectedTableViewCell(false, animated: true)
        
        // highlight the new selected cell
        selectedCell.setCustomSelectedTableViewCell(true, animated: true)
        
        // leave this code right here, don't move below or its value will be incorrect
        let beforeUpdateNotificationSound = UserConfiguration.notificationSound
        
        // assign user configuration to new value and play its audio
        UserConfiguration.notificationSound = selectedNotificationSound
        AudioManager.playAudio(forAudioPath: "\(UserConfiguration.notificationSound.rawValue.lowercased())")
        
        // contact server to attempt to persist change
        let body = [KeyConstant.userConfigurationNotificationSound.rawValue: UserConfiguration.notificationSound.rawValue]
        
        UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                // Revert local values to previous state due to an error
                UserConfiguration.notificationSound = beforeUpdateNotificationSound
                self.synchronizeValues(animated: true)
                return
            }
        }
    }
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        contentView.addSubview(headerLabel)
        contentView.addSubview(notificationSoundsTableView)
        contentView.addSubview(descriptionLabel)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // headerLabel (top)
        let headerLabelTop = headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: ConstraintConstant.Global.contentInset)
        let headerLabelLeading = headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: ConstraintConstant.Global.contentInset)
        let headerLabelTrailing = headerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -ConstraintConstant.Global.contentInset)
        
        // notificationSoundsTableView (middle)
        let notificationSoundsTableViewTop = notificationSoundsTableView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 5)
        let notificationSoundsTableViewLeading = notificationSoundsTableView.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor)
        let notificationSoundsTableViewTrailing = notificationSoundsTableView.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor)
        
        // descriptionLabel (bottom)
        let descriptionLabelTop = descriptionLabel.topAnchor.constraint(equalTo: notificationSoundsTableView.bottomAnchor, constant: 5)
        let descriptionLabelBottom = descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -ConstraintConstant.Global.contentInset)
        let descriptionLabelLeading = descriptionLabel.leadingAnchor.constraint(equalTo: headerLabel.leadingAnchor)
        let descriptionLabelTrailing = descriptionLabel.trailingAnchor.constraint(equalTo: headerLabel.trailingAnchor)
        
        NSLayoutConstraint.activate([
            // headerLabel
            headerLabelTop,
            headerLabelLeading,
            headerLabelTrailing,
            
            // notificationSoundsTableView
            notificationSoundsTableViewTop,
            notificationSoundsTableViewLeading,
            notificationSoundsTableViewTrailing,
            
            // descriptionLabel
            descriptionLabelTop,
            descriptionLabelBottom,
            descriptionLabelLeading,
            descriptionLabelTrailing
        ])
    }

}
