; ============================================================================
; FLOWWHEEL CORE ENGINE - CONSTANTS & GLOBAL DEFINITIONS
; ============================================================================

; --- WINDOWS MESSAGES ---
class WM {
    static MOUSEHWHEEL := 0x20E
    static SCROLL_DELTA := 120
}

; --- CORE CONSTANTS (Avoid Magic Numbers) ---
class Constants {
    ; Timers (milliseconds)
    static AUTOSAVE_INTERVAL := 300000      ; 5 minutes
    static WELCOME_DELAY := 500
    static ALT_SAFETY_TIMEOUT := 50
    static TRAY_GUIDE_DURATION := 5000      ; 5 seconds
    
    ; Animation
    static OSD_FADE_STEP := 20
    static OSD_ANIMATE_STEP := 0.08
    static PROGRESS_ANIMATE_SPEED := 0.15
    
    ; Limits
    static MAX_STATS_VALUE := 999999999     ; Prevent integer overflow
    static MAX_FEEDBACK_FILE_SIZE := 8      ; MB (Discord limit)
    static MIN_DURATION := 100
    static MAX_DURATION := 10000
    static MIN_STEP := 1
    static MAX_STEP := 20
    
    ; Default values
    static DEFAULT_VOLUME_STEP := 2
    static DEFAULT_BRIGHTNESS_STEP := 5
    static DEFAULT_MBUTTON_TIMEOUT := 300
    static DEFAULT_DURATION := 1000
}

; --- GESTURE TYPES ---
class GestureType {
    static NONE := 0
    static TAB_SWITCH := 1
    static WINDOW_SWITCH := 2
    static TASKBAR_FOCUS := 3
    static VOLUME := 4
    static BRIGHTNESS := 5
    static ZOOM := 6
    static HORIZONTAL_SCROLL := 7
}

; --- GLOBAL VARIABLES (Legacy compatibility) ---
global gestureA_active := false
global gestureB_active := false
global gestureC_active := false
global gestureD_active := false
global gestureE_active := false
global gestureF_active := false
global MButton_timer := 0
global MButton_scrolled := false
global altKeyHeld := false
global windowSwitchPending := false

; --- GLOBAL CONFIG VARIABLES ---
global cfg := {
    gestures: {
        tabSwitch: true,
        windowSwitch: false,
        taskbarfocus: false,
        zoom: false,
        volume: false,
        brightness: false,
        tabClose: false,
        tabRestore: false,
        comboClose: false,
        taskbarClose: false,
        ninjaVanish: false,
        mute: false,
        horizontalScroll: false,
        quickScreenshot: false,
        windowSnap: false,
        pinWindow: false
    },
    feedback: {
        enabled: true,
        duration: 1000,
        position: "topright",
        theme: "dark",
        soundEnabled: true
    },
    advanced: {
        volumeStep: 2,
        brightnessStep: 5,
        volumeDebounce: 10,
        brightnessDebounce: 10,
        zoomDebounce: 10,
        tabDebounce: 50,
        windowDebounce: 70,
        timelineDebounce: 100,
        mButtonTimeout: 300,
        scrollAcceleration: 0,
        startWithWindows: true,
        showStartup: true,
        debugMode: false
    },
    stats: {
        tabSwitch: 0,
        windowSwitch: 0,
        taskbarfocus: 0,
        volume: 0,
        brightness: 0,
        mute: 0,
        zoom: 0,
        tabClose: 0,
        tabRestore: 0,
        comboClose: 0,
        taskbarClose: 0,
        ninjaVanish: 0,
        secondsSaved: 0,
        horizontalScroll: 0,
        screenshot: 0,
        windowSnap: 0,
        pinWindow: 0,
        feedbackSent: 0
    },
    savings: {
        tabSwitch: 3,
        windowSwitch: 4,
        taskbarfocus: 2,
        volume: 2,
        brightness: 2,
        mute: 1,
        zoom: 5,
        tabClose: 2,
        tabRestore: 3,
        comboClose: 4,
        taskbarClose: 6,
        ninjaVanish: 8,
        horizontalScroll: 1,
        screenshot: 5,
        windowSnap: 3,
        pinWindow: 2,
        feedbackSent: 0
    },
    firstRun: true,
    language: "en",
    feedbackCooldown: {
        lastSentTime: 0,
        feedbackStep: 1
    }
}

global colors := {
    ; === PRIMARY PALETTE (Từ núi và nước) ===
    primary: "6E7E72",         
    primaryDark: "4A5A4D",     ; Xanh rêu đậm (text, header)
    primaryLight: "A8B5B2",    ; Xanh xám núi gần (backgrounds nhẹ)
    
    ; === WATER TONES (Từ mặt nước) ===
    water: "9DADB5",           ; Xanh xám nước chính
    waterLight: "C5CFD4",      ; Xanh nước nhạt (hover, borders)
    waterDark: "798896",       ; Xanh nước đậm (shadows)
    
    ; === EARTH TONES (Từ cát/đất) ===
    earth: "B89968",           ; Vàng nâu cát
    earthLight: "D4C4A8",      ; Cát nhạt
    earthDark: "9A7F55",       ; Đất sẫm
    secondary: "B89968",       ; Alias cho earth (compatibility)
    accent: "D4C4A8",          ; Alias cho earthLight
    
    ; === WHEEL CONTRAST (Từ bánh xe) ===
    wheel: "1C1E20",           ; Đen bánh xe (CTA mạnh)
    wheelPattern: "E8EEF0",    ; Trắng họa tiết (text on dark)
    ripple: "F0F4F5",          ; Trắng gợn sóng (subtle effects)
    
    ; === SKY NEUTRALS (Từ bầu trời) ===
    sky: "E4E8E8",             ; Xám trời mờ
    skyLight: "F5F7F7",        ; Gần như trắng
    cloud: "DADFE0",           ; Mây nhạt
    
    ; === SEMANTIC COLORS (Dựa trên palette tự nhiên) ===
    success: "7A9670",         ; Xanh lá núi
    warning: "C7A76F",         ; Vàng cát ấm
    danger: "A8846B",          ; Nâu đất đỏ
    info: "8A99A6",            ; Xanh nước trung tính
    
    ; === BACKGROUNDS ===
    bg: "F2F5F5",              ; Nền chính (tone trời + nước)
    bgLight: "FAFBFB",         ; Nền sáng nhất
    bgDark: "E1E6E6",          ; Nền tối hơn (sections)
    surface: "F7F9F9",         ; Card surfaces
    surfaceVariant: "EFF2F2",  ; ✅ Surface cho các card tính năng (giữa surface và bg)
    surfaceElevated: "FFFFFF", ; Elevated cards
    
    ; === TEXT HIERARCHY ===
    text: "1C1E20",            ; Text chính (màu bánh xe)
    textPrimary: "2E3638",     ; Text quan trọng
    textSecondary: "5A6769",   ; Text phụ
    textTertiary: "8A9295",    ; Text mờ nhất
    textLight: "8A9295",       ; Alias cho textTertiary
    textOnDark: "F5F7F7",      ; Text trên nền tối
    textOnPrimary: "F5F7F7",   ; Alias cho textOnDark
    
    ; === BORDERS & DIVIDERS ===
    border: "CDD5D6",          ; Border mặc định
    borderLight: "E1E8E8",     ; Border nhạt
    borderStrong: "B0BABB",    ; Border đậm
    divider: "DFE5E5",         ; Divider mỏng
    
    ; === INTERACTIVE STATES ===
    hover: "DAE2E4",           ; Hover (water light tone)
    hoverBg: "DAE2E4",         ; Alias cho hover
    active: "6B7C6E",          ; Active (primary)
    focus: "9DADB5",           ; Focus ring (water tone)
    focusRing: "9DADB5",       ; Alias cho focus
    disabled: "C8D0D1",        ; Disabled state
    
    ; === SHADOWS ===
    shadow: "1C1E2012",        ; Shadow nhẹ (12% opacity)
    shadowMedium: "1C1E201F",  ; Shadow trung (18% opacity)
    shadowStrong: "1C1E2028",  ; Shadow đậm (25% opacity)
    
    ; === OVERLAYS ===
    overlay: "1C1E2040",       ; Dark overlay (40%)
    overlayLight: "F5F7F780",  ; Light overlay (50%)
    scrim: "1C1E2060"          ; Modal backdrop (60%)
}

; --- UI GLOBAL VARIABLES ---
global selectedFeedbackFile := ""
global feedbackImagePreview := false
global guideGui := false
global settingsGui := false
global osdGui := false
global osdTimer := 0
global osdFadeTimer := 0
global osdCurrentOpacity := 255
global osdStartY := 0
global osdTargetY := 0
global osdAnimationStep := 0
global osdIconScale := 0
global osdCurrentProgress := 0
global osdProgressBar := ""
global osdPercentText := ""
global osdTargetLevel := -1
global osdMainTextControl := ""