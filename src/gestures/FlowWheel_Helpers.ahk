; ============================================================================
; FLOWWHEEL - GESTURE HELPER FUNCTIONS
; ============================================================================

; --- ADJUST VOLUME ---
AdjustVolume(Amount) {
    ; Use DebounceManager
    if !DebounceManager.CanExecute("volumeAdjust", cfg.advanced.volumeDebounce)
        return

    ; Mỗi lần gửi Volume_Up/Down là 2 đơn vị, nên số lần gửi = abs(Amount) / 2, làm tròn lên
    stepSize := 2
    times := Ceil(Abs(Amount) / stepSize)
    key := (Amount > 0) ? "{Volume_Up}" : "{Volume_Down}"
    Loop times {
        Send key
        Sleep 10 ; delay nhỏ cho ổn định
    }
    ; Get and clamp current volume
    currVol := SoundGetVolume()
    clampedVol := Clamp(Round(currVol), 0, 100)
    ; Show feedback and record gesture
    ShowVisualFeedback(_t("🔊 Âm lượng"), clampedVol)
    DebugLog("Volume adjusted to: " . clampedVol . "% (raw: " . Round(currVol) . "%)")
}

; --- ADJUST BRIGHTNESS ---
AdjustBrightness(Amount) {
    ; Use DebounceManager
    if !DebounceManager.CanExecute("brightnessAdjust", cfg.advanced.brightnessDebounce)
        return

    ; WMI connection with reconnect capability
    static wmi := false
    static lastWmiCheck := 0
    
    try {
        ; Reconnect WMI if needed (every 30 seconds max)
        if (!wmi || (A_TickCount - lastWmiCheck > 30000)) {
            try {
                wmi := ComObjGet("winmgmts:\\.\root\WMI")
                lastWmiCheck := A_TickCount
            } catch {
                wmi := false
                throw Error("WMI connection failed")
            }
        }
        
        ; Query monitors
        monitors := wmi.ExecQuery("SELECT * FROM WmiMonitorBrightness WHERE Active=True")
        methods := wmi.ExecQuery("SELECT * FROM WmiMonitorBrightnessMethods WHERE Active=True")
        
        for mon in monitors {
            curr := mon.CurrentBrightness
            newBrightness := curr + Amount
            newBrightness := Clamp(newBrightness, 0, 100)
            
            ; Apply brightness
            for method in methods
                method.WmiSetBrightness(0, newBrightness)
            
            ; Clamp and show feedback
            clampedBrightness := Clamp(Round(newBrightness), 0, 100)
            ShowVisualFeedback(_t("☀️ Độ sáng"), clampedBrightness)
            
            DebugLog("Brightness adjusted to: " . clampedBrightness . "%")
            break
        }
    } catch as e {
        ShowVisualFeedback(_t("⚠️ Không thể điều chỉnh độ sáng!"))
        DebugLog("Brightness error: " . e.Message, "ERROR")
    }
}

; --- HORIZONTAL SCROLL ---
HorizontalScroll(direction, firstScroll := true) {
    global cfg
    
    ; Use DebounceManager with lower threshold for smoother scrolling
    if !DebounceManager.CanExecute("horizontalScroll", 15)
        return
    
    ; Record gesture statistics (only once per gesture)
    if (firstScroll)
        RecordGesture("horizontalScroll")
    
    ; Get acceleration multiplier
    accelLevel := cfg.advanced.HasOwnProp("scrollAcceleration") ? cfg.advanced.scrollAcceleration : 0
    multiplier := AccelerationManager.GetMultiplier("horizontalScroll", accelLevel)
    
    ; Calculate scroll amount (3x base for smooth scrolling)
    scrollAmount := 3 * multiplier
    
    ; Send horizontal scroll using Shift+Wheel for better compatibility
    ; Method 1: Try native WheelLeft/Right first (for advanced mice)
    try {
        Loop scrollAmount {
            if (direction > 0) {
                Send "{WheelRight}"
            } else {
                Send "{WheelLeft}"
            }
            Sleep 5  ; Small delay for smoothness
        }
    } catch {
        ; Fallback: Use Shift+Wheel (universal method)
        Loop scrollAmount {
            if (direction > 0) {
                Send "+{WheelUp}"  ; Shift+WheelUp = scroll right
            } else {
                Send "+{WheelDown}"  ; Shift+WheelDown = scroll left
            }
            Sleep 5  ; Small delay for smoothness
        }
    }
    
    ; Show feedback (only on first scroll or direction change)
    static lastDirection := 0
    if (firstScroll || direction != lastDirection) {
        ShowVisualFeedback(_t(direction > 0 ? "↔️ Cuộn sang phải" : "↔️ Cuộn sang trái"))
        lastDirection := direction
    }
    
    DebugLog("Horizontal scroll: " . (direction > 0 ? "Right" : "Left") . " (x" . multiplier . ")")
}

; --- PIN WINDOW (Always On Top) ---
TogglePinWindow() {
    static pinnedWindows := Map()
    
    try {
        activeHwnd := WinGetID("A")
        
        ; Check if window is already pinned
        if (pinnedWindows.Has(activeHwnd)) {
            ; Unpin window
            WinSetAlwaysOnTop(false, activeHwnd)
            pinnedWindows.Delete(activeHwnd)
            ShowVisualFeedback(_t("📌 Đã bỏ ghim cửa sổ"))
            cfg.stats.pinWindow++
            DebugLog("Window unpinned: " . activeHwnd)
        } else {
            ; Pin window
            WinSetAlwaysOnTop(true, activeHwnd)
            pinnedWindows[activeHwnd] := true
            ShowVisualFeedback(_t("📍 Đã ghim cửa sổ (Always on Top)"))
            RecordGesture("pinWindow")
            DebugLog("Window pinned: " . activeHwnd)
        }
    } catch as err {
        ShowVisualFeedback(_t("⚠️ Không thể ghim cửa sổ"))
        DebugLog("Pin window error: " . err.Message, "ERROR")
    }
}