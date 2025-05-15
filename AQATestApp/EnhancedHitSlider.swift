import UIKit

class EnhancedHitSlider: UISlider {

    // Increase the touch area of the thumb. Value is in points.
    var thumbTouchExpansion: CGFloat = 15 // Expand by 15 points on each side (top, bottom, left, right)

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // Get the current frame of the thumb
        let currentThumbRect = thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
        
        // Create an expanded (inflated) rect around the thumb
        // This makes the touch target larger than the visible thumb
        let expandedThumbRect = currentThumbRect.insetBy(dx: -thumbTouchExpansion, dy: -thumbTouchExpansion)
        
        // Check if the touch point is within the expanded thumb rect
        if expandedThumbRect.contains(point) {
            return true // Point is within the expanded thumb area
        }
        
        // If not in the expanded thumb, check if it's within the track itself, if desired.
        // For this specific problem, we primarily care about making the thumb easier to hit.
        // The default behavior for the track is usually sufficient.
        // So, we can fall back to the superclass's implementation for points outside the expanded thumb.
        return super.point(inside: point, with: event)
    }
}
