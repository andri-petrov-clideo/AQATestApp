import UIKit

class EnhancedHitSlider: UISlider {

    var thumbTouchExpansion: CGFloat = 15 

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let currentThumbRect = thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
        
        let expandedThumbRect = currentThumbRect.insetBy(dx: -thumbTouchExpansion, dy: -thumbTouchExpansion)
        
        if expandedThumbRect.contains(point) {
            return true 
        }
        
        return super.point(inside: point, with: event)
    }
}
