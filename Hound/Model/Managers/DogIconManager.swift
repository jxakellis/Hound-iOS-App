//
//  DogIconManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/12/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DogIconManager {

    final class LocalDogIcon {
        // MARK: - Main

        init(dogUUID: UUID, dogIcon: UIImage) {
            self.dogUUID = dogUUID
            self.dogIcon = dogIcon
        }

        // MARK: - Properties

        var dogUUID: UUID
        var dogIcon: UIImage

    }

    // MARK: - Get Dog Icon

    /// Present openCameraOrGalleryForDogIconActionSheet to prompt the user with an action sheet asking if they want to open their camera or choose from their gallery for their dogIcon. Set didSelectDogIconController.delegate to allow you to recieve the dog icon that the user selected.
    static let (didSelectDogIconController, openCameraOrGalleryForDogIconActionSheet) = {
        let imagePickerController = UIImagePickerController()

        let imagePickMethodAlertController = UIAlertController(title: "Choose Image", message: "Your personal dog icons aren't shared with other family members", preferredStyle: .actionSheet)

        imagePickMethodAlertController.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            if UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                imagePickerController.sourceType = UIImagePickerController.SourceType.camera
                imagePickerController.allowsEditing = true
                imagePickerController.cameraCaptureMode = .photo
                imagePickerController.cameraDevice = .rear
                PresentationManager.enqueueViewController(imagePickerController)
            }
            else {
                PresentationManager.enqueueBanner(title: Constant.Visual.BannerText.noCameraTitle, subtitle: nil, style: .danger)
            }
        }))

        imagePickMethodAlertController.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
            imagePickerController.allowsEditing = true
            PresentationManager.enqueueViewController(imagePickerController)
        }))

        imagePickMethodAlertController.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        return (imagePickerController, imagePickMethodAlertController)
    }()

    /// Processes the information returned by the UIImagePickerController, attempts to create an image from it. In the process it scales the image to the point size of the ScaledUiButton of the dogIcon multiplied by the scale factor of the local screen. For Retina displays, the scale factor may be 3.0 or 2.0 and one point can represented by nine or four pixels, respectively. For standard-resolution displays, the scale factor is 1.0 and one point equals one pixel.
    static func processDogIcon(info: [UIImagePickerController.InfoKey: Any]) -> UIImage? {
        let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage

        guard let image = image else {
            return nil
        }

        // Arbitrary size multiplied by the scale factor of the user's screen
        let scaledSize = 300.0 * UIScreen.main.scale

        let scaledImageSize = CGSize(width: scaledSize, height: scaledSize)

        let renderer = UIGraphicsImageRenderer(size: scaledImageSize)

        let scaledImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: scaledImageSize))
        }

        return scaledImage
    }

    // MARK: - Storage of Icons

    /// If we retrieve a dogIcon from files, store it locally. Only retrieve from files if we don't have stored for this life cycle
    private static var icons: [LocalDogIcon] = []

    /// Attempts to create a file path url for the given dogUUID
    private static func getIconURL(dogUUID: UUID) -> URL? {
        // make sure we have a urls to read/write to
        let documentsURLs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // create URL
        guard let url = documentsURLs.first?.appendingPathComponent("dog\(dogUUID).png") else {
            return nil
        }

        return url
    }

    /// Attempts to retrieve the dogIcon for the provided dogUUID. If no dogIcon is found, then nil is returned
    static func getIcon(dogUUID: UUID) -> UIImage? {
        // Before reading icon from files, see if we have it stored in a reference (meaning we've retrieved it before in this lifecycle). Saves us from needlessly reading from files again
        if let icon = icons.first(where: { localDogIcon in
            localDogIcon.dogUUID.uuidString == dogUUID.uuidString
        }) {
            return icon.dogIcon
        }

        // need a url to perform any read/writes to
        guard let url = getIconURL(dogUUID: dogUUID) else {
            return nil
        }

        // attempt to find and return image
        let icon = UIImage(contentsOfFile: url.path)

        if let icon = icon {
            // add dog icon to life cycle storage
            icons.append(LocalDogIcon(dogUUID: dogUUID, dogIcon: icon))
        }

        return icon
    }

    /// Removes all LocalDogIcons stored in LocalConfiguration.dogIcons that match the provided dogUUID, then adds a LocalDogIcon to LocalConfiguration.dogIcons with the provided dogUUID and dogIcon.
    static func addIcon(dogUUID: UUID, dogIcon: UIImage) {

        removeIcon(dogUUID: dogUUID)

        // need a url to perform any read/writes to
        guard let url = getIconURL(dogUUID: dogUUID) else { return }

        // convert dogIcon to data, then attempt to write to url, saving the image
        do {
            try dogIcon.pngData()?.write(to: url)
            // add dog icon to life cycle storage
            icons.append(LocalDogIcon(dogUUID: dogUUID, dogIcon: dogIcon))
        }
        catch {
            // failed to add dog icon
        }
    }

    /// Removes all LocalDogIcons stored in LocalConfiguration.dogIcons that match the provided dogUUID
    static func removeIcon(dogUUID: UUID) {
        // need a url to perform any read/writes to
        guard let url = getIconURL(dogUUID: dogUUID) else { return }

        do {
            // attempt to remove any image at specified url
            try FileManager.default.removeItem(at: url)
            // remove lifecycle storage of dog icon
            icons.removeAll { localDogIcon in
                localDogIcon.dogUUID == dogUUID
            }
        }
        catch {
            // failed to remove dog icon
        }
    }
}
