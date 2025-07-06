//
//  HoundTextView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/30/22.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

/// Custom UITextView supporting a properly inset placeholder label, rounding, and border styling.
final class HoundTextView: UITextView, HoundUIProtocol, HoundDynamicBorder, HoundDynamicCorners {
    
    // MARK: - HoundUIProtocol
    
    var properties: [String: CompatibleDataTypeForJSON?] = [:]
    
    // MARK: - Properties
    
    var staticCornerRadius: CGFloat? = VisualConstant.LayerConstant.defaultCornerRadius
    /// If true, self.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius. Otherwise, self.layer.cornerRadius = 0.
    var shouldRoundCorners: Bool = false {
        didSet {
            updateCornerRounding()
        }
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
    
    /// Placeholder label shown when text is empty.
    private let placeholderLabel: HoundLabel = {
        let label = HoundLabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .placeholderText
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var placeholderTopConstraint: NSLayoutConstraint!
    private var placeholderLeadingConstraint: NSLayoutConstraint!
    private var placeholderTrailingConstraint: NSLayoutConstraint!
    
    /// Space from edge to text/placeholder (matches system if not set elsewhere)
    private var lastKnownTextContainerInset: UIEdgeInsets = .zero
    private var lastKnownLineFragmentPadding: CGFloat = 0
    
    // MARK: - Override Properties
    
    override var bounds: CGRect {
        didSet {
            // Make sure to incur didSet of superclass
            super.bounds = bounds
            updateCornerRounding()
        }
    }
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            super.isUserInteractionEnabled = isUserInteractionEnabled
            self.alpha = isUserInteractionEnabled ? 1 : 0.5
        }
    }
    
    /// Placeholder text (will show if text is empty).
    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            updatePlaceholderVisibility()
        }
    }
    
    override var text: String! {
        didSet { updatePlaceholderVisibility() }
    }
    
    override var attributedText: NSAttributedString! {
        didSet { updatePlaceholderVisibility() }
    }
    
    override var font: UIFont? {
        didSet {
            placeholderLabel.font = font
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            super.textContainerInset = textContainerInset
            updatePlaceholderConstraints()
        }
    }
    
    // MARK: - Main
    
    init(huggingPriority: Float = UILayoutPriority.defaultLow.rawValue, compressionResistancePriority: Float = UILayoutPriority.defaultLow.rawValue) {
        super.init(frame: .zero, textContainer: nil)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .horizontal)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .vertical)
        applyDefaultSetup()
    }
    
    init() {
        super.init(frame: .zero, textContainer: nil)
        let priority = UILayoutPriority.defaultLow.rawValue
        self.setContentHuggingPriority(UILayoutPriority(priority), for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriority(priority), for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority(priority), for: .horizontal)
        self.setContentCompressionResistancePriority(UILayoutPriority(priority), for: .vertical)
        self.applyDefaultSetup()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        applyDefaultSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkForOversizedFrame()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: self)
    }
    
    // MARK: - Setup
    
    private func applyDefaultSetup() {
        self.isMultipleTouchEnabled = true
        self.contentMode = .scaleToFill
        self.textAlignment = .natural
        self.translatesAutoresizingMaskIntoConstraints = false
        self.textContainerInset = UIEdgeInsets(top: 7.5, left: 7.5, bottom: 7.5, right: 7.5)
        self.font = self.font ?? VisualConstant.FontConstant.primaryRegularLabel
        
        placeholderLabel.font = self.font
        placeholderLabel.textAlignment = self.textAlignment
        
        addSubview(placeholderLabel)
        setupPlaceholderConstraints()
        updatePlaceholderConstraints()
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChangeNotification), name: UITextView.textDidChangeNotification, object: self)
        
        HoundSizeDebugView.install(on: self)
        updateCornerRounding()
        updatePlaceholderVisibility()
    }
    
    /// Adds constraints for the placeholder label, relative to textContainerInset and lineFragmentPadding.
    private func setupPlaceholderConstraints() {
        // Remove old constraints if they exist (in case font/insets change)
        if placeholderTopConstraint != nil { removeConstraint(placeholderTopConstraint) }
        if placeholderLeadingConstraint != nil { removeConstraint(placeholderLeadingConstraint) }
        if placeholderTrailingConstraint != nil { removeConstraint(placeholderTrailingConstraint) }
        
        let insets = textContainerInset
        let padding = textContainer.lineFragmentPadding
        
        placeholderTopConstraint = placeholderLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: insets.top)
        placeholderLeadingConstraint = placeholderLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: insets.left + padding)
        placeholderTrailingConstraint = placeholderLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -(insets.right + padding))
        placeholderTopConstraint.isActive = true
        placeholderLeadingConstraint.isActive = true
        placeholderTrailingConstraint.isActive = true
    }
    
    /// Updates the placeholder label's constraints if textContainerInset or lineFragmentPadding changes.
    private func updatePlaceholderConstraints() {
        if placeholderTopConstraint == nil || placeholderLeadingConstraint == nil || placeholderTrailingConstraint == nil { return }
        
        let insets = textContainerInset
        let padding = textContainer.lineFragmentPadding
        
        placeholderTopConstraint.constant = insets.top
        placeholderLeadingConstraint.constant = insets.left + padding
        placeholderTrailingConstraint.constant = -(insets.right + padding)
        layoutIfNeeded()
    }
    
    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !(text?.isEmpty ?? true)
    }
    
    @objc private func textViewDidChangeNotification(_ notification: Notification) {
        updatePlaceholderVisibility()
    }
    
    // MARK: - Trait/Appearance Overrides
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateDynamicBorderColor(using: previousTraitCollection)
    }
}
