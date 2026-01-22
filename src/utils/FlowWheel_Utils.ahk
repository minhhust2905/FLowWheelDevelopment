; ============================================================================
; FLOWWHEEL - UTILITY FUNCTIONS
; ============================================================================

; --- RECORD GESTURE USAGE ---
RecordGesture(gestureName) {
    global cfg
    
    ; Safety check - prevent errors
    if (!cfg.stats.HasOwnProp(gestureName))
        return
    
    ; Increment stat with overflow protection
    if (cfg.stats.%gestureName% < Constants.MAX_STATS_VALUE)
        cfg.stats.%gestureName%++
    
    ; Add time saved if defined
    if (cfg.savings.HasOwnProp(gestureName)) {
        if (cfg.stats.secondsSaved < Constants.MAX_STATS_VALUE)
            cfg.stats.secondsSaved += cfg.savings.%gestureName%
    }
    
    DebugLog("Statistics: " . gestureName . "++ (total: " . cfg.stats.%gestureName% . ")")
}

; --- SAFE INTEGER PARSING WITH VALIDATION ---
SafeInteger(value, defaultVal, minVal := 0, maxVal := 999999) {
    try {
        num := Integer(value)
        return Clamp(num, minVal, maxVal)
    } catch {
        return defaultVal
    }
}

; --- CLAMP VALUE BETWEEN MIN AND MAX ---
Clamp(value, minVal, maxVal) {
    return (value < minVal) ? minVal : (value > maxVal ? maxVal : value)
}

; --- FORCE RELEASE ALT KEY (AGGRESSIVE APPROACH) ---
ForceReleaseAlt() {
    global altKeyHeld, gestureB_active, windowSwitchPending
    
    Critical "On"  ; Prevent interruption
    
    ; Always send Alt Up, regardless of state
    SetKeyDelay 0, 50
    
    ; Send all three types of Alt Up
    SendEvent "{LAlt Up}"
    SendEvent "{RAlt Up}" 
    SendEvent "{Alt Up}"
    
    ; Small sleep for Windows to process
    Sleep 10
    
    ; Reset all states
    altKeyHeld := false
    gestureB_active := false
    windowSwitchPending := false
    
    ; Restore KeyDelay
    SetKeyDelay -1, -1
    
    Critical "Off"
    DebugLog("ForceReleaseAlt: Aggressive release completed")
}

; --- ALT SAFETY TIMER CALLBACK ---
AltSafetyRelease() {
    global altKeyHeld, gestureB_active, windowSwitchPending
    
    ; Check if Alt is actually stuck
    if (altKeyHeld || gestureB_active || windowSwitchPending || GetKeyState("Alt", "P")) {
        Critical "On"
        SetKeyDelay 0, 30
        SendEvent "{LAlt Up}"
        SendEvent "{RAlt Up}" 
        SendEvent "{Alt Up}"
        SetKeyDelay -1, -1
        altKeyHeld := false
        gestureB_active := false
        windowSwitchPending := false
        Critical "Off"
        DebugLog("AltSafetyRelease: Forced Alt release via timer")
    }
}

; --- TOGGLE PAUSE FUNCTION ---
TogglePause() {
    static isPaused := false
    isPaused := !isPaused
    if (isPaused) {
        Suspend(true)
        ShowVisualFeedback(_t("⏸️ FlowWheel PAUSED`nPress Ctrl+Alt+P to resume"))
        A_IconTip := "FlowWheel  (PAUSED)"
    } else {
        Suspend(false)
        ShowVisualFeedback(_t("▶️ FlowWheel RESUMED"))
        A_IconTip := "FlowWheel "
    }
}