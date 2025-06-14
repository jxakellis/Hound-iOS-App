//
//  SettingsAppearanceViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class SettingsAppearanceViewController: GeneralUIViewController {
    
    // MARK: - Elements
    
    private let interfaceStyleSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.contentMode = .scaleToFill
        segmentedControl.contentHorizontalAlignment = .left
        segmentedControl.contentVerticalAlignment = .top
        segmentedControl.apportionsSegmentWidthsByContent = true
        segmentedControl.selectedSegmentIndex = 2
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentTintColor = .systemBlue
        
        return segmentedControl
    }()
    
    @objc private func didUpdateInterfaceStyle(_ sender: Any) {
        guard let sender = sender as? UISegmentedControl else {
            return
        }
        
        /// Assumes the segmented control is configured for interfaceStyle selection (0: light, 1: dark, 2: unspecified). Using the selectedSegmentIndex, queries the server to update the interfaceStyle UserConfiguration. If successful, then changes UI to new interface style and saves new UserConfiguration value. If unsuccessful, reverts the selectedSegmentIndex to the position before the change, doesn't change the UI interface style, and doesn't save the new UserConfiguration value
        
        let beforeUpdateInterfaceStyle = UserConfiguration.interfaceStyle
        let unconvertedNewInterfaceStyle = sender.selectedSegmentIndex
        let convertedNewInterfaceStyle = {
            switch unconvertedNewInterfaceStyle {
            case 0:
                return 1
            case 1:
                return 2
            default:
                return 0
            }
        }()
        
        UserConfiguration.interfaceStyle = UIUserInterfaceStyle(rawValue: convertedNewInterfaceStyle) ?? UserConfiguration.interfaceStyle
        
        let body = [KeyConstant.userConfigurationInterfaceStyle.rawValue: convertedNewInterfaceStyle]
        UserRequest.update(forErrorAlert: .automaticallyAlertOnlyForFailure, forBody: body) { responseStatus, _ in
            guard responseStatus != .failureResponse else {
                // Revert local values to previous state due to an error
                UserConfiguration.interfaceStyle = beforeUpdateInterfaceStyle
                
                sender.selectedSegmentIndex = {
                    switch UserConfiguration.interfaceStyle.rawValue {
                        // system/unspecified
                    case 0:
                        return 2
                        // light
                    case 1:
                        return 0
                        // dark
                    case 2:
                        return 1
                    default:
                        return 2
                    }
                }()
                return
            }
        }
    }
    
    private let measurementSystemSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.contentMode = .scaleToFill
        segmentedControl.contentHorizontalAlignment = .left
        segmentedControl.contentVerticalAlignment = .top
        segmentedControl.apportionsSegmentWidthsByContent = true
        segmentedControl.selectedSegmentIndex = 2
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentTintColor = .systemBlue
        
        return segmentedControl
    }()
    
    // MARK: - Additional UI Elements
    private let scrollView: GeneralUIScrollView = {
        let scrollView = GeneralUIScrollView()
        
        scrollView.bounces = false
        scrollView.bouncesZoom = false
        
        return scrollView
    }()
    
    private let containerView: GeneralUIView = {
        let view = GeneralUIView()
        
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let themeHeaderLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Theme"
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    private let backButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 360, compressionResistancePriority: 360)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.backgroundCircleTintColor = .systemBackground
        
        button.shouldDismissParentViewController = true
        return button
    }()
    
    private let appearanceHeaderLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Appearance"
        label.font = .systemFont(ofSize: 32.5)
        return label
    }()
    
    private let measurementHeaderLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.text = "Measurement System"
        label.font = .systemFont(ofSize: 20)
        return label
    }()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        modalPresentationStyle = .pageSheet
        
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 15, weight: .bold), .foregroundColor: UIColor.systemBackground]
        let backgroundColor = UIColor.systemGray4
        
        // Dark Mode
        interfaceStyleSegmentedControl.setTitleTextAttributes(attributes, for: .normal)
        interfaceStyleSegmentedControl.backgroundColor = backgroundColor
        interfaceStyleSegmentedControl.selectedSegmentIndex = {
            switch UserConfiguration.interfaceStyle.rawValue {
                // system/unspecified
            case 0:
                return 2
                // light
            case 1:
                return 0
                // dark
            case 2:
                return 1
            default:
                return 2
            }
        }()
        
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
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(interfaceStyleSegmentedControl)
        containerView.addSubview(themeHeaderLabel)
        containerView.addSubview(backButton)
        containerView.addSubview(appearanceHeaderLabel)
        containerView.addSubview(measurementHeaderLabel)
        containerView.addSubview(measurementSystemSegmentedControl)
        
        interfaceStyleSegmentedControl.addTarget(self, action: #selector(didUpdateInterfaceStyle), for: .valueChanged)
        measurementSystemSegmentedControl.addTarget(self, action: #selector(didUpdateMeasurementSystem), for: .valueChanged)
    }
    
    override func setupConstraints() {
        NSLayoutConstraint.activate([
            interfaceStyleSegmentedControl.topAnchor.constraint(equalTo: themeHeaderLabel.bottomAnchor, constant: 10),
            interfaceStyleSegmentedControl.leadingAnchor.constraint(equalTo: themeHeaderLabel.leadingAnchor),
            interfaceStyleSegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            backButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: appearanceHeaderLabel.trailingAnchor, constant: 10),
            backButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor),
            backButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 50 / 414),
            backButton.heightAnchor.constraint(lessThanOrEqualToConstant: 75),
            backButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 25),
            
            appearanceHeaderLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            appearanceHeaderLabel.leadingAnchor.constraint(equalTo: themeHeaderLabel.leadingAnchor),
            appearanceHeaderLabel.heightAnchor.constraint(equalToConstant: 40),
            
            measurementSystemSegmentedControl.topAnchor.constraint(equalTo: measurementHeaderLabel.bottomAnchor, constant: 10),
            measurementSystemSegmentedControl.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            measurementSystemSegmentedControl.leadingAnchor.constraint(equalTo: themeHeaderLabel.leadingAnchor),
            measurementSystemSegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            
            themeHeaderLabel.topAnchor.constraint(equalTo: appearanceHeaderLabel.bottomAnchor, constant: 20),
            themeHeaderLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            themeHeaderLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            themeHeaderLabel.trailingAnchor.constraint(equalTo: interfaceStyleSegmentedControl.trailingAnchor),
            themeHeaderLabel.trailingAnchor.constraint(equalTo: measurementSystemSegmentedControl.trailingAnchor),
            themeHeaderLabel.trailingAnchor.constraint(equalTo: measurementHeaderLabel.trailingAnchor),
            
            measurementHeaderLabel.topAnchor.constraint(equalTo: interfaceStyleSegmentedControl.bottomAnchor, constant: 45),
            measurementHeaderLabel.leadingAnchor.constraint(equalTo: themeHeaderLabel.leadingAnchor),
            
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            
        ])
        
    }
}
