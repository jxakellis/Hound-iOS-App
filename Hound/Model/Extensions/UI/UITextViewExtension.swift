//
//  UITextViewPlaceholder.swift
//  TextViewPlaceholder
//
//  Copyright (c) 2017 Tijme Gommers <tijme@finnwea.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished todo so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

/// Extend UITextView and implemented UITextViewDelegate to listen for changes
extension UITextView {
    
    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderLabelForUITextView) as? GeneralUILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderLabelForUITextView) as? GeneralUILabel {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            }
            else if let newValue = newValue {
                self.addPlaceholder(newValue)
            }
        }
    }
    
    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    @objc public func textViewDidChange(_ sender: NSNotification) {
        if let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderLabelForUITextView) as? GeneralUILabel {
            togglePlaceholderLabelIsHidden(forPlaceholderLabel: placeholderLabel)
        }
    }
    
    /// Resize the placeholder GeneralUILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderLabelForUITextView) as? GeneralUILabel {
            let labelX = self.textContainer.lineFragmentPadding
            let labelY = self.textContainerInset.top - 2
            let labelWidth = self.frame.width - (labelX * 2)
            let labelHeight = placeholderLabel.frame.height
            
            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
        }
    }
    
    /// Adds a placeholder GeneralUILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = GeneralUILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.systemGray3
        placeholderLabel.tag = VisualConstant.ViewTagConstant.placeholderLabelForUITextView
        
        togglePlaceholderLabelIsHidden(forPlaceholderLabel: placeholderLabel)
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    /// Changes the isHidden status of the placeholderLabel passed, based upon the presence and contents of self.text
    private func togglePlaceholderLabelIsHidden(forPlaceholderLabel placeholderLabel: UILabel) {
        if let labelText = self.text {
            // If the text of the ui label exists, then we want to hide the placeholder label (if the ui label text contains actual characters)
            // "anyText" != "" -> true -> hide the placeholder label
            // "" != "" -> false -> show the placeholder label
            placeholderLabel.isHidden = labelText.trimmingCharacters(in: .whitespacesAndNewlines) != ""
        }
        // If the primary text of UILabel is nil, then show the placeholder label!
        else {
            placeholderLabel.isHidden = false
        }
    }
    
}
