//
//  SurveyAppExperienceVC.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/4/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SurveyAppExperienceVC: HoundScrollViewController, UITextViewDelegate {
    
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
    
    private let pageHeaderView: HoundPageSheetHeaderView = {
        let view = HoundPageSheetHeaderView(huggingPriority: 350, compressionResistancePriority: 350)
        view.useLeftTextAlignment = false
        
        view.pageHeaderLabel.text = "How Are You Enjoying Hound?"
        view.pageHeaderLabel.textColor = UIColor.systemBackground
        
        view.backButton.tintColor = UIColor.systemBackground
        view.backButton.backgroundCircleTintColor = nil
        
        return view
    }()
    
    private lazy var oneStarButton: HoundButton = {
        let button = HoundButton(huggingPriority: 280, compressionResistancePriority: 280)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = UIColor.systemBackground
        button.addTarget(self, action: #selector(didTapStar), for: .touchUpInside)
        return button
    }()
    
    private lazy var twoStarButton: HoundButton = {
        let button = HoundButton(huggingPriority: 280, compressionResistancePriority: 280)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = UIColor.systemBackground
        button.addTarget(self, action: #selector(didTapStar), for: .touchUpInside)
        return button
    }()

    private lazy var threeStarButton: HoundButton = {
        let button = HoundButton(huggingPriority: 280, compressionResistancePriority: 280)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = UIColor.systemBackground
        button.addTarget(self, action: #selector(didTapStar), for: .touchUpInside)
        return button
    }()
    
    private lazy var fourStarButton: HoundButton = {
        let button = HoundButton(huggingPriority: 280, compressionResistancePriority: 280)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = UIColor.systemBackground
        button.addTarget(self, action: #selector(didTapStar), for: .touchUpInside)
        return button
    }()
    
    private lazy var fiveStarButton: HoundButton = {
        let button = HoundButton(huggingPriority: 280, compressionResistancePriority: 280)
        button.setImage(UIImage(systemName: "star"), for: .normal)
        button.tintColor = UIColor.systemBackground
        button.addTarget(self, action: #selector(didTapStar), for: .touchUpInside)
        return button
    }()
    
    /// Stack view containing all star rating buttons
    private lazy var starsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [oneStarButton, twoStarButton, threeStarButton, fourStarButton, fiveStarButton])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    @objc private func didTapStar(_ sender: Any) {
        guard let tappedStar = sender as? HoundButton else {
            return
        }
        
        indexOfUserStarRating = orderedStarButtons.firstIndex(of: tappedStar)
    }
    
    private let descriptionLabel: HoundLabel = {
        let label = HoundLabel(huggingPriority: 270, compressionResistancePriority: 270)
        label.text = "What could we do to improve?"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = VisualConstant.FontConstant.secondaryHeaderLabel
        label.textColor = UIColor.systemBackground
        return label
    }()
    
    private let suggestionTextView: HoundTextView = {
        let textView = HoundTextView(huggingPriority: 260, compressionResistancePriority: 260)
        
        textView.backgroundColor = UIColor.systemBackground
        textView.textColor = UIColor.label
        textView.font = VisualConstant.FontConstant.primaryRegularLabel
        textView.placeholder = "Share any thoughts, suggestions, or issues..."
        
        textView.applyStyle(.labelBorder)
        return textView
    }()
    
    private lazy var submitButton: HoundButton = {
        let button = HoundButton()
        
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        
        button.backgroundColor = UIColor.systemBackground
        
         button.applyStyle(.labelBorder)
        
        // Continue button is disabled until the user selects a rating
        button.isEnabled = false
        
        button.addTarget(self, action: #selector(didTapSubmit), for: .touchUpInside)
        
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
    private var orderedStarButtons: [HoundButton] {
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
               
                UIView.animate(withDuration: VisualConstant.AnimationConstant.selectSingleElement) {
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
            
            UIView.animate(withDuration: VisualConstant.AnimationConstant.selectSingleElement) {
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
        view.backgroundColor = UIColor.systemBlue
        
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        containerView.addSubview(pageHeaderView)
        containerView.addSubview(starsStackView)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(suggestionTextView)
        containerView.addSubview(submitButton)
    }

    override func setupConstraints() {
        super.setupConstraints()
        
        // pageHeaderView
        NSLayoutConstraint.activate([
            pageHeaderView.topAnchor.constraint(equalTo: containerView.topAnchor),
            pageHeaderView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageHeaderView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor)
        ])
        
        // starsStackView
        NSLayoutConstraint.activate([
            starsStackView.topAnchor.constraint(equalTo: pageHeaderView.bottomAnchor, constant: ConstraintConstant.Spacing.contentSectionVert),
            starsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset * 2.0),
            starsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset * 2.0)
        ])
        
        // Make all stars equal size and square
        for starButton in orderedStarButtons {
            NSLayoutConstraint.activate([
                starButton.createHeightMultiplier(ConstraintConstant.Button.miniCircleHeightMultiplier * 1.5, relativeToWidthOf: view),
                starButton.createMaxHeight(ConstraintConstant.Button.miniCircleMaxHeight * 1.5),
                starButton.createSquareAspectRatio()
            ])
        }
        
        // descriptionLabel
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: starsStackView.bottomAnchor, constant: ConstraintConstant.Spacing.contentSectionVert),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset)
        ])
        
        // suggestionTextView
        NSLayoutConstraint.activate([
            suggestionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            suggestionTextView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            suggestionTextView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            suggestionTextView.createHeightMultiplier(ConstraintConstant.Input.textViewHeightMultiplier, relativeToWidthOf: view),
            suggestionTextView.createMaxHeight(ConstraintConstant.Input.textViewMaxHeight)
        ])
        
        // submitButton
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: suggestionTextView.bottomAnchor, constant: ConstraintConstant.Spacing.contentTallIntraVert),
            submitButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: ConstraintConstant.Spacing.absoluteHoriInset),
            submitButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -ConstraintConstant.Spacing.absoluteHoriInset),
            submitButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: view),
            submitButton.createMaxHeight(ConstraintConstant.Button.wideMaxHeight),
            submitButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -ConstraintConstant.Spacing.absoluteVertInset)
        ])
    }
}
