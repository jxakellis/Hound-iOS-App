//
//  DogIconManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/12/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DogIconManager {
    
    final class LocalDogIcon {
        // MARK: - Main
        
        init(forDogId dogId: Int, forDogIcon dogIcon: UIImage) {
            self.dogId = dogId
            self.dogIcon = dogIcon
        }
        
        // MARK: - Properties
        
        var dogId: Int = ClassConstant.DogConstant.defaultDogId
        var dogIcon: UIImage = ClassConstant.DogConstant.defaultDogIcon
        
    }
    
    // MARK: - Get Dog Icon
    
    /// Processes the information returned by the UIImagePickerController, attempts to create an image from it. In the process it scales the image to the point size of the ScaledUiButton of the dogIcon multiplied by the scale factor of the local screen. For Retina displays, the scale factor may be 3.0 or 2.0 and one point can represented by nine or four pixels, respectively. For standard-resolution displays, the scale factor is 1.0 and one point equals one pixel.
    static func processDogIcon(forDogIconButton dogIconButton: ScaledUIButton, forInfo info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        
        let scaleFactor = UIScreen.main.scale
        
        let image: UIImage!
        let scaledImageSize = CGSize(width: dogIconButton.frame.width * scaleFactor, height: dogIconButton.frame.width * scaleFactor)
        
        if let possibleImage = info[.editedImage] as? UIImage {
            image = possibleImage
        }
        else if let possibleImage = info[.originalImage] as? UIImage {
            image = possibleImage
        }
        else {
            return nil
        }
        
        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)
        
        let scaledImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }
        
        return scaledImage
    }
    
    /// Creates a GeneralUIAlertController that will prompt the user in the different methods they can choose their dog's Icon (e.g. choose from library or take a new picture) and then creates a UIImagePickerController to facilitate this. Returns a UIImagePickerController which you MUST set its delegate in order to get the image the user picked and returns a GeneralUIAlertController which you must present in order for the user to choose their method of choosing an image
    static func setupDogIconImagePicker(forViewController viewController: UIViewController) -> (UIImagePickerController, GeneralUIAlertController) {
        let imagePicker = UIImagePickerController()
        
        let imagePickMethodAlertController = GeneralUIAlertController(title: "Choose Image", message: "Other family members aren't able to see your personal dog icons", preferredStyle: .actionSheet)
        
        imagePickMethodAlertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            if UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                imagePicker.sourceType = UIImagePickerController.SourceType.camera
                imagePicker.allowsEditing = true
                imagePicker.cameraCaptureMode = .photo
                imagePicker.cameraDevice = .rear
                viewController.present(imagePicker, animated: true, completion: nil)
            }
            else {
                AlertManager.enqueueBannerForPresentation(forTitle: VisualConstant.BannerTextConstant.noCameraTitle, forSubtitle: nil, forStyle: .danger)
            }
        }))
        
        imagePickMethodAlertController.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePicker.allowsEditing = true
            viewController.present(imagePicker, animated: true, completion: nil)
        }))
        
        imagePickMethodAlertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        return (imagePicker, imagePickMethodAlertController)
    }
    
    // MARK: - Storage of Icons
    
    /// If we retrieve a dogIcon from files, store it locally. Only retrieve from files if we don't have stored for this life cycle
    private static var icons: [LocalDogIcon] = []
    
    /// Attempts to create a file path url for the given dogId
    private static func getIconURL(forDogId dogId: Int) -> URL? {
        // make sure we have a urls to read/write to
        let documentsURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        
        // create URL
        guard let url = documentsURLs.first?.appendingPathComponent("dog\(dogId).png") else {
            return nil
        }
        
        return url
    }
    
    /// Attempts to retrieve the dogIcon for the provided dogId. If no dogIcon is found, then nil is returned
    static func getIcon(forDogId dogId: Int) -> UIImage? {
        // Before reading icon from files, see if we have it stored in a reference (meaning we've retrieved it before in this lifecycle). Saves us from needlessly reading from files again
        if let icon = icons.first(where: { localDogIcon in
            return localDogIcon.dogId == dogId
        }) {
            return icon.dogIcon
        }
        
        // need a url to perform any read/writes to
        guard let url = getIconURL(forDogId: dogId) else {
            return nil
        }
        
        // attempt to find and return image
        let icon = UIImage(contentsOfFile: url.path)
        
        if let icon = icon {
            // add dog icon to life cycle storage
            icons.append(LocalDogIcon(forDogId: dogId, forDogIcon: icon))
        }
        
        return icon
    }
    
    /// Removes all LocalDogIcons stored in LocalConfiguration.dogIcons that match the provided dogId, then adds a LocalDogIcon to LocalConfiguration.dogIcons with the provided dogId and dogIcon.
    static func addIcon(forDogId dogId: Int, forDogIcon dogIcon: UIImage) {
        
        removeIcon(forDogId: dogId)
        
        // need a url to perform any read/writes to
        guard let url = getIconURL(forDogId: dogId) else {
            return
        }
        
        // convert dogIcon to data, then attempt to write to url, saving the image
        do {
            try dogIcon.pngData()?.write(to: url)
            // add dog icon to life cycle storage
            icons.append(LocalDogIcon(forDogId: dogId, forDogIcon: dogIcon))
        }
        catch {
            // failed to add dog icon
        }
    }
    
    /// Removes all LocalDogIcons stored in LocalConfiguration.dogIcons that match the provided dogId
    static func removeIcon(forDogId dogId: Int) {
        // need a url to perform any read/writes to
        guard let url = getIconURL(forDogId: dogId) else {
            return
        }
        
        do {
            // attempt to remove any image at specified url
            try FileManager.default.removeItem(at: url)
            // remove lifecycle storage of dog icon
            icons.removeAll { localDogIcon in
                return localDogIcon.dogId == dogId
            }
        }
        catch {
            // failed to remove dog icon
        }
    }
}
