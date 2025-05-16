import UIKit

protocol CustomSliderViewDelegate: AnyObject {
    func sliderValueChanged(to value: Float)
}

class CustomSliderView: UIView, UIScrollViewDelegate {

    weak var delegate: CustomSliderViewDelegate?

    var minimumValue: Float = -120
    var maximumValue: Float = 120
    private var internalValue: Float = 0

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsHorizontalScrollIndicator = false
        sv.showsVerticalScrollIndicator = false
        sv.bounces = false
        sv.decelerationRate = .normal
        return sv
    }()

    private let scaleContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let tickMarkView: TickMarkView = {
        let tmv = TickMarkView()
        tmv.translatesAutoresizingMaskIntoConstraints = false
        return tmv
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private let centralIndicatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }()
    
    private let gradientMaskLayer = CAGradientLayer()

    private var previousScrollViewWidth: CGFloat = 0

    var value: Float {
        get { return internalValue }
        set {
            let clampedValue = max(minimumValue, min(maximumValue, newValue))
            let valueToSet = clampedValue
            
            if internalValue != valueToSet {
                internalValue = valueToSet
                updateScrollViewOffsetToCurrentValue(animated: false)
                updateValueLabel(value: internalValue)
                delegate?.sliderValueChanged(to: internalValue)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupView()
        updateValueLabel(value: internalValue)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(scrollView)
        scrollView.addSubview(scaleContentView)
        scaleContentView.addSubview(tickMarkView)
        addSubview(valueLabel)
        addSubview(centralIndicatorView)

        scrollView.delegate = self

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            valueLabel.heightAnchor.constraint(equalToConstant: 25),

            scrollView.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 5),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            
            scaleContentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            scaleContentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            scaleContentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            scaleContentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            scaleContentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
            
            tickMarkView.topAnchor.constraint(equalTo: scaleContentView.topAnchor),
            tickMarkView.bottomAnchor.constraint(equalTo: scaleContentView.bottomAnchor),
            tickMarkView.leadingAnchor.constraint(equalTo: scaleContentView.leadingAnchor),
            tickMarkView.trailingAnchor.constraint(equalTo: scaleContentView.trailingAnchor),

            centralIndicatorView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -5),
            centralIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            centralIndicatorView.widthAnchor.constraint(equalToConstant: 2),
            centralIndicatorView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: -10)
        ])
        
        tickMarkView.minimumValue = minimumValue
        tickMarkView.maximumValue = maximumValue
        
        gradientMaskLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientMaskLayer.locations = [0, 0.1, 0.9, 1]
        gradientMaskLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientMaskLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.mask = gradientMaskLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientMaskLayer.frame = bounds
        
        let currentScrollViewWidth = scrollView.bounds.width
        guard currentScrollViewWidth > 0 else { return }

        let scaleFactor: CGFloat = 3.0
        let newScaleWidth = scrollView.bounds.width * scaleFactor
        
        if scaleContentView.constraints.first(where: { $0.firstAttribute == .width })?.constant != newScaleWidth {
            scaleContentView.constraints.first(where: { $0.firstAttribute == .width })?.isActive = false
            scaleContentView.widthAnchor.constraint(equalToConstant: newScaleWidth).isActive = true
        }
        
        scrollView.layoutIfNeeded()

        let currentScrollViewWidthAfterLayout = scrollView.bounds.width
        guard currentScrollViewWidthAfterLayout > 0 else { return }

        let horizontalInset = currentScrollViewWidthAfterLayout / 2
        if scrollView.contentInset.left != horizontalInset || scrollView.contentInset.right != horizontalInset {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: horizontalInset, bottom: 0, right: horizontalInset)
        }

        if currentScrollViewWidthAfterLayout != previousScrollViewWidth || previousScrollViewWidth == 0 {
            updateScrollViewOffsetToCurrentValue(animated: false)
            tickMarkView.setNeedsDisplay()
            previousScrollViewWidth = currentScrollViewWidthAfterLayout
        }
    }

    private func updateValueLabel(value: Float) {
        valueLabel.text = String(format: "%.0f°", value)
    }
    
    private var totalValueRange: Float { maximumValue - minimumValue }
    
    private var pixelsPerUnitOnScale: CGFloat {
        guard totalValueRange > 0, scaleContentView.bounds.width > 0 else { return 0 }
        return scaleContentView.bounds.width / CGFloat(totalValueRange)
    }

    private func valueFromScrollOffset() -> Float {
        guard pixelsPerUnitOnScale > 0 else { return minimumValue }

        let centerOfVisibleScrollView = scrollView.bounds.width / 2
        let effectiveOffsetOnScale = scrollView.contentOffset.x + centerOfVisibleScrollView
        
        let calculatedValue = minimumValue + Float(effectiveOffsetOnScale / pixelsPerUnitOnScale)
        return calculatedValue
    }

    private func updateScrollViewOffsetToCurrentValue(animated: Bool) {
        guard pixelsPerUnitOnScale > 0 else { return }

        let targetXOnScaleForInternalValue = CGFloat(internalValue - minimumValue) * pixelsPerUnitOnScale
        
        let targetContentOffsetX = targetXOnScaleForInternalValue - (scrollView.bounds.width / 2)
        
        let minPossibleContentOffsetX = -scrollView.contentInset.left
        let maxPossibleContentOffsetX = scrollView.contentSize.width - scrollView.bounds.width + scrollView.contentInset.right
        let clampedContentOffsetX = max(minPossibleContentOffsetX, min(targetContentOffsetX, maxPossibleContentOffsetX))
        
        if abs(scrollView.contentOffset.x - clampedContentOffsetX) > 0.01 {
             scrollView.setContentOffset(CGPoint(x: clampedContentOffsetX, y: 0), animated: animated)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentContinuousValue = valueFromScrollOffset()
        
        delegate?.sliderValueChanged(to: currentContinuousValue)
        
        let displayValue = round(currentContinuousValue)
        updateValueLabel(value: displayValue)

    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            let currentValue = valueFromScrollOffset()
            let snappingInterval: Float = 5.0
            let snappedValue = round(currentValue / snappingInterval) * snappingInterval
            self.value = snappedValue
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentValue = valueFromScrollOffset()
        let snappingInterval: Float = 5.0
        let snappedValue = round(currentValue / snappingInterval) * snappingInterval
        self.value = snappedValue
    }
}

class TickMarkView: UIView {
    var minimumValue: Float = -120
    var maximumValue: Float = 120

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let totalRange = maximumValue - minimumValue
        guard totalRange > 0 else { return }

        let majorTickInterval: Float = 30
        let minorTickInterval: Float = 10
        let tickStartY: CGFloat = 5
        let majorTickHeight: CGFloat = 15
        let minorTickHeight: CGFloat = 8
        let labelYOffset: CGFloat = 25

        context.setStrokeColor(UIColor.lightGray.cgColor)

        let viewWidth = bounds.width
        let pointsPerUnit = viewWidth / CGFloat(totalRange)

        for i in Int(minimumValue)...Int(maximumValue) {
            let value = Float(i)
            let xPosition = (CGFloat(value - minimumValue) * pointsPerUnit)
            
            let isMajorTick = Int(value) % Int(majorTickInterval) == 0
            let isMinorTick = Int(value) % Int(minorTickInterval) == 0
            let isZeroTick = (value == 0)

            if isMajorTick || isZeroTick {
                context.setLineWidth(isZeroTick ? 1.5 : 1.0)
                context.move(to: CGPoint(x: xPosition, y: tickStartY))
                context.addLine(to: CGPoint(x: xPosition, y: tickStartY + majorTickHeight))
                context.strokePath()
                
                let label = UILabel()
                label.font = UIFont.systemFont(ofSize: 10)
                label.textColor = .lightGray
                label.text = String(format: "%.0f", value)
                label.sizeToFit()
                var labelX = xPosition - (label.frame.width / 2)
                labelX = max(0, min(labelX, bounds.width - label.frame.width))
                label.drawText(in: CGRect(x: labelX, y: tickStartY + labelYOffset, width: label.frame.width, height: label.frame.height))
                 
            } else if isMinorTick {
                context.setLineWidth(0.75)
                context.move(to: CGPoint(x: xPosition, y: tickStartY))
                context.addLine(to: CGPoint(x: xPosition, y: tickStartY + minorTickHeight))
                context.strokePath()
            }
        }
    }
}
