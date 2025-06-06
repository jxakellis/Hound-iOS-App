//
//  RemindersIntroductionViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/6/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol RemindersIntroductionViewControllerDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager dogManager: DogManager)
}

final class RemindersIntroductionViewController: GeneralUIViewController {
    
    // MARK: - IB
    
    private let whiteBackgroundView: UIView = {
        let view = UIView()
        view.contentMode = .scaleToFill
        view.setContentHuggingPriority(UILayoutPriority(285), for: .horizontal)
        view.setContentHuggingPriority(UILayoutPriority(285), for: .vertical)
        view.setContentCompressionResistancePriority(UILayoutPriority(785), for: .horizontal)
        view.setContentCompressionResistancePriority(UILayoutPriority(785), for: .vertical)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        
        view.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    
    private let setUpRemindersButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 270, compressionResistancePriority: 770)

        button.backgroundColor = .systemBlue
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        button.setTitle("Set Up Reminders", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabelTextColor = .systemBackground
        button.buttonBackgroundColor = .systemBlue
        button.borderColor = .clear
        button.borderWidth = 0.0
        button.shouldRoundCorners = true
        return button
    }()
    
    @objc private func didTouchUpInsideSetUpReminders(_ sender: Any) {
        setUpRemindersButton.isEnabled = false
        maybeLaterButton.isEnabled = false
        
        NotificationPermissionsManager.requestNotificationAuthorization(shouldAdviseUserBeforeRequestingNotifications: true) {
            // Verify that the user is still eligible for default reminders
            guard self.dogManager.hasCreatedReminder == false, let dog = self.dogManager.dogs.first else {
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            // We are able to add the user's default reminders
            let reminders = ClassConstant.ReminderConstant.defaultReminders
            PresentationManager.beginFetchingInformationIndicator()
            RemindersRequest.create(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dog.dogUUID, forReminders: reminders) { responseStatus, _ in
                PresentationManager.endFetchingInformationIndicator {
                    guard responseStatus != .failureResponse else {
                        // Something failed, re-enable the buttons so they can try again
                        self.setUpRemindersButton.isEnabled = true
                        self.maybeLaterButton.isEnabled = true
                        return
                    }
                    
                    dog.dogReminders.addReminders(forReminders: reminders)
                    self.delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    private let maybeLaterButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.setContentHuggingPriority(UILayoutPriority(260), for: .horizontal)
        button.setContentHuggingPriority(UILayoutPriority(260), for: .vertical)
        button.setContentCompressionResistancePriority(UILayoutPriority(760), for: .horizontal)
        button.setContentCompressionResistancePriority(UILayoutPriority(760), for: .vertical)
        
        
        button.backgroundColor = .systemBackground
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        button.setTitle("Maybe Later", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabelTextColor = .label
        button.buttonBackgroundColor = .systemBackground
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        return button
    }()
    
    // MARK: - Additional UI Elements
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(UILayoutPriority(290), for: .horizontal)
        imageView.setContentHuggingPriority(UILayoutPriority(290), for: .vertical)
        imageView.setContentCompressionResistancePriority(UILayoutPriority(790), for: .horizontal)
        imageView.setContentCompressionResistancePriority(UILayoutPriority(790), for: .vertical)
        imageView.image = UIImage(named: "creamBackyardCoupleTeachingDogTrick")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let reminderLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(280), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(280), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(780), for: .vertical)
        label.text = "Reminders"
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        return label
    }()
    
    private let reminderDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(275), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(275), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(775), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(775), for: .vertical)
        label.text = "We'll create reminders that are useful for most dogs. Do you want to use them?"
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    @objc private func didTouchUpInsideMaybeLater(_ sender: Any) {
        setUpRemindersButton.isEnabled = false
        maybeLaterButton.isEnabled = false
        
        NotificationPermissionsManager.requestNotificationAuthorization(shouldAdviseUserBeforeRequestingNotifications: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Properties
    
    private weak var delegate: RemindersIntroductionViewControllerDelegate!
    
    // MARK: - Dog Manager
    
    private var dogManager = DogManager()
    
    // MARK: - Main
    
    override func viewDidLoad() {
        setupGeneratedViews()
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocalConfiguration.localHasCompletedRemindersIntroductionViewController = true
    }
    
    // MARK: - Functions
    
    func setup(forDelegate: RemindersIntroductionViewControllerDelegate, forDogManager: DogManager) {
        self.delegate = forDelegate
        self.dogManager = forDogManager
    }
    
}

extension RemindersIntroductionViewController {
    private func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        addSubViews()
        setupConstraints()
    }
    
    private func addSubViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(whiteBackgroundView)
        view.addSubview(reminderLabel)
        view.addSubview(reminderDescriptionLabel)
        view.addSubview(setUpRemindersButton)
        setUpRemindersButton.addTarget(self, action: #selector(didTouchUpInsideSetUpReminders), for: .touchUpInside)
        view.addSubview(maybeLaterButton)
        maybeLaterButton.addTarget(self, action: #selector(didTouchUpInsideMaybeLater), for: .touchUpInside)
        
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.widthAnchor.constraint(equalTo: backgroundImageView.heightAnchor, multiplier: 1/1),
            
            reminderLabel.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 25),
            reminderLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            reminderLabel.trailingAnchor.constraint(equalTo: reminderDescriptionLabel.trailingAnchor),
            reminderLabel.trailingAnchor.constraint(equalTo: setUpRemindersButton.trailingAnchor),
            reminderLabel.trailingAnchor.constraint(equalTo: maybeLaterButton.trailingAnchor),
            reminderLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            reminderLabel.heightAnchor.constraint(equalToConstant: 30),
            
            reminderDescriptionLabel.topAnchor.constraint(equalTo: reminderLabel.bottomAnchor, constant: 7.5),
            reminderDescriptionLabel.leadingAnchor.constraint(equalTo: reminderLabel.leadingAnchor),
            reminderDescriptionLabel.heightAnchor.constraint(equalToConstant: 20),
            
            setUpRemindersButton.topAnchor.constraint(equalTo: reminderDescriptionLabel.bottomAnchor, constant: 15),
            setUpRemindersButton.leadingAnchor.constraint(equalTo: reminderLabel.leadingAnchor),
            setUpRemindersButton.widthAnchor.constraint(equalTo: setUpRemindersButton.heightAnchor, multiplier: 1/0.16),
            
            maybeLaterButton.topAnchor.constraint(equalTo: setUpRemindersButton.bottomAnchor, constant: 45),
            maybeLaterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            maybeLaterButton.leadingAnchor.constraint(equalTo: reminderLabel.leadingAnchor),
            maybeLaterButton.widthAnchor.constraint(equalTo: maybeLaterButton.heightAnchor, multiplier: 1/0.16),
            maybeLaterButton.heightAnchor.constraint(equalTo: setUpRemindersButton.heightAnchor),
            
            whiteBackgroundView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -25),
            whiteBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            whiteBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            whiteBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
        ])
        
    }
}
