; ============================================================================
; FLOWWHEEL - STATISTICS UI
; ============================================================================

; --- SHOW STATISTICS WINDOW ---
ShowStats(*) {
    statsGui := Gui("+AlwaysOnTop -MaximizeBox", _t("Thống kê FlowWheel"))
    statsGui.BackColor := "FFFFFF"
    statsGui.MarginX := 0
    statsGui.MarginY := 0

    ; --- Modern header ---
    statsGui.AddText("x0 y0 w550 h50 Background" . colors.primary, "")
    statsGui.SetFont("s13 bold cFFFFFF", "Segoe UI")
    statsGui.AddText("x0 y10 w550 Center Background" . colors.primary, _t("📊 Thống kê sử dụng"))

    statsGui.SetFont("s10 c" . colors.text, "Segoe UI")

    ; Calculate total gestures (including new gestures)
    total := cfg.stats.tabSwitch + cfg.stats.windowSwitch + cfg.stats.taskbarfocus
        + cfg.stats.volume + cfg.stats.brightness + cfg.stats.mute + cfg.stats.zoom
        + cfg.stats.tabClose + cfg.stats.tabRestore + cfg.stats.comboClose + cfg.stats.taskbarClose + cfg.stats.ninjaVanish
        + cfg.stats.horizontalScroll + cfg.stats.screenshot + cfg.stats.windowSnap + cfg.stats.pinWindow
    
    ; --- Ranking ---
    rankName := _t("🐣 Người mới"), rankColorHex := "808080"
    if (total >= 9999999) {
        rankName := _t("👑 Thần chuột"), rankColorHex := "FFD700"
    } else if (total >= 99) {
        rankName := _t("🥉 Đồng khởi đầu"), rankColorHex := "CD7F32"
    }

    ; Number formatter
    FormatNum(n) {
        return RegExReplace(n, "\\G\\d+?(?=(\\d{3})+(?:\\D|$))", "$0,")
    }

    statsGui.SetFont("s10 bold c" . colors.primary)
    statsGui.AddText("x30 y60", _t("Tổng số cử chỉ đã thực hiện"))
    statsGui.SetFont("s18 bold c" . colors.secondary)
    statsGui.AddText("x30 y80 w490", FormatNum(total))
    statsGui.SetFont("s11 bold c" . rankColorHex, "Segoe UI")
    statsGui.AddText("x30 y110 w500", _t("Hạng: ") . rankName)

    ; Show time saved
    statsGui.SetFont("s10 bold c" . colors.success)
    timeSaved := FormatTimeSaved(cfg.stats.secondsSaved)
    statsGui.AddText("x30 y130 w500", _t("⏱️ Tiết kiệm: ") . timeSaved)

    statsGui.AddText("x30 y150 w490 h1 Background" . colors.border, "")

    ; --- Most used gesture ---
    if (total > 0) {
        maxStat := 0, maxName := ""
        for name, count in cfg.stats.OwnProps() {
            ; Skip secondsSaved when finding most used gesture
            if (name != "secondsSaved" && count > maxStat) {
                maxStat := count, maxName := name
            }
        }

        ; Gesture names with translation support
        gestureNames := Map(
            "brightness", _t("Độ sáng"),
            "feedbackSent", _t("Phản hồi đã gửi"),
            "mute", _t("Tắt/Bật tiếng"),
            "screenshot", _t("Chụp màn hình"),
            "tabClose", _t("Đóng tab"),
            "tabRestore", _t("Khôi phục tab"),
            "tabSwitch", _t("Chuyển tab"),
            "taskbarfocus", _t("Chọn taskbar"),
            "volume", _t("Âm lượng"),
            "windowSnap", _t("Ghim cửa sổ"),
            "windowSwitch", _t("Chuyển cửa sổ"),
            "zoom", _t("Phóng to/Thu nhỏ"),
            "horizontalScroll", _t("Cuộn ngang"),
            "comboClose", _t("Đóng (combo)"),
            "taskbarClose", _t("Đóng từ taskbar"),
            "ninjaVanish", _t("Ẩn nhanh (Ninja)"),
            "pinWindow", _t("Ghim cửa sổ (pin)")
        )

        statsGui.SetFont("s10 bold c" . colors.primary)
        statsGui.AddText("x30 y170", _t("🏆 Cử chỉ dùng nhiều nhất"))
        statsGui.SetFont("s10 c" . colors.text)
        maxNameVN := gestureNames.Has(maxName) ? gestureNames[maxName] : StrTitle(maxName)
        statsGui.AddText("x30 y188", maxNameVN . " - " . FormatNum(maxStat) . _t(" lần"))
        statsGui.SetFont("s10 bold c" . colors.primary)
        statsGui.AddText("x30 y210 w490 h1 Background" . colors.border, "")

        ; --- Detailed analysis ---
        statsGui.SetFont("s10 bold c" . colors.primary)
        statsGui.AddText("x30 y220", _t("Phân tích chi tiết"))

        yPos := 245
        for name, count in cfg.stats.OwnProps() {
            ; Skip secondsSaved in detailed analysis
            if (name != "secondsSaved" && count > 0) {
                pct := Round(count / total * 100)
                nameVN := gestureNames.Has(name) ? gestureNames[name] : StrTitle(name)

                statsGui.SetFont("s8 c" . colors.text)
                statsGui.AddText("x30 y" . yPos . " w120", nameVN . ":")

                ; Progress bar hiện đại
                progColor := colors.primary
                bgColor := colors.surfaceVariant
                progCtrl := statsGui.AddProgress("x160 y" . (yPos+4) . " w180 h14 Background" . bgColor . " c" . progColor, pct)
                ; Bo góc (nếu có hàm RoundControl)
                if IsSet(RoundControl)
                    RoundControl(progCtrl.Hwnd, 7)

                ; Hiển thị số liệu trên thanh
                statsGui.SetFont("s8 c" . colors.textSecondary)
                statsGui.AddText("x165 y" . (yPos+4) . " w170 Center BackgroundTrans", pct . "%")

                statsGui.SetFont("s8 bold c" . colors.secondary)
                statsGui.AddText("x350 y" . yPos . " w120 Right", FormatNum(count) . _t(" lần"))
                yPos += 22
            }
        }
    } else {
        statsGui.SetFont("s10 c" . colors.textLight, "Segoe UI")
        statsGui.AddText("Center x30 y250 w490", _t("Chưa có dữ liệu cử chỉ nào."))
        yPos := 350
    }

    yShareBtn := (total > 0 ? yPos + 10 : 220)
    btnShare := statsGui.AddButton("x30 y" . yShareBtn . " w495 h32", _t("🏆 Khoe thành tích & Hạng lên Discord"))
    btnShare.OnEvent("Click", (*) => ShareStatsToDiscord(statsGui))

    yBottomBtns := yShareBtn + 38
    btnClear := statsGui.AddButton("x30 y" . yBottomBtns . " w245 h32", _t("🗑️ Xóa thống kê"))
    btnClose := statsGui.AddButton("x285 yp w245 h32 Default", _t("✓ Đóng"))
    btnClear.OnEvent("Click", (*) => ClearStats(statsGui))
    btnClose.OnEvent("Click", (*) => statsGui.Destroy())

    statsGui.Show("w550 h" . (yBottomBtns + 45))
}

; --- CLEAR STATISTICS ---
ClearStats(gui) {
    try gui.Opt("-AlwaysOnTop")
    result := MsgBox(_t("Bạn có chắc muốn xóa toàn bộ thống kê?"), _t("Xác nhận"), "YesNo Icon!")
    try gui.Opt("+AlwaysOnTop")
    if (result = "Yes") {
        for name in cfg.stats.OwnProps()
            cfg.stats.%name% := 0
        SaveConfig()
        gui.Destroy()
        ShowVisualFeedback(_t("✓ Đã xóa thống kê"))
    }
}

; --- HELPER: ADD GESTURE ROW (for consistency) ---
AddGestureRow(guiObj, x, y, key, action, textColor) {
    guiObj.SetFont("s9 bold c" . textColor, "Segoe UI")
    guiObj.AddText("x" . x . " y" . y . " w160", key)
    
    guiObj.SetFont("s9 norm c" . textColor, "Segoe UI")
    guiObj.AddText("x" . x+160 . " y" . y . " w280", "→ " . action)
}