; ============================================================================
; FLOWWHEEL - WELCOME SCREEN (Google Material Design)
; ============================================================================

; --- SHOW WELCOME SCREEN ---
ShowWelcome(*) {
    welcomeGui := Gui("+AlwaysOnTop -MaximizeBox", "Welcome to FlowWheel")
    welcomeGui.BackColor := colors.bg
    welcomeGui.MarginX := 0
    welcomeGui.MarginY := 0
    
    ; === GOOGLE MATERIAL HEADER ===
    welcomeGui.AddText("x0 y0 w500 h70 Background" . colors.primary, "")
    
    ; Main title
    welcomeGui.SetFont("s16 bold cFFFFFF", "Segoe UI")
    welcomeGui.AddText("x20 y15 Background" . colors.primary, _t("👋 Chào mừng đến với FlowWheel"))
    
    ; Sub description
    welcomeGui.SetFont("s9 c" . colors.primaryLight, "Segoe UI")
    welcomeGui.AddText("x20 y42 Background" . colors.primary, _t("Thao tác chuột mạnh mẽ cho Windows 10/11"))
    
    ; Settings button (FAB style)
    btnSettings := welcomeGui.AddButton("x455 y15 w35 h35", "⚙️")
    btnSettings.SetFont("s14", "Segoe UI Emoji") 
    btnSettings.OnEvent("Click", (*) => (welcomeGui.Destroy(), ShowSettings()))

    ; === Content Card ===
    welcomeGui.SetFont("s10 c" . colors.text, "Segoe UI")
    welcomeGui.AddText("x24 y85 w452", _t("FlowWheel giúp chuột của bạn mạnh mẽ hơn với các cử chỉ thông minh, tăng tốc làm việc và điều khiển Windows dễ dàng."))
    
    ; === Warning Card ===
    welcomeGui.AddText("x26 y132 w452 h55 Background" . colors.shadow, "")
    welcomeGui.AddText("x24 y130 w452 h55 Background" . colors.surfaceVariant, "")
    welcomeGui.SetFont("s9 bold c" . colors.danger)
    welcomeGui.AddText("x34 y140 w432 Background" . colors.surfaceVariant, _t("⚠️ Yêu cầu phần cứng"))
    welcomeGui.SetFont("s9 c" . colors.text)
    welcomeGui.AddText("x34 y160 w432 Background" . colors.surfaceVariant, _t("Cần chuột có 2 nút bên hông (XButton1/XButton2)."))
    
    ; === Quick Start Section ===
    welcomeGui.SetFont("s10 bold c" . colors.primary)
    welcomeGui.AddText("x24 y200", _t("🚀 Bắt đầu nhanh"))
    
    welcomeGui.SetFont("s9 c" . colors.text)
    welcomeGui.AddText("x24 y225", _t("Hãy thử: Giữ CHUỘT PHẢI + cuộn để "))
    
    welcomeGui.SetFont("s9 bold c" . colors.danger)
    welcomeGui.AddText("x236 y225", _t("chuyển tab trình duyệt"))
    
    welcomeGui.SetFont("s9 c" . colors.text)
    welcomeGui.AddText("x364 y225", _t("ngay!"))
    
    welcomeGui.SetFont("s9 c" . colors.textLight . " italic")
    welcomeGui.AddText("x24 y250 w452", _t("Nhấn Ctrl+Alt+H bất cứ lúc nào để xem hướng dẫn cử chỉ"))
    
    ; === Language Selector ===
    welcomeGui.SetFont("s9 bold c" . colors.primary)
    welcomeGui.AddText("x24 y285", _t("🌐 Ngôn ngữ / Language:"))
    welcomeGui.SetFont("s9 c" . colors.text)
    langIdx := (cfg.language = "vi" ? 1 : 2)
    ddlWelcomeLang := welcomeGui.AddDropDownList("x195 y282 w120 Choose" . langIdx, ["Tiếng Việt", "English"])
    ddlWelcomeLang.OnEvent("Change", (*) => ChangeWelcomeLanguage(welcomeGui, ddlWelcomeLang, dontShow))
    RoundControl(ddlWelcomeLang.Hwnd, 6)
    
    ; === Checkbox ===
    welcomeGui.SetFont("s9 c" . colors.textSecondary)
    dontShow := welcomeGui.AddCheckbox("x24 y315 w452", _t("Không hiển thị màn hình chào mừng này nữa"))
    
    ; === Material Buttons ===
    btnGuide := welcomeGui.AddButton("x24 y350 w215 h45", _t("📖 Học cách dùng"))
    btnGuide.SetFont("s10", "Segoe UI")
    btnGuide.OnEvent("Click", (*) => (welcomeGui.Destroy(), ShowGestureGuide()))
    EnhanceButton(btnGuide)
    RoundControl(btnGuide.Hwnd, 10)
    
    ; Primary action button (Google Blue filled)
    btnStart := welcomeGui.AddButton("x249 y350 w227 h45 Default", _t("✓ Bắt đầu sử dụng"))
    btnStart.SetFont("s10 bold", "Segoe UI")
    btnStart.OnEvent("Click", (*) => (welcomeGui.Destroy(), ShowTrayGuide()))
    EnhanceButton(btnStart)
    RoundControl(btnStart.Hwnd, 10)

    welcomeGui.OnEvent("Close", (*) => (cfg.firstRun := !dontShow.Value, SaveConfig(), welcomeGui.Destroy(), ShowTrayGuide()))
    welcomeGui.Show("w500 h410")
    ; Apply rounded corners using Windows 11 DWM API
    try {
        ; DWMWA_WINDOW_CORNER_PREFERENCE = 33, DWMWCP_ROUND = 2
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", welcomeGui.Hwnd, "Int", 33, "Int*", 2, "Int", 4)
    }
}

; --- CHANGE LANGUAGE IN WELCOME SCREEN ---
ChangeWelcomeLanguage(guiObj, ddlLang, chkDontShow) {
    global cfg
    ; Save language choice immediately
    langArr := ["vi", "en"]
    cfg.language := langArr[ddlLang.Value]
    SaveConfig()
    
    ; Store checkbox state
    dontShowValue := chkDontShow.Value
    
    ; Close and reopen Welcome screen with new language
    guiObj.Destroy()
    
    ; Recreate Welcome screen with updated language
    SetTimer(() => ShowWelcome(), -100)
}