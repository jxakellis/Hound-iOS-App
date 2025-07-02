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

final class SettingsAppearanceVC: GeneralUIViewController {
    
    // MARK: - Elements
    
    private let scrollView: GeneralUIScrollView = {
        let scrollView = GeneralUIScrollView()
        scrollView.onlyBounceIfBigger()
        return scrollView
    }()
    
    private let containerView: GeneralUIView = {
        let view = GeneralUIView()
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let pageHeader: PageSheetHeaderView = {
        let view = PageSheetHeaderView(huggingPriority: 360, compressionResistancePriority: 360)
        view.pageHeaderLabel.text = "Appearance"
        return view
    }()
    
    private let interfaceStyleHeaderLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Theme"
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private let interfaceStyleSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.contentMode = .scaleToFill
        segmentedControl.contentHorizontalAlignment = .left
        segmentedControl.contentVerticalAlignment = .top
        segmentedControl.apportionsSegmentWidthsByContent = true
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentTintColor = .systemBlue
        
        InterfaceStyleOption.allCases.enumerated().forEach { index, option in
            segmentedControl.insertSegment(withTitle: option.title, at: index, animated: false)
        }
        
        return segmentedControl
    }()
    
    private let measurementHeaderLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Measurement System"
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        return label
    }()
    
    private let measurementSystemSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.contentMode = .scaleToFill
        segmentedControl.contentHorizontalAlignment = .center
        segmentedControl.contentVerticalAlignment = .top
        segmentedControl.apportionsSegmentWidthsByContent = true
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentTintColor = .systemBlue
        
        MeasurementSystem.allCases.enumerated().forEach { index, ms in
            segmentedControl.insertSegment(withTitle: ms.readableMeasurementSystem(), at: index, animated: false)
        }
        
        return segmentedControl
    }()
    
    @objc private func didUpdateInterfaceStyle(_ sender: Any) {
        guard let sender = sender as? UISegmentedControl else {
            return
        }
        
        /// Assumes the segmented control is configured for interfaceStyle selection (0: light, 1: dark, 2: unspecified). Using the selectedSegmentIndex, queries the server to update the interfaceStyle UserConfiguration. If successful, then changes UI to new interface style and saves new UserConfiguration value. If unsuccessful, reverts the selectedSegmentIndex to the position before the change, doesn't change the UI interface style, and doesn't save the new UserConfiguration value
        
        let selectedOption = InterfaceStyleOption.from(index: sender.selectedSegmentIndex)
        let beforeUpdateInterfaceStyle = UserConfiguration.interfaceStyle
        
        UserConfiguration.interfaceStyle = selectedOption.userInterfaceStyle
        
        let body = [KeyConstant.userConfigurationInterfaceStyle.rawValue: selectedOption.userInterfaceStyle.rawValue]
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
        guard let sender = sender as? UISegmentedControl else {
            return
        }
        
        /// Assumes the segmented control is configured for measurementSystem selection (0: imperial, 1: metric, 2: both).
        let beforeUpdateMeasurementSystem = UserConfiguration.measurementSystem
        
        UserConfiguration.measurementSystem = MeasurementSystem(rawValue: sender.selectedSegmentIndex) ?? UserConfiguration.measurementSystem
        
        let body = [KeyConstant.userConfigurationMeasurementSystem.rawValue: sender.selectedSegmentIndex]
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
        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: VisualConstant.FontConstant.primaryRegularLabel.pointSize, weight: .bold), .foregroundColor: UIColor.systemBackground]
        let backgroundColor = UIColor.systemGray4
        
        // Dark Mode
        interfaceStyleSegmentedControl.setTitleTextAttributes(attributes, for: .normal)
        interfaceStyleSegmentedControl.backgroundColor = backgroundColor
        interfaceStyleSegmentedControl.selectedSegmentIndex = InterfaceStyleOption.index(for: UserConfiguration.interfaceStyle)
        
        measurementSystemSegmentedControl.setTitleTextAttributes(attributes, for: .normal)
        measurementSystemSegmentedControl.backgroundColor = backgroundColor
        measurementSystemSegmentedControl.selectedSegmentIndex = UserConfiguration.measurementSystem.rawValue
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
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
        
        // scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // containerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // pageHeader
        NSLayoutConstraint.activate([
            pageHeader.topAnchor.constraint(equalTo: containerView.topAnchor),
            pageHeader.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageHeader.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
        
        // interfaceStyleHeaderLabel
        NSLayoutConstraint.activate([
            interfaceStyleHeaderLabel.topAnchor.constraint(equalTo: pageHeader.bottomAnchor, constant: ConstraintConstant.Spacing.headerVertSpacingToSection),
            interfaceStyleHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            interfaceStyleHeaderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset)
        ])
        
        // interfaceStyleSegmentedControl
        NSLayoutConstraint.activate([
            interfaceStyleSegmentedControl.topAnchor.constraint(equalTo: interfaceStyleHeaderLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVertSpacing),
            interfaceStyleSegmentedControl.leadingAnchor.constraint(equalTo: interfaceStyleHeaderLabel.leadingAnchor),
            interfaceStyleSegmentedControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset),
            interfaceStyleSegmentedControl.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: ConstraintConstant.Input.segmentedHeightMultiplier).withPriority(.defaultHigh),
            interfaceStyleSegmentedControl.createMaxHeight( ConstraintConstant.Input.segmentedMaxHeight)
        ])
        
        // measurementHeaderLabel
        NSLayoutConstraint.activate([
            measurementHeaderLabel.topAnchor.constraint(equalTo: interfaceStyleSegmentedControl.bottomAnchor, constant: ConstraintConstant.Spacing.sectionInterVertSpacing),
            measurementHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            measurementHeaderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset)
        ])
        
        // measurementSystemSegmentedControl
        NSLayoutConstraint.activate([
            measurementSystemSegmentedControl.topAnchor.constraint(equalTo: measurementHeaderLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentIntraVertSpacing),
            measurementSystemSegmentedControl.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            measurementSystemSegmentedControl.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset),
            measurementSystemSegmentedControl.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: ConstraintConstant.Input.segmentedHeightMultiplier).withPriority(.defaultHigh),
            measurementSystemSegmentedControl.createMaxHeight( ConstraintConstant.Input.segmentedMaxHeight),
            measurementSystemSegmentedControl.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Spacing.contentAbsVertInset)
        ])
    }
    
}
