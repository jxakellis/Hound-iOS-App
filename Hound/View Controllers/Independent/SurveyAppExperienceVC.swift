//
//  SurveyAppExperienceVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/4/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

// UI VERIFIED 6/25/25
class SurveyAppExperienceVC: GeneralUIViewController, UITextViewDelegate {
    
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
    
    private let scrollView: GeneralUIScrollView = {
        let scrollView = GeneralUIScrollView()
        
        scrollView.onlyBounceIfBigger()
        
        return scrollView
    }()
    
    private let containerView: GeneralUIView = GeneralUIView()
    
    private let pageHeaderLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 300, compressionResistancePriority: 300)
        label.text = "How are you enjoying Hound?"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.primaryHeaderLabel
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
    
    private let oneStarButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 280, compressionResistancePriority: 280)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .systemBackground
        return button
    }()
    
    private let twoStarButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 280, compressionResistancePriority: 280)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .systemBackground
        return button
    }()

    private let threeStarButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 280, compressionResistancePriority: 280)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .systemBackground
        return button
    }()
    
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
    
    /// Stack view containing all star rating buttons
    private let starsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    @objc private func didTapStar(_ sender: Any) {
        guard let tappedStar = sender as? GeneralUIButton else {
            return
        }
        
        indexOfUserStarRating = orderedStarButtons.firstIndex(of: tappedStar)
    }
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.text = "What could we do to improve?"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        label.textColor = .systemBackground
        return label
    }()
    
    private let suggestionTextView: GeneralUITextView = {
        let textView = GeneralUITextView(huggingPriority: 260, compressionResistancePriority: 260)
        
        textView.backgroundColor = .systemBackground
        textView.textColor = .label
        textView.font = VisualConstant.FontConstant.primaryRegularLabel
        textView.placeholder = "Share any thoughts, suggestions, or issues..."
        
        textView.borderWidth = 2
        textView.borderColor = .label
        textView.shouldRoundCorners = true
        return textView
    }()
    
    private let submitButton: GeneralUIButton = {
        let button = GeneralUIButton()
        
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = .systemBackground
        
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        
        // Continue button is disabled until the user selects a rating
        button.isEnabled = false
        
        return button
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
        
        // When this view controller is constructed, check that we requested survey feedback for app exp
        LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceRequested.append(Date())
        
        self.suggestionTextView.delegate = self
    }

    // MARK: - Setup Elements
    
    override func setupGeneratedViews() {
        view.backgroundColor = .systemBlue
        
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        // Setup stars stack
        orderedStarButtons.forEach { starButton in
            starsStackView.addArrangedSubview(starButton)
            starButton.addTarget(self, action: #selector(didTapStar), for: .touchUpInside)
        }
        
        // Add views to container
        containerView.addSubview(pageHeaderLabel)
        containerView.addSubview(backButton)
        containerView.addSubview(starsStackView)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(suggestionTextView)
        containerView.addSubview(submitButton)
        
        submitButton.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
    }

    override func setupConstraints() {
        super.setupConstraints()
        
        // ScrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        // ContainerView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // HeaderLabel
        NSLayoutConstraint.activate([
            pageHeaderLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            pageHeaderLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            pageHeaderLabel.trailingAnchor.constraint(lessThanOrEqualTo: backButton.leadingAnchor, constant: -ConstraintConstant.Spacing.contentIntraHoriSpacing)
        ])
        
        // backButton
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: ConstraintConstant.Spacing.miniCircleAbsInset),
            backButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.miniCircleAbsInset),
            backButton.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: ConstraintConstant.Button.miniCircleHeightMultiplier).withPriority(.defaultHigh),
            backButton.createMaxHeight( ConstraintConstant.Button.miniCircleMaxHeight),
            backButton.createSquareAspectRatio()
        ])
        
        // StarsStackView
        NSLayoutConstraint.activate([
            starsStackView.topAnchor.constraint(equalTo: pageHeaderLabel.bottomAnchor, constant: 35),
            starsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset * 2.0),
            starsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset * 2.0),
        ])
        
        // Make all stars equal size and square
        for starButton in orderedStarButtons {
            NSLayoutConstraint.activate([
                starButton.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: ConstraintConstant.Button.miniCircleHeightMultiplier * 1.5).withPriority(.defaultHigh),
                starButton.createMaxHeight( ConstraintConstant.Button.miniCircleMaxHeight * 1.5),
                starButton.createSquareAspectRatio()
            ])
        }
        
        // DescriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: starsStackView.bottomAnchor, constant: 45),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset)
        ])
        
        // SuggestionTextView
        NSLayoutConstraint.activate([
            suggestionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            suggestionTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            suggestionTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset),
            suggestionTextView.heightAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: ConstraintConstant.Input.inputHeightMultiplier * 3.0).withPriority(.defaultHigh),
            suggestionTextView.createMaxHeight( ConstraintConstant.Input.inputMaxHeight * 3.0)
        ])
        
        // SubmitButton
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: suggestionTextView.bottomAnchor, constant: 35),
            submitButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.contentAbsHoriInset),
            submitButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.contentAbsHoriInset),
            submitButton.heightAnchor.constraint(equalTo: submitButton.widthAnchor, multiplier: ConstraintConstant.Button.wideHeightMultiplier).withPriority(.defaultHigh),
            submitButton.createMaxHeight(ConstraintConstant.Button.wideMaxHeight),
            submitButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15)
        ])
    }
}
