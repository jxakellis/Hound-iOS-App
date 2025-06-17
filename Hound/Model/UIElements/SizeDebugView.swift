import UIKit

class SizeDebugView: UIView {
    private weak var targetView: UIView?
    private let label = UILabel()

    // MARK: – Init

    init(measuring view: UIView) {
        self.targetView = view
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 8, weight: .medium)
        label.textColor = .white
        label.isUserInteractionEnabled = true
        addSubview(label)

        // tap to toggle border
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        label.addGestureRecognizer(tap)

        layer.zPosition = .greatestFiniteMagnitude
    }

    // MARK: – Layout

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let target = targetView, let host = superview else { return }

        // update text
        let w = Int(target.bounds.width)
        let h = Int(target.bounds.height)
        label.text = "\(w)×\(h)"
        label.sizeToFit()

        // position & size ourselves over the target
        let origin = target.convert(CGPoint.zero, to: host)
        let newSize = CGSize(width: label.frame.width + 4,
                             height: label.frame.height + 4)
        frame = CGRect(origin: origin, size: newSize)

        // inset label
        label.frame.origin = CGPoint(x: 2, y: 2)
    }

    // MARK: – Tap handler

    @objc private func handleTap() {
        guard let tgt = targetView else { return }
        if tgt.layer.borderWidth > 0 {
            tgt.layer.borderWidth = 0
            tgt.layer.borderColor = nil
        }
        else {
            tgt.layer.borderWidth = 2
            tgt.layer.borderColor = UIColor.red.cgColor
        }
    }

    // MARK: – Installer

    static func install(on view: UIView) {
        DispatchQueue.main.async {
            let host = view.window
                ?? findNonClippingAncestor(of: view)
                ?? view.superview
            guard let container = host else { return }

            // avoid duplicates
            if container.subviews.contains(where: {
                guard let dbg = $0 as? SizeDebugView else { return false }
                return dbg.targetView === view
            }) { return }

            let overlay = SizeDebugView(measuring: view)
            container.addSubview(overlay)
            overlay.setNeedsLayout()
            overlay.layoutIfNeeded()
        }
    }

    private static func findNonClippingAncestor(of view: UIView) -> UIView? {
        var candidate: UIView? = view.superview
        while let c = candidate {
            if !c.clipsToBounds { return c }
            candidate = c.superview
        }
        return nil
    }
}
