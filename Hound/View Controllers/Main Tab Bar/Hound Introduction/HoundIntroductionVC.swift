//
//  IntroductionViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/26/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class HoundIntroductionViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - IB
    
    @IBOutlet private weak var dogsTitleLabel: ScaledUILabel!
    
    @IBOutlet private weak var dogNameDescriptionLabel: ScaledUILabel!
    // TO DO NOW when a user finishes editting dogNameTextField (clicks out or clicks return), animate show dogIcon description and dogIcon button
    @IBOutlet private weak var dogNameTextField: UITextField!
    
    @IBOutlet private weak var dogIconDescriptionLabel: ScaledUILabel!
    @IBOutlet private weak var dogIconButton: ScaledImageUIButton!
    @IBAction private func didTapDogIcon(_ sender: Any) {
        // TO DO NOW after a user selects an image, we should clear the text and stuff out of the button so its only the image
        PresentationManager.enqueueActionSheet(imagePickMethodAlertController, sourceView: dogIconButton)
    }
    
    @IBOutlet private weak var continueButton: SemiboldUIButton!
    
    /// Tapped continues button at the bottom to dismiss
    @IBAction private func willContinue(_ sender: Any) {
        
        continueButton.isEnabled = false
        // data passage handled in view will disappear as the view can also be swiped down instead of hitting the continue button.
        
        // synchronizes data when setup is done (aka disappearing)
        var dogName: String? {
            if let dogName = self.dogNameTextField.text, dogName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                return dogName.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            else {
                return nil
            }
        }
        
        // no dogs so we create a new one for the user
        if dogManager.dogs.isEmpty, let dog = try? Dog(dogName: dogName ?? ClassConstant.DogConstant.defaultDogName) {
            // set the dog objects dogIcon before contacting the server, then if the requset to the server is successful, dogsrequest will persist the icon
            
            // contact server to make their dog
            DogsRequest.create(invokeErrorManager: true, forDog: dog) { requestWasSuccessful, _ in
                self.continueButton.isEnabled = true
                guard requestWasSuccessful else {
                    return
                }
                
                self.dogManager.addDog(forDog: dog)
                LocalConfiguration.localHasCompletedHoundIntroductionViewController = true
                self.performSegueOnceInWindowHierarchy(segueIdentifier: "MainTabBarViewController")
            }
        }
        
        // updating the icon of an existing dog
        else if let dog = dogManager.dogs.first {
            dog.dogIcon = {
                if let image = self.dogIconButton.imageView?.image {
                    return image
                }
                else {
                    return nil
                }
            }()
            
            // Normally the DogIcon persistance is taken care of by DogsRequest. However, in this case we don't contact the server about the updating the dog so have to manually update the icon.
            if let dogIcon = dog.dogIcon {
                DogIconManager.addIcon(forDogId: dog.dogId, forDogIcon: dogIcon)
            }
            
            // close page because updated
            LocalConfiguration.localHasCompletedHoundIntroductionViewController = true
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "MainTabBarViewController")
            continueButton.isEnabled = true
        }
        
    }
    
    // MARK: - Properties
    
    var imagePickMethodAlertController: UIAlertController!
    
    // MARK: - Dog Manager
    
    private(set) var dogManager = DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the dogName fields
        if let dog = dogManager.dogs.first {
            // The user's family already has a dog. This means they can only add a icon to the existing dog
            
            // Hide and squash all dogName related fields
            dogNameDescriptionLabel.isHidden = true
            dogNameTextField.isHidden = true
            
        }
        else {
            
        }
        
        // TO DO NOW continue
        if let dog = dogManager.dogs.first {
            // The user's family already has a dog. This means they can only add a icon to the existing dog
            
            // TO DO NOW we know a dog already exists, show dogIcon label and button. This user will immediately start editting this
            dogIconDescriptionLabel.text = "It looks like \(dog.dogName) has already been added to your family. Add a cute picture for them!"
            dogIconDescriptionLabel.isHidden = false
            dogIconButton.isHidden = false
        }
        else {
            dogIconDescriptionLabel.text = "Wonderful! Now, select a cute picture of your dog."
            dogIconDescriptionLabel.isHidden = true
            dogIconButton.isHidden = true
        }
        dogIconButton.shouldRoundCorners = true
        dogIconButton.layer.borderWidth = VisualConstant.LayerConstant.boldBorderWidth
        dogIconButton.layer.borderColor = VisualConstant.LayerConstant.whiteBackgroundBorderColor
        
        // Theme
        continueButton.applyStyle(forStyle: .blackTextWhiteBackgroundBlackBorder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // This page, and its children, can be light or dark
        self.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PresentationManager.globalPresenter = self
    }
    
    // MARK: - Functions
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mainTabBarViewController: MainTabBarViewController = segue.destination as? MainTabBarViewController {
            mainTabBarViewController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        }
    }
}
