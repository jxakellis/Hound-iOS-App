//
//  SurveyFeedbackAppExperienceViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/4/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SurveyFeedbackAppExperienceViewController: GeneralUIViewController, UITextViewDelegate {
    
    // MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Don't allow the user to add a new line. If they do, we interpret that as the user hitting the done button.
        guard text != "\n" else {
            self.dismissKeyboard()
            return false
        }
        
        // get the current text, or use an empty string if that failed
        let currentText = textView.text ?? ""
        
        // attempt to read the range they are trying to change, or exit if we can't
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        // add their new text to the existing text
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        // make sure the result is under logNoteCharacterLimit
        return updatedText.count <= ClassConstant.FeedbackConstant.appExperienceSuggestionCharacterLimit
    }
    
    // MARK: - Elements
    
    private weak var oneStarTrailingConstraint: NSLayoutConstraint!
    private let oneStarButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 280, compressionResistancePriority: 280)
        
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .systemBackground
        
        return button
    }()
    
    private weak var twoStarTrailingConstraint: NSLayoutConstraint!
    private let twoStarButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 280, compressionResistancePriority: 280)
        
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .systemBackground
        
        return button
    }()

    private weak var threeStarTrailingConstraint: NSLayoutConstraint!
    private let threeStarButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 280, compressionResistancePriority: 280)
        
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .systemBackground
        
        return button
    }()

    
    private weak var fourStarTrailingConstraint: NSLayoutConstraint!
    private let fourStarButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 280, compressionResistancePriority: 280)

        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .systemBackground
        
        return button
    }()

    
    private let fiveStarButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 280, compressionResistancePriority: 280)
        
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .systemBackground
        
        return button
    }()
    
    @objc private func didTapStar(_ sender: Any) {
        guard let tappedStar = sender as? GeneralUIButton else {
            return
        }
        
        indexOfUserStarRating = orderedStarButtons.firstIndex(of: tappedStar)
    }
    
    private let suggestionTextView: GeneralUITextView = {
        let textView = GeneralUITextView(huggingPriority: 260, compressionResistancePriority: 260)
        
        textView.backgroundColor = .systemBackground
        textView.textColor = .label
        textView.font = .systemFont(ofSize: 17.5)
        textView.borderWidth = 2
        textView.borderColor = .label
        textView.shouldRoundCorners = true
        return textView
    }()
    
    private let submitButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        
        // Continue button is disabled until the user selects a rating
        button.isEnabled = false
        
        return button
    }()
    
    // MARK: - Additional UI Elements
    private let scrollView: GeneralUIScrollView = {
        let scrollView = GeneralUIScrollView()
        
        scrollView.alwaysBounceVertical = true
        
        return scrollView
    }()
    
    private let containerView: GeneralUIView = GeneralUIView()
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.text = "How are you enjoying Hound?"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 35, weight: .semibold)
        label.textColor = .systemBackground
        return label
    }()
    
    private let backButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 290, compressionResistancePriority: 290)
        
        button.tintColor = .systemBackground
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundCircleTintColor = .systemBlue
        
        button.shouldDismissParentViewController = true
        return button
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.text = "What could we do to improve?"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 25)
        label.textColor = .systemBackground
        return label
    }()
    @objc private func didTapSubmit(_ sender: Any) {
        guard let indexOfUserStarRating = indexOfUserStarRating else {
            return
        }
        
        // for numberOfStars, adjust the index 0-4 of the star rating to its actual 1-5 value.
        SurveyFeedbackRequest.create(forErrorAlert: .automaticallyAlertForNone, numberOfStars: (indexOfUserStarRating + 1), appExperienceFeedback: suggestionTextView.text ?? "") { _, _ in
            return
        }
        
        self.dismiss(animated: true) {
            // After we successfully submit this survey and dismiss the view, thank the user
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.surveyFeedbackAppExperienceTitle, forSubtitle: VisualConstant.BannerTextConstant.surveyFeedbackAppExperienceSubtitle, forStyle: .success)
        }
    }
    
    // MARK: - Properties
    
    /// An ordered array of the star buttons, where index 0 is 1 star and index 4 is 5 stars
    private var orderedStarButtons: [GeneralUIButton] {
        return [oneStarButton, twoStarButton, threeStarButton, fourStarButton, fiveStarButton]
    }
    
    private var storedIndexOfUserStarRating: Int?
    /// The index of what star the user rated Hound (1 star = 0 & 5 stars = 4)
    private var indexOfUserStarRating: Int? {
        get {
            return storedIndexOfUserStarRating
        }
        set {
            let oldValue = storedIndexOfUserStarRating
            storedIndexOfUserStarRating = newValue
            
            guard let indexOfUserStarRating = indexOfUserStarRating, oldValue != indexOfUserStarRating else {
                // The rating is being set to nil or the new rating is the same as the old rating, so clear all of the stars and the rating
                storedIndexOfUserStarRating = nil
               
                UIView.animate(withDuration: VisualConstant.AnimationConstant.toggleSelectUIElement) {
                    // A star isn't selected so the user can't submit
                    self.submitButton.isEnabled = false
                    self.orderedStarButtons.forEach { starButton in
                        starButton.isUserInteractionEnabled = false
                        starButton.setImage(UIImage(systemName: "star"), for: .normal)
                    }
                } completion: { _ in
                    self.orderedStarButtons.forEach { starButton in
                        starButton.isUserInteractionEnabled = true
                    }
                }
                return
            }
            
            // Find the number of stars the user rated
            // If the user rated 3 stars, then we want to change stars 1, 2, and 3 to being the selected filled star image, and change stars 4 and 5 to the unfilled star iamge
            let selectedStarButtons = indexOfUserStarRating >= orderedStarButtons.count ? orderedStarButtons : Array(orderedStarButtons.prefix(through: indexOfUserStarRating))
            let unselectedStarButtons = orderedStarButtons.filter { starButton in
                return selectedStarButtons.contains(starButton) == false
            }
            
            UIView.animate(withDuration: VisualConstant.AnimationConstant.toggleSelectUIElement) {
                // A star is selected so the user can now submit
                self.submitButton.isEnabled = true
                selectedStarButtons.forEach { selectedStarButton in
                    selectedStarButton.isUserInteractionEnabled = false
                    selectedStarButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
                }
                unselectedStarButtons.forEach { unselectedStarButton in
                    unselectedStarButton.isUserInteractionEnabled = false
                    unselectedStarButton.setImage(UIImage(systemName: "star"), for: .normal)
                }
            } completion: { _ in
                selectedStarButtons.forEach { selectedStarButton in
                    selectedStarButton.isUserInteractionEnabled = true
                }
                unselectedStarButtons.forEach { unselectedStarButton in
                    unselectedStarButton.isUserInteractionEnabled = true
                }
            }
        }
    }
    
    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        self.eligibleForGlobalPresenter = true
        modalPresentationStyle = .fullScreen
        
        // When this view controller is constructed, check that we requested survey feedback for app exp
        LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceRequested.append(Date())
        
        self.suggestionTextView.placeholder = "Share any thoughts, suggestions, or issues..."
        self.suggestionTextView.delegate = self
    }
    
    private var didSetupCustomSubviews: Bool = false
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        guard didSetupCustomSubviews == false else {
            return
        }

        didSetupCustomSubviews = true

        // the distance between week day buttons should be 12.5 points on a 375 point screen, so this adjusts that ratio to fit any width of screen
        // TODO GPT what is the proper way to adjust this dynamically?
        oneStarTrailingConstraint.constant = (12.5 / 375.0) * self.view.safeAreaLayoutGuide.layoutFrame.width
        twoStarTrailingConstraint.constant = (12.5 / 375.0) * self.view.safeAreaLayoutGuide.layoutFrame.width
        threeStarTrailingConstraint.constant = (12.5 / 375.0) * self.view.safeAreaLayoutGuide.layoutFrame.width
        fourStarTrailingConstraint.constant = (12.5 / 375.0) * self.view.safeAreaLayoutGuide.layoutFrame.width
    }

    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBlue
        
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(submitButton)
        containerView.addSubview(suggestionTextView)
        containerView.addSubview(headerLabel)
        containerView.addSubview(backButton)
        containerView.addSubview(threeStarButton)
        containerView.addSubview(fourStarButton)
        containerView.addSubview(fiveStarButton)
        containerView.addSubview(twoStarButton)
        containerView.addSubview(oneStarButton)
        containerView.addSubview(descriptionLabel)
        
        oneStarButton.addTarget(self, action: #selector(didTapStar), for: .touchUpInside)
        twoStarButton.addTarget(self, action: #selector(didTapStar), for: .touchUpInside)
        threeStarButton.addTarget(self, action: #selector(didTapStar), for: .touchUpInside)
        fourStarButton.addTarget(self, action: #selector(didTapStar), for: .touchUpInside)
        fiveStarButton.addTarget(self, action: #selector(didTapStar), for: .touchUpInside)
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
    }

    override func setupConstraints() {
        oneStarTrailingConstraint = twoStarButton.leadingAnchor.constraint(equalTo: oneStarButton.trailingAnchor, constant: 10)
        twoStarTrailingConstraint = threeStarButton.leadingAnchor.constraint(equalTo: twoStarButton.trailingAnchor, constant: 10)
        threeStarTrailingConstraint = fourStarButton.leadingAnchor.constraint(equalTo: threeStarButton.trailingAnchor, constant: 10)
        fourStarTrailingConstraint = fiveStarButton.leadingAnchor.constraint(equalTo: fourStarButton.trailingAnchor, constant: 10)
        
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: suggestionTextView.bottomAnchor, constant: 35),
            submitButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            submitButton.leadingAnchor.constraint(equalTo: suggestionTextView.leadingAnchor),
            submitButton.widthAnchor.constraint(equalTo: submitButton.heightAnchor, multiplier: 1 / 0.16),
        
            suggestionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            suggestionTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            suggestionTextView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            suggestionTextView.leadingAnchor.constraint(equalTo: oneStarButton.leadingAnchor),
            suggestionTextView.trailingAnchor.constraint(equalTo: fiveStarButton.trailingAnchor),
            suggestionTextView.trailingAnchor.constraint(equalTo: submitButton.trailingAnchor),
            suggestionTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            suggestionTextView.heightAnchor.constraint(equalToConstant: 175),
        
            backButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: headerLabel.trailingAnchor, constant: 5),
            backButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor),
            backButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 50 / 414),
            backButton.heightAnchor.constraint(equalToConstant: 75),
            backButton.heightAnchor.constraint(equalToConstant: 25),
        
            threeStarButton.topAnchor.constraint(equalTo: twoStarButton.topAnchor),
            threeStarButton.topAnchor.constraint(equalTo: oneStarButton.topAnchor),
            threeStarButton.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 35),
            threeStarButton.bottomAnchor.constraint(equalTo: fourStarButton.bottomAnchor),
            threeStarButton.bottomAnchor.constraint(equalTo: fiveStarButton.bottomAnchor),
            twoStarTrailingConstraint,
            threeStarButton.widthAnchor.constraint(equalTo: threeStarButton.heightAnchor),
            threeStarButton.widthAnchor.constraint(equalTo: oneStarButton.widthAnchor),
            threeStarButton.widthAnchor.constraint(equalTo: twoStarButton.widthAnchor),
        
            fourStarButton.topAnchor.constraint(equalTo: threeStarButton.topAnchor),
            threeStarTrailingConstraint,
            fourStarButton.widthAnchor.constraint(equalTo: fourStarButton.heightAnchor),
            fourStarButton.widthAnchor.constraint(equalTo: threeStarButton.widthAnchor),
        
            fiveStarButton.topAnchor.constraint(equalTo: threeStarButton.topAnchor),
            fourStarTrailingConstraint,
            fiveStarButton.widthAnchor.constraint(equalTo: fiveStarButton.heightAnchor),
            fiveStarButton.widthAnchor.constraint(equalTo: threeStarButton.widthAnchor),
        
            twoStarButton.bottomAnchor.constraint(equalTo: threeStarButton.bottomAnchor),
            oneStarTrailingConstraint,
            twoStarButton.widthAnchor.constraint(equalTo: twoStarButton.heightAnchor),
        
            oneStarButton.bottomAnchor.constraint(equalTo: threeStarButton.bottomAnchor),
            oneStarButton.widthAnchor.constraint(equalTo: oneStarButton.heightAnchor),
        
            descriptionLabel.topAnchor.constraint(equalTo: threeStarButton.bottomAnchor, constant: 45),
            descriptionLabel.trailingAnchor.constraint(equalTo: suggestionTextView.trailingAnchor),
        
            headerLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            headerLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
        
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            containerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
        
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        
        ])
        
    }
}
