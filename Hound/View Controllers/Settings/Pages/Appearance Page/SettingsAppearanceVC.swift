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

final class SettingsAppearanceVC: HoundScrollViewController {
    
    // MARK: - Elements
    
    private let pageHeader: HoundPageSheetHeaderView = {
        let view = HoundPageSheetHeaderView(huggingPriority: 360, compressionResistancePriority: 360)
        view.pageHeaderLabel.text = "Appearance"
        return view
    }()
    
    private let interfaceStyleHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Theme"
        label.font = Constant.VisualFont.secondaryHeaderLabel
        return label
    }()
    
    private let interfaceStyleSegmentedControl: HoundSegmentedControl = {
        let segmentedControl = HoundSegmentedControl()
        segmentedControl.selectedSegmentTintColor = UIColor.systemBlue
        
        InterfaceStyleOption.allCases.enumerated().forEach { index, option in
            segmentedControl.insertSegment(withTitle: option.title, at: index, animated: false)
        }
        
        let attributes: [NSAttributedString.Key: Any] = [.font: Constant.VisualFont.emphasizedPrimaryRegularLabel, .foregroundColor: UIColor.systemBackground]
        
        segmentedControl.setTitleTextAttributes(attributes, for: .normal)
        segmentedControl.backgroundColor = UIColor.systemGray4
        segmentedControl.selectedSegmentIndex = InterfaceStyleOption.index(for: UserConfiguration.interfaceStyle)
        
        return segmentedControl
    }()
    
    private let measurementHeaderLabel: HoundLabel = {
        let label = HoundLabel()
        label.text = "Measurement System"
        label.font = Constant.VisualFont.secondaryHeaderLabel
        return label
    }()
    
    private let measurementSystemSegmentedControl: HoundSegmentedControl = {
        let segmentedControl = HoundSegmentedControl()
        segmentedControl.selectedSegmentTintColor = UIColor.systemBlue
        
        MeasurementSystem.allCases.enumerated().forEach { index, ms in
            segmentedControl.insertSegment(withTitle: ms.readableMeasurementSystem(), at: index, animated: false)
        }
        
        let attributes: [NSAttributedString.Key: Any] = [.font: Constant.VisualFont.emphasizedPrimaryRegularLabel, .foregroundColor: UIColor.systemBackground]
        
        segmentedControl.setTitleTextAttributes(attributes, for: .normal)
        segmentedControl.backgroundColor = UIColor.systemGray4
        segmentedControl.selectedSegmentIndex = UserConfiguration.measurementSystem.rawValue
        
        return segmentedControl
    }()
    
    @objc private func didUpdateInterfaceStyle(_ sender: Any) {
        guard let sender = sender as? UISegmentedControl else { return }
        
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
        guard let sender = sender as? UISegmentedControl else { return }
        
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
        
        interfaceStyleSegmentedControl.addTarget(self, action: #selector(didUpdateInterfaceStyle), for: .valueChanged)
        measurementSystemSegmentedControl.addTarget(self, action: #selector(didUpdateMeasurementSystem), for: .valueChanged)
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
            measurementSystemSegmentedControl.createMaxHeight(Constant.Constraint.Input.segmentedMaxHeight),
            measurementSystemSegmentedControl.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Constant.Constraint.Spacing.absoluteVertInset)
        ])
    }
    
}
