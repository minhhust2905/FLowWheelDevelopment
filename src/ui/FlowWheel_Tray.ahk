; ============================================================================
; FLOWWHEEL - TRAY MENU SYSTEM
; ============================================================================

; --- CREATE TRAY MENU ---
CreateTrayMenu() {
    ; Clear existing menu
    A_TrayMenu.Delete()

    ; App name with version
    A_TrayMenu.Add(_t("FlowWheel "), (*) => ShowAbout())
    A_TrayMenu.Add() ; Separator

    ; Main functions
    A_TrayMenu.Add(_t("⚙️ Cài đặt`tCtrl+Alt+S"), (*) => ShowSettings())
    A_TrayMenu.Add(_t("📋 Tham khảo nhanh`tCtrl+Alt+H"), (*) => ShowGestureGuide())
    A_TrayMenu.Add(_t("📊 Thống kê"), (*) => ShowStats())
    
    ; Show time saved in menu
    timeSavedStr := FormatTimeSaved(cfg.stats.secondsSaved)
    A_TrayMenu.Add(_t("⏱️ Thời gian tiết kiệm : ") . timeSavedStr, (*) => ShowStats())
    A_TrayMenu.Add() ; Separator

    ; Toggle visual feedback
    A_TrayMenu.Add(_t("🎨 Phản hồi trực quan: ") . _t(cfg.feedback.enabled ? "Bật" : "Tắt"), (*) => ToggleFeedback())
    
    ; Pause function
    A_TrayMenu.Add(_t("⏸️ Tạm dừng FlowWheel`tCtrl+Alt+P"), (*) => TogglePause())
    A_TrayMenu.Add() ; Separator

    ; Reload and exit
    A_TrayMenu.Add(_t("🔄 Tải lại script`tCtrl+Alt+R"), (*) => Reload())
    A_TrayMenu.Add(_t("❌ Thoát`tCtrl+Alt+Q"), (*) => ExitApp())

    ; Set default item
    A_TrayMenu.Default := _t("⚙️ Cài đặt`tCtrl+Alt+S")
}

; --- TOGGLE VISUAL FEEDBACK ---
ToggleFeedback(*) {
    cfg.feedback.enabled := !cfg.feedback.enabled
    SaveConfig()
    CreateTrayMenu()
    ShowVisualFeedback(_t(cfg.feedback.enabled ? "✓ Đã bật phản hồi trực quan" : "✗ Đã tắt phản hồi trực quan"))
}

; --- SHOW TRAY GUIDE (System tray notification) ---
; --- SHOW TRAY GUIDE (Bản đã xóa thủ công dấu ^ lạ) ---
ShowTrayGuide() {
    static trayGuideGui := false
    if (trayGuideGui && IsObject(trayGuideGui)) {
        try trayGuideGui.Destroy()
    }
    
    trayGuideGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x20", "")
    trayGuideGui.BackColor := "FFFFE0" 

    ; Dòng 1: Màu Cam Đỏ (cFF5733)
    trayGuideGui.SetFont("s12 bold cFF5733", "Segoe UI")
    trayGuideGui.AddText("x0 y12 w340 Center", _t("FlowWheel đang chạy ở khay hệ thống 🔔"))

    ; Dòng 2: Màu Xám Đen (c333333) - Đã xóa ký tự ^ thủ công
    ; Thêm 'norm' để reset hoàn toàn thuộc tính bold và màu sắc từ dòng trên
    trayGuideGui.SetFont("s9 c333333 norm", "Segoe UI")
    trayGuideGui.AddText("x0 y45 w340 Center", _t("Nhấn vào mũi tên ở khay hệ thống để xem biểu tượng"))
    
    ; Hiển thị 
    x := A_ScreenWidth - 340 - 100
    y := A_ScreenHeight - 70 - 92  
    trayGuideGui.Show("x" x " y" y " w340 h80")
    
    SetTimer(() => (IsSet(trayGuideGui) && trayGuideGui ? trayGuideGui.Destroy() : ""), -5000)
}