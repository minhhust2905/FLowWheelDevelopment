; ============================================================================
; FLOWWHEEL - SCROLL ENGINE (Unified Handler)
; ============================================================================

; --- UNIFIED SCROLL HANDLER ---
HandleScroll(direction) {
    global gestureA_active, gestureB_active, gestureC_active
    global gestureD_active, gestureE_active, gestureF_active, MButton_scrolled
    global cfg, altKeyHeld, windowSwitchPending
    
    ; direction: 1 = Up, -1 = Down
    isUp := (direction > 0)
    
    DebugLog("Scroll " . (isUp ? "UP" : "DOWN") . " detected")
    
    ; --- PRIORITY 1: MButton + Scroll = Zoom ---
    if GetKeyState("MButton", "P") && cfg.gestures.zoom {
        if !DebounceManager.CanExecute("zoom", cfg.advanced.zoomDebounce)
            return
        if !gestureF_active {
            PlayGestureSound()
            ShowVisualFeedback(_t(isUp ? "🔍 Phóng to" : "🔍 Thu nhỏ"))
            RecordGesture("zoom")  ; Count once per gesture, not per notch
        }
        MButton_scrolled := true
        gestureF_active := true
        Send isUp ? "^{WheelUp}" : "^{WheelDown}"
        DebugLog("Gesture: Zoom " . (isUp ? "In" : "Out"))
        return
    }
    
    ; --- PRIORITY 2: RButton + XButton1 + Scroll = Volume ---
    if GetKeyState("RButton", "P") && GetKeyState("XButton1", "P") && cfg.gestures.volume {
        if !DebounceManager.CanExecute("volume", cfg.advanced.volumeDebounce)
            return
        if !gestureD_active {
            PlayGestureSound()
        }
        gestureD_active := true
        accelLevel := cfg.advanced.HasOwnProp("scrollAcceleration") ? cfg.advanced.scrollAcceleration : 0
        multiplier := AccelerationManager.GetMultiplier("volume", accelLevel)
        step := cfg.advanced.volumeStep * multiplier
        AdjustVolume(isUp ? step : -step)
        DebugLog("Gesture: Volume " . (isUp ? "Up" : "Down") . " (x" . multiplier . ")")
        return
    }
    
    ; --- PRIORITY 3: RButton + XButton2 + Scroll = Brightness ---
    if GetKeyState("RButton", "P") && GetKeyState("XButton2", "P") && cfg.gestures.brightness {
        if !DebounceManager.CanExecute("brightness", cfg.advanced.brightnessDebounce)
            return
        if !gestureE_active {
            PlayGestureSound()
        }
        gestureE_active := true
        accelLevel := cfg.advanced.HasOwnProp("scrollAcceleration") ? cfg.advanced.scrollAcceleration : 0
        multiplier := AccelerationManager.GetMultiplier("brightness", accelLevel)
        step := cfg.advanced.brightnessStep * multiplier
        AdjustBrightness(isUp ? step : -step)
        DebugLog("Gesture: Brightness " . (isUp ? "Up" : "Down") . " (x" . multiplier . ")")
        return
    }

    static lastTabDirection := 0
    static lastWinDirection := 0
    
    ; --- PRIORITY 4: XButton1 + Scroll = Window Switch (Alt+Tab) ---
    if GetKeyState("XButton1", "P") && cfg.gestures.windowSwitch {
        if !DebounceManager.CanExecute("windowSwitch", cfg.advanced.windowDebounce) {
            DebugLog("Debounce: Window Switch blocked")
            return
        }
        
        accelLevel := cfg.advanced.HasOwnProp("scrollAcceleration") ? cfg.advanced.scrollAcceleration : 0
        multiplier := AccelerationManager.GetMultiplier("windowSwitch", accelLevel)
        DebugLog("Acceleration: Window Switch multiplier=" . multiplier)
        
        ; [FIX] NEW APPROACH: Use SendEvent with explicit timing
        Critical "On"  ; Prevent interruption
        
        if (!gestureB_active) {
            PlayGestureSound()
            
            ; Send Alt Down with clear timing
            SetKeyDelay 0, 10
            SendEvent "{LAlt Down}"
            Sleep 5
            SendEvent isUp ? "+{Tab}" : "{Tab}"
            SetKeyDelay -1, -1
            
            altKeyHeld := true
            gestureB_active := true
            windowSwitchPending := true
            lastWinDirection := direction
            
            DebugLog("Gesture: Window Switch STARTED")
            ShowVisualFeedback(_t(isUp ? "🔄 Chuyển cửa sổ tiếp theo" : "🔄 Chuyển cửa sổ trước"))
        } else {
            ; Already active - just send Tab
            SetKeyDelay 0, 5
            Loop multiplier
                SendEvent isUp ? "+{Tab}" : "{Tab}"
            SetKeyDelay -1, -1
            
            if (direction != lastWinDirection) {
                lastWinDirection := direction
                ShowVisualFeedback(_t(isUp ? "🔄 Chuyển cửa sổ tiếp theo" : "🔄 Chuyển cửa sổ trước"))
            }
        }
        
        Critical "Off"
        return
    }

    ; --- PRIORITY 5: RButton + Scroll = Tab Switch ---
    if GetKeyState("RButton", "P") && cfg.gestures.tabSwitch {
        if !DebounceManager.CanExecute("tabSwitch", cfg.advanced.tabDebounce) {
            DebugLog("Debounce: Tab Switch blocked")
            return
        }
        
        if (!gestureA_active) {
            PlayGestureSound()
            gestureA_active := true
            lastTabDirection := direction
            accelLevel := cfg.advanced.HasOwnProp("scrollAcceleration") ? cfg.advanced.scrollAcceleration : 0
            multiplier := AccelerationManager.GetMultiplier("tabSwitch", accelLevel)
            DebugLog("Acceleration: Tab Switch multiplier=" . multiplier)
            Loop multiplier
                Send isUp ? "^{Tab}" : "^+{Tab}"
            ShowVisualFeedback(_t(isUp ? "🔄 Chuyển tab tiếp theo" : "🔄 Chuyển tab trước"))
            DebugLog("Gesture: Tab Switch " . (isUp ? "Next" : "Previous") . " (x" . multiplier . ")")
        } else {
            accelLevel := cfg.advanced.HasOwnProp("scrollAcceleration") ? cfg.advanced.scrollAcceleration : 0
            multiplier := AccelerationManager.GetMultiplier("tabSwitch", accelLevel)
            DebugLog("Acceleration: Tab Switch multiplier=" . multiplier)
            Loop multiplier
                Send isUp ? "^{Tab}" : "^+{Tab}"
            if (direction != lastTabDirection) {
                lastTabDirection := direction
                ShowVisualFeedback(_t(isUp ? "🔄 Chuyển tab tiếp theo" : "🔄 Chuyển tab trước"))
            }
        }
        return
    }

    ; --- PRIORITY 6: XButton2 + Scroll = Taskbar Focus ---
    if GetKeyState("XButton2", "P") && cfg.gestures.taskbarfocus {
        if !DebounceManager.CanExecute("taskbarFocus", 50) {
            DebugLog("Debounce: Taskbar Focus blocked")
            return
        }
        
        accelLevel := cfg.advanced.HasOwnProp("scrollAcceleration") ? cfg.advanced.scrollAcceleration : 0
        multiplier := AccelerationManager.GetMultiplier("taskbarFocus", accelLevel)
        DebugLog("Acceleration: Taskbar Focus multiplier=" . multiplier)
        
        static lastTaskbarDirection := 0
        if (!gestureC_active) {
            PlayGestureSound()
                Send "#{t}"
                Sleep 50  ; Đợi taskbar mở
                if (isUp) {
                    Send "{Right}"
                } else {
                    Send "{Left}"
                    Sleep 10
                    Send "{Left}"
                }
                gestureC_active := true
                lastTaskbarDirection := direction
                DebugLog("Gesture: Taskbar Focus STARTED" . (isUp ? " (phải)" : " (trái)"))
                ShowVisualFeedback(_t(isUp ? "🔳 Đang chọn taskbar (phải)" : "🔳 Đang chọn taskbar (trái)"))
        } else {
            ; Only send direction keys after first activation
            Loop multiplier
                Send isUp ? "{Right}" : "{Left}"
            if (direction != lastTaskbarDirection) {
                lastTaskbarDirection := direction
                ShowVisualFeedback(_t(isUp ? "🔳 Đang chọn taskbar (phải)" : "🔳 Đang chọn taskbar (trái)"))
            }
        }
        return
    }
    
    ; --- DEFAULT: Pass-through scroll ---
    Send isUp ? "{WheelUp}" : "{WheelDown}"
}

; --- HORIZONTAL SCROLL HANDLERS ---
*WheelLeft:: {
    global gestureA_active
    static isFirstScroll := true
    
    ; RButton + WheelLeft = Scroll Left
    if GetKeyState("RButton", "P") && cfg.gestures.horizontalScroll {
        gestureA_active := true
        
        if (isFirstScroll) {
            PlayGestureSound()
            isFirstScroll := false
            SetTimer(() => isFirstScroll := true, -200)  ; Reset after 200ms
        }
        
        HorizontalScroll(-1, isFirstScroll)  ; -1 for left direction
        return
    }
    Send "{WheelLeft}"  ; Send correct key
}

*WheelRight:: {
    global gestureA_active
    static isFirstScroll := true
    
    ; RButton + WheelRight = Scroll Right
    if GetKeyState("RButton", "P") && cfg.gestures.horizontalScroll {
        gestureA_active := true
        
        if (isFirstScroll) {
            PlayGestureSound()
            isFirstScroll := false
            SetTimer(() => isFirstScroll := true, -200)  ; Reset after 200ms
        }
        
        HorizontalScroll(1, isFirstScroll)  ; 1 for right direction
        return
    }
    Send "{WheelRight}"
}

; --- UNIFIED SCROLL HOTKEYS ---
*WheelUp::HandleScroll(1)
*WheelDown::HandleScroll(-1)

; --- SHIFT + WHEEL EMULATION FOR HORIZONTAL SCROLL ---
; Shift + WheelUp = Scroll Right (for mice without horizontal wheel)
+WheelUp:: {
    global cfg
    static isFirstScroll := true
    
    if cfg.gestures.horizontalScroll {
        if (isFirstScroll) {
            PlayGestureSound()
            isFirstScroll := false
            SetTimer(() => isFirstScroll := true, -200)  ; Reset after 200ms
        }
        HorizontalScroll(1, isFirstScroll)  ; 1 for right direction
        return
    }
    Send "+{WheelUp}"  ; Pass-through if disabled
}

; Shift + WheelDown = Scroll Left (for mice without horizontal wheel)
+WheelDown:: {
    global cfg
    static isFirstScroll := true
    
    if cfg.gestures.horizontalScroll {
        if (isFirstScroll) {
            PlayGestureSound()
            isFirstScroll := false
            SetTimer(() => isFirstScroll := true, -200)  ; Reset after 200ms
        }
        HorizontalScroll(-1, isFirstScroll)  ; -1 for left direction
        return
    }
    Send "+{WheelDown}"  ; Pass-through if disabled
}