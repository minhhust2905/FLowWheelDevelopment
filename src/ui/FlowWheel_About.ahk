; ============================================================================
; FLOWWHEEL - ABOUT SCREEN (Google Material Design)
; ============================================================================

; --- SHOW ABOUT WINDOW ---
ShowAbout(*) {
    aboutGui := Gui("+AlwaysOnTop -MaximizeBox", _t("Giới thiệu về FlowWheel"))
    aboutGui.BackColor := colors.bg
    aboutGui.MarginX := 0
    aboutGui.MarginY := 0
    
    ; === GOOGLE MATERIAL HEADER ===
    aboutGui.AddText("x0 y0 w400 h80 Background" . colors.primary, "")
    aboutGui.SetFont("s20 bold cFFFFFF", "Segoe UI")
    aboutGui.AddText("x24 y18 Background" . colors.primary, _t("FlowWheel"))
    aboutGui.SetFont("s9 c" . colors.primaryLight, "Segoe UI")
    aboutGui.AddText("x24 y50 Background" . colors.primary, _t("Chuyển động nhỏ - Dòng chảy lớn"))
    
    ; === Author Card ===
    aboutGui.AddText("x22 y97 w360 h70 Background" . colors.shadow, "")
    aboutGui.AddText("x20 y95 w360 h70 Background" . colors.surfaceVariant, "")
    aboutGui.SetFont("s9 bold c" . colors.primary)
    aboutGui.AddText("x30 y105 Background" . colors.surfaceVariant, _t("Được sáng tạo và phát triển bởi"))
    aboutGui.SetFont("s12 c" . colors.text)
    aboutGui.AddText("x30 y128 Background" . colors.surfaceVariant, _t("Minh Edward 🚀"))
    
    ; === Hotkeys Card ===
    aboutGui.AddText("x22 y177 w360 h130 Background" . colors.shadow, "")
    aboutGui.AddText("x20 y175 w360 h130 Background" . colors.surfaceVariant, "")
    aboutGui.SetFont("s9 bold c" . colors.primary)
    aboutGui.AddText("x30 y185 Background" . colors.surfaceVariant, _t("⌨️ Truy cập nhanh"))
    aboutGui.SetFont("s9 c" . colors.text, "Consolas")
    aboutGui.AddText("x30 y210 Background" . colors.surfaceVariant, _t("Ctrl + Alt + S  →  Cài đặt"))
    aboutGui.AddText("x30 y230 Background" . colors.surfaceVariant, _t("Ctrl + Alt + H  →  Tham khảo nhanh"))
    aboutGui.AddText("x30 y250 Background" . colors.surfaceVariant, _t("Ctrl + Alt + Q  →  Thoát ứng dụng"))
    aboutGui.AddText("x30 y270 Background" . colors.surfaceVariant, _t("Ctrl + Alt + P  →  Tạm dừng"))
    
    ; === Support Section ===
    aboutGui.SetFont("s11 bold c" . colors.warning)
    aboutGui.AddText("Center x20 y320 w360", _t("☕ Ủng hộ phát triển"))
    
    ; QR code
    qrPath := A_ScriptDir . "\resources\images\QR.png"
    if FileExist(qrPath) {
        try {
            aboutGui.AddPicture("x120 y345 w160 h160", qrPath)
        } catch {
            aboutGui.SetFont("s9 c" . colors.danger)
            aboutGui.AddText("Center x20 y365 w360", _t("(Lỗi tải hình ảnh QR)"))
        }
    } else {
        aboutGui.SetFont("s9 c" . colors.danger)
        aboutGui.AddText("Center x20 y365 w360", _t("(Không tìm thấy QR.png)"))
        aboutGui.SetFont("s8 c" . colors.textLight)
        aboutGui.AddText("Center x20 y385 w360", _t("Path: ") . qrPath)
    }
    
    aboutGui.SetFont("s8 c" . colors.textLight)
    aboutGui.AddText("Center x20 y515 w360", _t("Mời tác giả một ly cà phê ☕"))
    
    ; Footer
    aboutGui.AddText("x20 y535 w360 h1 Background" . colors.divider, "")
    aboutGui.SetFont("s8 italic c" . colors.textLight)
    aboutGui.AddText("Center x20 y545 w360", _t("© 2026 Minh Edward"))
    
    ; Close button (Material filled)
    btnClose := aboutGui.AddButton("Default x125 y565 w150 h40", _t("Đóng"))
    btnClose.SetFont("s10 bold")
    btnClose.OnEvent("Click", (*) => aboutGui.Destroy())
    EnhanceButton(btnClose)
    RoundControl(btnClose.Hwnd, 10)
    
    aboutGui.Show("w400 h620")
    ; Apply rounded corners using Windows 11 DWM API
    try {
        ; DWMWA_WINDOW_CORNER_PREFERENCE = 33, DWMWCP_ROUND = 2
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", aboutGui.Hwnd, "Int", 33, "Int*", 2, "Int", 4)
    }
}