; ============================================================================
; FLOWWHEEL CORE ENGINE - GESTURE STATE MANAGER
; ============================================================================

class GestureState {
    static _lock := false
    static _current := GestureType.NONE
    
    ; Gesture flags
    static tabSwitch := false      ; gestureA - RButton + Scroll
    static windowSwitch := false   ; gestureB - XButton1 + Scroll  
    static taskbarFocus := false   ; gestureC - XButton2 + Scroll
    static volume := false         ; gestureD - RButton + X1 + Scroll
    static brightness := false     ; gestureE - RButton + X2 + Scroll
    static zoom := false           ; gestureF - MButton + Scroll
    
    ; MButton state
    static mButtonTimer := 0
    static mButtonScrolled := false
    
    ; Enter gesture state (pseudo critical section)
    static Enter() {
        if this._lock
            return false
        this._lock := true
        return true
    }
    
    ; Leave gesture state
    static Leave() {
        this._lock := false
    }
    
    ; Set active gesture type
    static SetActive(gestureType) {
        this._current := gestureType
        DebugLog("Gesture activated: " . gestureType)
    }
    
    ; Get active gesture type
    static GetActive() => this._current
    
    ; Check if any gesture is active
    static IsAnyActive() {
        return this.tabSwitch || this.windowSwitch || this.taskbarFocus 
            || this.volume || this.brightness || this.zoom
    }
    
    ; Reset all gesture states
    static ResetAll() {
        this.tabSwitch := false
        this.windowSwitch := false
        this.taskbarFocus := false
        this.volume := false
        this.brightness := false
        this.zoom := false
        this.mButtonScrolled := false
        this._current := GestureType.NONE
        DebugLog("All gestures reset")
    }
    
    ; Reset gesture if key is released
    static ResetIfKeyUp(keyName, gestureFlag) {
        if !GetKeyState(keyName, "P") {
            %gestureFlag% := false
            DebugLog("Gesture reset: " . gestureFlag . " (key released: " . keyName . ")")
        }
    }
}