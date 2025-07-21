//
//  HoundLabel.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/3/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class HoundLabel: UILabel, HoundUIProtocol, HoundDynamicBorder, HoundDynamicCorners {
    
    // MARK: - HoundUIProtocol
    
    var properties: JSONRequestBody = [:]
    
    // MARK: - Properties
    
    var staticCornerRadius: CGFloat? = Constant.Visual.Layer.defaultCornerRadius
    /// If true, the corners of the view are rounded, depending upon the value of isRoundingToCircle. If false, cornerRadius = 0.
    var shouldRoundCorners: Bool = false {
        didSet {
            updateCornerRounding()
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
    
    private let insetSpacing: String = "  "
    private var placeholderLabel: UILabel?

    /// If true, the label's text will be inset with two spaces on both the
    /// leading and trailing edge. When reading `text` this padding is removed
    /// so consumers do not need to handle it.
    var shouldInsetText: Bool = false {
                self.text = self.text
                self.placeholder = placeholder
            }
        }
    }
    private var placeholderHasInsetApplied: Bool = false
    /// placeholder is a second HoundLabel that is added as a subview to this HoundLabel. It acts as temporary inlaid text until an actual value is input
    var placeholder: String? {
        get {
            var placeholderText: String? = placeholderLabel?.text
            
            if placeholderHasInsetApplied {
                if placeholderText?.hasPrefix(insetSpacing) == true {
                    placeholderText?.removeFirst(2)
                }
                if placeholderText?.hasSuffix(insetSpacing) == true {
                    placeholderText?.removeLast(2)
                }
            }
            
            return placeholderText
        }
        set {
            guard let placeholderLabel = placeholderLabel else {
                // We do not have a placeholderLabel yet
                if let newValue = newValue {
                    // We have placeholder text, so make a placeholderLabel
                    let placeholderLabel = UILabel()
                    var value = newValue

                    if shouldInsetText && !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        placeholderHasInsetApplied = true
                        value = insetSpacing + value + insetSpacing
                    }
                    else {
                        placeholderHasInsetApplied = false
                    }
                    placeholderLabel.text = value
                    placeholderLabel.sizeToFit()

                    placeholderLabel.font = self.font
                    placeholderLabel.textColor = UIColor.placeholderText
                    self.placeholderLabel = placeholderLabel
                    
                    self.updatePlaceholderLabelIsHidden()
                    
                    self.addSubview(placeholderLabel)
                    self.updatePlaceholderLabelFrame()
                }
                
                return
            }
            
            // We have a placeholderLabel, update it's text
            if let newValue = newValue {
                var value = newValue

                if shouldInsetText && !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    placeholderHasInsetApplied = true
                    value = insetSpacing + value + insetSpacing
                }
                else {
                    placeholderHasInsetApplied = false
                }
                
                placeholderLabel.text = value
            }
            else {
                placeholderHasInsetApplied = false
                placeholderLabel.text = nil
            }
            
            placeholderLabel.sizeToFit()
        }
    }
    
    /// When set, this closure will create the NSAttributedString for attributedText and set attributedTet equal to that. This is necessary because attributedText doesn't support dynamic colors and therefore doesn't change its colors when the UITraitCollection updates. Additionally, this closure is invoke when the UITraitCollection updates to manually make the attributedText support dynamic colors
    var attributedTextClosure: (() -> NSAttributedString)? {
        didSet {
            if let attributedText = attributedTextClosure?() {
                self.attributedText = attributedText
            }
        }
    }
    
    /// Color of the outlined background label. When set, a duplicate label is
    /// inserted behind this label with an outline matching this color. Set to
    /// `nil` to remove the background label.
    var backgroundLabelColor: UIColor? {
        didSet { updateBackgroundLabel() }
    }
    
    /// Label that mimics this label but draws only an outline.
    private var backgroundLabel: HoundLabel?
    /// Active constraints pinning the background label to this label.
    private var backgroundConstraints: [NSLayoutConstraint] = []
    /// Multiplier used to determine the outline stroke width based on the
    /// current font size.
    private static let backgroundLabelStrokeWidthScale: CGFloat = 0.8
    
    // MARK: - Override Properties
    
    override var bounds: CGRect {
        didSet {
            // Make sure to incur didSet of superclass
            super.bounds = bounds
            updateCornerRounding()
            self.updatePlaceholderLabelFrame()
        }
    }
    
    private var hasInsetApplied: Bool = false
    override var text: String? {
        get {
            var text = super.text
            if hasInsetApplied {
                if text?.hasPrefix(insetSpacing) == true {
                    text?.removeFirst(2)
                }
                if text?.hasSuffix(insetSpacing) == true {
                    text?.removeLast(2)
                }
            }
            return text
        }
        set {
            if let newValue = newValue {
                var value = newValue
                if shouldInsetText && !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    hasInsetApplied = true
                    value = insetSpacing + value + insetSpacing
                }
                else {
                    hasInsetApplied = false
                }
                super.text = value
            }
            else {
                hasInsetApplied = false
                super.text = nil
            }
            
            guard let placeholderLabel = placeholderLabel else {
                return
            }
            
            guard let placeholderLabelText = placeholderLabel.text, placeholderLabelText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
                placeholderLabel.isHidden = true
                return
            }
            
            updatePlaceholderLabelIsHidden()
            updateBackgroundLabelAttributes()
        }
    }
    
    override var font: UIFont! {
        didSet {
            updateBackgroundLabelAttributes()
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            super.textAlignment = textAlignment
            backgroundLabel?.textAlignment = textAlignment
        }
    }
    
    override var numberOfLines: Int {
        didSet {
            super.numberOfLines = numberOfLines
            backgroundLabel?.numberOfLines = numberOfLines
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
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        // Reattach background label to the new superview if needed
        if backgroundLabelColor != nil {
            updateBackgroundLabel()
        }
    }
    
    // MARK: - Override Functions
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateDynamicBorderColor(using: previousTraitCollection)
        
        // UI has changed its appearance to dark/light mode
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if let attributedText = attributedTextClosure?() {
                self.attributedText = attributedText
            }
            updateBackgroundLabelAttributes()
        }
    }
    
    // MARK: - Functions
    
    private func applyDefaultSetup() {
        self.contentMode = .left
        self.textAlignment = .natural
        self.lineBreakMode = .byTruncatingTail
        self.baselineAdjustment = .alignBaselines
        self.adjustsFontSizeToFitWidth = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.minimumScaleFactor = 0.825
        self.font = Constant.Visual.Font.primaryRegularLabel
        
        HoundSizeDebugView.install(on: self)
        
        updateCornerRounding()
    }
    
    private func updatePlaceholderLabelFrame() {
        placeholderLabel?.frame = self.bounds
    }
    
    private func updatePlaceholderLabelIsHidden() {
        // If text isn't nil and has a non-empty string, we want to hide the placeholder (since the place it was holding for now has text in it)
        placeholderLabel?.isHidden = self.text != nil && self.text?.trimmingCharacters(in: .whitespaces).isEmpty == false
    }
    
    // MARK: - Background Label
    
    /// Adds or removes the outlined background label as needed.
    private func updateBackgroundLabel() {
        guard let color = backgroundLabelColor else {
            backgroundConstraints.forEach { $0.isActive = false }
            backgroundConstraints.removeAll()
            backgroundLabel?.removeFromSuperview()
            backgroundLabel = nil
            return
        }
        
        if backgroundLabel == nil {
            let label = HoundLabel()
            label.isUserInteractionEnabled = false
            label.translatesAutoresizingMaskIntoConstraints = false
            backgroundLabel = label
        }
        
        guard let backgroundLabel = backgroundLabel else { return }
        
        // Attach to superview below this label if not already
        if backgroundLabel.superview !== superview, let superview = superview {
            backgroundConstraints.forEach { $0.isActive = false }
            backgroundConstraints.removeAll()
            backgroundLabel.removeFromSuperview()
            superview.insertSubview(backgroundLabel, belowSubview: self)
            backgroundConstraints = [
                backgroundLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
                backgroundLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
                backgroundLabel.topAnchor.constraint(equalTo: topAnchor),
                backgroundLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
            NSLayoutConstraint.activate(backgroundConstraints)
        }
        
        backgroundLabel.minimumScaleFactor = minimumScaleFactor
        backgroundLabel.numberOfLines = numberOfLines
        backgroundLabel.textAlignment = textAlignment
        updateBackgroundLabelAttributes(using: color)
    }
    
    /// Updates the attributed text of the background label.
    private func updateBackgroundLabelAttributes(using color: UIColor? = nil) {
        guard let backgroundLabel = backgroundLabel else { return }
        let outlineColor = color ?? backgroundLabelColor
        backgroundLabel.attributedTextClosure = { [weak self] in
            guard let self = self else { return NSAttributedString(string: "") }
            return NSAttributedString(string: self.text ?? "", attributes: [
                .strokeColor: outlineColor as Any,
                .foregroundColor: outlineColor as Any,
                .strokeWidth: self.font.pointSize * Self.backgroundLabelStrokeWidthScale,
                .font: self.font as Any
            ])
        }
    }
    
}
