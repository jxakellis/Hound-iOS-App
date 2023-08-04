//
//  AlertCheckboxButton.swift
//  RNAlertController
//
//  Created by Rayhan Nabi on 1/13/20.
//  Copyright © 2020 Rayhan Nabi. All rights reserved.
//

import UIKit

final class AlertCheckboxButton: UIButton {

    convenience init() {
        self.init(type: .custom)
        setConstraints()
        setCheckboxImages()
    }

}

private extension AlertCheckboxButton {

    func setConstraints() {
        heightAnchor.constraint(equalToConstant: 24).isActive = true
        widthAnchor.constraint(equalToConstant: 24).isActive = true
    }

    func setCheckboxImages() {
        let checkedImage = createTintedImage(named: "Checkbox Checked")
        let uncheckedImage = createTintedImage(named: "Checkbox Unchecked")
        setImage(uncheckedImage, for: .normal)
        setImage(checkedImage, for: .selected)
    }

    func createTintedImage(named imageName: String) -> UIImage? {
        let bundle = Bundle(for: type(of: self))
        guard let templateImage = UIImage(named: imageName, in: bundle, compatibleWith: nil) else { return nil }
        UIGraphicsBeginImageContextWithOptions(templateImage.size, false, templateImage.scale)
        UIColor.alertButtonTextRegular.set()
        let newSize = CGRect(x: 0, y: 0, width: templateImage.size.width, height: templateImage.size.height)
        templateImage.draw(in: newSize)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

}
