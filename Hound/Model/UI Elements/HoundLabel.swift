//
//  HoundLabel.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/3/21.
//  Copyright © 2023 Jonathan Xakellis. All rights reserved.
//

import SnapKit
import UIKit

final class HoundLabel: UILabel, HoundUIProtocol, HoundDynamicBorder, HoundDynamicCorners {
    
    // MARK: - HoundUIProtocol
    
    var properties: JSONRequestBody = [:]
    
    // MARK: - Properties
    
    var debugCheckForOversizedFrame: Bool = true
    
    var staticCornerRadius: CGFloat? = Constant.Visual.Layer.defaultCornerRadius
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
    
    override var bounds: CGRect {
        didSet {
            if oldValue != bounds {
                updateCornerRounding()
            }
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.isUserInteractionEnabled = isEnabled
            self.alpha = isEnabled ? 1 : 0.5
        }
    }
    
    var textInsets: UIEdgeInsets = .zero {
        didSet { setNeedsDisplay(); invalidateIntrinsicContentSize() }
    }
    
    var shouldInsetText: Bool = false {
        didSet {
            textInsets = shouldInsetText ? UIEdgeInsets(
                top: ConstraintConstant.Spacing.contentTightIntraVert,
                left: ConstraintConstant.Spacing.contentIntraHori,
                bottom: ConstraintConstant.Spacing.contentTightIntraVert,
                right: ConstraintConstant.Spacing.contentIntraHori) : .zero
            updatePlaceholderLabel()
        }
    }
    
    // MARK: - Placeholder and Background Label
    
    var placeholder: String? {
        didSet {
            placeholderLabel?.text = placeholder
            updatePlaceholderLabel()
        }
    }
    private var placeholderLabel: UILabel?
    
    /// Color of the outlined background label. When set, a duplicate label is
    /// inserted behind this label with an outline matching this color. Set to
    /// `nil` to remove the background label.
    var backgroundLabelColor: UIColor? {
        didSet {
            updateBackgroundLabel()
        }
    }
    private var backgroundLabel: UILabel?
    private let backgroundLabelStrokeWidthScale: CGFloat = 0.8
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetBounds = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetBounds, limitedToNumberOfLines: numberOfLines)
        return CGRect(
            x: textRect.origin.x - textInsets.left,
            y: textRect.origin.y - textInsets.top,
            width: textRect.width + textInsets.left + textInsets.right,
            height: textRect.height + textInsets.top + textInsets.bottom
        )
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }
    
    override var text: String? {
        didSet {
            if oldValue != text {
                updatePlaceholderLabel()
                updateBackgroundLabel()
            }
        }
    }
    
    override var attributedText: NSAttributedString? {
        didSet {
            if oldValue != attributedText {
                updatePlaceholderLabel()
                updateBackgroundLabel()
            }
        }
    }
    
    override var numberOfLines: Int {
        didSet {
            if oldValue != numberOfLines {
                placeholderLabel?.numberOfLines = numberOfLines
                backgroundLabel?.numberOfLines = numberOfLines
            }
        }
    }
    
    override var contentMode: UIView.ContentMode {
        didSet {
            if oldValue != contentMode {
                placeholderLabel?.contentMode = contentMode
                backgroundLabel?.contentMode = contentMode
            }
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            if oldValue != textAlignment {
                placeholderLabel?.textAlignment = textAlignment
                backgroundLabel?.textAlignment = textAlignment
            }
        }
    }
    
    override var lineBreakMode: NSLineBreakMode {
        didSet {
            if oldValue != lineBreakMode {
                placeholderLabel?.lineBreakMode = lineBreakMode
                backgroundLabel?.lineBreakMode = lineBreakMode
            }
        }
    }
    
    override var baselineAdjustment: UIBaselineAdjustment {
        didSet {
            if oldValue != baselineAdjustment {
                placeholderLabel?.baselineAdjustment = baselineAdjustment
                backgroundLabel?.baselineAdjustment = baselineAdjustment
            }
        }
    }
    
    override var adjustsFontSizeToFitWidth: Bool {
        didSet {
            if oldValue != adjustsFontSizeToFitWidth {
                placeholderLabel?.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
                backgroundLabel?.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
            }
        }
    }
    
    override var minimumScaleFactor: CGFloat {
        didSet {
            if oldValue != minimumScaleFactor {
                placeholderLabel?.minimumScaleFactor = minimumScaleFactor
                backgroundLabel?.minimumScaleFactor = minimumScaleFactor
            }
        }
    }
    
    override var font: UIFont! {
        didSet {
            if oldValue != font {
                placeholderLabel?.font = font
                // need to recalculate the attributed text for the background label
                updateBackgroundLabel()
            }
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
        if debugCheckForOversizedFrame {
            checkForOversizedFrame()
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        // Reattach background label to the new superview if needed
        updateBackgroundLabel()
    }
    
    // MARK: - Override Functions
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateDynamicBorderColor(using: previousTraitCollection)
        
        // UI has changed its appearance to dark/light mode
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateBackgroundLabel()
        }
    }
    
    // MARK: - Functions
    
    private func applyDefaultSetup() {
        self.numberOfLines = 1
        self.contentMode = .left
        self.textAlignment = .natural
        self.lineBreakMode = .byTruncatingTail
        self.baselineAdjustment = .alignBaselines
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.825
        self.font = Constant.Visual.Font.primaryRegularLabel
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        HoundSizeDebugView.install(on: self)
        
        updateCornerRounding()
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
        
        placeholderLabel.numberOfLines = numberOfLines
        placeholderLabel.contentMode = contentMode
        placeholderLabel.textAlignment = textAlignment
        placeholderLabel.lineBreakMode = lineBreakMode
        placeholderLabel.baselineAdjustment = baselineAdjustment
        placeholderLabel.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        placeholderLabel.minimumScaleFactor = minimumScaleFactor
        placeholderLabel.font = font
        
        if placeholderLabel.superview != self {
            placeholderLabel.removeFromSuperview()
            addSubview(placeholderLabel)
        }
        
        placeholderLabel.snp.remakeConstraints { make in
            if shouldInsetText {
                make.edges.equalTo(self.snp.edges).inset(textInsets)
            }
            else {
                make.edges.equalTo(self.snp.edges)
            }
        }
    }
    
    private func updateBackgroundLabel() {
        guard let color = backgroundLabelColor else {
            backgroundLabel?.snp.removeConstraints()
            backgroundLabel?.removeFromSuperview()
            backgroundLabel = nil
            return
        }
        
        if backgroundLabel == nil {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            backgroundLabel = label
        }
        
        guard let backgroundLabel = backgroundLabel else {
            return
        }
        
        if backgroundLabel.superview !== superview, let superview = superview {
            backgroundLabel.snp.removeConstraints()
            backgroundLabel.removeFromSuperview()
            superview.insertSubview(backgroundLabel, belowSubview: self)
            backgroundLabel.snp.makeConstraints { make in
                make.edges.equalTo(self.snp.edges).inset(textInsets)
            }
        }
        
        backgroundLabel.numberOfLines = numberOfLines
        backgroundLabel.contentMode = contentMode
        backgroundLabel.textAlignment = textAlignment
        backgroundLabel.lineBreakMode = lineBreakMode
        backgroundLabel.baselineAdjustment = baselineAdjustment
        backgroundLabel.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        backgroundLabel.minimumScaleFactor = minimumScaleFactor
        backgroundLabel.font = font
        
        backgroundLabel.attributedText = NSAttributedString(string: self.text ?? "", attributes: [
            .strokeColor: color as Any,
            .foregroundColor: color as Any,
            .strokeWidth: self.font.pointSize * self.backgroundLabelStrokeWidthScale
        ])
    }
    
}
