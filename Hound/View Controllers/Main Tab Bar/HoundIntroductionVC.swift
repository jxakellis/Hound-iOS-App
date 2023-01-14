//
//  IntroductionViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/26/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class HoundIntroductionViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        if let dogIcon = DogIconManager.processDogIcon(forDogIconButton: dogIcon, forInfo: info) {
            self.dogIcon.setImage(dogIcon, for: .normal)
        }
        
        picker.dismiss(animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return false
    }
    
    // MARK: - IB
    
    @IBOutlet private weak var dogsTitle: ScaledUILabel!
    
    @IBOutlet private weak var dogNameHeader: ScaledUILabel!
    
    @IBOutlet private weak var dogNameDescription: ScaledUILabel!
    
    @IBOutlet private weak var dogIcon: ScaledImageUIButton!
    @IBAction private func didClickIcon(_ sender: Any) {
        AlertManager.enqueueActionSheetForPresentation(imagePickMethodAlertController, sourceView: dogIcon, permittedArrowDirections: [.up, .down])
    }
    
    @IBOutlet private weak var dogName: UITextField!
    
    @IBOutlet private weak var continueButton: ScreenWidthUIButton!
    /// Clicked continues button at the bottom to dismiss
    @IBAction private func willContinue(_ sender: Any) {
        
        continueButton.isEnabled = false
        // data passage handled in view will disappear as the view can also be swiped down instead of hitting the continue button.
        
        // synchronizes data when setup is done (aka disappearing)
        var dogName: String? {
            if let dogName = self.dogName.text, dogName.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                return dogName.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            else {
                return nil
            }
        }
        
        // no dogs so we create a new one for the user
        if dogManager.dogs.isEmpty, let dog = try? Dog(dogName: dogName ?? ClassConstant.DogConstant.defaultDogName) {
            // set the dog objects dogIcon before contacting the server, then if the requset to the server is successful, dogsrequest will persist the icon
            dog.dogIcon = {
                if let image = self.dogIcon.imageView?.image, image != ClassConstant.DogConstant.chooseDogIcon {
                    return image
                }
                else {
                    return nil
                }
            }()
            
            // contact server to make their dog
            DogsRequest.create(invokeErrorManager: true, forDog: dog) { dogId, _ in
                self.continueButton.isEnabled = true
                guard let dogId = dogId else {
                    return
                }
                dog.dogId = dogId
                
                self.dogManager.addDog(forDog: dog)
                LocalConfiguration.localHasCompletedHoundIntroductionViewController = true
                self.performSegueOnceInWindowHierarchy(segueIdentifier: "MainTabBarViewController")
            }
        }
        
        // updating the icon of an existing dog
        else if dogManager.dogs.count >= 1 {
            dogManager.dogs[0].dogIcon = {
                if let image = self.dogIcon.imageView?.image, image != ClassConstant.DogConstant.chooseDogIcon {
                    return image
                }
                else {
                    return nil
                }
            }()
            
            // Normally the DogIcon persistance is taken care of by DogsRequest. However, in this case we don't contact the server about the updating the dog so have to manually update the icon.
            if let dogIcon = dogManager.dogs[0].dogIcon {
                DogIconManager.addIcon(forDogId: dogManager.dogs[0].dogId, forDogIcon: dogIcon)
            }
            
            // close page because updated
            LocalConfiguration.localHasCompletedHoundIntroductionViewController = true
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "MainTabBarViewController")
            continueButton.isEnabled = true
        }
        
    }
    
    // MARK: - Properties
    
    var imagePickMethodAlertController: GeneralUIAlertController!
    
    // MARK: - Dog Manager
    
    private(set) var dogManager = DogManager()
    
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        dogManager = forDogManager
    }
    
    // MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dogNameHeader.text = (dogManager.dogs.isEmpty) ? "What Is Your Dog's Name?" : "Customize Your Dog"
        
        dogNameDescription.text = (dogManager.dogs.isEmpty) ? "We will generate a basic dog for you. Reminders will come later." : "It looks like your family has already created a dog. Although, if you want, you can add your own custom icon to it."
        
        // Dog Name
        dogName.text = ""
        if dogManager.dogs.isEmpty {
            dogName.placeholder = "Bella"
            dogName.delegate = self
            dogName.isEnabled = true
            setupToHideKeyboardOnTapOnView()
        }
        else {
            dogName.placeholder = dogManager.dogs[0].dogName
            dogName.isEnabled = false
        }
        
        // Dog Icon
        
        dogIcon.setImage(ClassConstant.DogConstant.chooseDogIcon, for: .normal)
        dogIcon.imageView?.layer.masksToBounds = VisualConstant.LayerConstant.defaultMasksToBounds
        dogIcon.imageView?.layer.cornerRadius = dogIcon.frame.width / 2
        
        // Setup AlertController for dogIcon button now, increases responsiveness
        let (picker, viewController) = DogIconManager.setupDogIconImagePicker(forViewController: self)
        picker.delegate = self
        imagePickMethodAlertController = viewController
        
        // Theme
        
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
        
        continueButton.applyStyle(forStyle: .whiteTextBlueBackgroundNoBorder)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let mainTabBarViewController: MainTabBarViewController = segue.destination as? MainTabBarViewController {
            mainTabBarViewController.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)
        }
    }
}
