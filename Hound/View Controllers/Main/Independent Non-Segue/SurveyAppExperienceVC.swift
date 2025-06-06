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
    
    private let oneStarButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 280, compressionResistancePriority: 780)
        
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .systemBackground
        button.shouldScaleImagePointSize = true
        
        return button
    }()
    
    // TODO have gpt fix these constraints

    @IBOutlet private weak var oneStarTrailingConstraint: NSLayoutConstraint!
    private let twoStarButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 280, compressionResistancePriority: 780)
        
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .systemBackground
        button.shouldScaleImagePointSize = true
        return button
    }()

    @IBOutlet private weak var twoStarTrailingConstraint: NSLayoutConstraint!
    private let threeStarButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 280, compressionResistancePriority: 780)
        
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .systemBackground
        button.shouldScaleImagePointSize = true
        return button
    }()

    @IBOutlet private weak var threeStarTrailingConstraint: NSLayoutConstraint!
    private let fourStarButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 280, compressionResistancePriority: 780)

        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .systemBackground
        button.shouldScaleImagePointSize = true
        
        return button
    }()

    @IBOutlet private weak var fourStarTrailingConstraint: NSLayoutConstraint!
    private let fiveStarButton: GeneralUIButton = {
        let button = GeneralUIButton(huggingPriority: 280, compressionResistancePriority: 780)
        
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = .systemBackground
        button.shouldScaleImagePointSize = true
        
        return button
    }()

    
    @objc private func didTapStar(_ sender: Any) {
        guard let tappedStar = sender as? GeneralUIButton else {
            return
        }
        
        indexOfUserStarRating = orderedStarButtons.firstIndex(of: tappedStar)
    }
    
    private let suggestionTextView: GeneralUITextView = {
        let textView = GeneralUITextView()
        textView.clipsToBounds = true
        textView.isMultipleTouchEnabled = true
        textView.contentMode = .scaleToFill
        textView.setContentHuggingPriority(UILayoutPriority(260), for: .horizontal)
        textView.setContentHuggingPriority(UILayoutPriority(260), for: .vertical)
        textView.setContentCompressionResistancePriority(UILayoutPriority(760), for: .horizontal)
        textView.setContentCompressionResistancePriority(UILayoutPriority(760), for: .vertical)
        textView.textAlignment = .natural
        textView.translatesAutoresizingMaskIntoConstraints = false
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
        
        button.backgroundColor = .systemBackground
        button.titleLabel?.font = .systemFont(ofSize: 25, weight: .semibold)
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabelTextColor = .label
        button.buttonBackgroundColor = .systemBackground
        button.borderWidth = 2
        button.borderColor = .label
        button.shouldRoundCorners = true
        // Continue button is disabled until the user selects a rating
        button.isEnabled = false
        
        return button
    }()
    
    // MARK: - Additional UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.isMultipleTouchEnabled = true
        scrollView.contentMode = .scaleToFill
        scrollView.alwaysBounceVertical = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.contentMode = .scaleToFill
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private let headerLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(300), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(300), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(800), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(800), for: .vertical)
        label.text = "How are you enjoying Hound?"
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 35, weight: .semibold)
        label.textColor = .systemBackground
        return label
    }()
    
    private let backButton: GeneralWithBackgroundUIButton = {
        let button = GeneralWithBackgroundUIButton()
        
        button.setContentHuggingPriority(UILayoutPriority(290), for: .horizontal)
        button.setContentHuggingPriority(UILayoutPriority(290), for: .vertical)
        button.setContentCompressionResistancePriority(UILayoutPriority(790), for: .horizontal)
        button.setContentCompressionResistancePriority(UILayoutPriority(790), for: .vertical)
        
        button.isPointerInteractionEnabled = true
        
        button.tintColor = .systemBackground
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundUIButtonTintColor = .systemBlue
        button.shouldScaleImagePointSize = true
        button.shouldDismissParentViewController = true
        return button
    }()
    
    private let descriptionLabel: GeneralUILabel = {
        let label = GeneralUILabel()
        label.contentMode = .left
        label.setContentHuggingPriority(UILayoutPriority(270), for: .horizontal)
        label.setContentHuggingPriority(UILayoutPriority(270), for: .vertical)
        label.setContentCompressionResistancePriority(UILayoutPriority(770), for: .horizontal)
        label.setContentCompressionResistancePriority(UILayoutPriority(770), for: .vertical)
        label.text = "What could we do to improve?"
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.numberOfLines = 0
        label.baselineAdjustment = .alignBaselines
        label.adjustsFontSizeToFitWidth = false
        label.translatesAutoresizingMaskIntoConstraints = false
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
        setupGeneratedViews()
        self.eligibleForGlobalPresenter = true
        
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
        oneStarTrailingConstraint.constant = (12.5 / 375.0) * self.view.safeAreaLayoutGuide.layoutFrame.width
        twoStarTrailingConstraint.constant = (12.5 / 375.0) * self.view.safeAreaLayoutGuide.layoutFrame.width
        threeStarTrailingConstraint.constant = (12.5 / 375.0) * self.view.safeAreaLayoutGuide.layoutFrame.width
        fourStarTrailingConstraint.constant = (12.5 / 375.0) * self.view.safeAreaLayoutGuide.layoutFrame.width
    }

}

// TODO: Dont forget to add setupViews func in init, viewDidLoad
// TODO: Incase any indentation error, use shortcut Cmd A + Ctrl I to fix
extension SurveyFeedbackAppExperienceViewController {
    private func setupGeneratedViews() {
        view.backgroundColor = .systemBlue
        
        addSubViews()
        setupConstraints()
    }

    private func addSubViews() {
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

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: suggestionTextView.bottomAnchor, constant: 35),
            submitButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -15),
            submitButton.leadingAnchor.constraint(equalTo: suggestionTextView.leadingAnchor),
            submitButton.widthAnchor.constraint(equalTo: submitButton.heightAnchor, multiplier: 1/0.16),
        
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
            backButton.widthAnchor.constraint(equalTo: backButton.heightAnchor, multiplier: 1/1),
            backButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 50/414),
            backButton.heightAnchor.constraint(equalToConstant: 75),
            backButton.heightAnchor.constraint(equalToConstant: 25),
        
            threeStarButton.topAnchor.constraint(equalTo: twoStarButton.topAnchor),
            threeStarButton.topAnchor.constraint(equalTo: oneStarButton.topAnchor),
            threeStarButton.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 35),
            threeStarButton.bottomAnchor.constraint(equalTo: fourStarButton.bottomAnchor),
            threeStarButton.bottomAnchor.constraint(equalTo: fiveStarButton.bottomAnchor),
            threeStarButton.leadingAnchor.constraint(equalTo: twoStarButton.trailingAnchor, constant: 10),
            threeStarButton.widthAnchor.constraint(equalTo: threeStarButton.heightAnchor, multiplier: 1/1),
            threeStarButton.widthAnchor.constraint(equalTo: oneStarButton.widthAnchor),
            threeStarButton.widthAnchor.constraint(equalTo: twoStarButton.widthAnchor),
        
            fourStarButton.topAnchor.constraint(equalTo: threeStarButton.topAnchor),
            fourStarButton.leadingAnchor.constraint(equalTo: threeStarButton.trailingAnchor, constant: 10),
            fourStarButton.widthAnchor.constraint(equalTo: fourStarButton.heightAnchor, multiplier: 1/1),
            fourStarButton.widthAnchor.constraint(equalTo: threeStarButton.widthAnchor),
        
            fiveStarButton.topAnchor.constraint(equalTo: threeStarButton.topAnchor),
            fiveStarButton.leadingAnchor.constraint(equalTo: fourStarButton.trailingAnchor, constant: 10),
            fiveStarButton.widthAnchor.constraint(equalTo: fiveStarButton.heightAnchor, multiplier: 1/1),
            fiveStarButton.widthAnchor.constraint(equalTo: threeStarButton.widthAnchor),
        
            twoStarButton.bottomAnchor.constraint(equalTo: threeStarButton.bottomAnchor),
            twoStarButton.leadingAnchor.constraint(equalTo: oneStarButton.trailingAnchor, constant: 10),
            twoStarButton.widthAnchor.constraint(equalTo: twoStarButton.heightAnchor, multiplier: 1/1),
        
            oneStarButton.bottomAnchor.constraint(equalTo: threeStarButton.bottomAnchor),
            oneStarButton.widthAnchor.constraint(equalTo: oneStarButton.heightAnchor, multiplier: 1/1),
        
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
        
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
        
        ])
        
    }
}
