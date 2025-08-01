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
    
    var properties: JSONRequestBody = [:]
    
    // MARK: - Properties
    
    var staticCornerRadius: CGFloat? = Constant.Visual.Layer.defaultCornerRadius
    /// If true, self.layer.cornerRadius = Constant.Visual.Layer.defaultCornerRadius. Otherwise, self.layer.cornerRadius = 0.
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
    
    override var bounds: CGRect {
        didSet {
            updateCornerRounding()
        }
    }
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            self.alpha = isUserInteractionEnabled ? 1 : 0.5
        }
    }
    
    // MARK: - Placeholder Label
    
    var placeholder: String? {
        didSet {
            placeholderLabel?.text = placeholder
            updatePlaceholderLabel()
        }
    }
    private var placeholderLabel: UILabel?
    
    override var text: String? {
        didSet {
            if oldValue != text {
                updatePlaceholderLabel()
            }
        }
    }
    
    override var attributedText: NSAttributedString? {
        didSet {
            if oldValue != attributedText {
                updatePlaceholderLabel()
            }
        }
    }
    
    override var contentMode: UIView.ContentMode {
        didSet {
            placeholderLabel?.contentMode = contentMode
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel?.textAlignment = textAlignment
        }
    }
    
    override var font: UIFont! {
        didSet {
            placeholderLabel?.font = font
        }
    }
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            updatePlaceholderLabel()
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
        updatePlaceholderPreferredWidth()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Override Functions
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateDynamicBorderColor(using: previousTraitCollection)
    }
    
    // MARK: - Functions
    
    private func applyDefaultSetup() {
        self.isMultipleTouchEnabled = true
        self.contentMode = .scaleToFill
        self.textAlignment = .natural
        self.textContainerInset = UIEdgeInsets(
            top: ConstraintConstant.Spacing.contentIntraVert,
            left: ConstraintConstant.Spacing.contentTightIntraHori,
            bottom: ConstraintConstant.Spacing.contentIntraVert,
            right: ConstraintConstant.Spacing.contentTightIntraHori)
        self.font = Constant.Visual.Font.primaryRegularLabel
        self.isScrollEnabled = false
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChangeNotification), name: UITextView.textDidChangeNotification, object: self)
        
        HoundSizeDebugView.install(on: self)
        
        updateCornerRounding()
    }
    
    @objc private func textDidChangeNotification() {
        updatePlaceholderLabel()
    }
    
    private func updatePlaceholderLabel() {
        let usesPlaceholderLabel = !(placeholder?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        
        guard usesPlaceholderLabel else {
            placeholderLabel?.snp.removeConstraints()
            placeholderLabel?.removeFromSuperview()
            placeholderLabel = nil
            return
        }
        
        if placeholderLabel == nil {
            let label = UILabel()
            label.textColor = .placeholderText
            label.translatesAutoresizingMaskIntoConstraints = false
            label.isUserInteractionEnabled = false
            label.text = placeholder
            placeholderLabel = label
        }
        
        guard let placeholderLabel = placeholderLabel else {
            return
        }
        
        let isEmpty: Bool = (text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        placeholderLabel.isHidden = !isEmpty
        
        placeholderLabel.numberOfLines = 0
        placeholderLabel.contentMode = contentMode
        placeholderLabel.textAlignment = textAlignment
        placeholderLabel.lineBreakMode = .byWordWrapping
        // placeholderLabel.baselineAdjustment = baselineAdjustment
        placeholderLabel.adjustsFontSizeToFitWidth = false
        // placeholderLabel.minimumScaleFactor = minimumScaleFactor
        placeholderLabel.font = font
        
        if placeholderLabel.superview != self {
            placeholderLabel.removeFromSuperview()
            addSubview(placeholderLabel)
        }
        
        placeholderLabel.snp.remakeConstraints { make in
            make.top.equalTo(self.snp.top).inset(self.textContainerInset.top)
            make.left.equalTo(self.snp.left).inset(self.textContainerInset.left + self.textContainer.lineFragmentPadding)
            make.right.equalTo(self.snp.right).inset(self.textContainerInset.right + self.textContainer.lineFragmentPadding)
            make.bottom.lessThanOrEqualTo(self.snp.bottom).inset(self.textContainerInset.bottom)
        }
        
        updatePlaceholderPreferredWidth()
    }
    
    // Ensures the placeholder label wraps text to multiple lines by setting
    // `preferredMaxLayoutWidth` to the available width inside the text view.
    // Without this, UILabel will not wrap and the placeholder will be clipped.
    private func updatePlaceholderPreferredWidth() {
        guard let placeholderLabel = placeholderLabel else { return }
        
        let leftInset = self.textContainerInset.left + self.textContainer.lineFragmentPadding
        let rightInset = self.textContainerInset.right + self.textContainer.lineFragmentPadding
        let maxWidth = self.bounds.width - leftInset - rightInset
        
        guard placeholderLabel.preferredMaxLayoutWidth != maxWidth else { return }
        
        placeholderLabel.preferredMaxLayoutWidth = maxWidth
        placeholderLabel.setNeedsLayout()
    }
}
