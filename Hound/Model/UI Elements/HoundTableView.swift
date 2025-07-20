import UIKit

final class HoundTableView: UITableView, HoundUIProtocol, HoundDynamicBorder, HoundDynamicCorners {
    
    // MARK: - HoundUIProtocol
    
    var properties: JSONRequestBody = [:]
    
    // MARK: - Properties

    var shouldAutomaticallyAdjustHeight: Bool = false {
        didSet {
            if shouldAutomaticallyAdjustHeight {
                self.invalidateIntrinsicContentSize()
                self.layoutIfNeeded()
            }
        }
    }

    /// Optional view to display when table is empty. If nil, falls back to a message label.
    private var emptyStateView: UIView?
    var emptyStateEnabled: Bool = false
    /// Message string to show if table is empty and no custom view is set.
    var emptyStateMessage: String = "No content available..."
    /// Attributed message to override the plain string.
    var emptyStateAttributedMessage: NSAttributedString?
    /// Minimum height for the empty state (when using automatic height adjustment).
    var minimumEmptyStateHeight: CGFloat = 60.0

    var staticCornerRadius: CGFloat? = Constant.VisualLayer.defaultCornerRadius
    var shouldRoundCorners: Bool = false {
        didSet {
            updateCornerRounding()
        }
    }
    
    var enableDummyHeaderView: Bool = false {
        didSet {
            if enableDummyHeaderView {
                let dummyHeaderHeight: CGFloat = 100.0
                let dummyHeader = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: dummyHeaderHeight))
                self.tableHeaderView = dummyHeader
                self.contentInset = UIEdgeInsets(top: -dummyHeaderHeight, left: 0, bottom: 0, right: 0)
            }
            else {
                self.tableHeaderView = nil
                self.contentInset = .zero
            }
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

    var shadowColor: UIColor? {
        didSet {
            if let shadowColor = shadowColor {
                self.layer.shadowColor = shadowColor.cgColor
            }
        }
    }

    var shadowOffset: CGSize? {
        didSet {
            if let shadowOffset = shadowOffset {
                self.layer.shadowOffset = shadowOffset
            }
        }
    }

    var shadowRadius: CGFloat? {
        didSet {
            if let shadowRadius = shadowRadius {
                self.layer.shadowRadius = shadowRadius
            }
        }
    }

    var shadowOpacity: Float? {
        didSet {
            if let shadowOpacity = shadowOpacity {
                self.layer.shadowOpacity = shadowOpacity
            }
        }
    }

    // MARK: - Override Properties

    override var intrinsicContentSize: CGSize {
        if shouldAutomaticallyAdjustHeight {
            self.layoutIfNeeded()
            let totalRows = numberOfRowsInAllSections()
            if totalRows == 0 && emptyStateEnabled {
                // If empty, ensure there's at least enough space for the empty state
                return CGSize(width: UIView.noIntrinsicMetric, height: minimumEmptyStateHeight)
            }
            else {
                return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
            }
        }
        else {
            return super.intrinsicContentSize
        }
    }

    override var contentSize: CGSize {
        didSet {
            // Make sure to incur didSet of superclass
            super.contentSize = contentSize
            if shouldAutomaticallyAdjustHeight {
                invalidateIntrinsicContentSize()
            }
        }
    }

    override var bounds: CGRect {
        didSet {
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

    // MARK: - Main
    
    init(huggingPriority: Float = UILayoutPriority.defaultLow.rawValue, compressionResistancePriority: Float = UILayoutPriority.defaultLow.rawValue) {
        super.init(frame: .zero, style: .plain)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriority(huggingPriority), for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .horizontal)
        self.setContentCompressionResistancePriority(UILayoutPriority(compressionResistancePriority), for: .vertical)
        self.applyDefaultSetup()
    }
    
    init() {
        super.init(frame: .zero, style: .plain)
        let priority = UILayoutPriority.defaultLow.rawValue
        self.setContentHuggingPriority(UILayoutPriority(priority), for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriority(priority), for: .vertical)
        self.setContentCompressionResistancePriority(UILayoutPriority(priority), for: .horizontal)
        self.setContentCompressionResistancePriority(UILayoutPriority(priority), for: .vertical)
        self.applyDefaultSetup()
    }

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        applyDefaultSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("NIB/Storyboard is not supported")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkForOversizedFrame()
        updateEmptyStateIfNeeded()
    }

    // MARK: - Override Functions
    
    private func applyDefaultSetup() {
        self.contentMode = .scaleToFill
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.separatorStyle = .none
        self.translatesAutoresizingMaskIntoConstraints = false
        self.sectionHeaderTopPadding = 0
        
        HoundSizeDebugView.install(on: self)
        updateCornerRounding()
        updateEmptyStateIfNeeded()
    }

    override func reloadData() {
        super.reloadData()
        if shouldAutomaticallyAdjustHeight {
            self.invalidateIntrinsicContentSize()
        }
        updateEmptyStateIfNeeded()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateDynamicBorderColor(using: previousTraitCollection)

        // UI has changed its appearance to dark/light mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if let shadowColor = shadowColor {
                self.layer.shadowColor = shadowColor.cgColor
            }
        }
    }

    // MARK: - Empty State Handling

    /// Sets a custom view for the empty state (removes previous).
    func setEmptyStateView(_ view: UIView) {
        emptyStateView?.removeFromSuperview()
        emptyStateView = view
        updateEmptyStateIfNeeded()
    }

    /// Helper: Counts all rows in all sections.
    private func numberOfRowsInAllSections() -> Int {
        let dataSource = self.dataSource
        let sections = dataSource?.numberOfSections?(in: self) ?? 1
        var totalRows = 0
        for section in 0..<sections {
            totalRows += dataSource?.tableView(self, numberOfRowsInSection: section) ?? 0
        }
        return totalRows
    }

    /// Call this after data changes to update the empty state view.
    private func updateEmptyStateIfNeeded() {
        let totalRows = numberOfRowsInAllSections()
        guard emptyStateEnabled && totalRows == 0 else {
            emptyStateView?.removeFromSuperview()
            return
        }
        
        if emptyStateView == nil {
            let label = HoundLabel()
            label.textAlignment = .center
            label.numberOfLines = 0
            if let attributed = emptyStateAttributedMessage {
                label.attributedText = attributed
            }
            else {
                label.text = emptyStateMessage
            }
            label.textColor = UIColor.secondaryLabel
            
            setEmptyStateView(label)
        }
        if let emptyView = emptyStateView, emptyView.superview !== self {
            self.addSubview(emptyView)
            NSLayoutConstraint.activate([
                emptyView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                emptyView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
            ])
        }
    }
}
