//
//  GeneralUIButton.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/19/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

@IBDesignable class GeneralUIButton: UIButton, GeneralUIProtocol {
    
    // MARK: - GeneralUIProtocol
    
    var properties: [String: CompatibleDataTypeForJSON?] = [:]
    
    // MARK: - Properties

    private var hasAdjustedShouldRoundCorners: Bool = false
    /// If true, self.layer.cornerRadius = self.bounds.height / 2 is applied upon bounds change. Otherwise, self.layer.cornerRadius = 0 is applied upon bounds change.
    var shouldRoundCorners: Bool = false {
        didSet {
            self.hasAdjustedShouldRoundCorners = true
            self.updateCornerRoundingIfNeeded()
        }
    }

    var shouldScaleImagePointSize: Bool = false {
        didSet {
            self.updateScaleImagePointSizeIfNeeded()
        }
    }

    /// If true, upon .touchUpInside the button will dismiss the closest parent UIViewController.
    var shouldDismissParentViewController: Bool = false {
        didSet {
            if shouldDismissParentViewController {
                self.addTarget(self, action: #selector(dismissParentViewController), for: .touchUpInside)
            }
            else {
                self.removeTarget(self, action: #selector(dismissParentViewController), for: .touchUpInside)
            }
        }
    }
    @objc private func dismissParentViewController() {
        self.closestParentViewController?.dismiss(animated: true)
    }

    var titleLabelTextColor: UIColor? {
        get {
            self.titleLabel?.textColor
        }
        set {
            self.setTitleColor(newValue, for: .normal)
        }
    }

    var buttonBackgroundColor: UIColor? {
        get {
            self.backgroundColor
        }
        set {
            self.backgroundColor = newValue
        }
    }

    var borderWidth: Double {
        get {
            Double(self.layer.borderWidth)
        }
        set {
            self.layer.borderWidth = CGFloat(newValue)
        }
    }

    var borderColor: UIColor? {
        didSet {
            if let borderColor = borderColor {
                self.layer.borderColor = borderColor.cgColor
            }
        }
    }

    /// When set, this closure will create the NSAttributedString for attributedText and set attributedTet equal to that. This is necessary because attributedText doesn't support dynamic colors and therefore doesn't change its colors when the UITraitCollection updates. Additionally, this closure is invoke when the UITraitCollection updates to manually make the attributedText support dynamic colors
    var attributedTextClosure: (() -> NSAttributedString)? {
        didSet {
            if let attributedText = attributedTextClosure?() {
                self.setAttributedTitle(attributedText, for: .normal)
            }
        }
    }

    /// Used in beginSpinning and endSpinning to track state before spin began
    private var beforeSpinTintColor: UIColor?
    /// Used in beginSpinning and endSpinning to track state before spin began
    private var beforeSpinUserInteractionEnabled: Bool?
    /// Used in beginSpinning and endSpinning to track state before spin began
    private var isSpinning: Bool {
        beforeSpinTintColor != nil || beforeSpinUserInteractionEnabled != nil
    }

    // MARK: - Override Properties

    /// Resize corner radius when the bounds change
    override var bounds: CGRect {
        didSet {
            // Make sure to incur didSet of superclass
            super.bounds = bounds
            self.updateCornerRoundingIfNeeded()
            self.updateScaleImagePointSizeIfNeeded()
        }
    }

    override var isEnabled: Bool {
        didSet {
            // Make sure to incur didSet of superclass
            super.isEnabled = isEnabled
            self.alpha = isEnabled ? 1 : 0.5
        }
    }

    // MARK: - Main
    
    init(huggingPriority: Float = 250, compressionResistancePriority: Float = 750) {
        super.init(frame: .zero)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .horizontal)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .vertical)
        self.applyDefaultSetup()
    }
    
    // TODO what are all the inits of uibutton? how do i override them all
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.applyDefaultSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.applyDefaultSetup()
    }
    
    // MARK: - Override Functions

    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        
        shouldScaleImagePointSize = true
        updateScaleImagePointSizeIfNeeded()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // UI has changed its appearance to dark/light mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if let borderColor = borderColor {
                self.layer.borderColor = borderColor.cgColor
            }
            if let attributedText = attributedTextClosure?() {
                self.setAttributedTitle(attributedText, for: .normal)
            }
        }
    }

    // MARK: - Functions
    
    private func applyDefaultSetup() {
        self.contentHorizontalAlignment = .center
        self.contentVerticalAlignment = .center
        self.contentMode = .scaleToFill
        self.translatesAutoresizingMaskIntoConstraints = false
        
        updateCornerRoundingIfNeeded()
        updateScaleImagePointSizeIfNeeded()
    }
    
    private func updateCornerRoundingIfNeeded() {
        if self.hasAdjustedShouldRoundCorners == true {
            if shouldRoundCorners {
                self.layer.masksToBounds = true
            }
            self.layer.cornerRadius = shouldRoundCorners ? self.bounds.height / 2.0 : 0.0
            self.layer.cornerCurve = .continuous
        }
    }

    /// If there is a current, symbol image, scales its point size to the smallest dimension of bounds
    private func updateScaleImagePointSizeIfNeeded() {
        guard shouldScaleImagePointSize else {
            return
        }

        guard let currentImage = currentImage, currentImage.isSymbolImage == true else {
            return
        }

        let smallestDimension = bounds.height <= bounds.width ? bounds.height : bounds.width

        super.setImage(currentImage.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: smallestDimension)), for: .normal)
    }

    func beginSpinning() {
        guard isSpinning == false else {
            return
        }

        beforeSpinUserInteractionEnabled = isUserInteractionEnabled
        isUserInteractionEnabled = false
        beforeSpinTintColor = tintColor
        tintColor = UIColor.systemGray2

        spin()

        func spin() {
            guard isSpinning == true else {
                return
            }
            // begin spin
            UIView.animate(withDuration: VisualConstant.AnimationConstant.spinUIElement, delay: 0, options: .curveLinear) {

                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)

            } completion: { _ in
                guard self.isSpinning == true else {
                    return
                }
                // end spin
                UIView.animate(withDuration: VisualConstant.AnimationConstant.spinUIElement, delay: 0, options: .curveLinear) {

                    self.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
                } completion: { _ in
                    guard self.isSpinning == true else {
                        return
                    }
                    spin()
                }
            }
        }
    }

    func endSpinning() {
        guard isSpinning == true else {
            return
        }

        transform = .identity

        if let beforeSpinTintColor = beforeSpinTintColor {
            tintColor = beforeSpinTintColor
            self.beforeSpinTintColor = nil
        }
        if let beforeSpinUserInteractionEnabled = beforeSpinUserInteractionEnabled {
            isUserInteractionEnabled = beforeSpinUserInteractionEnabled
            self.beforeSpinUserInteractionEnabled = nil
        }
    }

}
