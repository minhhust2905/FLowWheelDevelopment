; ============================================================================
; FLOWWHEEL - CONFIGURATION MANAGEMENT
; ============================================================================

; --- LOAD CONFIGURATION FROM FILE ---
LoadConfig() {
    try {
        ; Priority 1: Script directory resources
        configFile := A_ScriptDir . "\..\resources\config\flowwheel.ini"
        ; Priority 2: Legacy script directory
        if !FileExist(configFile)
            configFile := A_ScriptDir . "\..\resources\flowwheel.ini"
        ; Priority 3: AppData for compiled exe
        if (A_IsCompiled && !FileExist(configFile)) {
            configDir := A_AppData . "\FlowWheel"
            if !DirExist(configDir)
                DirCreate(configDir)
            configFile := configDir . "\flowwheel.ini"
        }
        
        ; Load config if file exists
        if FileExist(configFile) {
            ; Gestures
            cfg.gestures.tabSwitch := Integer(IniRead(configFile, "Gestures", "tabSwitch", 1))
            cfg.gestures.windowSwitch := Integer(IniRead(configFile, "Gestures", "windowSwitch", 1))
            cfg.gestures.taskbarfocus := Integer(IniRead(configFile, "Gestures", "taskbarfocus", 1))
            cfg.gestures.zoom := Integer(IniRead(configFile, "Gestures", "zoom", 1))
            cfg.gestures.volume := Integer(IniRead(configFile, "Gestures", "volume", 1))
            cfg.gestures.brightness := Integer(IniRead(configFile, "Gestures", "brightness", 1))
            cfg.gestures.tabClose := Integer(IniRead(configFile, "Gestures", "tabClose", 1))
            cfg.gestures.tabRestore := Integer(IniRead(configFile, "Gestures", "tabRestore", 1))
            cfg.gestures.comboClose := Integer(IniRead(configFile, "Gestures", "comboClose", 1))
            cfg.gestures.taskbarClose := Integer(IniRead(configFile, "Gestures", "taskbarClose", 1))
            cfg.gestures.ninjaVanish := Integer(IniRead(configFile, "Gestures", "ninjaVanish", 1))
            cfg.gestures.mute := Integer(IniRead(configFile, "Gestures", "mute", 0))
            cfg.gestures.horizontalScroll := Integer(IniRead(configFile, "Gestures", "horizontalScroll", 1))
            cfg.gestures.quickScreenshot := Integer(IniRead(configFile, "Gestures", "quickScreenshot", 1))
            cfg.gestures.windowSnap := Integer(IniRead(configFile, "Gestures", "windowSnap", 1))
            
            ; Feedback
            cfg.feedback.enabled := Integer(IniRead(configFile, "Feedback", "enabled", 1))
            cfg.feedback.duration := Integer(IniRead(configFile, "Feedback", "duration", 1000))
            cfg.feedback.position := IniRead(configFile, "Feedback", "position", "cursor")
            cfg.feedback.theme := IniRead(configFile, "Feedback", "theme", "dark")
            cfg.feedback.soundEnabled := Integer(IniRead(configFile, "Feedback", "soundEnabled", 1))
            cfg.feedbackCooldown.lastSentTime := Integer(IniRead(configFile, "Feedback", "lastSentTime", 0))
            cfg.feedbackCooldown.feedbackStep := Integer(IniRead(configFile, "Feedback", "feedbackStep", 1))
            
            ; Advanced
            cfg.advanced.volumeStep := Integer(IniRead(configFile, "Advanced", "volumeStep", 2))
            cfg.advanced.brightnessStep := Integer(IniRead(configFile, "Advanced", "brightnessStep", 5))
            cfg.advanced.volumeDebounce := Integer(IniRead(configFile, "Advanced", "volumeDebounce", 30))
            cfg.advanced.brightnessDebounce := Integer(IniRead(configFile, "Advanced", "brightnessDebounce", 40))
            cfg.advanced.mButtonTimeout := Integer(IniRead(configFile, "Advanced", "mButtonTimeout", 300))
            cfg.advanced.scrollAcceleration := Integer(IniRead(configFile, "Advanced", "scrollAcceleration", 0))
            cfg.advanced.startWithWindows := Integer(IniRead(configFile, "Advanced", "startWithWindows", 0))
            cfg.advanced.showStartup := Integer(IniRead(configFile, "Advanced", "showStartup", 1))
            cfg.advanced.debugMode := Integer(IniRead(configFile, "Advanced", "debugMode", 0))
            
            ; Stats
            cfg.stats.tabSwitch := Integer(IniRead(configFile, "Stats", "tabSwitch", 0))
            cfg.stats.windowSwitch := Integer(IniRead(configFile, "Stats", "windowSwitch", 0))
            cfg.stats.taskbarfocus := Integer(IniRead(configFile, "Stats", "taskbarfocus", 0))
            cfg.stats.volume := Integer(IniRead(configFile, "Stats", "volume", 0))
            cfg.stats.brightness := Integer(IniRead(configFile, "Stats", "brightness", 0))
            cfg.stats.mute := Integer(IniRead(configFile, "Stats", "mute", 0))
            cfg.stats.zoom := Integer(IniRead(configFile, "Stats", "zoom", 0))
            cfg.stats.tabClose := Integer(IniRead(configFile, "Stats", "tabClose", 0))
            cfg.stats.tabRestore := Integer(IniRead(configFile, "Stats", "tabRestore", 0))
            cfg.stats.horizontalScroll := Integer(IniRead(configFile, "Stats", "horizontalScroll", 0))
            cfg.stats.screenshot := Integer(IniRead(configFile, "Stats", "screenshot", 0))
            cfg.stats.windowSnap := Integer(IniRead(configFile, "Stats", "windowSnap", 0))
            cfg.stats.feedbackSent := Integer(IniRead(configFile, "Stats", "feedbackSent", 0))
            cfg.stats.secondsSaved := Integer(IniRead(configFile, "Stats", "secondsSaved", 0))
            
            ; General
            cfg.firstRun := Integer(IniRead(configFile, "General", "firstRun", 1))
            cfg.language := IniRead(configFile, "General", "language", "en")
            
            ; Ensure mute gesture property exists
            if (!cfg.gestures.HasOwnProp("mute"))
                cfg.gestures.mute := false
                
            ; Ensure soundEnabled property exists
            if (!cfg.feedback.HasOwnProp("soundEnabled"))
                cfg.feedback.soundEnabled := true
                
            ; Ensure scrollAcceleration property exists
            if (!cfg.advanced.HasOwnProp("scrollAcceleration"))
                cfg.advanced.scrollAcceleration := 0
        }
    } catch as err {
        MsgBox(_t("Error loading config") . ": " . err.Message, _t("Config Error"), "Icon!")
    }
}

; --- SAVE CONFIGURATION TO FILE ---
SaveConfig() {
    try {
        ; Determine config file path
        configFile := A_ScriptDir . "\..\resources\config\flowwheel.ini"
        if !FileExist(A_ScriptDir . "\..\resources\config")
            configFile := A_ScriptDir . "\..\resources\flowwheel.ini"
        
        ; If compiled and can't write to script dir, use AppData
        if (A_IsCompiled && !FileExist(configFile)) {
            configDir := A_AppData . "\FlowWheel"
            if !DirExist(configDir)
                DirCreate(configDir)
            configFile := configDir . "\flowwheel.ini"
        }
        
        ; Ensure config directory exists
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