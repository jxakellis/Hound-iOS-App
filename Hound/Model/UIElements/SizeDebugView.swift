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

class SizeDebugView: UIView {
    private weak var targetView: UIView?
    private weak var targetVC: UIViewController?
    private let label = UILabel()
    private var cleanupTimer: Timer?
    
    // MARK: – Shared state
    private static let overlays = NSHashTable<SizeDebugView>.weakObjects()
    private static var highlightsVisible = false
    private static var highlightBoxes: [UIView] = []
    
    // MARK: – Init & teardown
    
    init(measuring view: UIView) {
        super.init(frame: .zero)
        targetView = view
        targetVC = view.closestParentViewController
        setupLabel()
        SizeDebugView.overlays.add(self)
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
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleHighlights))
        label.addGestureRecognizer(tap)
        
        layer.zPosition = .greatestFiniteMagnitude
    }
    
    // MARK: – Layout
    
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
    
    // MARK: – Highlight toggle
    
    @objc private func toggleHighlights() {
        // clear existing
        SizeDebugView.highlightBoxes.forEach { $0.removeFromSuperview() }
        SizeDebugView.highlightBoxes.removeAll()
        
        SizeDebugView.highlightsVisible.toggle()
        guard SizeDebugView.highlightsVisible else { return }
        
        // draw new highlight boxes
        for overlay in SizeDebugView.overlays.allObjects {
            guard
                let tgt = overlay.targetView,
                let container = overlay.superview
            else { continue }
            
            let boxFrame = tgt.convert(tgt.bounds, to: container)
            let box = UIView(frame: boxFrame)
            box.backgroundColor = .clear
            box.layer.borderWidth = 2
            box.layer.borderColor = UIColor.red.cgColor
            box.layer.zPosition = .greatestFiniteMagnitude
            box.isUserInteractionEnabled = false
            container.addSubview(box)
            SizeDebugView.highlightBoxes.append(box)
        }
    }
    
    // MARK: – Cleanup loop
    
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
    
    // MARK: – Installer
    
    static func install(on view: UIView) {
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
