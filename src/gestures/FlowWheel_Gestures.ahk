; ============================================================================
; FLOWWHEEL - GESTURE MANAGEMENT
; ============================================================================

; This file contains functions for managing gesture states and coordination
; Note: Most gesture logic is now in the mouse handlers and scroll engine

; --- RESET ALL GESTURE STATES ---
ResetAllGestures() {
    global gestureA_active, gestureB_active, gestureC_active
    global gestureD_active, gestureE_active, gestureF_active
    global MButton_scrolled, altKeyHeld, windowSwitchPending
    
    ; Reset all active gesture flags
    gestureA_active := false
    gestureB_active := false
    gestureC_active := false
    gestureD_active := false
    gestureE_active := false
    gestureF_active := false
    
    ; Reset MButton state
    MButton_scrolled := false
    
    ; Reset Alt state
    altKeyHeld := false
    windowSwitchPending := false
    
    ; Reset managers
    GestureState.ResetAll()
    DebounceManager.ResetAll()
    AccelerationManager.ResetAll()
    
    DebugLog("All gestures and managers reset")
}

; --- CHECK IF ANY GESTURE IS ACTIVE ---
IsAnyGestureActive() {
    global gestureA_active, gestureB_active, gestureC_active
    global gestureD_active, gestureE_active, gestureF_active
    
    return gestureA_active || gestureB_active || gestureC_active || 
           gestureD_active || gestureE_active || gestureF_active
}

; --- GET ACTIVE GESTURE TYPE ---
GetActiveGestureType() {
    global gestureA_active, gestureB_active, gestureC_active
    global gestureD_active, gestureE_active, gestureF_active
    
    if (gestureA_active) {
        return "TabSwitch"
    }
    if (gestureB_active) {
        return "WindowSwitch"
    }
    if (gestureC_active) {
        return "TaskbarFocus"
    }
    if (gestureD_active) {
        return "Volume"
    }
    if (gestureE_active) {
        return "Brightness"
    }
    if (gestureF_active) {
        return "Zoom"
    }
    
    return "None"
}

; --- VALIDATE GESTURE CONFIGURATION ---
ValidateGestureConfig() {
    global cfg
    
    ; Ensure all required gesture properties exist
    requiredGestures := [
        "tabSwitch", "windowSwitch", "taskbarfocus", "zoom", "volume", "brightness",
        "tabClose", "tabRestore", "comboClose", "taskbarClose", "ninjaVanish",
        "mute", "horizontalScroll", "quickScreenshot", "windowSnap", "pinWindow"
    ]
    
    for gesture in requiredGestures {
        if (!cfg.gestures.HasOwnProp(gesture)) {
            cfg.gestures.%gesture% := false
            DebugLog("Added missing gesture property: " . gesture, "WARN")
        }
    }
    
    ; Ensure all required stats properties exist
    requiredStats := [
        "tabSwitch", "windowSwitch", "taskbarfocus", "volume", "brightness", "mute", "zoom",
        "tabClose", "tabRestore", "comboClose", "taskbarClose", "ninjaVanish",
        "horizontalScroll", "screenshot", "windowSnap", "pinWindow",
        "feedbackSent", "secondsSaved"
    ]
    
    for stat in requiredStats {
        if (!cfg.stats.HasOwnProp(stat)) {
            cfg.stats.%stat% := 0
            DebugLog("Added missing stat property: " . stat, "WARN")
        }
    }
    
    ; Ensure all required savings properties exist
    requiredSavings := [
        "tabSwitch", "windowSwitch", "taskbarfocus", "volume", "brightness", "mute", "zoom",
        "tabClose", "tabRestore", "comboClose", "taskbarClose", "ninjaVanish",
        "horizontalScroll", "screenshot", "windowSnap", "pinWindow", "feedbackSent"
    ]
    
    for saving in requiredSavings {
        if (!cfg.savings.HasOwnProp(saving)) {
            cfg.savings.%saving% := 0
            DebugLog("Added missing savings property: " . saving, "WARN")
        }
    }
    
    DebugLog("Gesture configuration validated")
}

; --- INITIALIZE GESTURE SYSTEM ---
InitializeGestureSystem() {
    ; Validate configuration
    ValidateGestureConfig()
    
    ; Reset all states
    ResetAllGestures()
    
    ; Initialize managers
    DebounceManager.ResetAll()
    AccelerationManager.ResetAll()
    GestureState.ResetAll()
    
    DebugLog("Gesture system initialized")
}