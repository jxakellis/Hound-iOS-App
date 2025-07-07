//
//  HoundButton.swift
//  Hound
//
//  Created by Jonathan Xakellis on 7/19/23.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

class HoundButton: UIButton, HoundUIProtocol, HoundDynamicBorder, HoundDynamicCorners {
    
    // MARK: - HoundUIProtocol
    
    var properties: [String: CompatibleDataTypeForJSON?] = [:]
    
    // MARK: - Properties
    
    var staticCornerRadius: CGFloat?
    /// If true, self.layer.cornerRadius = self.bounds.height / 2 is applied upon bounds change. Otherwise, self.layer.cornerRadius = 0 is applied upon bounds change.
    var shouldRoundCorners: Bool = false {
        didSet {
            updateCornerRounding()
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
    
    var backgroundCircleTintColor: UIColor? {
        didSet {
            updateBackgroundCircle()
        }
    }
    
    /// Using UIImageView to avoid button recursion/layout issues.
    private var backgroundCircleView: UIImageView?
    
    /// The activity indicator used when the button is in a loading state.
    private var loadingIndicator: UIActivityIndicatorView?
    private var beforeLoadingTintColor: UIColor?
    private var beforeLoadingBackgroundCircleTintColor: UIColor?
    private var beforeLoadingBackgroundColor: UIColor?
    private var beforeLoadingBorderColor: UIColor?
    /// Stores the preloading state of `isUserInteractionEnabled` so that it can be restored when loading ends.
    private var beforeLoadingUserInteractionEnabled: Bool?
    /// If `true` the button hides its title/image and shows a spinning indicator instead.
    var isLoading: Bool = false {
        didSet { updateLoadingState() }
    }
    
    // MARK: - Override Properties
    
    /// Resize corner radius when the bounds change
    override var bounds: CGRect {
        didSet {
            // Make sure to incur didSet of superclass
            super.bounds = bounds
            updateCornerRounding()
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkForOversizedFrame()
    }
    
    // MARK: - Override Functions
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        updateScaleImagePointSize()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateDynamicBorderColor(using: previousTraitCollection)
        // UI has changed its appearance to dark/light mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
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
        
        HoundSizeDebugView.install(on: self)
        
        updateCornerRounding()
        updateScaleImagePointSize()
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
    
    private func updateLoadingState() {
        if isLoading {
            guard loadingIndicator == nil else { return }
            UIView.animate(withDuration: VisualConstant.AnimationConstant.selectUIElement) {
                self.beforeLoadingUserInteractionEnabled = self.isUserInteractionEnabled
                self.isUserInteractionEnabled = false
                self.beforeLoadingTintColor = self.tintColor
                self.tintColor = .systemGray2
                if self.backgroundCircleTintColor != nil {
                    self.beforeLoadingBackgroundCircleTintColor = self.backgroundCircleTintColor
                    self.backgroundCircleTintColor = .systemGray2
                }
                if self.backgroundColor != nil {
                    self.beforeLoadingBackgroundColor = self.backgroundColor
                    self.backgroundColor = .systemGray2
                }
                if self.borderColor != nil {
                    self.beforeLoadingBorderColor = self.borderColor
                    self.borderColor = .systemGray2
                }

                self.titleLabel?.alpha = 0
                self.imageView?.alpha = 0
                
                let indicator = UIActivityIndicatorView(style: .large)
                indicator.translatesAutoresizingMaskIntoConstraints = false
                indicator.hidesWhenStopped = true
                indicator.startAnimating()
                indicator.color = .systemBackground
                
                self.addSubview(indicator)
                NSLayoutConstraint.activate([
                    indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                    indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor)
                ])
                self.loadingIndicator = indicator
            }
        }
        else {
            guard let indicator = loadingIndicator else { return }
            UIView.animate(withDuration: VisualConstant.AnimationConstant.selectUIElement) {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
                self.loadingIndicator = nil
                
                self.titleLabel?.alpha = 1
                self.imageView?.alpha = 1
                
                if let before = self.beforeLoadingUserInteractionEnabled {
                    self.isUserInteractionEnabled = before
                    self.beforeLoadingUserInteractionEnabled = nil
                }
                if let before = self.beforeLoadingTintColor {
                    self.tintColor = before
                    self.beforeLoadingTintColor = nil
                }
                if let before = self.beforeLoadingBackgroundCircleTintColor {
                    self.backgroundCircleTintColor = before
                    self.beforeLoadingBackgroundCircleTintColor = nil
                }
                if let before = self.beforeLoadingBackgroundColor {
                    self.backgroundColor = before
                    self.beforeLoadingBackgroundColor = nil
                }
                if let before = self.beforeLoadingBorderColor {
                    self.borderColor = before
                    self.beforeLoadingBorderColor = nil
                }
            }
        }
    }
    
}
