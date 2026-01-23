; ============================================================================
; FlowWheel - Main Entry Point
; ============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#UseHook True

A_MenuMaskKey := "vkE8"

; ============================================================================
; ĐẢM BẢO CHỈ CÓ 1 INSTANCE FLOWWHEEL.EXE (KHI CHẠY EXE)
; ============================================================================
if (A_IsCompiled) {
    pid := ProcessExist("FlowWheel.exe")
    if (pid && pid != DllCall("GetCurrentProcessId")) {
        ProcessClose(pid)
        Sleep 500
    }
}

; ============================================================================
; INCLUDES - Load all modules
; ============================================================================

; Core Engine
#Include %A_ScriptDir%\core\FlowWheel_Core.ahk
#Include %A_ScriptDir%\core\FlowWheel_Debounce.ahk
#Include %A_ScriptDir%\core\FlowWheel_Acceleration.ahk
#Include %A_ScriptDir%\core\FlowWheel_State.ahk
#Include %A_ScriptDir%\core\FlowWheel_Easing.ahk

; Config System
#Include %A_ScriptDir%\config\FlowWheel_Language.ahk
#Include %A_ScriptDir%\config\FlowWheel_Config.ahk
#Include %A_ScriptDir%\config\FlowWheel_ExportImport.ahk

; Utilities
#Include %A_ScriptDir%\utils\FlowWheel_Debug.ahk
#Include %A_ScriptDir%\utils\FlowWheel_Utils.ahk
#Include %A_ScriptDir%\utils\FlowWheel_Webhook.ahk

; Gestures Engine
#Include %A_ScriptDir%\gestures\FlowWheel_Helpers.ahk
#Include %A_ScriptDir%\gestures\FlowWheel_MouseHandlers.ahk
#Include %A_ScriptDir%\gestures\FlowWheel_ScrollEngine.ahk
#Include %A_ScriptDir%\gestures\FlowWheel_Gestures.ahk

; UI System
#Include %A_ScriptDir%\ui\FlowWheel_OSD.ahk
#Include %A_ScriptDir%\ui\FlowWheel_Tray.ahk
#Include %A_ScriptDir%\ui\FlowWheel_UIEnhanced.ahk
#Include %A_ScriptDir%\ui\FlowWheel_Welcome.ahk
#Include %A_ScriptDir%\ui\FlowWheel_Guide.ahk
#Include %A_ScriptDir%\ui\FlowWheel_Settings.ahk
#Include %A_ScriptDir%\ui\FlowWheel_Stats.ahk
#Include %A_ScriptDir%\ui\FlowWheel_About.ahk
#Include %A_ScriptDir%\ui\FlowWheel_Support.ahk

; ============================================================================
; INITIALIZATION
; ============================================================================

; Load configuration
LoadConfig()

; Create tray menu
CreateTrayMenu()

; Auto-save on exit
OnExit((*) => SaveConfig())

; Auto-save periodically
SetTimer(() => SaveConfig(), Constants.AUTOSAVE_INTERVAL)

; Show welcome screen on first run
if (cfg.firstRun && cfg.advanced.showStartup)
    SetTimer(() => ShowWelcome(), -Constants.WELCOME_DELAY)

; Set tray icon
SetTrayIcon()

; ============================================================================
; GLOBAL HOTKEYS (Always active)
; ============================================================================

; Show gesture guide
^!h::ShowGestureGuide()

; Show settings
^!s::ShowSettings()

; Reload script
^!r::Reload()

; Toggle pause (exempt from Suspend)
#SuspendExempt
^!p::TogglePause()
#SuspendExempt False

; Exit application (exempt from Suspend)
#SuspendExempt
^!q::ExitApp()
#SuspendExempt False

; ============================================================================
; HELPER FUNCTION: Set Tray Icon
; ============================================================================

SetTrayIcon() {
    ; Tìm icon ở nhiều vị trí để đảm bảo chạy đúng khi exe nằm ở bất kỳ đâu
    iconCandidates := [
        A_ScriptDir . "\resources\icons\FlowWheel.png",
        A_ScriptDir . "\resources\FlowWheel.png",
        A_ScriptDir . "\icons\FlowWheel.png",
        A_ScriptDir . "\FlowWheel.png"
    ]
    for path in iconCandidates {
        if FileExist(path) {
            TraySetIcon(path)
            return
        }
    }
    ; Nếu không tìm thấy, giữ icon mặc định
}