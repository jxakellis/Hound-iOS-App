//
//  HoundIntroductionDogIconView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/21/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol HoundIntroductionDogIconViewDelegate: AnyObject {
    func willFinish(forDogIcon: UIImage?)
}

final class HoundIntroductionDogIconView: HoundView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: - UIImagePickerControllerDelegate

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let dogIcon = DogIconManager.processDogIcon(forInfo: info) {
            dogIconButton.setTitle(nil, for: .normal)
            dogIconButton.setImage(dogIcon, for: .normal)
        }
        picker.dismiss(animated: true)
    }

    // MARK: - Elements

    private let introductionView = HoundIntroductionView()

    private let dogIconButton: HoundButton = {
        let button = HoundButton(huggingPriority: 230, compressionResistancePriority: 230)
        button.setTitle("Choose", for: .normal)
        button.setTitleColor(.placeholderText, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.circleButton
        button.backgroundColor = UIColor.systemBackground
        button.applyStyle(.thinGrayBorder)
        return button
    }()

    private let finishButton: HoundButton = {
        let button = HoundButton(huggingPriority: 290, compressionResistancePriority: 290)
        button.setTitle("Finish", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = VisualConstant.FontConstant.wideButton
        button.backgroundColor = UIColor.systemBackground
         button.applyStyle(.labelBorder)
        return button
    }()

    private var mainStack: UIStackView!

    // MARK: - Properties

    private weak var delegate: HoundIntroductionDogIconViewDelegate?

    private var dogIcon: UIImage? {
        dogIconButton.imageView?.image
    }

    // MARK: - Setup

    func setup(forDelegate: HoundIntroductionDogIconViewDelegate, forDogName dogName: String) {
        delegate = forDelegate

        introductionView.backgroundImageView.image = UIImage(named: "blueShorelineManThrowingStickForDog")
        introductionView.pageHeaderLabel.text = "Select an Icon For \(dogName)"
        introductionView.pageDescriptionLabel.text = "It's optional, but adding a cute picture for them is a wonderful choice"

        dogIconButton.isEnabled = true
        finishButton.isEnabled = true

        DogIconManager.didSelectDogIconController.delegate = self
    }

    // MARK: - Functions

    @objc private func didTouchUpInsideDogIcon(_ sender: Any) {
        PresentationManager.enqueueActionSheet(DogIconManager.openCameraOrGalleryForDogIconActionSheet, sourceView: dogIconButton)
    }

    @objc private func didTouchUpInsideFinish(_ sender: Any) {
        dogIconButton.isEnabled = false
        finishButton.isEnabled = false
        delegate?.willFinish(forDogIcon: dogIcon)
    }

    // MARK: - Setup Elements

    override func setupGeneratedViews() {
        backgroundColor = UIColor.systemBackground
        super.setupGeneratedViews()
    }

    override func addSubViews() {
        super.addSubViews()
        addSubview(introductionView)

        mainStack = UIStackView(arrangedSubviews: [dogIconButton, finishButton])
        mainStack.axis = .vertical
        mainStack.spacing = ConstraintConstant.Spacing.contentSectionVert
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        introductionView.contentView.addSubview(mainStack)

        dogIconButton.addTarget(self, action: #selector(didTouchUpInsideDogIcon), for: .touchUpInside)
        finishButton.addTarget(self, action: #selector(didTouchUpInsideFinish), for: .touchUpInside)
    }

    override func setupConstraints() {
        super.setupConstraints()

        NSLayoutConstraint.activate([
            introductionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            introductionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            introductionView.topAnchor.constraint(equalTo: topAnchor),
            introductionView.bottomAnchor.constraint(equalTo: bottomAnchor),

            mainStack.centerXAnchor.constraint(equalTo: introductionView.contentView.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: introductionView.contentView.centerYAnchor),
            mainStack.leadingAnchor.constraint(equalTo: introductionView.contentView.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: introductionView.contentView.trailingAnchor),

            dogIconButton.createSquareAspectRatio(),
            dogIconButton.createHeightMultiplier(ConstraintConstant.Button.circleHeightMultiplier * 1.25, relativeToWidthOf: self),
            dogIconButton.createMaxHeight(ConstraintConstant.Button.circleMaxHeight * 1.25),

            finishButton.leadingAnchor.constraint(equalTo: mainStack.leadingAnchor),
            finishButton.trailingAnchor.constraint(equalTo: mainStack.trailingAnchor),
            finishButton.createHeightMultiplier(ConstraintConstant.Button.wideHeightMultiplier, relativeToWidthOf: self),
            finishButton.createMaxHeight(ConstraintConstant.Button.wideMaxHeight)
        ])
    }
}
