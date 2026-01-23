; ============================================================================
; FLOWWHEEL - GESTURE GUIDE UI
; ============================================================================

; --- SHOW GESTURE GUIDE ---
ShowGestureGuide(*) {
    global guideGui
    if (guideGui && IsObject(guideGui)) {
        try {
            if WinExist("ahk_id " . guideGui.Hwnd) {
                guideGui.Hide()
                return
            }
        }
    }
    
    ; Dynamic screen size calculation
    scrW := A_ScreenWidth
    scrH := A_ScreenHeight
    winW := 1200
    winH := Min(680, Floor(scrH * 0.75))
    
    guideGui := Gui("+AlwaysOnTop -Resize", _t("FlowWheel - Bảng Tham Khảo Nhanh"))
    guideGui.BackColor := "FFFFFF"
    guideGui.MarginX := 0
    guideGui.MarginY := 0

    ; --- HEADER GRADIENT ---
    guideGui.AddText("x0 y0 w1200 h100 Background" . colors.primary, "")
    guideGui.SetFont("s24 bold cFFFFFF", "Segoe UI")
    guideGui.AddText("x40 y20 w600 Background" . colors.primary, _t("FlowWheel"))
    guideGui.SetFont("s10 cE8F4FF", "Segoe UI")
    guideGui.AddText("x40 y58 w600 Background" . colors.primary, _t("Bảng Tham Khảo Nhanh"))

    ; Settings button top right with effect
    btnSet := guideGui.AddButton("x1120 y25 w50 h50", "⚙️")
    btnSet.SetFont("s18", "Segoe UI Emoji")
    btnSet.OnEvent("Click", (*) => (guideGui.Hide(), ShowSettings()))
    RoundControl(btnSet.Hwnd, 10)
    guideGui.SetFont("s9 cFFFFFF", "Segoe UI")
    guideGui.AddText("x1090 y75 w110 Center Background" . colors.primary, _t("Nhấn để mở cài đặt"))

    ; --- LEFT COLUMN: IMAGE CARD ---
    guideGui.AddText("x30 y120 w280 h480 Background" . colors.bg, "")
    guideGui.SetFont("s11 bold c" . colors.primary, "Segoe UI")
    guideGui.AddText("x50 y140 w240", _t("🖱️ Cấu Hình Thiết Bị"))
    guideGui.AddText("x50 y165 w240 h2 Background" . colors.primary, "")
    
    guideGui.AddText("x50 y185 w230 h280 Background" . colors.bgDark . " +0x400000", "")
    try {
        parentDir := RegExReplace(A_ScriptDir, "\\[^\\]+$", "")
        guidePath := parentDir . "\resources\images\mouse_guide.png"
        if FileExist(guidePath) {
            guideGui.AddPicture("x65 y205 w200 h240", guidePath)
        } else {
            guideGui.SetFont("s9 c" . colors.textLight, "Segoe UI")
            MsgBox("Không tìm thấy file mouse_guide.png tại: " . guidePath, "Không tìm thấy ảnh hướng dẫn", "Icon!")
        }
    } catch {
        guideGui.SetFont("s9 c" . colors.textLight, "Segoe UI")
    }
    guideGui.SetFont("s9 italic c" . colors.textLight, "Segoe UI")
    guideGui.AddText("x50 y480 w230 Center", _t("Tối ưu cho chuột 5 nút"))
    
    ; --- RIGHT COLUMNS: GESTURES (2 COLUMNS) ---
    xLeft := 340
    xRight := 670
    yBase := 130
    
    ; Left column
    AddGestureCard(guideGui, xLeft, yBase, _t("🌐Điều hướng Web / Trình duyệt"), [
        [_t("RButton + Wheel"), _t("Chuyển Tab trình `n duyệt")],
        [_t("RButton + MButton"), _t("Đóng Tab nhanh")],
        [_t("LButton + MButton"), _t("Khôi phục Tab đã `n đóng")],
        [_t("RButton + Wheel L/R `n / Shift + Wheel "), _t("Cuộn ngang ")]
    ])
    
    AddGestureCard(guideGui, xLeft, yBase + 230, _t("🖥️Quản lý Cửa sổ / Hệ thống"), [
        [_t("X1 + Wheel /+ RButton"), _t("Chuyển / đóng cửa `n sổ (Alt+Tab)")],
        [_t("X2 + Wheel"), _t("Chọn ứng dụng Taskbar")],
        [_t("X1 + MButton"), _t("Đóng cửa sổ nhanh")],
        [_t("X2 + MButton"), _t("Show/Hide Desktop")]
    ])
    
    ; Right column
    AddGestureCard(guideGui, xRight, yBase, _t("🎵Điều khiển Đa phương tiện"), [
        [_t("X1 + RButton + Wheel"), _t("Điều chỉnh âm lượng")],
        [_t("X2 + RButton + Wheel"), _t("Điều chỉnh độ sáng")],
        [_t("MButton (Nhấn giữ)"), _t("Bật/Tắt âm thanh (Mute)")],
        [_t("MButton + Wheel"), _t("Phóng to / Thu nhỏ (Zoom)")]
    ])
    
    AddGestureCard(guideGui, xRight, yBase + 230, _t("🛠️Tiện ích / Nâng cao"), [
        [_t("X1 + X2"), _t("Chụp màn hình nhanh")],
        [_t("RButton + X1/X2"), _t("Ghim cửa sổ (Snap)")],
        [_t("X1 (on Taskbar)"), _t("Đóng ứng dụng từ Taskbar")],       
    ])
    
    ; --- FAR RIGHT COLUMN: QUICK ACCESS ---
    guideGui.AddText("x1000 y130 w180 h350 Background" . colors.bg . " Border", "")
    guideGui.SetFont("s11 bold c" . colors.primary, "Segoe UI")
    guideGui.AddText("x1020 y135 w140", _t("⚡ Truy cập nhanh"))
    guideGui.AddText("x1020 y160 w140 h2 Background" . colors.accent, "")
    
    ; Each shortcut with background box
    yPos := 175
    shortcuts := [
        ["Ctrl + Alt + S", _t("Cài đặt")],
        ["Ctrl + Alt + H", _t("Hướng dẫn")],
        ["Ctrl + Alt + Q", _t("Thoát")],
        ["Ctrl + Alt + P", _t("Tạm dừng")],
        ["Ctrl + Alt + R", _t("Tải lại")]
    ]
    
    for sc in shortcuts {
        guideGui.AddText("x1015 y" . (yPos-2) . " w150 h20 Background" . colors.bgDark . " +0x200", "")
        guideGui.SetFont("s8 bold c000000", "Consolas")
        guideGui.AddText("x1020 y" . yPos . " w140 Center BackgroundTrans", sc[1])
        guideGui.SetFont("s8 c" . colors.textLight, "Segoe UI")
        guideGui.AddText("x1020 y" . (yPos+22) . " w140 Center", sc[2])
        yPos += 50
    }

    ; --- FOOTER ---
    guideGui.AddText("x0 y600 w1200 h80 Background" . colors.bg, "")
    
    ; Highlighted message box
    guideGui.AddText("x30 y608 w850 h32 BackgroundFFFFE0 Border", "")
    guideGui.SetFont("s11 bold c" . colors.warning, "Segoe UI")
    guideGui.AddText("x40 y615 w830 Center BackgroundTrans", _t("💡 Hãy vào Cài đặt để tùy chỉnh cử chỉ theo ý bạn!"))
    
    guideGui.SetFont("s9 c" . colors.textLight, "Segoe UI")
    guideGui.AddText("x30 y650 w850 Center", _t("Nhấn Ctrl+Alt+H bất cứ lúc nào để mở lại hướng dẫn này"))
    
    ; Close button with primary color
    btnClose := guideGui.AddButton("x920 y610 w250 h55 Default", _t("✓ ĐÃ HIỂU!"))
    btnClose.SetFont("s12 bold", "Segoe UI")
    btnClose.OnEvent("Click", (*) => guideGui.Destroy())
    RoundControl(btnClose.Hwnd, 12)

    guideGui.Show("w" . winW . " h" . winH)
}

; --- HELPER: CREATE GESTURE CARD ---
AddGestureCard(guiObj, x, y, title, items) {
    global colors
    
    ; Card background with border
    guiObj.AddText("x" . x . " y" . y . " w300 h210 Background" . colors.bg . " Border", "")
    
    ; Card header with accent color and better spacing
    guiObj.SetFont("s10 bold c" . colors.primary, "Segoe UI")
    guiObj.AddText("x" . (x+15) . " y" . (y+12) . " w270", title)
    guiObj.AddText("x" . (x+15) . " y" . (y+36) . " w270 h2 Background" . colors.accent, "")
    
    ; Gesture items with optimal spacing
    currY := y + 50
    for item in items {
        ; Calculate height based on text length (auto-adjust for long text)
        textLen := StrLen(item[1])
        boxHeight := (textLen > 30) ? 36 : 24  ; Taller box for long text
        textYOffset := (boxHeight > 24) ? (currY + 6) : currY  ; Center text vertically
        
        ; Shortcut key with background highlight rounded
        guiObj.AddText("x" . (x+12) . " y" . (currY-3) . " w135 h" . boxHeight . " Background" . colors.bgDark . " +0x200", "")
        guiObj.SetFont("s8 bold c000000", "Segoe UI")
        guiObj.AddText("x" . (x+16) . " y" . textYOffset . " w127 Center BackgroundTrans", item[1])
        
        ; Action description with clearer color
        guiObj.SetFont("s9 norm c" . colors.text, "Segoe UI")
        guiObj.AddText("x" . (x+155) . " y" . currY . " w130", "→  " . item[2])
        
        currY += 35  ; Spacing between items
    }
}