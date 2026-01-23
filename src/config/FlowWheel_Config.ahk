; ============================================================================
; FLOWWHEEL - CONFIGURATION MANAGEMENT
; ============================================================================

; --- LOAD CONFIGURATION FROM FILE ---
LoadConfig() {
    try {
        ; Luôn dùng đúng file config/stats tại thư mục gốc dự án
        configFile := "E:\FlowWheelModule\resources\config\flowwheel.ini"
        if !FileExist(configFile) {
            ; Nếu chưa có, tạo thư mục
            SplitPath(configFile, , &configDir)
            if !DirExist(configDir)
                DirCreate(configDir)
        }
        
        ; Load config if file exists
        if FileExist(configFile) {
            ; ...existing code...
            cfg.firstRun := Integer(IniRead(configFile, "General", "firstRun", 1))
            cfg.language := IniRead(configFile, "General", "language", "en")
            ; ...existing code...
        }
        ; Nếu lần đầu chạy và chưa có thiết lập ngôn ngữ, tự động phát hiện ngôn ngữ hệ điều hành
        if (cfg.firstRun = 1) {
            if (!cfg.HasOwnProp("language") || cfg.language = "" || cfg.language = "en") {
                ; Lấy mã ngôn ngữ hệ điều hành
                langId := DllCall("GetUserDefaultUILanguage")
                if (langId = 1066) { ; 1066 = Vietnamese
                    cfg.language := "vi"
                } else {
                    cfg.language := "en"
                }
                IniWrite(cfg.language, configFile, "General", "language")
            }
        }
    } catch as err {
        MsgBox(_t("Error loading config") . ": " . err.Message, _t("Config Error"), "Icon!")
    }
}

; --- SAVE CONFIGURATION TO FILE ---
SaveConfig() {
    try {
        ; Luôn dùng đúng file config/stats tại thư mục gốc dự án
        configFile := "E:\FlowWheelModule\resources\config\flowwheel.ini"
        SplitPath(configFile, , &configDir)
        if !DirExist(configDir)
            DirCreate(configDir)
        
        ; Save Gestures
        IniWrite(cfg.gestures.tabSwitch, configFile, "Gestures", "tabSwitch")
        IniWrite(cfg.gestures.windowSwitch, configFile, "Gestures", "windowSwitch")
        IniWrite(cfg.gestures.taskbarfocus, configFile, "Gestures", "taskbarfocus")
        IniWrite(cfg.gestures.zoom, configFile, "Gestures", "zoom")
        IniWrite(cfg.gestures.volume, configFile, "Gestures", "volume")
        IniWrite(cfg.gestures.brightness, configFile, "Gestures", "brightness")
        IniWrite(cfg.gestures.tabClose, configFile, "Gestures", "tabClose")
        IniWrite(cfg.gestures.tabRestore, configFile, "Gestures", "tabRestore")
        IniWrite(cfg.gestures.comboClose, configFile, "Gestures", "comboClose")
        IniWrite(cfg.gestures.taskbarClose, configFile, "Gestures", "taskbarClose")
        IniWrite(cfg.gestures.ninjaVanish, configFile, "Gestures", "ninjaVanish")
        IniWrite(cfg.gestures.mute, configFile, "Gestures", "mute")
        IniWrite(cfg.gestures.horizontalScroll, configFile, "Gestures", "horizontalScroll")
        IniWrite(cfg.gestures.quickScreenshot, configFile, "Gestures", "quickScreenshot")
        IniWrite(cfg.gestures.windowSnap, configFile, "Gestures", "windowSnap")
        
        ; Save Feedback
        IniWrite(cfg.feedback.enabled, configFile, "Feedback", "enabled")
        IniWrite(cfg.feedback.duration, configFile, "Feedback", "duration")
        IniWrite(cfg.feedback.position, configFile, "Feedback", "position")
        IniWrite(cfg.feedback.theme, configFile, "Feedback", "theme")
        IniWrite(cfg.feedback.soundEnabled, configFile, "Feedback", "soundEnabled")
        IniWrite(cfg.feedbackCooldown.lastSentTime, configFile, "Feedback", "lastSentTime")
        IniWrite(cfg.feedbackCooldown.feedbackStep, configFile, "Feedback", "feedbackStep")
        
        ; Save Advanced
        IniWrite(cfg.advanced.volumeStep, configFile, "Advanced", "volumeStep")
        IniWrite(cfg.advanced.brightnessStep, configFile, "Advanced", "brightnessStep")
        IniWrite(cfg.advanced.volumeDebounce, configFile, "Advanced", "volumeDebounce")
        IniWrite(cfg.advanced.brightnessDebounce, configFile, "Advanced", "brightnessDebounce")
        IniWrite(cfg.advanced.mButtonTimeout, configFile, "Advanced", "mButtonTimeout")
        IniWrite(cfg.advanced.scrollAcceleration, configFile, "Advanced", "scrollAcceleration")
        IniWrite(cfg.advanced.startWithWindows, configFile, "Advanced", "startWithWindows")
        IniWrite(cfg.advanced.showStartup, configFile, "Advanced", "showStartup")
        IniWrite(cfg.advanced.debugMode, configFile, "Advanced", "debugMode")
        
        ; Save Stats
        IniWrite(cfg.stats.tabSwitch, configFile, "Stats", "tabSwitch")
        IniWrite(cfg.stats.windowSwitch, configFile, "Stats", "windowSwitch")
        IniWrite(cfg.stats.taskbarfocus, configFile, "Stats", "taskbarfocus")
        IniWrite(cfg.stats.volume, configFile, "Stats", "volume")
        IniWrite(cfg.stats.brightness, configFile, "Stats", "brightness")
        IniWrite(cfg.stats.mute, configFile, "Stats", "mute")
        IniWrite(cfg.stats.zoom, configFile, "Stats", "zoom")
        IniWrite(cfg.stats.tabClose, configFile, "Stats", "tabClose")
        IniWrite(cfg.stats.tabRestore, configFile, "Stats", "tabRestore")
        IniWrite(cfg.stats.horizontalScroll, configFile, "Stats", "horizontalScroll")
        IniWrite(cfg.stats.screenshot, configFile, "Stats", "screenshot")
        IniWrite(cfg.stats.windowSnap, configFile, "Stats", "windowSnap")
        IniWrite(cfg.stats.feedbackSent, configFile, "Stats", "feedbackSent")
        IniWrite(cfg.stats.secondsSaved, configFile, "Stats", "secondsSaved")
        
        ; Save General
        IniWrite(cfg.firstRun, configFile, "General", "firstRun")
        IniWrite(cfg.language, configFile, "General", "language")
        
        ; Update Windows startup
        SetStartup(cfg.advanced.startWithWindows)
        
    } catch as err {
        MsgBox(_t("Error saving config") . ": " . err.Message, _t("Config Error"), "Icon!")
    }
}

; --- SET WINDOWS STARTUP ---
SetStartup(enable) {
    startupKey := "HKCU\Software\Microsoft\Windows\CurrentVersion\Run"
    appName := "FlowWheel"
    scriptPath := A_ScriptFullPath
    
    try {
        if (enable) {
            RegWrite(scriptPath, "REG_SZ", startupKey, appName)
        } else {
            try RegDelete(startupKey, appName)
        }
    } catch {
        ; Silently fail if registry access is denied
    }
}