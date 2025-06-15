//
//  GeneralUITextView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/30/22.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class GeneralUITextView: UITextView, GeneralUIProtocol {
    
    // MARK: - GeneralUIProtocol
    
    var properties: [String: CompatibleDataTypeForJSON?] = [:]
    
    // MARK: - Properties
    
    private var hasAdjustedShouldRoundCorners: Bool = false
    /// If true, self.layer.cornerRadius = VisualConstant.LayerConstant.defaultCornerRadius. Otherwise, self.layer.cornerRadius = 0.
    var shouldRoundCorners: Bool = false {
        didSet {
            self.hasAdjustedShouldRoundCorners = true
            self.updateCornerRoundingIfNeeded()
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
    
    private let textInset: CGFloat = 7.5
    private var placeholderLabel: GeneralUILabel?
    
    // MARK: - Override Properties
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            // Make sure to incur didSet of superclass
            super.isUserInteractionEnabled = isUserInteractionEnabled
            self.alpha = isUserInteractionEnabled ? 1 : 0.5
        }
    }
    
    /// placeholder is a second GeneralUILabel that is added as a subview to this GeneralUILabel. It acts as temporary inlaid text until an actual value is input
    var placeholder: String? {
        didSet {
            guard let placeholderLabel = placeholderLabel else {
                // We do not have a placeholderLabel yet
                if let placeholder = placeholder {
                    // We have placeholder text, so make a placeholderLabel
                    let placeholderLabel = GeneralUILabel()
                    placeholderLabel.font = self.font
                    placeholderLabel.text = placeholder
                    placeholderLabel.textColor = UIColor.placeholderText
                    placeholderLabel.sizeToFit()
                    
                    self.placeholderLabel = placeholderLabel
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange), name: UITextView.textDidChangeNotification, object: nil)
                    
                    self.addSubview(placeholderLabel)
                    
                    self.updatePlaceholderLabelIsHidden()
                    self.updatePlaceholderLabelFrame()
                }
                
                return
            }
            
            placeholderLabel.text = placeholder
        }
    }
    
    override var bounds: CGRect {
        didSet {
            super.bounds = bounds
            self.updatePlaceholderLabelFrame()
        }
    }
    
    override var text: String? {
        didSet {
            guard let placeholderLabel = placeholderLabel else {
                return
            }
            
            guard let placeholderLabelText = placeholderLabel.text, placeholderLabelText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
                placeholderLabel.isHidden = true
                return
            }
            
            updatePlaceholderLabelIsHidden()
        }
    }
    
    // MARK: - Main
    
    init(huggingPriority: Float = 250, compressionResistancePriority: Float = 250) {
        super.init(frame: .zero, textContainer: nil)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .horizontal)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .vertical)
        applyDefaultSetup()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        applyDefaultSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    // MARK: - Override Functions
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // UI has changed its appearance to dark/light mode
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if let borderColor = borderColor {
                self.layer.borderColor = borderColor.cgColor
            }
        }
    }
    
    // MARK: - Functions
    
    private func applyDefaultSetup() {
        self.clipsToBounds = true
        self.isMultipleTouchEnabled = true
        self.contentMode = .scaleToFill
        self.textAlignment = .natural
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.textContainerInset = UIEdgeInsets(top: textInset, left: textInset, bottom: textInset, right: textInset)
        
        updateCornerRoundingIfNeeded()
    }
    
    private func updateCornerRoundingIfNeeded() {
        if self.hasAdjustedShouldRoundCorners == true {
            if shouldRoundCorners {
                self.layer.masksToBounds = true
            }
            self.layer.cornerRadius = shouldRoundCorners ? VisualConstant.LayerConstant.defaultCornerRadius : 0.0
            self.layer.cornerCurve = .continuous
        }
    }
    
    private func updatePlaceholderLabelFrame() {
        let width: CGFloat = {
            self.bounds.width - (textInset * 2)
        }()
        let height: CGFloat = {
            if let pointSize = self.font?.pointSize {
                return pointSize + self.textInset
            }
            else {
                return self.bounds.height - (textInset * 2)
            }
        }()
        
        placeholderLabel?.frame = CGRect(x: self.bounds.minX + textInset, y: self.bounds.minY + textInset, width: width, height: height)
    }
    
    private func updatePlaceholderLabelIsHidden() {
        // If text isn't nil and has a non-empty string, we want to hide the placeholder (since the place it was holding for now has text in it)
        placeholderLabel?.isHidden = self.text != nil && self.text?.trimmingCharacters(in: .whitespaces).isEmpty == false
    }
    
    @objc func textViewDidChange(_ textView: UITextView) {
        updatePlaceholderLabelIsHidden()
    }
    
}
