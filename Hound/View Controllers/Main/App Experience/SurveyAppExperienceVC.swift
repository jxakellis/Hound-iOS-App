//
//  SurveyAppExperienceViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/4/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

class SurveyAppExperienceViewController: GeneralUIViewController, UITextViewDelegate {
    
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
        
        userRatedNumberOfStars = orderedStarButtons.firstIndex(of: tappedStar)
    }
    
    @IBOutlet private weak var suggestionTextView: GeneralUITextView!
    
    @IBOutlet private weak var submitButton: GeneralUIButton!
    @IBAction private func didTapSubmit(_ sender: Any) {
        let body: [String: Any?] = [ KeyConstant.surveyFeedback.rawValue: [
            KeyConstant.surveyFeedbackType.rawValue: SurveyFeedbackType.appExperience.rawValue,
            KeyConstant.appExperienceNumberOfStars.rawValue: userRatedNumberOfStars as Any,
            KeyConstant.appExperienceFeedback.rawValue: suggestionTextView.text ?? ""
        ]]
        SurveyFeedbackRequest.create(invokeErrorManager: false, forBody: body) { _, _, _ in
            return
        }
        
        self.dismiss(animated: true) {
            PresentationManager.enqueueBanner(forTitle: VisualConstant.BannerTextConstant.surveyFeedbackAppExperienceTitle, forSubtitle: VisualConstant.BannerTextConstant.surveyFeedbackAppExperienceSubtitle, forStyle: .success)
        }
    }
    
    // MARK: - Properties
    
    /// An ordered array of the star buttons, where index 0 is 1 star and index 4 is 5 stars
    private var orderedStarButtons: [GeneralUIButton] {
        return [oneStarButton, twoStarButton, threeStarButton, fourStarButton, fiveStarButton]
    }
    
    private var storedUserRatedNumberOfStars: Int?
    /// The number of stars that the user rated Hound
    private var userRatedNumberOfStars: Int? {
        get {
            return storedUserRatedNumberOfStars
        }
        set {
            let oldValue = storedUserRatedNumberOfStars
            storedUserRatedNumberOfStars = newValue
            
            guard let userRatedNumberOfStars = userRatedNumberOfStars, oldValue != userRatedNumberOfStars else {
                // The rating is being set to nil or the new rating is the same as the old rating, so clear all of the stars and the rating
                storedUserRatedNumberOfStars = nil
                
                UIView.animate(withDuration: VisualConstant.AnimationConstant.toggleSelectUIElement) {
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
            let selectedStarButtons = userRatedNumberOfStars >= orderedStarButtons.count ? orderedStarButtons : Array(orderedStarButtons.prefix(through: userRatedNumberOfStars))
            let unselectedStarButtons = orderedStarButtons.filter { starButton in
                return selectedStarButtons.contains(starButton) == false
            }
            
            UIView.animate(withDuration: VisualConstant.AnimationConstant.toggleSelectUIElement) {
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
        self.suggestionTextView.placeholder = "Share any thoughts, suggestions, or issues..."
        self.suggestionTextView.delegate = self
        
        // TODO test that both this feedback and cancel subscription feedbacks work
        
        // TODO have the display of this vc to review hound only appear if 1. the user's time-eligible to share hound with friends (remove that old feature as it wasn't used much and 2. the user hasn't completed any survey recently
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

