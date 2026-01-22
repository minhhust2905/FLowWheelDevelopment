; ============================================================================
; FLOWWHEEL CORE ENGINE - EASING FUNCTIONS (For smooth animations)
; ============================================================================

class EasingFunctions {
    ; Ease Out Cubic - Smooth deceleration
    static EaseOutCubic(t) {
        return 1 - (1 - t) ** 3
    }
    
    ; Ease Out Elastic - Bounce effect
    static EaseOutElastic(t) {
        c4 := (2 * 3.14159) / 3
        if (t = 0 || t = 1)
            return t
        return (2 ** (-10 * t)) * Sin((t * 10 - 0.75) * c4) + 1
    }
    
    ; Ease Out Back - Overshoot then settle
    static EaseOutBack(t) {
        c1 := 1.70158
        c3 := c1 + 1
        return 1 + c3 * ((t - 1) ** 3) + c1 * ((t - 1) ** 2)
    }
    
    ; Ease In Out Quad - Smooth acceleration and deceleration
    static EaseInOutQuad(t) {
        return (t < 0.5) ? 2 * t * t : 1 - ((-2 * t + 2) ** 2) / 2
    }
}