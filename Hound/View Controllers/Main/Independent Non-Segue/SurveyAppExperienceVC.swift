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
    
    // MARK: - IB
    
    @IBOutlet private weak var oneStarButton: GeneralUIButton!
    @IBOutlet private weak var oneStarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var twoStarButton: GeneralUIButton!
    @IBOutlet private weak var twoStarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var threeStarButton: GeneralUIButton!
    @IBOutlet private weak var threeStarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var fourStarButton: GeneralUIButton!
    @IBOutlet private weak var fourStarTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var fiveStarButton: GeneralUIButton!
    
    @IBAction private func didTapStar(_ sender: Any) {
        guard let tappedStar = sender as? GeneralUIButton else {
            return
        }
        
        indexOfUserStarRating = orderedStarButtons.firstIndex(of: tappedStar)
    }
    
    @IBOutlet private weak var suggestionTextView: GeneralUITextView!
    
    @IBOutlet private weak var submitButton: GeneralUIButton!
    @IBAction private func didTapSubmit(_ sender: Any) {
        guard let indexOfUserStarRating = indexOfUserStarRating else {
            return
        }
        
        // for numberOfStars, adjust the index 0-4 of the star rating to its actual 1-5 value.
        SurveyFeedbackRequest.create(forErrorAlert: .automaticallyAlertForNone, numberOfStars: (indexOfUserStarRating + 1), appExperienceFeedback: suggestionTextView.text ?? "") { _, _ in
            return
        }
        
        // TODO NOW when SurveyFeedbackRequest submits feedback, then have it automayically add to local config
        LocalConfiguration.localPreviousDatesUserSurveyFeedbackAppExperienceSubmitted.append(Date())
        
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
        // Continue button is disabled until the user selects a rating
        self.submitButton.isEnabled = false
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
