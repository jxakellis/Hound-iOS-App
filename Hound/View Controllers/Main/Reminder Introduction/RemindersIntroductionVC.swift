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
    
    // MARK: - Elements
    
    private let backgroundImageView: GeneralUIImageView = {
        let imageView = GeneralUIImageView(huggingPriority: 290, compressionResistancePriority: 290)

        imageView.image = UIImage(named: "creamBackyardCoupleTeachingDogTrick")
        
        return imageView
    }()
    
    private let whiteBackgroundView: GeneralUIView = {
        let view = GeneralUIView(huggingPriority: 285, compressionResistancePriority: 285)
        view.backgroundColor = .systemBackground
        
        view.layer.cornerRadius = VisualConstant.LayerConstant.imageCoveringViewCornerRadius
        view.layer.cornerCurve = .continuous
        return view
    }()
    
    private let reminderLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 280, compressionResistancePriority: 280)
        label.text = "Reminders"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 25, weight: .semibold)
        return label
    }()
    
    private let reminderDescriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 275, compressionResistancePriority: 275)
        label.text = "We'll create reminders that are useful for most dogs. Do you want to use them?"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let maybeLaterButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 260, compressionResistancePriority: 260)
        
        button.setTitle("Maybe Later", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        
        return button
    }()
    
    private let setUpRemindersButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 270, compressionResistancePriority: 270)

        button.setTitle("Set Up Reminders", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBlue
        
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
                    self.delegate?.didUpdateDogManager(sender: Sender(origin: self, localized: self), forDogManager: self.dogManager)
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    @objc private func didTouchUpInsideMaybeLater(_ sender: Any) {
        setUpRemindersButton.isEnabled = false
        maybeLaterButton.isEnabled = false
        
        NotificationPermissionsManager.requestNotificationAuthorization(shouldAdviseUserBeforeRequestingNotifications: true) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Properties
    
    private weak var delegate: RemindersIntroductionViewControllerDelegate?
    
    // MARK: - Dog Manager
    
    private var dogManager = DogManager()
    
    // MARK: - Main
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocalConfiguration.localHasCompletedRemindersIntroductionViewController = true
    }
    
    // MARK: - Setup
    
    func setup(forDelegate: RemindersIntroductionViewControllerDelegate, forDogManager: DogManager) {
        self.delegate = forDelegate
        self.dogManager = forDogManager
    }
    
    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBackground
        
        super.setupGeneratedViews()
    }
    
    override func addSubViews() {
        super.addSubViews()
        view.addSubview(backgroundImageView)
        view.addSubview(whiteBackgroundView)
        view.addSubview(reminderLabel)
        view.addSubview(reminderDescriptionLabel)
        view.addSubview(setUpRemindersButton)
        setUpRemindersButton.addTarget(self, action: #selector(didTouchUpInsideSetUpReminders), for: .touchUpInside)
        view.addSubview(maybeLaterButton)
        maybeLaterButton.addTarget(self, action: #selector(didTouchUpInsideMaybeLater), for: .touchUpInside)
        
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // TODO UIKIT buttons r broken

        // backgroundImageView
        let backgroundImageViewTop = backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor)
        let backgroundImageViewLeading = backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let backgroundImageViewTrailing = backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let backgroundImageViewWidth = backgroundImageView.widthAnchor.constraint(equalTo: backgroundImageView.heightAnchor)
        
        // whiteBackgroundView
        let whiteBackgroundViewTop = whiteBackgroundView.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -25)
        let whiteBackgroundViewBottom = whiteBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let whiteBackgroundViewLeading = whiteBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let whiteBackgroundViewTrailing = whiteBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        
        // reminderLabel
        let reminderLabelTop = reminderLabel.topAnchor.constraint(equalTo: whiteBackgroundView.topAnchor, constant: 25)
        let reminderLabelLeading = reminderLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20)
        let reminderLabelTrailing = reminderLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
        let reminderLabelHeight = reminderLabel.heightAnchor.constraint(equalToConstant: 30)
        
        // reminderDescriptionLabel
        let reminderDescriptionLabelTop = reminderDescriptionLabel.topAnchor.constraint(equalTo: reminderLabel.bottomAnchor, constant: 7.5)
        let reminderDescriptionLabelLeading = reminderDescriptionLabel.leadingAnchor.constraint(equalTo: reminderLabel.leadingAnchor)
        let reminderDescriptionLabelTrailing = reminderDescriptionLabel.trailingAnchor.constraint(equalTo: reminderLabel.trailingAnchor)
        
        // setUpRemindersButton
        let setUpRemindersButtonTop = setUpRemindersButton.topAnchor.constraint(equalTo: reminderDescriptionLabel.bottomAnchor, constant: 15)
        let setUpRemindersButtonLeading = setUpRemindersButton.leadingAnchor.constraint(equalTo: reminderLabel.leadingAnchor)
        let setUpRemindersButtonWidth = setUpRemindersButton.widthAnchor.constraint(equalTo: setUpRemindersButton.heightAnchor, multiplier: 1 / 0.16)
        
        // maybeLaterButton
        let maybeLaterButtonTop = maybeLaterButton.topAnchor.constraint(equalTo: setUpRemindersButton.bottomAnchor, constant: 45)
        let maybeLaterButtonBottom = maybeLaterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15)
        let maybeLaterButtonLeading = maybeLaterButton.leadingAnchor.constraint(equalTo: reminderLabel.leadingAnchor)
        let maybeLaterButtonWidth = maybeLaterButton.widthAnchor.constraint(equalTo: maybeLaterButton.heightAnchor, multiplier: 1 / 0.16)
        let maybeLaterButtonHeight = maybeLaterButton.heightAnchor.constraint(equalTo: setUpRemindersButton.heightAnchor)
        
        NSLayoutConstraint.activate([
            // backgroundImageView
            backgroundImageViewTop,
            backgroundImageViewLeading,
            backgroundImageViewTrailing,
            backgroundImageViewWidth,
            
            // whiteBackgroundView
            whiteBackgroundViewTop,
            whiteBackgroundViewBottom,
            whiteBackgroundViewLeading,
            whiteBackgroundViewTrailing,
            
            // reminderLabel
            reminderLabelTop,
            reminderLabelLeading,
            reminderLabelTrailing,
            reminderLabelHeight,
            
            // reminderDescriptionLabel
            reminderDescriptionLabelTop,
            reminderDescriptionLabelLeading,
            reminderDescriptionLabelTrailing,
            
            // setUpRemindersButton
            setUpRemindersButtonTop,
            setUpRemindersButtonLeading,
            setUpRemindersButtonWidth,
            
            // maybeLaterButton
            maybeLaterButtonTop,
            maybeLaterButtonBottom,
            maybeLaterButtonLeading,
            maybeLaterButtonWidth,
            maybeLaterButtonHeight
        ])
    }

}
