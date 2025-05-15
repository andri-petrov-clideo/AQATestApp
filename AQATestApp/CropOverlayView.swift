import UIKit

class CropOverlayView: UIView {

    var gridColor: UIColor = UIColor.white.withAlphaComponent(0.7)
    var gridLineWidth: CGFloat = 1.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false // Initially, let touches pass through
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setStrokeColor(gridColor.cgColor)
        context.setLineWidth(gridLineWidth)

        let path = UIBezierPath()

        // Border
        path.append(UIBezierPath(rect: bounds))

        // Vertical lines
        let oneThirdWidth = bounds.width / 3
        path.move(to: CGPoint(x: oneThirdWidth, y: 0))
        path.addLine(to: CGPoint(x: oneThirdWidth, y: bounds.height))

        path.move(to: CGPoint(x: 2 * oneThirdWidth, y: 0))
        path.addLine(to: CGPoint(x: 2 * oneThirdWidth, y: bounds.height))

        // Horizontal lines
        let oneThirdHeight = bounds.height / 3
        path.move(to: CGPoint(x: 0, y: oneThirdHeight))
        path.addLine(to: CGPoint(x: bounds.width, y: oneThirdHeight))

        path.move(to: CGPoint(x: 0, y: 2 * oneThirdHeight))
        path.addLine(to: CGPoint(x: bounds.width, y: 2 * oneThirdHeight))

        context.addPath(path.cgPath)
        context.strokePath()
    }
    
    // Call this when the overlay needs to be redrawn, e.g., after bounds change
    func updateGrid() {
        setNeedsDisplay()
    }
}
