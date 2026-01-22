; ============================================================================
; FLOWWHEEL - OSD (ON-SCREEN DISPLAY) - Google Material Design Style
; ============================================================================

; --- SHOW VISUAL FEEDBACK (MAIN OSD FUNCTION) ---
ShowVisualFeedback(Txt, Level := -1) {
    global osdGui, osdTimer, osdFadeTimer, osdCurrentOpacity, cfg, colors
    
    if (!cfg.feedback.enabled)
        return
    
    ; Cancel old timers
    SetTimer(OSDHide, 0)
    SetTimer(OSDFadeOut, 0)
    SetTimer(OSDAnimateIn, 0)
    SetTimer(OSDAnimateProgress, 0)

    ; If OSD exists and already has progress bar, just update target level
    if (osdGui && IsObject(osdGui)) {
        if (Level >= 0 && osdProgressBar && IsObject(osdProgressBar)) {
            ; Don't recreate GUI - just set new target and continue animating
            osdTargetLevel := Round(Level)
            ; Restart progress animation timer
            SetTimer(OSDAnimateProgress, 30)
            ; Extend display duration
            SetTimer(OSDHide, -cfg.feedback.duration)
            return
        }
        ; If not progress update case, destroy old GUI to create new one
        try osdGui.Destroy()
    }
    
    ; Determine icon and color based on content
    iconData := GetOSDIcon(Txt)
    
    ; Remove emoji from text to avoid duplication
    cleanText := RegExReplace(Txt, "^[^\w\s]*\s*", "")
    cleanText := RegExReplace(cleanText, "`n.*$", "")
    
    ; Calculate OSD width (Material Design snackbar style)
    textLen := StrLen(cleanText)
    if (Level >= 0) {
        osdW := 480 + textLen * 6
        osdW := Min(osdW, 800)
    } else {
        osdW := Max(400, Min(800, 100 + textLen * 12))
    }
    
    ; Calculate height
    baseH := (Level >= 0) ? 100 : 60
    extraH := 0
    charsPerLine := (osdW - 70) // 8
    numLines := Ceil(textLen / charsPerLine)
    if RegExMatch(cleanText, "[0-9%☀️🔊]") {
        numLines += 1
    }
    if (numLines > 1) {
        extraH := (numLines - 1) * 22
    }
    osdH := baseH + extraH
    
    ; === CREATE MATERIAL DESIGN OSD ===
    osdGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20")
    
    ; Dark theme = Google dark surface with elevation, Light = white
    osdGui.BackColor := (cfg.feedback.theme = "dark") ? "2D2D30" : "FFFFFF"
    
    cornerRadius := 16  ; Material Design rounded corners
    
    ; Icon with Google color
    osdGui.SetFont("s22", "Segoe UI Emoji")
    iconColor := (cfg.feedback.theme = "dark") ? "FFFFFF" : iconData.color
    osdGui.AddText("x14 y" . ((Level >= 0) ? "10" : "12") . " w40 h40 c" . iconColor, iconData.icon)
    
    ; Main text - Material typography
    osdGui.SetFont("s10 bold", "Segoe UI")
    textColor := (cfg.feedback.theme = "dark") ? "FFFFFF" : colors.text
    textWidth := osdW - 70
    
    global osdMainTextControl
    if (Level >= 0) {
        osdMainTextControl := osdGui.AddText("x56 y12 w" . textWidth . " c" . textColor . " +Wrap", cleanText . " " . Level . "%")
    } else {
        osdMainTextControl := osdGui.AddText("x56 y16 w" . textWidth . " c" . textColor . " +Wrap", cleanText)
    }
    
    ; === Material Progress Bar ===
    global osdProgressBar, osdPercentText, osdTargetLevel
    if (Level >= 0) {
        barWidth := osdW - 75
        if (barWidth < 350) barWidth := 350
        
        ; Google-style progress bar colors
        bgBarColor := (cfg.feedback.theme = "dark") ? "424242" : "E8EAED"
        
        osdProgressBar := osdGui.AddProgress("x56 y42 w" . barWidth . " h14 Background" . bgBarColor . " c" . iconData.color . " Range0-100 Smooth", 0)
        
        ; Percentage text
        osdGui.SetFont("s9", "Segoe UI")
        percentColor := (cfg.feedback.theme = "dark") ? "9AA0A6" : colors.textSecondary
        osdPercentText := osdGui.AddText("x56 y60 w" . barWidth . " c" . percentColor, "0%")
        
        osdTargetLevel := Clamp(Round(Level), 0, 100)
        SetTimer(OSDAnimateProgress, 16)
    } else {
        osdProgressBar := ""
        osdPercentText := ""
        osdTargetLevel := -1
    }
    
    ; Calculate display position
    CoordMode("Mouse", "Screen")
    MouseGetPos(&mx, &my)
    
    switch cfg.feedback.position {
        case "cursor":
            posX := mx + 25
            posY := my + 25
        case "center":
            MonitorGetWorkArea(MonitorGetPrimary(), &mLeft, &mTop, &mRight, &mBottom)
            posX := (mLeft + mRight) // 2 - osdW // 2
            posY := (mTop + mBottom) // 2 - osdH // 2
        case "topright":
            MonitorGetWorkArea(MonitorGetPrimary(), &mLeft, &mTop, &mRight, &mBottom)
            posX := mRight - osdW - 20
            posY := mTop + 50
    }
    
    ; Ensure not off-screen
    MonitorGetWorkArea(MonitorGetPrimary(), &mLeft, &mTop, &mRight, &mBottom)
    if (posX + osdW > mRight)
        posX := mRight - osdW - 10
    if (posY + osdH > mBottom)
        posY := mBottom - osdH - 10
    if (posX < mLeft)
        posX := mLeft + 10
    if (posY < mTop)
        posY := mTop + 10
    
    ; Initialize animation state
    global osdStartY, osdTargetY, osdAnimationStep, osdIconScale, osdCurrentProgress
    osdCurrentOpacity := 0
    osdAnimationStep := 0
    osdIconScale := 0
    osdCurrentProgress := (Level >= 0) ? 0 : -1  ; -1 means no progress bar
    
    ; Show OSD at final position (no slide to avoid jitter)
    osdGui.Show("x" . posX . " y" . posY . " w" . osdW . " h" . osdH . " NoActivate")
    
    ; Apply rounded corners using Windows 11 DWM API
    try {
        ; DWMWA_WINDOW_CORNER_PREFERENCE = 33, DWMWCP_ROUND = 2
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", osdGui.Hwnd, "Int", 33, "Int*", 2, "Int", 4)
    }
    
    ; Enhanced shadow effect with blur
    try {
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", osdGui.Hwnd, "Int", 2, "Int*", 2, "Int", 4)
    }
    
    ; Start smooth fade-in animation (30 FPS)
    SetTimer(OSDAnimateIn, 30)
    
    ; Timer to start fade-out
    osdTimer := cfg.feedback.duration
    SetTimer(OSDHide, -osdTimer)
}

; --- ANIMATE-IN WITH SMOOTH FADE-IN ---
OSDAnimateIn() {
    global osdGui, osdCurrentOpacity, osdAnimationStep
    
    if (!osdGui || !IsObject(osdGui))
        return SetTimer(OSDAnimateIn, 0)
    
    ; Increment animation step (0 to 1) - slower for smoothness
    osdAnimationStep += 0.08  ; 0.08 * 30ms ≈ 375ms total (perfect sweet spot)
    
    if (osdAnimationStep >= 1) {
        osdAnimationStep := 1
        osdCurrentOpacity := 245
        SetTimer(OSDAnimateIn, 0)
    } else {
        ; Apply smooth easing (cubic)
        easedProgress := EasingFunctions.EaseOutCubic(osdAnimationStep)
        osdCurrentOpacity := Round(245 * easedProgress)
    }
    
    ; Only fade, no movement (avoid jitter)
    try WinSetTransparent(osdCurrentOpacity, osdGui)
}

; --- ANIMATE PROGRESS BAR (SMOOTH FILL ANIMATION) ---
OSDAnimateProgress() {
    global osdProgressBar, osdPercentText, osdCurrentProgress, osdTargetLevel
    
    ; Safety check with Critical section
    Critical "On"
    
    if (!osdProgressBar || !IsObject(osdProgressBar) || osdTargetLevel < 0) {
        SetTimer(OSDAnimateProgress, 0)
        Critical "Off"
        return
    }
    
    ; Smooth approach to target
    diff := osdTargetLevel - osdCurrentProgress
    
    if (Abs(diff) < 0.5) {
        osdCurrentProgress := osdTargetLevel
        SetTimer(OSDAnimateProgress, 0)
    } else {
        ; Ease towards target
        osdCurrentProgress += diff * Constants.PROGRESS_ANIMATE_SPEED
    }
    
    ; Update UI - Clamp values to prevent overflow
    try {
        if (!osdProgressBar || !IsObject(osdProgressBar)) {
            Critical "Off"
            return
        }
        clampedProgress := Clamp(Round(osdCurrentProgress), 0, 100)
        osdProgressBar.Value := clampedProgress
        if (osdPercentText && IsObject(osdPercentText))
            osdPercentText.Value := clampedProgress . "%"
        ; If has main text control, update number next to text
        if (osdMainTextControl && IsObject(osdMainTextControl)) {
            ; Get base text without number
            baseText := RegExReplace(osdMainTextControl.Value, "[0-9]+%$", "")
            ; If volume or brightness then update number
            if InStr(baseText, "Âm lượng") || InStr(baseText, "Độ sáng") || InStr(baseText, "volume") || InStr(baseText, "brightness") {
                osdMainTextControl.Value := baseText . clampedProgress . "%"
            }
        }
    } catch as err {
        DebugLog("OSDAnimateProgress error: " . err.Message, "WARN")
        SetTimer(OSDAnimateProgress, 0)
    }
    
    Critical "Off"
}

; --- START FADE-OUT ---
OSDHide() {
    ; Stop all other timers
    SetTimer(OSDAnimateProgress, 0)
    SetTimer(OSDFadeOut, 30)  ; 30ms = smooth and no jitter
}

; --- FADE-OUT ANIMATION ---
OSDFadeOut() {
    global osdGui, osdCurrentOpacity
    
    ; Safety check with Critical
    Critical "On"
    
    if (!osdGui || !IsObject(osdGui)) {
        SetTimer(OSDFadeOut, 0)
        Critical "Off"
        return
    }
    
    ; Reduce opacity each frame
    osdCurrentOpacity -= Constants.OSD_FADE_STEP
    
    if (osdCurrentOpacity <= 0) {
        SetTimer(OSDFadeOut, 0)
        try osdGui.Destroy()
        osdGui := false
        Critical "Off"
        return
    }
    
    try WinSetTransparent(osdCurrentOpacity, osdGui)
    catch {
        SetTimer(OSDFadeOut, 0)
        osdGui := false
    }
    
    Critical "Off"
}

; --- GET OSD ICON AND COLOR (Google Material Colors) ---
GetOSDIcon(txt) {
    txt := StrLower(txt)
    
    ; Volume - Google Blue
    if InStr(txt, "âm lượng") || InStr(txt, "volume") || InStr(txt, "🔊") || InStr(txt, "🔇")
        return {icon: "🔊", color: "1A73E8", gradient: true}
    
    ; Brightness - Google Yellow/Orange
    if InStr(txt, "độ sáng") || InStr(txt, "brightness") || InStr(txt, "☀️")
        return {icon: "☀️", color: "F9AB00", gradient: true}
    
    ; Tab - Google Teal
    if InStr(txt, "tab") || InStr(txt, "🔄")
        return {icon: "🔄", color: "129EAF", gradient: false}
    
    ; Window/Desktop - Google Blue
    if InStr(txt, "cửa sổ") || InStr(txt, "window") || InStr(txt, "desktop") || InStr(txt, "💻")
        return {icon: "💻", color: "4285F4", gradient: false}
    
    ; Close/Delete - Google Red
    if InStr(txt, "đóng") || InStr(txt, "close") || InStr(txt, "❌") || InStr(txt, "xóa")
        return {icon: "❌", color: "EA4335", gradient: false}
    
    ; Screenshot - Google Green
    if InStr(txt, "chụp") || InStr(txt, "screenshot") || InStr(txt, "📸")
        return {icon: "📸", color: "34A853", gradient: false}
    
    ; Pin - Google Pink/Magenta
    if InStr(txt, "ghim") || InStr(txt, "pin") || InStr(txt, "📌") || InStr(txt, "📍")
        return {icon: "📍", color: "E91E63", gradient: false}
    
    ; Scroll - Google Teal
    if InStr(txt, "cuộn") || InStr(txt, "scroll") || InStr(txt, "↔️")
        return {icon: "↔️", color: "009688", gradient: false}
    
    ; Restore - Google Green
    if InStr(txt, "khôi phục") || InStr(txt, "restore") || InStr(txt, "♻️")
        return {icon: "♻️", color: "34A853", gradient: false}
    
    ; Mute - Google Orange/Red
    if InStr(txt, "tắt tiếng") || InStr(txt, "mute") || InStr(txt, "bật tiếng")
        return {icon: "🔇", color: "F4511E", gradient: false}
    
    ; Success - Google Green
    if InStr(txt, "✓") || InStr(txt, "✅") || InStr(txt, "thành công")
        return {icon: "✅", color: "34A853"}
    
    ; Warning - Google Yellow
    if InStr(txt, "⚠️") || InStr(txt, "cảnh báo") || InStr(txt, "warning")
        return {icon: "⚠️", color: "FBBC04"}
    
    ; Error - Google Red
    if InStr(txt, "lỗi") || InStr(txt, "error") || InStr(txt, "thất bại")
        return {icon: "❌", color: "EA4335"}
    
    ; Zoom - Google Blue
    if InStr(txt, "zoom") || InStr(txt, "phóng") || InStr(txt, "🔍")
        return {icon: "🔍", color: "1A73E8"}
    
    ; Wait - Google Yellow
    if InStr(txt, "đợi") || InStr(txt, "wait") || InStr(txt, "⏳")
        return {icon: "⏳", color: "FBBC04"}
    
    ; Send/Feedback - Google Blue
    if InStr(txt, "gửi") || InStr(txt, "send") || InStr(txt, "📤")
        return {icon: "📤", color: "1A73E8"}
    
    ; Default - Google Blue
    return {icon: "💡", color: "1A73E8"}
}