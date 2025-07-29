//
//  SettingsAppearanceVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

private enum InterfaceStyleOption: CaseIterable {
    case light, dark, system
    
    var title: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        case .system: return "System"
        }
    }
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return .unspecified
        }
    }
    
    static func index(for style: UIUserInterfaceStyle) -> Int {
        switch style {
        case .light: return allCases.firstIndex(of: .light) ?? 0
        case .dark: return allCases.firstIndex(of: .dark) ?? 0
        default: return allCases.firstIndex(of: .system) ?? 0
        }
    }
    
    static func from(index: Int) -> InterfaceStyleOption {
        return allCases[safe: index] ?? .system
    }
}

enum SettingsAppearanceDropDownTypes: String, HoundDropDownType {
    case timeZone = "DropDownTimeZone"
}

final class SettingsAppearanceVC: HoundScrollViewController,
                                  HoundDropDownDataSource,
                                  HoundDropDownManagerDelegate {
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: - Elements
    
    private let pageHeader: HoundPageSheetHeaderView = {
        let view = HoundPageSheetHeaderView(huggingPriority: 360, compressionResistancePriority: 360)
        view.pageHeaderLabel.text = "Appearance"
        return view
    }()
    
    private let interfaceStyleHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Theme"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private let interfaceStyleSegmentedControl: HoundSegmentedControl = {
        let segmentedControl = HoundSegmentedControl()
        segmentedControl.selectedSegmentTintColor = UIColor.systemBlue
        
        InterfaceStyleOption.allCases.enumerated().forEach { index, option in
            segmentedControl.insertSegment(withTitle: option.title, at: index, animated: false)
        }
        
        let attributes: [NSAttributedString.Key: Any] = [.font: Constant.Visual.Font.emphasizedPrimaryRegularLabel, .foregroundColor: UIColor.systemBackground]
        
        segmentedControl.setTitleTextAttributes(attributes, for: .normal)
        segmentedControl.backgroundColor = UIColor.systemGray4
        segmentedControl.selectedSegmentIndex = InterfaceStyleOption.index(for: UserConfiguration.interfaceStyle)
        
        return segmentedControl
    }()
    
    private let measurementHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Measurement System"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private let measurementSystemSegmentedControl: HoundSegmentedControl = {
        let segmentedControl = HoundSegmentedControl()
        segmentedControl.selectedSegmentTintColor = UIColor.systemBlue
        
        MeasurementSystem.allCases.enumerated().forEach { index, ms in
            segmentedControl.insertSegment(withTitle: ms.readableMeasurementSystem(), at: index, animated: false)
        }
        
        let attributes: [NSAttributedString.Key: Any] = [.font: Constant.Visual.Font.emphasizedPrimaryRegularLabel, .foregroundColor: UIColor.systemBackground]
        
        segmentedControl.setTitleTextAttributes(attributes, for: .normal)
        segmentedControl.backgroundColor = UIColor.systemGray4
        segmentedControl.selectedSegmentIndex = UserConfiguration.measurementSystem.rawValue
        
        return segmentedControl
    }()
    
    private let hapticsHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Haptics"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private lazy var hapticsEnabledSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 260, compressionResistancePriority: 260)
        uiSwitch.isOn = UserConfiguration.isHapticsEnabled
        return uiSwitch
    }()
    
    private let usesDeviceTimeZoneHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Use Device Time Zone"
        label.font = Constant.Visual.Font.secondaryHeaderLabel
        return label
    }()
    
    private lazy var usesDeviceTimeZoneSwitch: HoundSwitch = {
        let uiSwitch = HoundSwitch(huggingPriority: 255, compressionResistancePriority: 255)
        uiSwitch.isOn = UserConfiguration.usesDeviceTimeZone
        return uiSwitch
    }()
    
    private lazy var timeZoneLabel: HoundLabel = {
        let label = HoundLabel()
        label.applyStyle(.thinGrayBorder)
        label.placeholder = "Select a time zone..."
        label.shouldInsetText = true
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(dropDownManager.showHideDropDownGesture(identifier: .timeZone, delegate: self))
        dropDownManager.register(identifier: .timeZone, label: label, autoscroll: .firstOpen)
        return label
    }()
    
    private lazy var dropDownManager = HoundDropDownManager<SettingsAppearanceDropDownTypes>(rootView: containerView, dataSource: self, delegate: self)
    
    @objc private func didUpdateInterfaceStyle(_ sender: Any) {
        guard let sender = sender as? HoundSegmentedControl else { return }
        
        /// Assumes the segmented control is configured for interfaceStyle selection (0: light, 1: dark, 2: unspecified). Using the selectedSegmentIndex, queries the server to update the interfaceStyle UserConfiguration. If successful, then changes UI to new interface style and saves new UserConfiguration value. If unsuccessful, reverts the selectedSegmentIndex to the position before the change, doesn't change the UI interface style, and doesn't save the new UserConfiguration value
        
        let selectedOption = InterfaceStyleOption.from(index: sender.selectedSegmentIndex)
        let beforeUpdateInterfaceStyle = UserConfiguration.interfaceStyle
        
        UserConfiguration.interfaceStyle = selectedOption.userInterfaceStyle
        
        let body: JSONRequestBody = [Constant.Key.userConfigurationInterfaceStyle.rawValue: .int(selectedOption.userInterfaceStyle.rawValue)]
        
        UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                // Revert local values to previous state due to an error
                UserConfiguration.interfaceStyle = beforeUpdateInterfaceStyle
                sender.selectedSegmentIndex = InterfaceStyleOption.index(for: beforeUpdateInterfaceStyle)
                return
            }
        }
    }
    
    @objc private func didUpdateMeasurementSystem(_ sender: Any) {
        guard let sender = sender as? HoundSegmentedControl else { return }
        
        /// Assumes the segmented control is configured for measurementSystem selection (0: imperial, 1: metric, 2: both).
        let beforeUpdateMeasurementSystem = UserConfiguration.measurementSystem
        
        UserConfiguration.measurementSystem = MeasurementSystem(rawValue: sender.selectedSegmentIndex) ?? UserConfiguration.measurementSystem
        
        let body: JSONRequestBody = [Constant.Key.userConfigurationMeasurementSystem.rawValue: .int(UserConfiguration.measurementSystem.rawValue)]
        
        UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                // Revert local values to previous state due to an error
                UserConfiguration.measurementSystem = beforeUpdateMeasurementSystem
                sender.selectedSegmentIndex = beforeUpdateMeasurementSystem.rawValue
                return
            }
        }
    }
    
    @objc private func didToggleHapticsEnabled(_ sender: Any) {
        let beforeUpdate = UserConfiguration.isHapticsEnabled
        
        UserConfiguration.isHapticsEnabled = hapticsEnabledSwitch.isOn
        
        let body: JSONRequestBody = [Constant.Key.userConfigurationIsHapticsEnabled.rawValue: .bool(UserConfiguration.isHapticsEnabled)]
        
        UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                UserConfiguration.isHapticsEnabled = beforeUpdate
                self.hapticsEnabledSwitch.setOn(beforeUpdate, animated: true)
                return
            }
        }
    }
    
    @objc private func didToggleUsesDeviceTimeZone(_ sender: Any) {
        let newUses = usesDeviceTimeZoneSwitch.isOn
        let beforeUpdateUses = UserConfiguration.usesDeviceTimeZone
        
        let newTz = usesDeviceTimeZoneSwitch.isOn ? (UserConfiguration.userTimeZone ?? UserConfiguration.timeZone) : UserConfiguration.userTimeZone
        let beforeUpdateTz = UserConfiguration.userTimeZone
        
        UserConfiguration.usesDeviceTimeZone = newUses
        // if setting usesDeviceTimeZone to true, then we need a userTimeZone
        UserConfiguration.userTimeZone = newTz
        synchronizeTimeZoneUI(animated: true)
        
        let body: JSONRequestBody = [
            Constant.Key.userConfigurationUsesDeviceTimeZone.rawValue: .bool(newUses),
            Constant.Key.userConfigurationUserTimeZone.rawValue: .string(newTz?.identifier)
        ]
        
        UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                UserConfiguration.usesDeviceTimeZone = beforeUpdateUses
                UserConfiguration.userTimeZone = beforeUpdateTz
                self.synchronizeTimeZoneUI(animated: true)
                return
            }
        }
    }
    
    // MARK: - Main
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .pageSheet
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        
        self.synchronizeTimeZoneUI(animated: false)
    }
    
    // MARK: - Functions
    
    private func synchronizeTimeZoneUI(animated: Bool) {
        timeZoneLabel.isEnabled = !UserConfiguration.usesDeviceTimeZone
        // use UserConfiguration.timeZone b/c if no UserConfiguration.userTimeZone, then this defaults to current TZ
        // don't provide currentTimeZone because that adds on (current) to the end
        timeZoneLabel.text = UserConfiguration.timeZone.displayName(currentTimeZone: nil)
        usesDeviceTimeZoneSwitch.setOn(UserConfiguration.usesDeviceTimeZone, animated: animated)
    }
    
    // MARK: - HoundDropDownManagerDelegate
    
    @objc func didTapScreen(sender: UITapGestureRecognizer) {
        dropDownManager.hideDropDownIfNotTapped(sender: sender)
    }
    
    func willShowDropDown(_ identifier: any HoundDropDownType, animated: Bool) {
        guard let type = identifier as? SettingsAppearanceDropDownTypes else { return }
        switch type {
        case .timeZone:
            dropDownManager.show(identifier: .timeZone, numberOfRowsToShow: min(6.5, CGFloat(TimeZone.houndTimeZones.count)), animated: animated)
        }
    }
    
    // MARK: - HoundDropDownDataSource
    
    func setupCellForDropDown(cell: HoundDropDownTVC, indexPath: IndexPath, identifier: any HoundDropDownType) {
        guard let type = identifier as? SettingsAppearanceDropDownTypes else { return }
        switch type {
        case .timeZone:
            let tz = TimeZone.houndTimeZones[indexPath.row]
            // we only want to show (current) if the cell's tz genuinely matches the current device tz (not just the selected one)
            cell.label.text = tz.displayName(currentTimeZone: TimeZone.current)
            // use UserConfiguration.timeZone b/c if no UserConfiguration.userTimeZone, then this defaults to current TZ
            cell.setCustomSelected(tz == UserConfiguration.timeZone, animated: false)
        }
    }
    
    func numberOfRows(forSection: Int, identifier: any HoundDropDownType) -> Int {
        guard let type = identifier as? SettingsAppearanceDropDownTypes else { return 0 }
        switch type {
        case .timeZone:
            return TimeZone.houndTimeZones.count
        }
    }
    
    func numberOfSections(identifier: any HoundDropDownType) -> Int {
        1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, identifier: any HoundDropDownType) {
        guard let type = identifier as? SettingsAppearanceDropDownTypes else { return }
        guard let dropDown = dropDownManager.dropDown(for: type), let cell = dropDown.dropDownTableView?.cellForRow(at: indexPath) as? HoundDropDownTVC else { return }
        switch type {
        case .timeZone:
            if let prevTz = UserConfiguration.userTimeZone,
               let prevIndex = TimeZone.houndTimeZones.firstIndex(where: { $0.identifier == prevTz.identifier }),
               prevIndex != indexPath.row {
                let prevIndexPath = IndexPath(row: prevIndex, section: 0)
                if let prevCell = dropDown.dropDownTableView?.cellForRow(at: prevIndexPath) as? HoundDropDownTVC {
                    prevCell.setCustomSelected(false)
                }
            }
            
            let beforeUpdateTz = UserConfiguration.userTimeZone
            
            let newTz = TimeZone.houndTimeZones[indexPath.row]
            cell.setCustomSelected(true)
            UserConfiguration.userTimeZone = newTz
            // set currentTimeZone to nil so it doesn't append (current) to the end
            timeZoneLabel.text = newTz.displayName(currentTimeZone: nil)
            dropDown.hideDropDown(animated: true)
            
            let body: JSONRequestBody = [
                Constant.Key.userConfigurationUserTimeZone.rawValue: .string(newTz.identifier)
            ]
            
            UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
                guard responseStatus != .failureResponse else {
                    UserConfiguration.userTimeZone = beforeUpdateTz
                    self.synchronizeTimeZoneUI(animated: true)
                    return
                }
            }
        }
    }
    
    func firstSelectedIndexPath(identifier: any HoundDropDownType) -> IndexPath? {
            guard let type = identifier as? SettingsAppearanceDropDownTypes else { return nil }
            switch type {
            case .timeZone:
                let tz = UserConfiguration.timeZone
                if let idx = TimeZone.houndTimeZones.firstIndex(of: tz) {
                    return IndexPath(row: idx, section: 0)
                }
            }
            return nil
        }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        containerView.addSubview(pageHeader)
        containerView.addSubview(interfaceStyleSegmentedControl)
        containerView.addSubview(interfaceStyleHeaderLabel)
        containerView.addSubview(measurementHeaderLabel)
        containerView.addSubview(measurementSystemSegmentedControl)
        containerView.addSubview(usesDeviceTimeZoneHeaderLabel)
        containerView.addSubview(usesDeviceTimeZoneSwitch)
        containerView.addSubview(timeZoneLabel)
        containerView.addSubview(hapticsHeaderLabel)
        containerView.addSubview(hapticsEnabledSwitch)
        
        let didTapScreenGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(didTapScreen(sender:))
        )
        didTapScreenGesture.delegate = self
        didTapScreenGesture.cancelsTouchesInView = false
        containerView.addGestureRecognizer(didTapScreenGesture)
        
        interfaceStyleSegmentedControl.addTarget(self, action: #selector(didUpdateInterfaceStyle), for: .valueChanged)
        measurementSystemSegmentedControl.addTarget(self, action: #selector(didUpdateMeasurementSystem), for: .valueChanged)
        hapticsEnabledSwitch.addTarget(self, action: #selector(didToggleHapticsEnabled), for: .valueChanged)
        usesDeviceTimeZoneSwitch.addTarget(self, action: #selector(didToggleUsesDeviceTimeZone), for: .valueChanged)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // pageHeader
        NSLayoutConstraint.activate([
            pageHeader.topAnchor.constraint(equalTo: containerView.topAnchor),
            pageHeader.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageHeader.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // interfaceStyleHeaderLabel
        NSLayoutConstraint.activate([
            interfaceStyleHeaderLabel.topAnchor.constraint(equalTo: pageHeader.bottomAnchor, constant: Constant.Constraint.Spacing.contentTallIntraVert),
            interfaceStyleHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            interfaceStyleHeaderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])
        
        // interfaceStyleSegmentedControl
        NSLayoutConstraint.activate([
            interfaceStyleSegmentedControl.topAnchor.constraint(equalTo: interfaceStyleHeaderLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            interfaceStyleSegmentedControl.leadingAnchor.constraint(equalTo: interfaceStyleHeaderLabel.leadingAnchor),
            interfaceStyleSegmentedControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            interfaceStyleSegmentedControl.createHeightMultiplier(Constant.Constraint.Input.segmentedHeightMultiplier, relativeToWidthOf: view),
            interfaceStyleSegmentedControl.createMaxHeight(Constant.Constraint.Input.segmentedMaxHeight)
        ])
        
        // measurementHeaderLabel
        NSLayoutConstraint.activate([
            measurementHeaderLabel.topAnchor.constraint(equalTo: interfaceStyleSegmentedControl.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            measurementHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            measurementHeaderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset)
        ])
        
        // measurementSystemSegmentedControl
        NSLayoutConstraint.activate([
            measurementSystemSegmentedControl.topAnchor.constraint(equalTo: measurementHeaderLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentIntraVert),
            measurementSystemSegmentedControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            measurementSystemSegmentedControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            measurementSystemSegmentedControl.createHeightMultiplier(Constant.Constraint.Input.segmentedHeightMultiplier, relativeToWidthOf: view),
            measurementSystemSegmentedControl.createMaxHeight(Constant.Constraint.Input.segmentedMaxHeight)
        ])
        
        // usesDeviceTimeZoneHeaderLabel
        NSLayoutConstraint.activate([
            usesDeviceTimeZoneHeaderLabel.topAnchor.constraint(equalTo: measurementSystemSegmentedControl.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            usesDeviceTimeZoneHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset)
        ])
        
        // usesDeviceTimeZoneSwitch
        NSLayoutConstraint.activate([
            usesDeviceTimeZoneSwitch.centerYAnchor.constraint(equalTo: usesDeviceTimeZoneHeaderLabel.centerYAnchor),
            usesDeviceTimeZoneSwitch.leadingAnchor.constraint(equalTo: usesDeviceTimeZoneHeaderLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentIntraHori),
            usesDeviceTimeZoneSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset * 2.0)
        ])
        
        // timeZoneLabel
        NSLayoutConstraint.activate([
            timeZoneLabel.topAnchor.constraint(equalTo: usesDeviceTimeZoneHeaderLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentTallIntraVert),
            timeZoneLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset),
            timeZoneLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset),
            timeZoneLabel.createHeightMultiplier(Constant.Constraint.Input.textFieldHeightMultiplier, relativeToWidthOf: view),
            timeZoneLabel.createMaxHeight(Constant.Constraint.Input.textFieldMaxHeight)
        ])
        
        // hapticsHeaderLabel
        NSLayoutConstraint.activate([
            hapticsHeaderLabel.topAnchor.constraint(equalTo: timeZoneLabel.bottomAnchor, constant: Constant.Constraint.Spacing.contentSectionVert),
            // TEMP extra spacing for timeZoneLabel dropdown
            hapticsHeaderLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -250.0),
            hapticsHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Constant.Constraint.Spacing.absoluteHoriInset)
        ])
        
        // hapticsEnabledSwitch
        NSLayoutConstraint.activate([
            hapticsEnabledSwitch.centerYAnchor.constraint(equalTo: hapticsHeaderLabel.centerYAnchor),
            hapticsEnabledSwitch.leadingAnchor.constraint(equalTo: hapticsHeaderLabel.trailingAnchor, constant: Constant.Constraint.Spacing.contentIntraHori),
            hapticsEnabledSwitch.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Constant.Constraint.Spacing.absoluteHoriInset * 2.0)
        ])
    }
    
}
