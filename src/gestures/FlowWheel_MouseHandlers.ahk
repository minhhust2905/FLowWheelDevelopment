; ============================================================================
; FLOWWHEEL - MOUSE BUTTON HANDLERS
; ============================================================================

; --- RIGHT MOUSE BUTTON ---
*RButton:: {
    global gestureA_active, gestureB_active, gestureC_active
    global gestureD_active, gestureE_active
    
    DebugLog("RButton DOWN - States: A=" . gestureA_active . " B=" . gestureB_active . " D=" . gestureD_active . " E=" . gestureE_active)

    ; --- In Alt+Tab (XButton1 + Scroll) -> Close selected window ---
    if (gestureB_active && GetKeyState("XButton1", "P")) {
        Send "{Blind}{Delete}"
        ShowVisualFeedback(_t("❌ Đã đóng ứng dụng (Alt+Tab)"))
        DebugLog("RButton: Closed window in Alt+Tab")
        return
    }

    ; Reset gestures when starting RButton press
    gestureA_active := false
    gestureD_active := false
    gestureE_active := false
}

RButton Up:: {   
    global gestureA_active, gestureD_active, gestureE_active
    
    DebugLog("RButton UP - States: A=" . gestureA_active . " D=" . gestureD_active . " E=" . gestureE_active)
    
    ; Record Tab Switch when gesture ends
    if (gestureA_active) {
        DebugLog("Gesture: Tab Switch detected")
        DebugLog("Gesture: Tab Switch detected")
        RecordGesture("tabSwitch")
    }
    
    ; Record Volume when gesture ends (if XButton1 released)
    if (gestureD_active && !GetKeyState("XButton1", "P")) {
        DebugLog("Gesture: Volume detected")
        RecordGesture("volume")
    }
    
    ; Record Brightness when gesture ends (if XButton2 released)
    if (gestureE_active && !GetKeyState("XButton2", "P")) {
        DebugLog("Gesture: Brightness detected")
        RecordGesture("brightness")
    }
    
    ; If Volume or Brightness was used, cancel context menu
    if (gestureD_active || gestureE_active) {
        Send "{Esc}"
        DebugLog("RButton UP: Cancelled context menu (gesture was used)")
    } else if (!gestureA_active) {
        ; Normal right-click if no gesture was active
        Click "Right"
        DebugLog("RButton UP: Sent normal right-click")
    }
        
    gestureA_active := false
    
    ; Only reset Volume state if X1 is actually released
    if !GetKeyState("XButton1", "P")
        gestureD_active := false
        
    ; Only reset Brightness state if X2 is actually released
    if !GetKeyState("XButton2", "P")
        gestureE_active := false
        
    ; Reset debounce
    DebounceManager.Reset("tabSwitch")
}

; --- MIDDLE MOUSE BUTTON ---
MButton:: {
    global MButton_timer, MButton_scrolled, gestureF_active
    global gestureB_active, gestureD_active, gestureE_active, gestureA_active

    DebugLog("MButton DOWN")

    ; --- In Alt+Tab -> Close window ---
    if (gestureB_active && GetKeyState("XButton1", "P")) {
        MButton_scrolled := true 
        SendEvent "{Blind}{Delete}"
        ShowVisualFeedback(_t("❌ Đã đóng ứng dụng (Tab)"))
        DebugLog("MButton: Closed window in Alt+Tab")
        return 
    }

    ; --- RButton + MButton -> CLOSE TAB ---
    if GetKeyState("RButton", "P") && cfg.gestures.tabClose {
        MButton_scrolled := true
        gestureA_active := true
        PlayGestureSound()
        Send "^w"
        DebugLog("Gesture: Tab Close detected")
        RecordGesture("tabClose")
        ShowVisualFeedback(_t("❌ Đã đóng tab trình duyệt"))
        DebugLog("MButton: Closed browser tab")
        return
    }

    ; --- LButton + MButton -> RESTORE TAB ---
    if GetKeyState("LButton", "P") && cfg.gestures.tabRestore {
        MButton_scrolled := true
        PlayGestureSound()
        Send "^+t"
        DebugLog("Gesture: Tab Restore detected")
        RecordGesture("tabRestore")
        ShowVisualFeedback(_t("♻️ Đã khôi phục tab vừa đóng"))
        DebugLog("MButton: Restored closed tab")
        return
    }

    ; --- XButton1 + MButton -> CLOSE WINDOW ---
    if cfg.gestures.comboClose && GetKeyState("XButton1", "P") {
        MButton_scrolled := true
        gestureD_active := true
        WinClose("A")
        DebugLog("Gesture: Combo Close detected")
        RecordGesture("comboClose")
        ShowVisualFeedback(_t("❌ Đã đóng cửa sổ"))
        DebugLog("MButton: Closed active window")
        return
    }

    ; --- XButton2 + MButton -> SHOW/HIDE DESKTOP ---
    if cfg.gestures.ninjaVanish && GetKeyState("XButton2", "P") {
        MButton_scrolled := true
        gestureE_active := true
        PlayGestureSound()
        Send "#{d}"
        DebugLog("Gesture: Ninja Vanish detected")
        RecordGesture("ninjaVanish")
        ShowVisualFeedback(_t("💻 Show/Hide Desktop: Ẩn/Hiện Desktop"))
        DebugLog("MButton: Show/Hide Desktop activated")
        return
    }

    ; Start timer for Mute gesture
    MButton_timer := A_TickCount
    MButton_scrolled := false
    gestureF_active := false
}

MButton Up:: {
    global gestureF_active, MButton_timer, MButton_scrolled
    
    DebugLog("MButton UP - Timer=" . (A_TickCount - MButton_timer) . "ms, Scrolled=" . MButton_scrolled . ", ZoomActive=" . gestureF_active)
    
    ; Long press -> Mute (if mute gesture enabled)
    if (!MButton_scrolled && (A_TickCount - MButton_timer > cfg.advanced.mButtonTimeout) && cfg.gestures.mute) {
        PlayGestureSound()
        Send "{Volume_Mute}"
        DebugLog("Gesture: Mute detected")
        RecordGesture("mute")
        ShowVisualFeedback(_t("🔇 Đã bật/tắt tiếng hệ thống"))
        DebugLog("MButton UP: Mute toggled (long press)")
    }
    ; Quick click and not scrolled -> Normal middle click
    else if (!gestureF_active && !MButton_scrolled) {
        Click "Middle"
        DebugLog("MButton UP: Sent normal middle-click")
    }
    
    gestureF_active := false
    MButton_timer := 0
    MButton_scrolled := false
    DebounceManager.Reset("zoom")
}

; --- XBUTTON1 (BACK BUTTON) ---
XButton1:: {
    global gestureB_active, gestureD_active, altKeyHeld, windowSwitchPending
    
    DebugLog("XButton1 DOWN - gestureB=" . gestureB_active . " altHeld=" . altKeyHeld)
    
    ; [FIX] AGGRESSIVE: Always release Alt when pressing X1
    Critical "On"
    SetTimer(AltSafetyRelease, 0)  ; Disable safety timer
    
    ; Force release regardless of state
    SetKeyDelay 0, 30
    SendEvent "{LAlt Up}"
    SendEvent "{RAlt Up}"
    SendEvent "{Alt Up}"
    Sleep 20  ; Wait for Windows to process
    SetKeyDelay -1, -1
    
    ; Reset states
    altKeyHeld := false
    gestureB_active := false
    windowSwitchPending := false
    
    Critical "Off"
    
    ; --- X1 + X2 (Both together) = QUICK SCREENSHOT ---
    if GetKeyState("XButton2", "P") && cfg.gestures.quickScreenshot {
        PlayGestureSound()
        DebugLog("Gesture: Screenshot detected")
        RecordGesture("screenshot")
        Send "#{PrintScreen}"
        ShowVisualFeedback(_t("📸 Đã chụp màn hình!"))
        DebugLog("XButton1: Screenshot taken")
        return
    }
    
    ; --- RBUTTON + X1 = WINDOW SNAP LEFT ---
    if GetKeyState("RButton", "P") && cfg.gestures.windowSnap {
        gestureD_active := true
        PlayGestureSound()
        DebugLog("Gesture: Window Snap detected")
        RecordGesture("windowSnap")
        Send "#{Left}"
        ShowVisualFeedback(_t("⬅️ Đã ghim cửa sổ sang trái"))
        DebugLog("XButton1: Window snapped left")
        return
    }
    
    gestureB_active := false 
}

XButton1 Up:: {
    global gestureB_active, gestureD_active, altKeyHeld, windowSwitchPending
    
    DebugLog("XButton1 UP - gestureB=" . gestureB_active . " altHeld=" . altKeyHeld . " pending=" . windowSwitchPending)
    
    ; [FIX] AGGRESSIVE release when releasing X1
    if (gestureB_active || altKeyHeld || windowSwitchPending) {
        Critical "On"
        
        ; Send Alt Up multiple times with delay
        SetKeyDelay 0, 30
        SendEvent "{LAlt Up}"
        Sleep 5
        SendEvent "{RAlt Up}"
        Sleep 5  
        SendEvent "{Alt Up}"
        Sleep 30  ; Wait for Windows to close Alt+Tab UI
        SetKeyDelay -1, -1
        
        ; Record Window Switch statistics
        if (gestureB_active || windowSwitchPending) {
            DebugLog("Gesture: Window Switch detected")
            DebugLog("Gesture: Window Switch detected")
            RecordGesture("windowSwitch")
        }
        
        ; Reset states
        altKeyHeld := false
        gestureB_active := false
        windowSwitchPending := false
        
        Critical "Off"
        DebugLog("XButton1 UP: Aggressive Alt release completed")
    }
    else if (!gestureD_active) ; If NOT Volume gesture
    {
        ; --- [NEW] FEATURE: X1 ON TASKBAR TO CLOSE WINDOW ---
        if (cfg.gestures.taskbarClose) {
            MouseGetPos &mouseX, &mouseY, &hWnd, &ctrl
            try {
                winClass := WinGetClass(hWnd)
                ; Check if mouse is over Taskbar
                if (winClass = "Shell_TrayWnd" || winClass = "Shell_SecondaryTrayWnd") {
                    ; Check if hovering over thumbnail preview
                    MouseGetPos ,, &thumbHwnd
                    thumbClass := WinGetClass(thumbHwnd)
                    if (thumbClass = "TaskListThumbnailWnd") {
                        ; Click to activate preview window, then close
                        Click
                        Sleep 100 ; Increased wait time to ensure window activates
                        activeWin := WinExist("A")
                        if (activeWin) {
                            PlayGestureSound()
                            WinClose(activeWin)
                            DebugLog("Gesture: Taskbar Close detected")
                            RecordGesture("taskbarClose")
                            ShowVisualFeedback(_t("❌ Đóng window từ Taskbar (hover thumbnail)"))
                            DebugLog("Statistics: TaskbarClose++ on XButton1 over Taskbar THUMBNAIL - WinID: " . activeWin)
                        } else {
                            ; Fallback
                            PlayGestureSound()
                            Send "!{F4}"
                            RecordGesture("taskbarClose")
                            DebugLog("Statistics: TaskbarClose++ Fallback Alt+F4")
                        }
                    } else {
                        ; If only on taskbar button, click to activate first
                        Click
                        Sleep 100
                        activeWin := WinExist("A")
                        if (activeWin) {
                            PlayGestureSound()
                            WinClose(activeWin)
                            RecordGesture("taskbarClose")
                            ShowVisualFeedback(_t("❌ Đóng window từ Taskbar"))
                            DebugLog("Statistics: TaskbarClose++ on XButton1 over Taskbar Button - WinID: " . activeWin)
                        } else {
                            ; Fallback if no window is active
                            Send "{XButton1}"
                        }
                    }
                } else {
                    ; If not Taskbar, send Back button as normal
                    Send "{XButton1}"
                }
            } catch {
                Send "{XButton1}"
            }
        } else {
            ; If gesture is disabled, send Back button as normal
            Send "{XButton1}"
        }
    }
    
    ; [FIX] Reset states
    gestureB_active := false
    altKeyHeld := false
    windowSwitchPending := false
    
    ; Record Volume when gesture ends (if RButton released)
    if (gestureD_active && !GetKeyState("RButton", "P")) {
        DebugLog("Gesture: Volume detected")
        RecordGesture("volume")
    }
    
    DebugLog("XButton1 UP FINAL - all states reset")
    
    ; [IMPORTANT FIX]
    ; Only reset Volume state if right mouse button is released
    if !GetKeyState("RButton", "P")
        gestureD_active := false
    
    ; Reset debounce when window switch completes
    DebounceManager.Reset("windowSwitch")
    
    ; [FIX] Safety timer - release Alt after 50ms if still stuck
    SetTimer(AltSafetyRelease, -50)
}

; --- XBUTTON2 (FORWARD BUTTON) ---
XButton2:: {
    global gestureC_active, gestureE_active
    
    DebugLog("XButton2 DOWN")
    
    ; --- X2 + X1 (Both together) = QUICK SCREENSHOT ---
    if GetKeyState("XButton1", "P") && cfg.gestures.quickScreenshot {
        PlayGestureSound()
        DebugLog("Gesture: Screenshot detected")
        RecordGesture("screenshot")
        Send "#{PrintScreen}"
        ShowVisualFeedback(_t("📸 Đã chụp màn hình!"))
        DebugLog("XButton2: Screenshot taken")
        return
    }
    
    ; --- RBUTTON + X2 = WINDOW SNAP RIGHT ---
    if GetKeyState("RButton", "P") && cfg.gestures.windowSnap {
        gestureE_active := true
        PlayGestureSound()
        DebugLog("Gesture: Window Snap detected")
        RecordGesture("windowSnap")
        Send "#{Right}"
        ShowVisualFeedback(_t("➡️ Đã ghim cửa sổ sang phải"))
        DebugLog("XButton2: Window snapped right")
        return
    }
    
    gestureC_active := false
}

XButton2 Up:: {
    global gestureC_active, gestureE_active
    
    DebugLog("XButton2 UP - TaskbarFocus=" . gestureC_active . " Brightness=" . gestureE_active)
    
    ; Record Taskbar Focus when gesture ends
    if (gestureC_active) {
        DebugLog("Gesture: Taskbar Focus detected")
        DebugLog("Gesture: Taskbar Focus detected")
        RecordGesture("taskbarfocus")
    }
    
    ; Record Brightness when gesture ends (if RButton released)
    if (gestureE_active && !GetKeyState("RButton", "P")) {
        DebugLog("Gesture: Brightness detected")
        RecordGesture("brightness")
    }
    
    if (gestureC_active)
        Send "{Enter}"
    else if (!gestureE_active)
        Send "{XButton2}"
        
    gestureC_active := false
    
    ; [IMPORTANT FIX]
    if !GetKeyState("RButton", "P")
        gestureE_active := false
        
    ; Reset debounce
    DebounceManager.Reset("taskbarFocus")
    DebounceManager.Reset("brightness")
}