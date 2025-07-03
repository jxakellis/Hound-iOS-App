//
//  GeneralUIButton.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/19/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class GeneralUIButton: UIButton, GeneralUIProtocol {

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

    var borderWidth: Double {
        get { Double(self.layer.borderWidth) }
        set { self.layer.borderWidth = CGFloat(newValue) }
    }

    var borderColor: UIColor? {
        didSet {
            if let borderColor = borderColor {
                self.layer.borderColor = borderColor.cgColor
            }
        }
    }

    /// When set, this closure will create the NSAttributedString for attributedText and set attributedTitle equal to that. This is necessary because attributedText doesn't support dynamic colors and therefore doesn't change its colors when the UITraitCollection updates. Additionally, this closure is invoked when the UITraitCollection updates to manually make the attributedText support dynamic colors.
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

    var backgroundCircleTintColor: UIColor? {
        didSet {
            updateBackgroundCircle()
        }
    }

    /// Using UIImageView to avoid button recursion/layout issues.
    private var backgroundCircleView: UIImageView?

    // MARK: - Override Properties

    /// Resize corner radius when the bounds change
    override var bounds: CGRect {
        didSet {
            super.bounds = bounds
            self.updateCornerRoundingIfNeeded()
            self.updateScaleImagePointSize()
            self.updateBackgroundCircle()
        }
    }

    override var isEnabled: Bool {
        didSet {
            super.isEnabled = isEnabled
            self.alpha = isEnabled ? 1 : 0.5
        }
    }

    override var isHidden: Bool {
        didSet {
            super.isHidden = isHidden
            backgroundCircleView?.isHidden = isHidden
        }
    }

    // MARK: - Main

    init(huggingPriority: Float = UILayoutPriority.defaultLow.rawValue, compressionResistancePriority: Float = UILayoutPriority.defaultLow.rawValue) {
        super.init(frame: .zero)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .horizontal)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .vertical)
        self.applyDefaultSetup()
    }
    
    init() {
        super.init(frame: .zero)
        let priority = UILayoutPriority.defaultLow.rawValue
        self.setContentHuggingPriority(UILayoutPriority(priority), for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriority(priority), for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority(priority), for: .horizontal)
        self.setContentCompressionResistancePriority(UILayoutPriority(priority), for: .vertical)
        self.applyDefaultSetup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.applyDefaultSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }

    // MARK: - Override Functions

    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        updateScaleImagePointSize()
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

    override func layoutSubviews() {
        super.layoutSubviews()
        // Check for accidentally huge frames
        checkForOversizedFrame()
    }

    // MARK: - Functions

    private func applyDefaultSetup() {
        self.contentHorizontalAlignment = .center
        self.contentVerticalAlignment = .center
        self.contentMode = .scaleToFill
        self.translatesAutoresizingMaskIntoConstraints = false
        
        SizeDebugView.install(on: self)

        updateCornerRoundingIfNeeded()
        updateScaleImagePointSize()
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
    private func updateScaleImagePointSize() {
        guard let currentImage = currentImage, currentImage.isSymbolImage == true else {
            return
        }
        let smallestDimension = bounds.height <= bounds.width ? bounds.height : bounds.width
        super.setImage(currentImage.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: smallestDimension)), for: .normal)
    }

    private func updateBackgroundCircle() {
        guard let backgroundCircleTintColor = backgroundCircleTintColor else {
            // Remove background circle if tint is cleared
            backgroundCircleView?.removeFromSuperview()
            backgroundCircleView = nil
            return
        }

        // If it doesn't exist, create it and insert below imageView
        if backgroundCircleView == nil {
            let image = UIImageView(image: UIImage(systemName: "circle.fill"))
            image.isUserInteractionEnabled = false
            if let imageView = imageView {
                                insertSubview(image, belowSubview: imageView)
                            }
                            else {
                                addSubview(image)
                            }
            
            backgroundCircleView = image
        }

        // Update color and frame each time
        backgroundCircleView?.tintColor = backgroundCircleTintColor

        let multiplier = 1.05
        let width = bounds.width / multiplier
        let height = bounds.height / multiplier
        let adjustedBounds = CGRect(
            x: (bounds.width / 2.0) - (width / 2),
            y: (bounds.height / 2.0) - (height / 2),
            width: width,
            height: height)

        backgroundCircleView?.frame = adjustedBounds
    }

    func beginSpinning() {
        guard isSpinning == false else { return }
        beforeSpinUserInteractionEnabled = isUserInteractionEnabled
        isUserInteractionEnabled = false
        beforeSpinTintColor = tintColor
        tintColor = UIColor.systemGray2

        spin()

        func spin() {
            guard isSpinning == true else { return }
            // begin spin
            UIView.animate(withDuration: VisualConstant.AnimationConstant.spinUIElement, delay: 0, options: .curveLinear) {
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            } completion: { _ in
                guard self.isSpinning == true else { return }
                // end spin
                UIView.animate(withDuration: VisualConstant.AnimationConstant.spinUIElement, delay: 0, options: .curveLinear) {
                    self.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
                } completion: { _ in
                    guard self.isSpinning == true else { return }
                    spin()
                }
            }
        }
    }

    func endSpinning() {
        guard isSpinning == true else { return }
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

    // MARK: - Debugging

    /// Logs a warning if the frame size is unreasonably large, indicating a likely constraint or layout issue
    private func checkForOversizedFrame() {
        let maxReasonableSize: CGFloat = 5000
        if bounds.width > maxReasonableSize || bounds.height > maxReasonableSize {
            AppDelegate.generalLogger.error(
                """
                [GeneralUIButton] WARNING: Oversized frame detected.
                Button Frame: \(self.bounds.width) x \(self.bounds.height)
                Superview: \(String(describing: self.superview))
                Stack: \(Thread.callStackSymbols.joined(separator: "\n"))
                """
            )
        }
    }

}
