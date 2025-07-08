//
//  RemindersIntroductionVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/6/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol RemindersIntroductionVCDelegate: AnyObject {
    func didUpdateDogManager(sender: Sender, forDogManager dogManager: DogManager)
}

final class RemindersIntroductionVC: HoundViewController {
    
    // MARK: - Elements

    private let introductionView = HoundIntroductionView()

    private lazy var setUpRemindersButton: HoundButton = {
        let button = HoundButton(huggingPriority: 270, compressionResistancePriority: 270)

        button.setTitle("Set Up Reminders", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        button.backgroundColor = UIColor.systemBlue
        button.shouldRoundCorners = true
        button.addTarget(self, action: #selector(didTouchUpInsideSetUpReminders), for: .touchUpInside)

        return button
    }()

    private lazy var maybeLaterButton: HoundButton = {
        let button = HoundButton(huggingPriority: 260, compressionResistancePriority: 260)

        button.setTitle("Maybe Later", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        button.backgroundColor = UIColor.systemBackground
        button.applyStyle(.labelBorder)
        button.addTarget(self, action: #selector(didTouchUpInsideMaybeLater), for: .touchUpInside)

        return button
    }()

    /// Stack view containing the two buttons
    private var buttonStack: UIStackView!

    // MARK: - Properties

    private weak var delegate: RemindersIntroductionVCDelegate?
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

        introductionView.backgroundImageView.image = UIImage(named: "creamBackyardCoupleTeachingDogTrick")
        introductionView.pageHeaderLabel.text = "Reminders"
        introductionView.pageDescriptionLabel.text = "We'll create reminders that are useful for most dogs. Do you want to use them?"
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        LocalConfiguration.localHasCompletedRemindersIntroductionViewController = true
    }

    // MARK: - Setup

    func setup(forDelegate: RemindersIntroductionVCDelegate, forDogManager: DogManager) {
        self.delegate = forDelegate
        self.dogManager = forDogManager
    }

    // MARK: - Functions

    @objc private func didTouchUpInsideSetUpReminders(_ sender: Any) {
        setUpRemindersButton.isEnabled = false
        maybeLaterButton.isEnabled = false

        NotificationPermissionsManager.requestNotificationAuthorization(shouldAdviseUserBeforeRequestingNotifications: true) {
            guard self.dogManager.hasCreatedReminder == false, let dog = self.dogManager.dogs.first else {
                self.dismiss(animated: true, completion: nil)
                return
            }

            let reminders = ClassConstant.ReminderConstant.defaultReminders
            PresentationManager.beginFetchingInformationIndicator()
            RemindersRequest.create(forErrorAlert: .automaticallyAlertOnlyForFailure, forDogUUID: dog.dogUUID, forReminders: reminders) { responseStatus, _ in
                PresentationManager.endFetchingInformationIndicator {
                    guard responseStatus != .failureResponse else {
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

    // MARK: - Setup Elements

    override func setupGeneratedViews() {
        view.backgroundColor = UIColor.systemBackground
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        view.addSubview(introductionView)

        buttonStack = UIStackView(arrangedSubviews: [setUpRemindersButton, maybeLaterButton])
        buttonStack.axis = .vertical
        buttonStack.spacing = ConstraintConstant.Spacing.contentSectionVert
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        introductionView.contentView.addSubview(buttonStack)
    }

    override func setupConstraints() {
        super.setupConstraints()

        NSLayoutConstraint.activate([
            introductionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            introductionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            introductionView.topAnchor.constraint(equalTo: view.topAnchor),
            introductionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            buttonStack.centerXAnchor.constraint(equalTo: introductionView.contentView.centerXAnchor),
            buttonStack.centerYAnchor.constraint(equalTo: introductionView.contentView.centerYAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: introductionView.contentView.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: introductionView.contentView.trailingAnchor),

            setUpRemindersButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: view),
            setUpRemindersButton.createMaxHeight(ConstraintConstant.Button.wideMaxHeight),

            maybeLaterButton.heightAnchor.constraint(equalTo: setUpRemindersButton.heightAnchor)
        ])
    }
}
