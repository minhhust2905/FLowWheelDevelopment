; ============================================================================
; FLOWWHEEL - MODERN SETTINGS UI (Material Design 3)
; ============================================================================

; === HELPER: DEBOUNCED SAVE FUNCTIONS ===
SavePositionDebounced(pos) {
    global cfg
    cfg.feedback.position := pos
    SaveConfig()
    CreateTrayMenu()
}

SavePositionDebounce(pos) {
    SetTimer(SavePositionDebounced.Bind(pos), -300)
}

; === CREATE GESTURE CARD (Card Selection Style) ===
; gestureGuideMap chứa hướng dẫn thao tác cho từng gesture
global gestureGuideMap
CreateGestureCard(gui, x, y, w, label, isChecked) {
    ; Outer card (creates border effect) 
    borderBg := isChecked ? "7DBE7C" : "E0E0E0"
    cardOuter := gui.AddText("x" x " y" y " w" w " h48 Background" . borderBg, "")
    RoundControl(cardOuter.Hwnd, 16)
    
    ; Inner card  (giữ cố định offset 2px)
    innerBgColor := isChecked ? "DFF5E3" : "FFFFFF"
    innerBg := gui.AddText("x" (x+2) " y" (y+2) " w" (w-4) " h44 Background" . innerBgColor, "")
    RoundControl(innerBg.Hwnd, 14)
    
    ; Label text
    gui.SetFont("s9 " . (isChecked ? "bold" : "norm") . " c" . colors.text, "Segoe UI")
    lblText := gui.AddText("x" (x+16) " y" (y+14) " w" (w-60) " BackgroundTrans", label)

    ; Hướng dẫn thao tác nhỏ (ẩn nếu chưa bật card)
    guideText := gestureGuideMap.Has(label) ? gestureGuideMap[label] : ""
    lblGuide := gui.AddText("x" (x+16) " y" (y+32) " w" (w-60) " BackgroundTrans cGray " . (isChecked ? "" : "Hidden"), guideText)
    
    ; Checkmark icon (visible when active)
    gui.SetFont("s12 bold c" . colors.primary, "Segoe UI")
    checkmark := gui.AddText("x" (x+w-32) " y" (y+12) " w24 h24 BackgroundTrans " . (isChecked ? "" : "Hidden"), "✓")
    
    ; Create card object with Value property
    card := {
        Value: isChecked ? 1 : 0,
        cardOuter: cardOuter,
        innerBg: innerBg,
        lblText: lblText,
        lblGuide: lblGuide,
        checkmark: checkmark,
        x: x,
        y: y,
        w: w
    }
    
    ; Store card object for callbacks
    cardOuter._card := card
    innerBg._card := card
    lblText._card := card
    lblGuide._card := card
    checkmark._card := card
    
    ; Click handlers
    cardOuter.OnEvent("Click", GestureCardClick)
    innerBg.OnEvent("Click", GestureCardClick)
    lblText.OnEvent("Click", GestureCardClick)
    lblGuide.OnEvent("Click", GestureCardClick)
    checkmark.OnEvent("Click", GestureCardClick)
    
    return card
}

; Gesture card click handler
GestureCardClick(ctrl, *) {
    global colors, cfg
    card := ctrl._card

    ; Toggle value
    card.Value := !card.Value

    ; Update outer card background (border color)
    outerBg := card.Value ? "7DBE7C" : "E0E0E0"
    card.cardOuter.Opt("Background" . outerBg)

    ; Update inner card color (giữ nguyên kích thước)
    innerBgColor := card.Value ? "DFF5E3" : "FFFFFF"
    card.innerBg.Opt("Background" . innerBgColor)

    ; Force redraw
    DllCall("RedrawWindow", "Ptr", card.cardOuter.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0001 | 0x0004)
    DllCall("RedrawWindow", "Ptr", card.innerBg.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0001 | 0x0004)

    ; Update label font weight
    card.lblText.SetFont(card.Value ? "bold" : "norm")

    ; Show/hide checkmark with smooth transition
    card.checkmark.Visible := card.Value

    ; Show/hide hướng dẫn thao tác
    card.lblGuide.Visible := card.Value

    ; Sound feedback nếu bật
    if (cfg.feedback.HasProp("soundEnabled") && cfg.feedback.soundEnabled) {
        PlayGestureSound()
    }

    ; AUTO-SAVE: Debounced save (200ms after last click)
    SetTimer(() => SaveGestureConfig(), -200)
}

; === CREATE POSITION CARD (Radio-style Selection) ===
CreatePositionCard(gui, x, y, w, label, icon, isSelected, positionValue) {
    ; Outer card
    borderBg := isSelected ? "7DBE7C" : "E0E0E0"
    cardOuter := gui.AddText("x" x " y" y " w" w " h48 Background" . borderBg, "")
    RoundControl(cardOuter.Hwnd, 16)
    
    ; Inner card
    innerBgColor := isSelected ? "DFF5E3" : "FFFFFF"
    innerBg := gui.AddText("x" (x+2) " y" (y+2) " w" (w-4) " h44 Background" . innerBgColor, "")
    RoundControl(innerBg.Hwnd, 14)
    
    ; Icon
    gui.SetFont("s14 c" . colors.primary, "Segoe UI")
    iconCtrl := gui.AddText("x" (x+16) " y" (y+10) " w24 h24 BackgroundTrans", icon)
    
    ; Label text
    gui.SetFont("s9 " . (isSelected ? "bold" : "norm") . " c" . colors.text, "Segoe UI")
    lblText := gui.AddText("x" (x+48) " y" (y+14) " w" (w-90) " BackgroundTrans", label)
    
    ; Checkmark
    gui.SetFont("s12 bold c" . colors.primary, "Segoe UI")
    checkmark := gui.AddText("x" (x+w-32) " y" (y+12) " w24 h24 BackgroundTrans " . (isSelected ? "" : "Hidden"), "✓")
    
    ; Create card object
    card := {
        position: positionValue,
        isSelected: isSelected,
        cardOuter: cardOuter,
        innerBg: innerBg,
        iconCtrl: iconCtrl,
        lblText: lblText,
        checkmark: checkmark
    }
    
    ; Store card object
    cardOuter._posCard := card
    innerBg._posCard := card
    iconCtrl._posCard := card
    lblText._posCard := card
    checkmark._posCard := card
    
    ; Click handlers
    cardOuter.OnEvent("Click", PositionCardClick)
    innerBg.OnEvent("Click", PositionCardClick)
    iconCtrl.OnEvent("Click", PositionCardClick)
    lblText.OnEvent("Click", PositionCardClick)
    checkmark.OnEvent("Click", PositionCardClick)
    
    return card
}

; Position card click handler
PositionCardClick(ctrl, *) {
    global positionCards, selectedPosition, colors, cfg
    card := ctrl._posCard

    ; Update selected position
    selectedPosition := card.position

    ; Update all cards
    for posCard in positionCards {
        isSelected := (posCard.position = selectedPosition)

        ; Update colors
        outerBg := isSelected ? "7DBE7C" : "E0E0E0"
        innerBgColor := isSelected ? "DFF5E3" : "FFFFFF"
        posCard.cardOuter.Opt("Background" . outerBg)
        posCard.innerBg.Opt("Background" . innerBgColor)

        ; Update font weight
        posCard.lblText.SetFont(isSelected ? "bold" : "norm")

        ; Update checkmark visibility
        posCard.checkmark.Visible := isSelected
        posCard.isSelected := isSelected

        ; Force redraw all controls
        DllCall("RedrawWindow", "Ptr", posCard.cardOuter.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0001 | 0x0004)
        DllCall("RedrawWindow", "Ptr", posCard.innerBg.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0001 | 0x0004)
        DllCall("RedrawWindow", "Ptr", posCard.iconCtrl.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0001 | 0x0004)
        DllCall("RedrawWindow", "Ptr", posCard.lblText.Hwnd, "Ptr", 0, "Ptr", 0, "UInt", 0x0001 | 0x0004)
    }

    ; Sound feedback nếu bật
    if (cfg.feedback.HasProp("soundEnabled") && cfg.feedback.soundEnabled) {
        PlayGestureSound()
    }

    ; AUTO-SAVE: Debounced save (100ms after last click)
    SavePositionDebounce(selectedPosition)
}

; === HELPER: SAVE GESTURE CONFIG ===
SaveGestureConfig() {
    global cfg, chkTabSwitch, chkTabClose, chkTabRestore, chkHorizontalScroll
    global chkVolume, chkBrightness, chkMute, chkZoom
    global chkWindowSwitch, chkTaskbarFocus, chkComboClose
    global chkNinjaVanish, chkQuickScreenshot, chkWindowSnap, chkTaskbarClose
    
    ; Update all gesture configs from cards
    cfg.gestures.tabSwitch := chkTabSwitch.Value
    cfg.gestures.tabClose := chkTabClose.Value
    cfg.gestures.tabRestore := chkTabRestore.Value
    cfg.gestures.horizontalScroll := chkHorizontalScroll.Value
    cfg.gestures.volume := chkVolume.Value
    cfg.gestures.brightness := chkBrightness.Value
    cfg.gestures.mute := chkMute.Value
    cfg.gestures.zoom := chkZoom.Value
    cfg.gestures.windowSwitch := chkWindowSwitch.Value
    cfg.gestures.taskbarfocus := chkTaskbarFocus.Value
    cfg.gestures.comboClose := chkComboClose.Value
    cfg.gestures.ninjaVanish := chkNinjaVanish.Value
    cfg.gestures.quickScreenshot := chkQuickScreenshot.Value
    cfg.gestures.windowSnap := chkWindowSnap.Value
    cfg.gestures.taskbarClose := chkTaskbarClose.Value
    
    ; Save to file and update tray menu
    SaveConfig()
    CreateTrayMenu()
}

ShowSettings() {
    global settingsGui
    try {
        if (IsSet(settingsGui) && IsObject(settingsGui)) {
            ; Nếu đang mở thì ẩn đi
            settingsGui.Destroy()
            settingsGui := unset
            ; Không return, tiếp tục tạo lại GUI
        }
    }
    CreateSettingsGui()
}
CreateSettingsGui() {
    ; Map hướng dẫn thao tác gesture (label: hướng dẫn)
    global gestureGuideMap := Map(
        _t("Chuyển Tab"), "RButton + Wheel",
        _t("Đóng Tab nhanh"), "RButton + MButton",
        _t("Khôi phục Tab"), "LButton + MButton",
        _t("Cuộn ngang"), "Shift + Wheel / RButton + Wheel L/R",
        _t("Âm lượng"), "RButton + X1 + Wheel",
        _t("Độ sáng"), "RButton + X2 + Wheel",
        _t("Tắt/Bật âm"), "MButton (Nhấn giữ)",
        _t("Phóng to/Thu nhỏ"), "MButton + Wheel",
        _t("Chuyển/Đóng cửa sổ"), "X1 + Wheel /+ RButton",
        _t("App Taskbar"), "X2 + Wheel",
        _t("Đóng cửa sổ"), "X1 + MButton",
        _t("Ẩn/Hiện Desktop"), "X2 + MButton",
        _t("Chụp màn hình"), "X1 + X2",
        _t("Ghim cửa sổ"), "RButton + X1/X2",
        _t("Đóng app trên Taskbar"), "X1 (on Taskbar)"
    )
    global settingsGui
    global chkTabSwitch, chkTabClose, chkTabRestore, chkHorizontalScroll
    global chkVolume, chkBrightness, chkMute, chkZoom
    global chkWindowSwitch, chkTaskbarFocus, chkComboClose
    global chkNinjaVanish, chkQuickScreenshot, chkWindowSnap, chkTaskbarClose
    global isAdvancedMode
    
    if !IsSet(isAdvancedMode)
        isAdvancedMode := false

    settingsGui := Gui("-MaximizeBox", _t("FlowWheel Settings"))
    settingsGui.BackColor := colors.bg
    settingsGui.MarginX := 0
    settingsGui.MarginY := 0

    ; Increase height for Tab 4
    guiHeight := 750
    
    ; === MATERIAL HEADER ===
    settingsGui.AddText("x0 y0 w750 h70 Background" . colors.primary, "")
    settingsGui.SetFont("s18 bold cFFFFFF", "Segoe UI")
    settingsGui.AddText("x24 y14 Background" . colors.primary, "⚙️ " . _t("Cài đặt"))
    settingsGui.SetFont("s9 c" . colors.primaryLight, "Segoe UI")
    settingsGui.AddText("x24 y46 Background" . colors.primary, _t("Quản lý và tùy chỉnh trải nghiệm FlowWheel của bạn"))
    
    settingsGui.OnEvent("Close", (guiObj) => (SetTimer(CheckStarHover, 0), guiObj.Hide()))
    
    ; === TABS ===
    settingsGui.SetFont("s10 c" . colors.text, "Segoe UI Semibold")
    tabNamesFull := [_t("🎯 Cử chỉ"), _t("🎨 Hiển thị"), _t("⚙️ Nâng cao"), _t("💬 Hỗ trợ")]
    tabNamesSimple := [_t("🎯 Cử chỉ")]
    global tab, tabNamesFull, tabNamesSimple
    tab := settingsGui.AddTab3("x15 y80 w720 h540", isAdvancedMode ? tabNamesFull : tabNamesSimple)

    ; ...existing code...

    ; (Đã thay thế bằng phiên bản reload toàn bộ settingsGui ở dưới)
    
    ; --- TAB 1: GESTURES (ROW-BASED TOGGLE) ---
    tab.UseTab(1)
    settingsGui.AddText("x25 y105 w700 h505 Background" . colors.surfaceVariant, "")
    
    ; Section 1: Browser & Scrolling
    settingsGui.SetFont("s10 bold c" . colors.primary, "Segoe UI Semibold")
    settingsGui.AddText("x40 y118", _t("🌐 Trình duyệt_Cuộn"))
    settingsGui.AddText("x40 y136 w315 h2 Background" . colors.primary, "")
    
    chkTabSwitch := CreateGestureCard(settingsGui, 40, 145, 315, _t("Chuyển Tab"), cfg.gestures.tabSwitch)
    chkTabClose := CreateGestureCard(settingsGui, 40, 198, 315, _t("Đóng Tab nhanh"), cfg.gestures.tabClose)
    chkTabRestore := CreateGestureCard(settingsGui, 40, 251, 315, _t("Khôi phục Tab"), cfg.gestures.tabRestore)
    chkHorizontalScroll := CreateGestureCard(settingsGui, 40, 304, 315, _t("Cuộn ngang"), cfg.gestures.horizontalScroll)
    
    ; Section 2: Entertainment & Media
    settingsGui.SetFont("s10 bold c" . colors.primary, "Segoe UI Semibold")
    settingsGui.AddText("x385 y118", _t("🎵 Giải trí_Media"))
    settingsGui.AddText("x385 y136 w315 h2 Background" . colors.primary, "")
    
    chkVolume := CreateGestureCard(settingsGui, 385, 145, 315, _t("Âm lượng"), cfg.gestures.volume)
    chkBrightness := CreateGestureCard(settingsGui, 385, 198, 315, _t("Độ sáng"), cfg.gestures.brightness)
    chkMute := CreateGestureCard(settingsGui, 385, 251, 315, _t("Tắt/Bật âm"), cfg.gestures.mute)
    chkZoom := CreateGestureCard(settingsGui, 385, 304, 315, _t("Phóng to/Thu nhỏ"), cfg.gestures.zoom)
    
    ; Section 3: System & Window
    settingsGui.SetFont("s10 bold c" . colors.primary, "Segoe UI Semibold")
    settingsGui.AddText("x40 y365", _t("🖥️ Hệ thống_Cửa sổ"))
    settingsGui.AddText("x40 y383 w315 h2 Background" . colors.primary, "")
    
    chkWindowSwitch := CreateGestureCard(settingsGui, 40, 392, 315, _t("Chuyển/Đóng cửa sổ"), cfg.gestures.windowSwitch)
    chkTaskbarFocus := CreateGestureCard(settingsGui, 40, 445, 315, _t("App Taskbar"), cfg.gestures.taskbarfocus)
    chkComboClose := CreateGestureCard(settingsGui, 40, 498, 315, _t("Đóng cửa sổ"), cfg.gestures.comboClose)
    
    ; Section 4: Tools & Utilities
    settingsGui.SetFont("s10 bold c" . colors.primary, "Segoe UI Semibold")
    settingsGui.AddText("x385 y365", _t("🛠️ Công cụ_Tiện ích"))
    settingsGui.AddText("x385 y383 w315 h2 Background" . colors.primary, "")
    
    chkNinjaVanish := CreateGestureCard(settingsGui, 385, 392, 315, _t("Ẩn/Hiện Desktop"), cfg.gestures.ninjaVanish)
    chkQuickScreenshot := CreateGestureCard(settingsGui, 385, 445, 315, _t("Chụp màn hình"), cfg.gestures.quickScreenshot)
    chkWindowSnap := CreateGestureCard(settingsGui, 385, 498, 315, _t("Ghim cửa sổ"), cfg.gestures.windowSnap)
    chkTaskbarClose := CreateGestureCard(settingsGui, 385, 551, 315, _t("Đóng app trên Taskbar"), cfg.gestures.taskbarClose)
    
    ; --- TAB 2: DISPLAY ---
    tab.UseTab(2)
    settingsGui.AddText("x27 y107 w700 h505 Background" . colors.shadow, "")
    settingsGui.AddText("x25 y105 w700 h505 Background" . colors.surfaceVariant, "")
    
    settingsGui.SetFont("s10 bold c" . colors.primary, "Segoe UI Semibold")
    settingsGui.AddText("x50 y125", _t("Phản hồi trực quan"))
    settingsGui.AddText("x50 y146 w650 h2 Background" . colors.primary, "")
    
    settingsGui.SetFont("s9 c" . colors.text, "Segoe UI")
    chkFeedback := settingsGui.AddCheckbox("x50 y165 Checked" . cfg.feedback.enabled, _t(" Hiển thị phản hồi khi thao tác"))
    chkFeedback.OnEvent("Click", (*) => (
        cfg.feedback.enabled := chkFeedback.Value,
        SaveConfig()
    ))
    
    chkSound := settingsGui.AddCheckbox("x50 y192 Checked" . ((cfg.feedback.HasProp("soundEnabled") && cfg.feedback.soundEnabled) ? "1" : "0"), _t("Âm thanh phản hồi"))
    chkSound.OnEvent("Click", (*) => (
        cfg.feedback.soundEnabled := chkSound.Value,
        SaveConfig()
    ))
    
    btnSoundTest := settingsGui.AddButton("x280 y189 w120 h28", _t("🔊 Nghe thử"))
    btnSoundTest.OnEvent("Click", (*) => PlayGestureSound())
    EnhanceButton(btnSoundTest)
    RoundControl(btnSoundTest.Hwnd, 6)
    
    settingsGui.AddText("x50 y230", _t("Thời gian hiển thị:"))
    edtDuration := settingsGui.AddEdit("x180 y227 w80", cfg.feedback.duration)
    edtDuration.OnEvent("LoseFocus", (*) => (
        cfg.feedback.duration := SafeInteger(edtDuration.Value, Constants.DEFAULT_DURATION, Constants.MIN_DURATION, Constants.MAX_DURATION),
        SaveConfig(),
        edtDuration.Value := cfg.feedback.duration
    ))
    settingsGui.AddText("x268 y230", _t("ms"))
    RoundControl(edtDuration.Hwnd, 6)
    
    settingsGui.SetFont("s9 c" . colors.text, "Segoe UI")
    settingsGui.AddText("x50 y265", _t("Vị trí:"))
    
    ; Position Cards
    global positionCards := []
    global selectedPosition := cfg.feedback.position
    
    posCard1 := CreatePositionCard(settingsGui, 50, 285, 200, _t("Gần con trỏ"), "👆", (selectedPosition = "cursor"), "cursor")
    posCard2 := CreatePositionCard(settingsGui, 260, 285, 200, _t("Giữa màn hình"), "🎯", (selectedPosition = "center"), "center")
    posCard3 := CreatePositionCard(settingsGui, 470, 285, 200, _t("Góc trên phải"), "↗️", (selectedPosition = "topright"), "topright")
    
    positionCards.Push(posCard1)
    positionCards.Push(posCard2)
    positionCards.Push(posCard3)
    
    btnPreview := settingsGui.AddButton("x50 y345 w220 h40", _t("👁️ Xem thử"))
    btnPreview.SetFont("s10", "Segoe UI Semibold")
    btnPreview.OnEvent("Click", (*) => ShowVisualFeedback(_t("Preview"), 36))
    AddButtonHover(btnPreview)
    RoundControl(btnPreview.Hwnd, 8)
    
    ; --- TAB 3: ADVANCED ---
    tab.UseTab(3)
    settingsGui.AddText("x27 y107 w700 h505 Background" . colors.shadow, "")
    settingsGui.AddText("x25 y105 w700 h505 Background" . colors.surfaceVariant, "")
    
    settingsGui.SetFont("s10 bold c" . colors.primary, "Segoe UI Semibold")
    settingsGui.AddGroupBox("x50 y120 w650 h130", _t("🔧 Hệ thống"))
    settingsGui.SetFont("s9 c" . colors.text, "Segoe UI")
    
    settingsGui.AddText("x70 y150", _t("Ngôn ngữ/Language:"))
    langIdx := (cfg.language = "vi" ? 1 : 2)
    ddlLanguage := settingsGui.AddDropDownList("x225 y147 w130 Choose" . langIdx, [_t("Tiếng Việt"), _t("English")])
    ddlLanguage.OnEvent("Change", (*) => (
        langArr := ["vi", "en"],
        newLang := langArr[ddlLanguage.Value],
        (newLang != cfg.language) ? (
            result := MsgBox(_t("Reload UI to apply language?"), _t("Confirm"), "YesNo Icon?"),
            (result = _t("Yes")) ? (
                cfg.language := newLang,
                SaveConfig(),
                CreateTrayMenu(),
                settingsGui.Destroy(),
                SetTimer(() => ShowSettings(), -300)
            ) : ddlLanguage.Value := (cfg.language = "vi" ? 1 : 2)
        ) : 0
    ))
    RoundControl(ddlLanguage.Hwnd, 6)
    
    chkStartup := settingsGui.AddCheckbox("x70 y185 Checked" . (cfg.advanced.startWithWindows ? "1" : "0"), _t("Khởi động cùng Windows"))
    chkStartup.OnEvent("Click", (*) => (
        cfg.advanced.startWithWindows := chkStartup.Value,
        SaveConfig()
    ))
    
    chkShowStartup := settingsGui.AddCheckbox("x70 y212 Checked" . (cfg.advanced.showStartup ? "1" : "0"), _t("Hiện màn hình chào mừng"))
    chkShowStartup.OnEvent("Click", (*) => (
        cfg.advanced.showStartup := chkShowStartup.Value,
        SaveConfig()
    ))
    
    settingsGui.SetFont("s10 bold c" . colors.primary, "Segoe UI Semibold")
    settingsGui.AddGroupBox("x50 y260 w650 h160", _t("⚡ Hiệu năng"))
    settingsGui.SetFont("s9 c" . colors.text, "Segoe UI")
    
    settingsGui.AddText("x70 y290", _t("Bước âm lượng:"))
    edtVolStep := settingsGui.AddEdit("x240 y287 w70", cfg.advanced.volumeStep)
    edtVolStep.OnEvent("LoseFocus", (*) => UpdateVolumeStep())

    UpdateVolumeStep() {
        rawStep := SafeInteger(edtVolStep.Value, Constants.DEFAULT_VOLUME_STEP, Constants.MIN_STEP, Constants.MAX_STEP)
        evenStep := Round(rawStep / 2) * 2
        cfg.advanced.volumeStep := evenStep
        SaveConfig()
        LoadConfig()
        edtVolStep.Value := cfg.advanced.volumeStep
    }
    RoundControl(edtVolStep.Hwnd, 6)
    
    settingsGui.AddText("x70 y322", _t("Bước độ sáng:"))
    edtBriStep := settingsGui.AddEdit("x240 y319 w70", cfg.advanced.brightnessStep)
    edtBriStep.OnEvent("LoseFocus", (*) => (
        cfg.advanced.brightnessStep := SafeInteger(edtBriStep.Value, Constants.DEFAULT_BRIGHTNESS_STEP, Constants.MIN_STEP, Constants.MAX_STEP),
        SaveConfig(),
        edtBriStep.Value := cfg.advanced.brightnessStep
    ))
    RoundControl(edtBriStep.Hwnd, 6)
    
    settingsGui.AddText("x380 y290", _t("Thời gian nhấn giữ MButton:"))
    edtMTime := settingsGui.AddEdit("x540 y287 w60", cfg.advanced.mButtonTimeout)
    edtMTime.OnEvent("LoseFocus", (*) => (
        cfg.advanced.mButtonTimeout := SafeInteger(edtMTime.Value, Constants.DEFAULT_MBUTTON_TIMEOUT, 100, 2000),
        SaveConfig(),
        edtMTime.Value := cfg.advanced.mButtonTimeout
    ))
    RoundControl(edtMTime.Hwnd, 6)
    
    settingsGui.AddText("x380 y322", _t("Gia tốc cuộn:"))
    accelLabels := [_t("Tắt"), _t("x2"), _t("x3"), _t("x5"), _t("x8")]
    accelLevel := cfg.advanced.HasOwnProp("scrollAcceleration") ? cfg.advanced.scrollAcceleration : 0
    sldAccel := settingsGui.AddSlider("x485 y319 w120 Range0-4 ToolTip", accelLevel)
    txtAccelVal := settingsGui.AddText("x610 y322 w80", accelLabels[accelLevel + 1])
    sldAccel.OnEvent("Change", (*) => (
        txtAccelVal.Text := accelLabels[sldAccel.Value + 1],
        SetTimer(() => (
            cfg.advanced.scrollAcceleration := sldAccel.Value,
            SaveConfig()
        ), -300)
    ))
    
    chkDebug := settingsGui.AddCheckbox("x70 y360 Checked" . (cfg.advanced.debugMode ? "1" : "0"), _t("🐛 Chế độ gỡ lỗi"))
    chkDebug.OnEvent("Click", (*) => (
        cfg.advanced.debugMode := chkDebug.Value,
        SaveConfig()
    ))
    
    settingsGui.SetFont("s10 bold c" . colors.primary, "Segoe UI Semibold")
    settingsGui.AddText("x50 y435", _t("🗂️ Bảo trì"))
    settingsGui.AddText("x50 y456 w650 h2 Background" . colors.primary, "")
    
    settingsGui.SetFont("s9 c" . colors.text, "Segoe UI")
    btnConfigFolder := settingsGui.AddButton("x50 y470 w200 h32", _t("📁 Mở thư mục"))
    btnConfigFolder.OnEvent("Click", (*) => Run(A_ScriptDir))
    AddButtonHover(btnConfigFolder)
    RoundControl(btnConfigFolder.Hwnd, 6)
    
    btnExport := settingsGui.AddButton("x260 y470 w200 h32", _t("📤 Xuất"))
    btnExport.OnEvent("Click", (*) => ExportConfig())
    AddButtonHover(btnExport)
    RoundControl(btnExport.Hwnd, 6)
    
    btnImport := settingsGui.AddButton("x470 y470 w200 h32", _t("📥 Nhập"))
    btnImport.OnEvent("Click", (*) => ImportConfig())
    AddButtonHover(btnImport)
    RoundControl(btnImport.Hwnd, 6)
    
    ; --- TAB 4: SUPPORT (MODERN FEEDBACK FORM) ---
    tab.UseTab(4)

    ; Card background
    settingsGui.AddText("x25 y105 w700 h505 Background" . colors.surfaceVariant, "")

    ; === HEADER ===
    settingsGui.SetFont("s16 bold c" . colors.text, "Segoe UI")
    settingsGui.AddText("x50 y120", "💬 " . _t("Gửi phản hồi của bạn"))
    settingsGui.SetFont("s9 c" . colors.textLight, "Segoe UI")
    settingsGui.AddText("x50 y148", _t("Ý kiến của bạn giúp FlowWheel tốt hơn!"))

    ; Divider
    settingsGui.AddText("x50 y170 w650 h1 Background" . colors.divider, "")

    ; === FEEDBACK TEXTAREA ===
    settingsGui.SetFont("s9 c" . colors.text, "Segoe UI")
    edtFeedback := settingsGui.AddEdit("x50 y185 w650 h70 +Multi", "")
    SendMessage(0x1501, 1, StrPtr(_t("Hãy chia sẻ ý kiến, góp ý hoặc vấn đề bạn gặp phải...")), edtFeedback)
    RoundControl(edtFeedback.Hwnd, 12)

    ; === ATTACHMENT SECTION ===
    btnAttachment := settingsGui.AddButton("x50 y265 w100 h32", _t("📎 Đính kèm"))
    btnClearAttachment := settingsGui.AddButton("x160 y265 w100 h32", _t("🗑️ Xóa tệp"))
    EnhanceButton(btnAttachment)
    EnhanceButton(btnClearAttachment)
    RoundControl(btnAttachment.Hwnd, 8)
    RoundControl(btnClearAttachment.Hwnd, 8)

    global txtAttachment
    txtAttachment := settingsGui.AddText("x275 y271 w425 c" . colors.success, "")

    global feedbackImagePreview

    btnAttachment.OnEvent("Click", (*) => ShowAttachmentMenu(settingsGui))
    btnClearAttachment.OnEvent("Click", (*) => ClearAllAttachments())


    ; === CATEGORY CHIPS ===
    settingsGui.AddText("x50 y320", _t("Phản hồi của bạn thuộc loại nào?"))
    global categoryButtons := []
    global selectedCategory := 1
    categories := [{text: _t("🐛 Lỗi"), x: 50}, {text: _t("💡 Ý tưởng"), x: 170}, {text: _t("❓ Câu hỏi"), x: 290}, {text: _t("💬 Khác"), x: 410}]
    Loop categories.Length {
        cat := categories[A_Index]
        btn := settingsGui.AddButton("x" . cat.x . " y340 w110 h40", cat.text)
        btn.SetFont("s9", "Segoe UI Semibold")
        categoryButtons.Push(btn)
        RoundControl(btn.Hwnd, 20)
        if (A_Index = 1) {
            btn.Opt("Background" . colors.primary . " Border cFFFFFF")
            btn.SetFont("cFFFFFF bold")
        } else {
            btn.Opt("Background" . colors.surface . " c" . colors.text)
            btn.SetFont("c" . colors.text . " norm")
        }
        btnIndex := A_Index
        btn.OnEvent("Click", ((idx) => (*) => SelectCategory(idx))(btnIndex))
    }

    ; === RATING SECTION ===
    settingsGui.SetFont("s9 c" . colors.text, "Segoe UI")
    settingsGui.AddText("x50 y385", _t("Bạn đánh giá trải nghiệm FlowWheel thế nào?"))
    global starControls := []
    global selectedRating := 5
    Loop 5 {
        starX := 50 + (A_Index - 1) * 40
        star := settingsGui.AddButton("x" . starX . " y405 w35 h35 Center BackgroundTrans c" . colors.warning, "⭐")
        star.SetFont("s20", "Segoe UI Emoji")
        starControls.Push(star)
        currentIndex := A_Index  ; Lưu chỉ số hiện tại cho closure
        star.OnEvent("Click", ((idx) => (*) => SelectRating(idx))(currentIndex))
    }
    ; === HOVER STARS BẰNG KIỂM TRA VỊ TRÍ CHUỘT ===
    global starHoverIndex := 0
    ; Tắt timer cũ nếu có
    SetTimer(CheckStarHover, 0)
    ; Bật timer mới
    SetTimer(CheckStarHover, 30)
    CheckStarHover() {
        global starControls, starHoverIndex, settingsGui
        ; Kiểm tra GUI còn tồn tại
        if (!IsSet(settingsGui) || !IsObject(settingsGui)) {
            SetTimer(CheckStarHover, 0)
            return
        }
        try {
            MouseGetPos(&mx, &my)
            found := 0
            Loop starControls.Length {
                star := starControls[A_Index]
                star.GetPos(&x, &y, &w, &h)
                ; Lấy vị trí cửa sổ trên màn hình
                WinGetPos(&winX, &winY,,, star.Gui.Hwnd)
            absX := winX + x
            absY := winY + y
            if (mx >= absX && mx <= absX + w && my >= absY && my <= absY + h) {
                if (starHoverIndex != A_Index) {
                    starHoverIndex := A_Index
                    HighlightStars(starHoverIndex)
                }
                found := 1
                break
            }
        }
            if (!found && starHoverIndex != 0) {
                starHoverIndex := 0
                SelectRating(selectedRating)
            }
        } catch {
            ; Nếu có lỗi (GUI bị destroy), tắt timer
            SetTimer(CheckStarHover, 0)
        }
    }
    ; Dynamic rating label
    global txtRatingLabel
    txtRatingLabel := settingsGui.AddText("x255 y420 w250 c" . colors.textLight, _t("😍 Xuất sắc!"))
    txtRatingLabel.SetFont("s9", "Segoe UI")

    ; Soft divider
    settingsGui.AddText("x50 y455 w650 h1 Background" . colors.divider, "")

    ; === CONTACT INFO ===
    settingsGui.SetFont("s9 c" . colors.text, "Segoe UI")
    settingsGui.AddText("x50 y465", "📧 " . _t("Thông tin liên hệ (không bắt buộc)"))
    edtContact := settingsGui.AddEdit("x50 y485 w315 h20", "")
    SendMessage(0x1501, 1, StrPtr(_t("email.cua.ban@email.com")), edtContact)
    RoundControl(edtContact.Hwnd, 10)

    ; === DISCORD BUTTON ===
    settingsGui.AddText("x385 y465", "💬 " . _t("Tham gia cộng đồng FlowWheel"))
    btnJoinDiscord := settingsGui.AddButton("x385 y485 w315 h20", _t("🔗 Tham gia Discord  →"))
    btnJoinDiscord.SetFont("s9", "Segoe UI")
    btnJoinDiscord.OnEvent("Click", (*) => Run("https://discord.gg/UU2RXG8g"))
    EnhanceButton(btnJoinDiscord)
    RoundControl(btnJoinDiscord.Hwnd, 10)

    ; Divider
    settingsGui.AddText("x50 y530 w650 h1 Background" . colors.divider, "")

    ; === SUBMIT BUTTON ===
    btnSendFeedback := settingsGui.AddButton("x550 y370 w150 h60", "📤 " . _t("Gửi phản hồi"))
    btnSendFeedback.SetFont("s11 bold cFFFFFF", "Segoe UI Semibold")
    btnSendFeedback.Opt("Background" . colors.primary)
    btnSendFeedback.OnEvent("Click", (*) => SendFeedbackModern(edtFeedback, edtContact, txtAttachment, feedbackImagePreview))
    EnhanceButton(btnSendFeedback)
    RoundControl(btnSendFeedback.Hwnd, 12)
    ; === HOVER STARS FOR RATING ===
    HighlightStars(hoverIndex) {
        global starControls, colors
        Loop starControls.Length {
            star := starControls[A_Index]
            if (A_Index <= hoverIndex) {
                star.SetFont("c" . colors.warning)
            } else {
                star.SetFont("c" . colors.textLight)
            }
        }
    }


    ; --- BOTTOM ACTION BUTTONS ---
    tab.UseTab()
    
    settingsGui.AddText("x15 y628 w720 h1 Background" . colors.divider, "")
    
    settingsGui.SetFont("s10 c" . colors.textSecondary, "Segoe UI")


    ; Ba nút căn đều hàng dưới cùng (FULL WIDTH)
    btnReset := settingsGui.AddButton("x0 y642 w250 h42", "↺ " . _t("Đặt lại mặc định"))
    EnhanceButton(btnReset)
    RoundControl(btnReset.Hwnd, 10)

    btnModeSwitchText := isAdvancedMode ? _t("Cài đặt nhanh") : _t("Cài đặt nâng cao")
    btnModeSwitch := settingsGui.AddButton("x250 y642 w250 h42", btnModeSwitchText)
    EnhanceButton(btnModeSwitch)
    RoundControl(btnModeSwitch.Hwnd, 10)

    btnModeSwitch.OnEvent("Click", (*) => ToggleSettingsMode())

    ToggleSettingsMode() {
        global isAdvancedMode, settingsGui
        isAdvancedMode := !isAdvancedMode
        if (IsSet(settingsGui) && IsObject(settingsGui)) {
            settingsGui.Destroy()
        }
        CreateSettingsGui()
    }

    btnClose := settingsGui.AddButton("x500 y642 w250 h42", _t("✗ Đóng"))
    EnhanceButton(btnClose)
    RoundControl(btnClose.Hwnd, 10)

    btnReset.OnEvent("Click", (*) => ResetConfig(settingsGui))
    btnClose.OnEvent("Click", (*) => settingsGui.Hide())
    

    ; Support links & stats - chỉ cho tab 4 (Support)
    tab.UseTab(4)
    settingsGui.SetFont("s8 c" . colors.text, "Segoe UI")
    settingsGui.AddLink("x50 y520", '<a href="https://flowwheel.web.app/faq">• ' . _t("FAQ") . '</a>')
    settingsGui.AddLink("x150 y520", '<a href="https://flowwheel.web.app/donate">• ' . _t("Donate") . '</a>')
    settingsGui.AddLink("x270 y520", '<a href="https://flowwheel.web.app/changelog">• ' . _t("Changelog") . '</a>')
    settingsGui.AddLink("x390 y520", '<a href="https://github.com/minhhust2905/FLowWheelDevelopment.git">• ' . _t("GitHub") . '</a>')
    settingsGui.SetFont("s8 c" . colors.textLight, "Segoe UI")
    settingsGui.AddText("x600 y440 BackgroundTrans", "📊 " . _t("Sent: ") . cfg.stats.feedbackSent)
    tab.UseTab()
    settingsGui.Show("w750 h720")
    
    try {
        DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", settingsGui.Hwnd, "Int", 33, "Int*", 2, "Int", 4)
    }
    
    ApplySettingsNoFeedback(
        settingsGui,
        chkTabSwitch, chkWindowSwitch, chkTaskbarFocus, chkZoom, chkVolume, chkBrightness, chkFeedback, edtDuration, false,
        chkStartup, chkShowStartup, chkDebug,
        edtVolStep, edtBriStep, edtMTime, sldAccel,
        chkComboClose, chkTaskbarClose,
        chkTabClose, chkTabRestore, chkNinjaVanish,
        chkHorizontalScroll, chkQuickScreenshot, chkWindowSnap,
        chkMute,
        ddlLanguage
    )
}

; === SELECT RATING WITH DYNAMIC LABEL ===
SelectRating(rating) {
    global starControls, selectedRating, txtRatingLabel, colors
    selectedRating := rating
    
    ratingLabels := [_t("😞 Needs improvement"), _t("😕 Could be better"), _t("😐 Okay"), _t("😊 Good"), _t("😍 Excellent!")]
    
    Loop starControls.Length {
        star := starControls[A_Index]
        if (A_Index <= rating) {
            star.SetFont("c" . colors.warning)
        } else {
            star.SetFont("c" . colors.textLight)
        }
    }
    
    if (IsSet(txtRatingLabel) && IsObject(txtRatingLabel)) {
        txtRatingLabel.Text := ratingLabels[rating]
    }
}

; === SELECT CATEGORY (CHIP TOGGLE) ===
SelectCategory(index) {
    global categoryButtons, selectedCategory, colors
    selectedCategory := index
    
    Loop categoryButtons.Length {
        btn := categoryButtons[A_Index]
        if (A_Index = index) {
            btn.Opt("Background" . colors.primary)
            btn.SetFont("cFFFFFF bold")
        } else {
            btn.Opt("Background" . colors.surface)
            btn.SetFont("c" . colors.text . " norm")
        }
    }
}

; === SEND FEEDBACK ===
SendFeedbackModern(edtFeedback, edtContact, txtAttachment, feedbackImagePreview) {
    global selectedCategory, selectedRating
    
    categories := [_t("🐛 Bug"), _t("💡 Idea"), _t("❓ Question"), _t("💬 Other")]
    categoryText := categories[selectedCategory]
    
    SendToDiscord(edtFeedback.Value, edtContact.Value, categoryText, edtFeedback, edtContact, txtAttachment, feedbackImagePreview, selectedRating)
}

; === APPLY SETTINGS WITHOUT FEEDBACK (for initial load) ===
ApplySettingsNoFeedback(gui, chkTab, chkWin, chkTime, chkZoom, chkVol, chkBri, chkFeed, edtDur, _ddlTheme, 
    chkStart, chkShow, chkDebug, edtVolStep, edtBriStep, edtMTime, sldAccel, chkCombo, chkTaskbar, chkTabC, chkTabR, chkNinja,
    chkHScroll, chkScreenshot, chkSnap, chkMute, ddlLang) {
    global selectedPosition
    
    cfg.gestures.tabSwitch := chkTab.Value
    cfg.gestures.windowSwitch := chkWin.Value
    cfg.gestures.taskbarfocus := chkTime.Value
    cfg.gestures.zoom := chkZoom.Value
    cfg.gestures.volume := chkVol.Value
    cfg.gestures.brightness := chkBri.Value
    cfg.gestures.mute := chkMute.Value
    cfg.gestures.tabClose := chkTabC.Value
    cfg.gestures.tabRestore := chkTabR.Value
    cfg.gestures.comboClose := chkCombo.Value
    cfg.gestures.taskbarClose := chkTaskbar.Value
    cfg.gestures.ninjaVanish := chkNinja.Value
    cfg.gestures.horizontalScroll := chkHScroll.Value
    cfg.gestures.quickScreenshot := chkScreenshot.Value
    cfg.gestures.windowSnap := chkSnap.Value
    
    cfg.feedback.enabled := chkFeed.Value
    cfg.feedback.duration := SafeInteger(edtDur.Value, Constants.DEFAULT_DURATION, Constants.MIN_DURATION, Constants.MAX_DURATION)
    
    cfg.feedback.position := selectedPosition
    cfg.feedback.theme := "dark"
    
    langArr := ["vi", "en"]
    cfg.language := langArr[ddlLang.Value]
    
    cfg.advanced.volumeStep := SafeInteger(edtVolStep.Value, Constants.DEFAULT_VOLUME_STEP, Constants.MIN_STEP, Constants.MAX_STEP)
    cfg.advanced.brightnessStep := SafeInteger(edtBriStep.Value, Constants.DEFAULT_BRIGHTNESS_STEP, Constants.MIN_STEP, Constants.MAX_STEP)
    cfg.advanced.mButtonTimeout := SafeInteger(edtMTime.Value, Constants.DEFAULT_MBUTTON_TIMEOUT, 100, 2000)
    cfg.advanced.scrollAcceleration := sldAccel.Value
    cfg.advanced.startWithWindows := chkStart.Value
    cfg.advanced.showStartup := chkShow.Value
    cfg.advanced.debugMode := chkDebug.Value
}

; === APPLY SETTINGS ===
ApplySettings(gui, chkTab, chkWin, chkTime, chkZoom, chkVol, chkBri, chkFeed, edtDur, _ddlTheme, 
    chkStart, chkShow, chkDebug, edtVolStep, edtBriStep, edtMTime, sldAccel, chkCombo, chkTaskbar, chkTabC, chkTabR, chkNinja,
    chkHScroll, chkScreenshot, chkSnap, chkMute, ddlLang) {
    global selectedPosition
    
    ; Update all gestures
    cfg.gestures.tabSwitch := chkTab.Value
    cfg.gestures.windowSwitch := chkWin.Value
    cfg.gestures.taskbarfocus := chkTime.Value
    cfg.gestures.zoom := chkZoom.Value
    cfg.gestures.volume := chkVol.Value
    cfg.gestures.brightness := chkBri.Value
    cfg.gestures.mute := chkMute.Value
    cfg.gestures.tabClose := chkTabC.Value
    cfg.gestures.tabRestore := chkTabR.Value
    cfg.gestures.comboClose := chkCombo.Value
    cfg.gestures.taskbarClose := chkTaskbar.Value
    cfg.gestures.ninjaVanish := chkNinja.Value
    cfg.gestures.horizontalScroll := chkHScroll.Value
    cfg.gestures.quickScreenshot := chkScreenshot.Value
    cfg.gestures.windowSnap := chkSnap.Value
    
    ; Save feedback settings
    cfg.feedback.enabled := chkFeed.Value
    cfg.feedback.duration := SafeInteger(edtDur.Value, Constants.DEFAULT_DURATION, Constants.MIN_DURATION, Constants.MAX_DURATION)
    
    cfg.feedback.position := selectedPosition
    cfg.feedback.theme := "dark"
    
    ; Save language
    langArr := ["vi", "en"]
    oldLang := cfg.language
    cfg.language := langArr[ddlLang.Value]
    
    ; Save advanced settings
    cfg.advanced.volumeStep := SafeInteger(edtVolStep.Value, Constants.DEFAULT_VOLUME_STEP, Constants.MIN_STEP, Constants.MAX_STEP)
    cfg.advanced.brightnessStep := SafeInteger(edtBriStep.Value, Constants.DEFAULT_BRIGHTNESS_STEP, Constants.MIN_STEP, Constants.MAX_STEP)
    cfg.advanced.mButtonTimeout := SafeInteger(edtMTime.Value, Constants.DEFAULT_MBUTTON_TIMEOUT, 100, 2000)
    cfg.advanced.scrollAcceleration := sldAccel.Value
    cfg.advanced.startWithWindows := chkStart.Value
    cfg.advanced.showStartup := chkShow.Value
    cfg.advanced.debugMode := chkDebug.Value
    
    SaveConfig()
    CreateTrayMenu()
    
    ; Show feedback notification
    if (oldLang != cfg.language) {
        ShowVisualFeedback(_t("✓ Settings applied!") . " " . _t("Language changed!"))
        gui.Destroy()
        SetTimer(() => ShowSettings(), -300)
    } else {
        ShowVisualFeedback(_t("✓ Settings applied!"))
    }
}

; === RESET CONFIGURATION ===
ResetConfig(gui) {
    result := MsgBox(_t("Reset all settings to defaults?"), _t("Reset Configuration"), "YesNo Icon!")
    if (result = _t("Yes")) {
        cfg.gestures := {
            tabSwitch: true, windowSwitch: false, taskbarfocus: false, 
            zoom: false, volume: false, brightness: false,
            tabClose: false, tabRestore: false, comboClose: false, 
            taskbarClose: false, ninjaVanish: false, mute: false,
            horizontalScroll: false, quickScreenshot: false, windowSnap: false
        }
        cfg.feedback := {enabled: true, duration: 1000, position: "topright", theme: "dark", soundEnabled: true}
        cfg.advanced := {
            volumeStep: 2, brightnessStep: 5, 
            volumeDebounce: 10, brightnessDebounce: 10, zoomDebounce: 10,
            tabDebounce: 50, windowDebounce: 70, timelineDebounce: 100,
            mButtonTimeout: 300, scrollAcceleration: 0, 
            startWithWindows: true, showStartup: true, debugMode: false
        }
        SaveConfig()
        ShowVisualFeedback(_t("✓ Reset to defaults"))
        gui.Destroy()
        SetTimer(() => ShowSettings(), -300)
    }
}

