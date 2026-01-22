; ============================================================================
; FLOWWHEEL CORE ENGINE - SCROLL ACCELERATION MANAGER
; ============================================================================

class AccelerationManager {
    static lastScrollTime := Map()
    static scrollCount := Map()
    static ACCEL_WINDOW := 300  ; Time window for acceleration (ms)
    
    ; Multiplier parameters: [base_multiplier, max_multiplier, ramp_speed]
    static LEVELS := Map(
        0, [1, 1, 0],      ; Off - no acceleration
        1, [1, 2, 3],      ; Low - light
        2, [1, 3, 4],      ; Medium - average
        3, [1, 5, 5],      ; High - strong
        4, [1, 8, 6]       ; Ultra - extreme
    )
    
    ; Get multiplier for an action based on scroll frequency
    static GetMultiplier(actionName, level) {
        if (level <= 0 || !this.LEVELS.Has(level))
            return 1
        
        now := A_TickCount
        params := this.LEVELS[level]
        
        ; Initialize if not exists
        if (!this.lastScrollTime.Has(actionName)) {
            this.lastScrollTime[actionName] := now
            this.scrollCount[actionName] := 1
            return params[1]  ; base_multiplier
        }
        
        elapsed := now - this.lastScrollTime[actionName]
        
        ; If scrolling within time window -> increase count
        if (elapsed < this.ACCEL_WINDOW) {
            this.scrollCount[actionName] := this.scrollCount[actionName] + 1
        } else {
            ; Reset if too much time passed
            this.scrollCount[actionName] := 1
        }
        
        this.lastScrollTime[actionName] := now
        
        ; Calculate multiplier based on continuous scroll count
        count := this.scrollCount[actionName]
        baseM := params[1]
        maxM := params[2]
        ramp := params[3]
        
        ; Formula: base + (count / ramp), limited by max
        multiplier := Min(baseM + Floor(count / ramp), maxM)
        
        DebugLog("Acceleration [" . actionName . "]: count=" . count . " mult=" . multiplier)
        return multiplier
    }
    
    ; Reset acceleration for specific action
    static Reset(actionName) {
        if this.lastScrollTime.Has(actionName)
            this.lastScrollTime.Delete(actionName)
        if this.scrollCount.Has(actionName)
            this.scrollCount.Delete(actionName)
    }
    
    ; Reset all acceleration data
    static ResetAll() {
        this.lastScrollTime.Clear()
        this.scrollCount.Clear()
    }
}