//
//  SizeDebugView.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/26/24.
//  Copyright © 2024 Jonathan Xakellis. All rights reserved.
//

import UIKit

private extension UIApplication {
    /// Finds the currently visible (topmost) view controller.
    func topMostViewController() -> UIViewController? {
        let keyWindow = windows.first { $0.isKeyWindow }
        guard var top = keyWindow?.rootViewController else { return nil }
        while true {
            if let presented = top.presentedViewController {
                top = presented
            }
            else if let nav = top as? UINavigationController, let v = nav.visibleViewController {
                top = v
            }
            else if let tab = top as? UITabBarController, let v = tab.selectedViewController {
                top = v
            }
            else {
                break
            }
        }
        return top
    }
}

final class SizeDebugView: UIView {
    
    // MARK: - Properties
    
    private weak var targetView: UIView?
    private weak var targetVC: UIViewController?
    private let label = UILabel()
    private var cleanupTimer: Timer?
    
    /// If true, all overlays are permanently disabled and will never reappear.
    private static var permanentlyDisabled = false
    
    // MARK: - Shared state
    
    private static let overlays = NSHashTable<SizeDebugView>.weakObjects()
    private static var highlightsVisible = false
    private static var highlightBoxes: [UIView] = []
    
    // MARK: - Init & teardown
    
    init(measuring view: UIView) {
        super.init(frame: .zero)
        targetView = view
        targetVC = view.closestParentViewController
        setupLabel()
        guard Self.permanentlyDisabled == false else {
            // If overlays were nuked before init, never add self.
            return
        }
        Self.overlays.add(self)
        startCleanupLoop()
    }
    
    required init?(coder: NSCoder) { fatalError("not supported") }
    
    deinit { cleanupTimer?.invalidate() }
    
    private func setupLabel() {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 8, weight: .medium)
        label.textColor = .white
        label.isUserInteractionEnabled = true
        addSubview(label)
        
        // Single tap toggles border overlays
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleHighlights))
        label.addGestureRecognizer(tap)
        
        // Long press removes ALL overlays and disables debug forever
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 0.7
        label.addGestureRecognizer(longPress)
        
        layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let target = targetView, let host = superview else { return }
        // update label text
        let w = Int(target.bounds.width), h = Int(target.bounds.height)
        label.text = "\(w)×\(h)"
        label.sizeToFit()
        
        // position over target
        let origin = target.convert(CGPoint.zero, to: host)
        let newSize = CGSize(width: label.frame.width + 4,
                             height: label.frame.height + 4)
        frame = CGRect(origin: origin, size: newSize)
        label.frame.origin = CGPoint(x: 2, y: 2)
    }
    
    // MARK: - Highlight toggle
    
    @objc private func toggleHighlights() {
        // If overlays are disabled, don't allow toggling highlights.
        guard Self.permanentlyDisabled == false else { return }
        
        // clear existing
        Self.highlightBoxes.forEach { $0.removeFromSuperview() }
        Self.highlightBoxes.removeAll()
        
        Self.highlightsVisible.toggle()
        guard Self.highlightsVisible else { return }
        
        // draw new highlight boxes
        for overlay in Self.overlays.allObjects {
            guard
                let tgt = overlay.targetView,
                let container = overlay.superview
            else { continue }
            
            let boxFrame = tgt.convert(tgt.bounds, to: container)
            let box = UIView(frame: boxFrame)
            box.backgroundColor = .clear
            box.layer.borderWidth = HoundBorderStyle.redBorder.borderWidth
            box.layer.borderColor = HoundBorderStyle.redBorder.borderColor.cgColor
            box.layer.zPosition = CGFloat(Float.greatestFiniteMagnitude)
            box.isUserInteractionEnabled = false
            container.addSubview(box)
            Self.highlightBoxes.append(box)
        }
    }
    
    // MARK: - Long press destroyer
    
    /// Handles long-press on any label. Nukes all overlays and permanently disables further debug overlays.
    @objc private func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        
        // Permanently disable overlays for the lifetime of the app
        Self.permanentlyDisabled = true
        
        // Remove all overlays immediately
        for overlay in Self.overlays.allObjects {
            overlay.removeOverlay()
        }
        Self.overlays.removeAllObjects()
        
        // Remove all highlight boxes
        Self.highlightBoxes.forEach { $0.removeFromSuperview() }
        Self.highlightBoxes.removeAll()
        
        // Once nuked, overlays/highlights never reappear (even if install is called again)
    }
    
    // MARK: - Cleanup loop
    
    private func startCleanupLoop() {
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard
                let self = self,
                let tv = self.targetView,
                let vc = self.targetVC
            else {
                self?.removeOverlay()
                return
            }
            
            // 1) removed from hierarchy?
            if tv.superview == nil {
                removeOverlay(); return
            }
            // 2) VC still topmost?
            if UIApplication.shared.topMostViewController() !== vc {
                removeOverlay(); return
            }
            // 3) still around → update
            self.setNeedsLayout()
        }
    }
    
    private func removeOverlay() {
        cleanupTimer?.invalidate()
        removeFromSuperview()
    }
    
    // MARK: - Installer
    
    /// Installs a size debug overlay for the given view, unless overlays are permanently disabled.
    static func install(on view: UIView) {
        guard DevelopmentConstant.isProduction == false else {
            return
        }
        guard Self.permanentlyDisabled == false else { return }
        DispatchQueue.main.async {
            let host = findNonClippingAncestor(of: view) ?? view.superview
            guard let container = host else { return }
            
            // avoid dupes
            if container.subviews.contains(where: {
                ($0 as? SizeDebugView)?.targetView === view
            }) { return }
            
            let overlay = SizeDebugView(measuring: view)
            container.addSubview(overlay)
            overlay.setNeedsLayout()
            overlay.layoutIfNeeded()
        }
    }
    
    private static func findNonClippingAncestor(of view: UIView) -> UIView? {
        var c = view.superview
        while let cand = c {
            if !cand.clipsToBounds { return cand }
            c = cand.superview
        }
        return nil
    }
}
