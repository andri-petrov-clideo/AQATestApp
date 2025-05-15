import UIKit

protocol CustomSliderViewDelegate: AnyObject {
    func sliderValueChanged(to value: Float)
}

class CustomSliderView: UIView {

    weak var delegate: CustomSliderViewDelegate?

    private let privateSlider: EnhancedHitSlider = {
        let slider = EnhancedHitSlider()
        slider.minimumValue = -120
        slider.maximumValue = 120
        slider.value = 0
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isContinuous = true // Ensure continuous updates for label during drag
        slider.minimumTrackTintColor = .white
        slider.maximumTrackTintColor = .darkGray
        slider.thumbTintColor = .white // Fallback if custom image fails
        // Apply custom thumb image for better touchability
        // Make canvas larger than visible thumb for better touch area, especially vertically.
        let thumbImage = CustomSliderView.createThumbImage(canvasSize: CGSize(width: 44, height: 44), visibleThumbDiameter: 28, color: .white, borderColor: .gray, borderWidth: 0.5)
        slider.setThumbImage(thumbImage, for: .normal)
        slider.setThumbImage(thumbImage, for: .highlighted) // Can use a different image for highlighted state if desired
        return slider
    }()

    var slider: EnhancedHitSlider { // Expose the slider if its properties are needed externally
        return self.privateSlider
    }

    var value: Float {
        get { return privateSlider.value } 
        set {
            let steppedValue = round(newValue)
            // Update the slider's actual position only if it's different from the target stepped value
            // This prevents unnecessary updates if the continuous value was already close to a step.
            if privateSlider.value != steppedValue {
                privateSlider.setValue(steppedValue, animated: false)
            }
            updateValueLabel(value: steppedValue)
            sendValueChangedAction(value: steppedValue) // Ensure delegate is called with final stepped value
        }
    }

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let tickMarkView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupView()
        updateValueLabel(value: privateSlider.value)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(privateSlider)
        addSubview(valueLabel)
        addSubview(tickMarkView)
        tickMarkView.translatesAutoresizingMaskIntoConstraints = false

        privateSlider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)
        // Add targets for when the drag finishes to snap to the rounded value
        privateSlider.addTarget(self, action: #selector(sliderDragEnded(_:)), for: [.touchUpInside, .touchUpOutside])

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            privateSlider.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8),
            privateSlider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            privateSlider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),

            tickMarkView.topAnchor.constraint(equalTo: privateSlider.bottomAnchor, constant: 0),
            tickMarkView.leadingAnchor.constraint(equalTo: privateSlider.leadingAnchor),
            tickMarkView.trailingAnchor.constraint(equalTo: privateSlider.trailingAnchor),
            tickMarkView.heightAnchor.constraint(equalToConstant: 30),
            tickMarkView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }

    @objc private func sliderValueChanged(_ sender: EnhancedHitSlider) {
        // During drag, update the label to show the current rounded value for feedback.
        // The actual slider thumb moves smoothly with the finger.
        updateValueLabel(value: round(sender.value))
        // Inform the delegate about the current (rounded) potential value for live updates (e.g., image rotation).
        delegate?.sliderValueChanged(to: round(sender.value))
    }

    @objc private func sliderDragEnded(_ sender: EnhancedHitSlider) {
        // When the drag ends (finger lifted), set our 'value' property.
        // This will trigger the 'value' setter, which rounds the value and
        // updates the privateSlider to snap to that final rounded position.
        self.value = sender.value 
    }

    private func sendValueChangedAction(value: Float) { // Ensure this takes a parameter
        delegate?.sliderValueChanged(to: value)
    }

    private func updateValueLabel(value: Float) {
        valueLabel.text = String(format: "%.0f°", value)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawTickMarks()
    }

    private func drawTickMarks() {
        tickMarkView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let trackRect = privateSlider.trackRect(forBounds: privateSlider.bounds)
        let tickStartY = CGFloat(5)

        let majorTickInterval: Float = 30
        let minorTickInterval: Float = 10
        let minValue: Float = privateSlider.minimumValue
        let maxValue: Float = privateSlider.maximumValue
        let totalRange = maxValue - minValue

        guard totalRange > 0 else { return }

        for i in Int(minValue)...Int(maxValue) {
            let value = Float(i)

            let xPosition = (CGFloat((value - minValue) / totalRange) * tickMarkView.bounds.width)

            let tickPath = UIBezierPath()
            tickPath.move(to: CGPoint(x: xPosition, y: tickStartY))

            let tickLayer = CAShapeLayer()
            tickLayer.strokeColor = UIColor.lightGray.cgColor

            let isMajorTick = Int(value) % Int(majorTickInterval) == 0
            let isZeroTick = (value == 0)

            if isMajorTick || isZeroTick {
                tickLayer.lineWidth = 1.5
                tickPath.addLine(to: CGPoint(x: xPosition, y: tickStartY + 10))

                let isEdgeTick = (value == minValue || value == maxValue)
                if !isEdgeTick || value == 0 {
                    let label = UILabel()
                    label.font = UIFont.systemFont(ofSize: 10)
                    label.text = "\(Int(value))°"
                    label.textColor = .lightGray
                    label.textAlignment = .center
                    label.sizeToFit()

                    var labelX = xPosition - (label.frame.width / 2)
                    labelX = max(0, min(labelX, tickMarkView.bounds.width - label.frame.width))
                    label.frame = CGRect(x: labelX, y: tickStartY + 12, width: label.frame.width, height: label.frame.height)
                    tickMarkView.addSubview(label)
                }
            } else if Int(value) % Int(minorTickInterval) == 0 {
                tickLayer.lineWidth = 0.75
                tickPath.addLine(to: CGPoint(x: xPosition, y: tickStartY + 6))
            }
            if isMajorTick || isZeroTick || (Int(value) % Int(minorTickInterval) == 0) {
                tickLayer.path = tickPath.cgPath
                tickMarkView.layer.addSublayer(tickLayer)
            }
        }
    }

    // Helper to create a thumb image
    private static func createThumbImage(canvasSize: CGSize, visibleThumbDiameter: CGFloat, color: UIColor, borderColor: UIColor? = nil, borderWidth: CGFloat = 0) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: canvasSize)

        let image = renderer.image { ctx in
            // Calculate the rect for the visible thumb, centered within the canvas
            let thumbOriginX = (canvasSize.width - visibleThumbDiameter) / 2
            let thumbOriginY = (canvasSize.height - visibleThumbDiameter) / 2
            let visibleThumbRect = CGRect(x: thumbOriginX, y: thumbOriginY, width: visibleThumbDiameter, height: visibleThumbDiameter)

            let path = UIBezierPath(ovalIn: visibleThumbRect)
            color.setFill()
            path.fill()

            if let borderColor = borderColor, borderWidth > 0 {
                // Inset for border to be drawn inside
                let borderRect = visibleThumbRect.insetBy(dx: borderWidth / 2, dy: borderWidth / 2)
                let borderPath = UIBezierPath(ovalIn: borderRect)
                borderColor.setStroke()
                borderPath.lineWidth = borderWidth
                borderPath.stroke()
            }
        }
        return image
    }

    override var bounds: CGRect {
        didSet {
            if oldValue.size != bounds.size {
                setNeedsDisplay()
            }
        }
    }
}
