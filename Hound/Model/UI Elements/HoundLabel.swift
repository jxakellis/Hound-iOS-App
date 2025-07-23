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
    
    var textInsets: UIEdgeInsets = .zero {
        didSet { setNeedsDisplay(); invalidateIntrinsicContentSize() }
    }
    
    var shouldInsetText: Bool = false {
        didSet {
            textInsets = shouldInsetText ? UIEdgeInsets(top: ConstraintConstant.Spacing.contentTightIntraVert, left: ConstraintConstant.Spacing.contentIntraHori, bottom: ConstraintConstant.Spacing.contentTightIntraVert, right: ConstraintConstant.Spacing.contentIntraHori) : .zero
            updatePlaceholderLabel()
        }
    }
    
    var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            updatePlaceholderLabel()
        }
    }
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .placeholderText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
        didSet {
            updateBackgroundLabel()
        }
    }
    
    // has to be optional to prevent infinite recursion, but need HoundLabel for attributed text closure
    private var backgroundLabel: HoundLabel?
    /// Multiplier used to determine the outline stroke width based on the
    /// current font size.
    private static let backgroundLabelStrokeWidthScale: CGFloat = 0.8
    
    var debugCheckForOversizedFrame: Bool = true
    
    // MARK: - Override Properties
    
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
    
    override var bounds: CGRect {
        didSet {
            updateCornerRounding()
        }
    }
    
    override var text: String? {
        didSet {
            updatePlaceholderLabel()
        }
    }
    
    override var font: UIFont! {
        didSet {
            updateBackgroundLabel()
            updatePlaceholderLabel()
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            updateBackgroundLabel()
        }
    }
    
    override var numberOfLines: Int {
        didSet {
            updateBackgroundLabel()
        }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.isUserInteractionEnabled = isEnabled
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
            if let attributedText = attributedTextClosure?() {
                self.attributedText = attributedText
            }
            updateBackgroundLabel()
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
    
    // MARK: - Background Label
    
    private func updatePlaceholderLabel() {
        let usesPlaceholderLabel = !(placeholderLabel.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
        
        guard usesPlaceholderLabel else {
            // if theres no placeholder text but we try to constrain it, the whole houndlabel gets fucked and lays itself upon the 0 size view
            placeholderLabel.snp.removeConstraints()
            placeholderLabel.removeFromSuperview()
            return
        }
        
        placeholderLabel.isHidden = !(text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true)
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
    
    /// Adds or removes the outlined background label as needed.
    private func updateBackgroundLabel() {
        guard let color = backgroundLabelColor else {
            backgroundLabel?.snp.removeConstraints()
            backgroundLabel?.removeFromSuperview()
            backgroundLabel = nil
            return
        }
        
        if backgroundLabel == nil {
            let label = HoundLabel()
            label.debugCheckForOversizedFrame = false
            // Important to prevent recursive insets
            label.shouldInsetText = false
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
        
        backgroundLabel.minimumScaleFactor = minimumScaleFactor
        backgroundLabel.numberOfLines = numberOfLines
        backgroundLabel.textAlignment = textAlignment
        
        backgroundLabel.attributedTextClosure = { [weak self] in
            guard let self = self else { return NSAttributedString(string: "") }
            return NSAttributedString(string: self.text ?? "", attributes: [
                .strokeColor: color as Any,
                .foregroundColor: color as Any,
                .strokeWidth: self.font.pointSize * Self.backgroundLabelStrokeWidthScale,
                .font: self.font as Any
            ])
        }
    }
    
}
