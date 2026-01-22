; ============================================================================
; FLOWWHEEL - DEBUG LOGGING SYSTEM
; ============================================================================

; --- DEBUG LOG FUNCTION ---
DebugLog(message, level := "INFO") {
    global cfg
    
    ; Check if debug mode is enabled
    if !cfg.advanced.debugMode
        return
    
    ; Create timestamp with milliseconds
    timestamp := FormatTime(, "HH:mm:ss.") . SubStr(A_TickCount, -3)
    
    ; Format log line
    logLine := "[" . timestamp . "] [" . level . "] " . message
    
    ; Output to debugger (View with DebugView or VS Code Debug Console)
    OutputDebug(logLine)
    
    ; Optional: Write to file for persistent logging
    ; Uncomment if you want file logging
    /*
    try {
        logFile := A_ScriptDir . "\flowwheel_debug.log"
        FileAppend(logLine . "`n", logFile)
    } catch {
        ; Silent fail on file write error
    }
    */
}

; --- HELPER: CHECK IF DEBUG MODE ENABLED ---
IsDebugMode() {
    global cfg
    return cfg.advanced.debugMode
}