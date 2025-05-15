import UIKit

protocol CustomSliderViewDelegate: AnyObject {
    func sliderValueChanged(to value: Float)
}

class CustomSliderView: UIView {

    weak var delegate: CustomSliderViewDelegate?

    private let slider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = -100
        slider.maximumValue = 100
        slider.value = 0
        slider.isContinuous = true
        slider.translatesAutoresizingMaskIntoConstraints = false
        return slider
    }()

    var value: Float {
        get { return slider.value }
        set {
            let steppedValue = round(newValue)
            slider.setValue(steppedValue, animated: true)
            sendValueChangedAction()
        }
    }

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tickMarkView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        updateValueLabel(value: slider.value)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(slider)
        addSubview(valueLabel)
        addSubview(tickMarkView)
        tickMarkView.translatesAutoresizingMaskIntoConstraints = false

        slider.addTarget(self, action: #selector(sliderValueChanged(_:)), for: .valueChanged)

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            valueLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            slider.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 5),
            slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            tickMarkView.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 0),
            tickMarkView.leadingAnchor.constraint(equalTo: slider.leadingAnchor),
            tickMarkView.trailingAnchor.constraint(equalTo: slider.trailingAnchor),
            tickMarkView.heightAnchor.constraint(equalToConstant: 40), // Height for tick marks and labels
            tickMarkView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10)
        ])
    }

    @objc private func sliderValueChanged(_ sender: UISlider) {
        let steppedValue = round(sender.value)
        sender.value = steppedValue // Snap to integer values
        updateValueLabel(value: steppedValue)
        sendValueChangedAction()
    }

    private func sendValueChangedAction() {
        delegate?.sliderValueChanged(to: slider.value)
    }
    
    private func updateValueLabel(value: Float) {
        valueLabel.text = String(format: "%.0f", value)
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawTickMarks()
    }

    private func drawTickMarks() {
        tickMarkView.layer.sublayers?.forEach { $0.removeFromSuperlayer() } // Clear old ticks

        let trackRect = slider.trackRect(forBounds: slider.bounds)
        let tickStartY = slider.frame.height / 2 + 5 // Start ticks below the slider thumb path

        let majorTickInterval: Float = 20
        let minValue: Float = -100
        let maxValue: Float = 100
        let totalRange = maxValue - minValue

        for i in 0...Int(totalRange) {
            let value = minValue + Float(i)
            let isMajorTick = Int(value) % Int(majorTickInterval) == 0
            
            let xPosition = (CGFloat((value - minValue) / totalRange) * slider.frame.width) 

            let tickPath = UIBezierPath()
            tickPath.move(to: CGPoint(x: xPosition, y: tickStartY))
            
            let tickLayer = CAShapeLayer()
            tickLayer.strokeColor = UIColor.gray.cgColor
            tickLayer.lineWidth = 1

            if isMajorTick {
                tickPath.addLine(to: CGPoint(x: xPosition, y: tickStartY + 10))
                tickLayer.lineWidth = 2
                
                let label = UILabel()
                label.font = UIFont.systemFont(ofSize: 10)
                label.text = "\(Int(value))"
                label.textAlignment = .center
                label.sizeToFit()
                // Adjust label position to be centered on the tick
                let labelX = xPosition - (label.frame.width / 2)
                // Ensure label doesn't go out of bounds
                let constrainedLabelX = max(0, min(labelX, slider.frame.width - label.frame.width))
                label.frame = CGRect(x: constrainedLabelX, y: tickStartY + 12, width: label.frame.width, height: label.frame.height)
                tickMarkView.addSubview(label)
            } else {
                tickPath.addLine(to: CGPoint(x: xPosition, y: tickStartY + 5))
            }
            tickLayer.path = tickPath.cgPath
            tickMarkView.layer.addSublayer(tickLayer)
        }
    }
    
    // Call setNeedsDisplay when bounds change to redraw ticks if view is resized
    override var bounds: CGRect {
        didSet {
            if oldValue.size != bounds.size {
                setNeedsDisplay()
            }
        }
    }
}
