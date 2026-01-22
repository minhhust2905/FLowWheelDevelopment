; ============================================================================
; FLOWWHEEL - UI ENHANCEMENTS (Windows 11 Style)
; ============================================================================
; Hover effects, transitions, shadows, and focus indicators

; --- HELPER: APPLY ROUNDED CORNERS TO CONTROLS ---
RoundControl(hwnd, radius := 8) {
    try {
        DllCall("SetWindowRgn", "Ptr", hwnd, "Ptr",
            DllCall("CreateRoundRectRgn", "Int", 0, "Int", 0, "Int", 9999, "Int", 9999, "Int", radius, "Int", radius)
        )
    }
}

; --- ADD BUTTON HOVER EFFECT (Windows 11 Style) ---
AddButtonHover(btn) {
    ; Note: Full hover implementation requires custom WM_PAINT handling
    ; Windows provides default button hover states
    ; This is a placeholder for future custom implementation
    ; Current buttons use native Windows hover behavior
}

; --- ADD FOCUS INDICATOR (Accessibility) ---
AddFocusRing(ctrl) {
    static WM_SETFOCUS := 0x7
    static WM_KILLFOCUS := 0x8
    
    ; Note: Focus ring implementation would require WM_PAINT handling
    ; For now, this is a placeholder for future enhancement
    ; Windows handles default focus visuals
}

; --- SMOOTH OPACITY TRANSITION ---
SmoothOpacityTransition(guiHwnd, fromOpacity, toOpacity, duration := 150) {
    static WS_EX_LAYERED := 0x80000
    
    ; Make window layered if not already
    currentStyle := DllCall("GetWindowLong", "Ptr", guiHwnd, "Int", -20, "Int")
    if !(currentStyle & WS_EX_LAYERED) {
        DllCall("SetWindowLong", "Ptr", guiHwnd, "Int", -20, "Int", currentStyle | WS_EX_LAYERED)
    }
    
    steps := 10
    stepDelay := duration // steps
    opacityStep := (toOpacity - fromOpacity) / steps
    currentOp := fromOpacity
    
    Loop steps {
        currentOp += opacityStep
        DllCall("SetLayeredWindowAttributes", "Ptr", guiHwnd, "UInt", 0, "UChar", Round(currentOp), "UInt", 2)
        Sleep(stepDelay)
    }
    
    ; Ensure final opacity
    DllCall("SetLayeredWindowAttributes", "Ptr", guiHwnd, "UInt", 0, "UChar", toOpacity, "UInt", 2)
}

; --- CREATE SHADOW LAYER (Windows 11 Elevation) ---
CreateShadowLayer(x, y, w, h, color := "00000015") {
    ; Returns shadow control position for layering
    return {
        x: x + 2,
        y: y + 2,
        w: w,
        h: h,
        color: color
    }
}

; --- ADD RIPPLE EFFECT (Material Design) ---
; Note: Complex ripple requires GDI+, this is a simplified version
AddRippleEffect(btn) {
    ; Ripple effect requires GDI+ and custom drawing
    ; This is a placeholder for future implementation
    ; Current implementation uses native Windows button animations
}

; --- APPLY ALL ENHANCEMENTS TO BUTTON ---
EnhanceButton(btn, options := {}) {
    ; Default options
    if !options.HasProp("hover")
        options.hover := true
    if !options.HasProp("focus")
        options.focus := true
    if !options.HasProp("ripple")
        options.ripple := false
    
    ; Apply enhancements
    if options.hover
        AddButtonHover(btn)
    if options.focus
        AddFocusRing(btn)
    if options.ripple
        AddRippleEffect(btn)
    
    return btn
}

; --- SMOOTH SCROLL ANIMATION ---
; Can be used for listboxes, edit controls, etc.
SmoothScrollTo(ctrl, targetPosition, duration := 200) {
    ; Placeholder for smooth scroll implementation
    ; Would require control-specific handling
}

; --- APPLY ELEVATION SHADOW (DWM) ---
ApplyDWMShadow(guiHwnd) {
    ; Use Windows Desktop Window Manager for real shadow
    ; DWMWA_NCRENDERING_POLICY = 2, DWMNCRP_ENABLED = 2
    try {
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", guiHwnd, "Int", 2, "Int*", 2, "Int", 4)
        
        ; Add shadow margin
        ; DWMWA_EXTENDED_FRAME_BOUNDS = 9
        margins := Buffer(16)
        NumPut("Int", 1, margins, 0)   ; left
        NumPut("Int", 1, margins, 4)   ; right  
        NumPut("Int", 1, margins, 8)   ; top
        NumPut("Int", 1, margins, 12)  ; bottom
        DllCall("dwmapi\DwmExtendFrameIntoClientArea", "Ptr", guiHwnd, "Ptr", margins)
    }
}

; --- ADD ENTRANCE ANIMATION ---
AnimateEntrance(guiHwnd, type := "fade") {
    switch type {
        case "fade":
            SmoothOpacityTransition(guiHwnd, 0, 255, 150)
        case "slide":
            ; Slide from top (placeholder)
            ; Would require DWM animation APIs
        case "scale":
            ; Scale from center (placeholder)
            ; Would require more complex implementation
    }
}

; --- IMPROVED BUTTON STYLE (Windows 11) ---
StyleButton(btn, type := "standard") {
    ; Apply consistent styling based on button type
    switch type {
        case "primary":
            btn.SetFont("s10 bold", "Segoe UI")
        case "secondary":
            btn.SetFont("s10", "Segoe UI")
        case "accent":
            btn.SetFont("s10 bold", "Segoe UI Semibold")
        default:
            btn.SetFont("s9", "Segoe UI")
    }
    
    return btn
}
