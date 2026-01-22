; ============================================================================
; FLOWWHEEL - WEBHOOK FUNCTIONS (DISCORD)
; ============================================================================

; --- TEST WEBHOOK CONNECTION ---

; --- MULTIPART FILE UPLOAD HELPER ---
PostMultipart(url, filePath, payloadJSON) {
    try {
        Boundary := "----WebKitFormBoundary" . A_TickCount . A_Now
        
        ; Read file data
        fileObj := FileOpen(filePath, "r")
        fileSize := fileObj.Length
        fileData := Buffer(fileSize)
        fileObj.RawRead(fileData)
        fileObj.Close()
        SplitPath(filePath, &fileName)

        ; Build multipart data
        strTop := "--" . Boundary . "`r`n"
        strTop .= 'Content-Disposition: form-data; name="payload_json"' . "`r`n`r`n"
        strTop .= payloadJSON . "`r`n"
        strTop .= "--" . Boundary . "`r`n"
        strTop .= 'Content-Disposition: form-data; name="file"; filename="' . fileName . '"' . "`r`n"
        strTop .= "Content-Type: application/octet-stream`r`n`r`n"

        strBottom := "`r`n--" . Boundary . "--`r`n"

        ; Convert strings to UTF-8 buffers
        bufTop := StrToUtf8(strTop)
        bufBottom := StrToUtf8(strBottom)

        ; Calculate total body length
        bodyLen := bufTop.Size + fileSize + bufBottom.Size
        finalBody := Buffer(bodyLen)
        
        ; Assemble final body
        DllCall("RtlMoveMemory", "Ptr", finalBody.Ptr, "Ptr", bufTop.Ptr, "UPtr", bufTop.Size)
        DllCall("RtlMoveMemory", "Ptr", finalBody.Ptr + bufTop.Size, "Ptr", fileData.Ptr, "UPtr", fileSize)
        DllCall("RtlMoveMemory", "Ptr", finalBody.Ptr + bufTop.Size + fileSize, "Ptr", bufBottom.Ptr, "UPtr", bufBottom.Size)

        ; Convert buffer to SafeArray for WinHttpRequest
        safeArray := ComObjArray(0x11, bodyLen) ; 0x11 = VT_UI1 (Byte Array)
        pvData := 0
        DllCall("oleaut32\SafeArrayAccessData", "Ptr", ComObjValue(safeArray), "Ptr*", &pvData)
        DllCall("RtlMoveMemory", "Ptr", pvData, "Ptr", finalBody.Ptr, "UPtr", bodyLen)
        DllCall("oleaut32\SafeArrayUnaccessData", "Ptr", ComObjValue(safeArray))

        ; Send request using WinHttp.WinHttpRequest.5.1
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("POST", url, false)
        http.SetRequestHeader("Content-Type", "multipart/form-data; boundary=" . Boundary)
        http.Send(safeArray)
        
        ; Return success status
        return (http.Status = 204 || http.Status = 200)
    } catch as err {
        DebugLog("PostMultipart Error: " . err.Message, "ERROR")
        return false
    }
}

; --- STRING TO UTF-8 BUFFER ---
StrToUtf8(str) {
    size := StrPut(str, "UTF-8")
    buf := Buffer(size)
    StrPut(str, buf, "UTF-8")
    return buf
}

; --- SHARE STATS TO DISCORD ---
ShareStatsToDiscord(gui) {
    ; 1. Calculate total gestures (including new ones)
    total := cfg.stats.tabSwitch + cfg.stats.windowSwitch + cfg.stats.taskbarfocus 
        + cfg.stats.volume + cfg.stats.brightness + cfg.stats.mute + cfg.stats.zoom
        + cfg.stats.tabClose + cfg.stats.tabRestore + cfg.stats.comboClose + cfg.stats.taskbarClose 
        + cfg.stats.ninjaVanish + cfg.stats.horizontalScroll + cfg.stats.screenshot + cfg.stats.windowSnap 
        + cfg.stats.pinWindow
    
    if (total == 0) {
        ShowVisualFeedback(_t("⚠️ Chưa có dữ liệu để chia sẻ!"))
        return
    }

    ; 2. Rank System (in English for Discord)
    rank := "🐣 Newbie Clicker"
    rankColor := 10070709 
    
    if (total >= 9999999) {
        rank := "👑 GODLIKE FLOW"
        rankColor := 16766720 ; Gold
    } else if (total >= 999999) {
        rank := "🔥 Flow Master"
        rankColor := 15158332 ; Orange
    } else if (total >= 99999) {
        rank := "💎 Diamond User"
        rankColor := 3447003 ; Blue
    } else if (total >= 9999) {
        rank := "🥇 Gold Member"
        rankColor := 16776960 ; Gold
    } else if (total >= 999) {
        rank := "🥈 Silver Surfer"
        rankColor := 12370112 ; Silver
    } else if (total >= 99) {
        rank := "🥉 Bronze Starter"
        rankColor := 13467442 ; Bronze
    }

    ; 3. Find most used gesture
    maxStat := 0
    maxName := "None"
    for name, count in cfg.stats.OwnProps() {
        if (count > maxStat) {
            maxStat := count
            maxName := name
        }
    }

    ; 4. Number formatter
    FormatNum(n) {
        return RegExReplace(n, "\G\d+?(?=(\d{3})+(?:\D|$))", "$0,")
    }

    ; 5. Confirmation dialog
    try gui.Opt("-AlwaysOnTop")
    confirm := MsgBox(_t("Bạn có muốn chia sẻ thành tích") . " '" . rank . "' (" . FormatNum(total) . " gestures) " . _t("lên Discord không?"), _t("Xác nhận"), "YesNo Icon?")
    try gui.Opt("+AlwaysOnTop")
    if (confirm != "Yes")
        return

    ; 6. Send to Discord Webhook
    webhookUrl := "https://discord.com/api/webhooks/1460430434503495823/hTZa5ux7wnv1B2gPuKfLB2yTMKaH5aSeSetmfxH99G374VKPFtGmIMRr73Fnt7tVJIMS"
    
    sysInfo := A_ComputerName . " (" . A_OSVersion . ")"
    safeUser := (A_UserName != "") ? A_UserName : "Anonymous FlowWheel User"

    ; Total time saved formatter
    FormatSecondsSmall(n) {
        h := Floor(n/3600)
        m := Floor((n - h*3600)/60)
        s := n - h*3600 - m*60
        if (h>0)
            return h . "h " . m . "m " . s . "s"
        else if (m>0)
            return m . "m " . s . "s"
        return s . "s"
    }

    ; Build payload
    payload := '{'
        . '"username": "FlowWheel Stats Bot",'
        . '"embeds": [{'            . '"title": "🏆 A New Challenger Appears!",'
            . '"description": "User **' . safeUser . '** just reached a new milestone!",'
            . '"color": ' . rankColor . ','
            . '"fields": ['
                . '{"name": "🎖️ Rank Achieved", "value": "## ' . rank . '", "inline": false},'
                . '{"name": "🖱️ Total Gestures", "value": "**' . FormatNum(total) . '** gestures", "inline": true},'
                . '{"name": "⭐ Most Used", "value": "' . StrTitle(maxName) . ' (' . FormatNum(maxStat) . ' times)", "inline": true},'
                . '{"name": "⏱️ Time Saved", "value": "**' . FormatSecondsSmall(cfg.stats.secondsSaved) . '**", "inline": true},'
                . '{"name": "💻 System", "value": "' . sysInfo . '", "inline": false}'
            . '],'
            . '"footer": {"text": "FlowWheel  | Usage Statistics | Saved: ' . FormatSecondsSmall(cfg.stats.secondsSaved) . '"}' 
        . '}]'
    . '}'

    try {
        ; Use WinHttp.WinHttpRequest.5.1 for better stability
        http := ComObject("WinHttp.WinHttpRequest.5.1")
        http.Open("POST", webhookUrl, false)
        http.SetRequestHeader("Content-Type", "application/json")
        http.Send(payload)
        
        if (http.Status = 204 || http.Status = 200) {
            ShowVisualFeedback(_t("✅ Đã chia sẻ thành tích thành công!"))
        } else {
            ShowVisualFeedback(_t("⚠️ Không thể gửi: Mã lỗi") . " " . http.Status)
        }
        gui.Destroy()
    } catch as err {
        DebugLog("ShareToDiscord Error: " . err.Message, "WARN")
        ShowVisualFeedback(_t("⚠️ Không thể kết nối tới Discord!"))
    }
}

; --- COPY SYSTEM INFORMATION ---

; --- SHOW ATTACHMENT MENU ---
ShowAttachmentMenu(parentGui) {
    attachMenu := Menu()
    attachMenu.Add(_t("📷 Ảnh (PNG, JPG, BMP...)"), (*) => SelectFeedbackFile("image"))
    attachMenu.Add(_t("🎬 Video (MP4, AVI, MOV...)"), (*) => SelectFeedbackFile("video"))
    attachMenu.Add(_t("📄 Tài liệu (PDF, DOCX, TXT...)"), (*) => SelectFeedbackFile("document"))
    attachMenu.Add(_t("📦 File khác (ZIP, RAR...)"), (*) => SelectFeedbackFile("other"))
    attachMenu.Show()
}

; --- SELECT FEEDBACK FILE ---
SelectFeedbackFile(fileType) {
    global selectedFeedbackFile, txtAttachment, feedbackImagePreview, colors
    
    ; Determine filter and title based on file type
    switch fileType {
        case "image":
            filter := "Images (*.png; *.jpg; *.jpeg; *.bmp; *.gif; *.webp)"
            icon := "📷"
        case "video":
            filter := "Videos (*.mp4; *.avi; *.mov; *.wmv; *.mkv; *.flv)"
            icon := "🎬"
        case "document":
            filter := "Documents (*.pdf; *.docx; *.doc; *.txt; *.xlsx; *.pptx)"
            icon := "📄"
        case "other":
            filter := "All Files (*.*)"
            icon := "📦"
        default:
            filter := "All Files (*.*)"
            icon := "📎"
    }
    
    selectedFile := FileSelect(1, , "Chọn file đính kèm", filter)
    
    if (selectedFile) {
        ; Check file size (Discord webhook limit 8MB)
        fileSize := FileGetSize(selectedFile) / 1024 / 1024 ; Convert to MB
        if (fileSize > 8) {
            ShowVisualFeedback(_t("⚠️ File quá lớn! Discord giới hạn 8MB"))
            return
        }
        
        selectedFeedbackFile := selectedFile
        SplitPath(selectedFile, &fileName)
        
        ; Update UI
        if (IsSet(txtAttachment) && IsObject(txtAttachment)) {
            txtAttachment.Text := icon . " " . fileName
            txtAttachment.SetFont("cBlue")
        }
        
        ; Preview image if it's an image file
        if (fileType = "image" && IsSet(feedbackImagePreview) && IsObject(feedbackImagePreview)) {
            try {
                feedbackImagePreview.Value := selectedFile
                feedbackImagePreview.Visible := true
                feedbackImagePreview.Move(40, 335, 200, 120)
            }
        } else if (IsSet(feedbackImagePreview) && IsObject(feedbackImagePreview)) {
            feedbackImagePreview.Visible := false
        }
        
        ShowVisualFeedback(_t("✅ Đã chọn file: ") . fileName)
    }
}

; --- CLEAR ALL ATTACHMENTS ---
ClearAllAttachments() {
    global selectedFeedbackFile, txtAttachment, feedbackImagePreview, colors
    
    selectedFeedbackFile := ""
    
    if (IsSet(txtAttachment) && IsObject(txtAttachment)) {
        txtAttachment.Text := "(Chưa chọn file)"
        txtAttachment.SetFont("c" . colors.textLight)
    }
    
    if (IsSet(feedbackImagePreview) && IsObject(feedbackImagePreview)) {
        feedbackImagePreview.Value := ""
        feedbackImagePreview.Visible := false
    }
    
    ShowVisualFeedback(_t("🗑️ Đã xóa file đính kèm"))
}

; --- SEND TO DISCORD WITH COOLDOWN ---
SendToDiscord(Content, Contact, Category, EditCtrl, ContactCtrl, TxtCtrl := "", PicCtrl := "", Rating := 5) {
    global selectedFeedbackFile, cfg
    
    ; --- ANTI-SPAM COOLDOWN SYSTEM ---
    cooldowns := [60000, 120000, 300000] ; 60s, 120s, 300s
    lastSentTime := cfg.feedbackCooldown.lastSentTime
    feedbackStep := cfg.feedbackCooldown.feedbackStep
    cooldownTime := cooldowns[feedbackStep]

    if (lastSentTime > 0 && (A_TickCount - lastSentTime < cooldownTime)) {
        remaining := Round((cooldownTime - (A_TickCount - lastSentTime)) / 1000)
        ShowVisualFeedback(_t("⏳ FlowWheel vừa nhận phản hồi của bạn. Hãy đợi ") . remaining . _t(" giây để gửi thêm"))
        return
    }

    ; Validate input
    if (Trim(Content) == "" && selectedFeedbackFile == "") {
        ShowVisualFeedback(_t("⚠️ Vui lòng nhập nội dung hoặc đính kèm file!")) 
        return
    }

    webhookUrl := "https://discord.com/api/webhooks/1460508816561930337/IdgvCZtE6gIQJcqnEA5ZWoifaxkVg33ECzUMFXHcBiuqHnYo4Aj2_vYRpi8JDZucSAo9"
    
    ; Prepare data
    sysInfo := A_ComputerName . " (" . A_OSVersion . ")"
    contactName := (Contact == "") ? _t("Người dùng ẩn danh") : Contact
    currentCfg := "VolStep: " . cfg.advanced.volumeStep . " | BriStep: " . cfg.advanced.brightnessStep

    ; Build embed JSON
    embedJSON := '{'
        . '"embeds": [{' 
            . '"title": "📩 Feedback mới",'
            . '"color": 30871,' 
            . '"fields": ['
                . '{"name": "📁 Danh mục", "value": "' . Category . '", "inline": true},'
                . '{"name": "👤 Người gửi", "value": "' . contactName . '", "inline": true},'
                . '{"name": "⭐ Đánh giá", "value": "' . Rating . '/5", "inline": true},'
                . '{"name": "💻 Máy tính", "value": "' . sysInfo . '", "inline": true},'
                . '{"name": "⚙️ Cấu hình", "value": "' . currentCfg . '", "inline": false},'
                . '{"name": "📝 Nội dung", "value": "' . StrReplace(StrReplace(Content, '"', '\"'), "`n", "\n") . '", "inline": false}'
            . '],'
            . '"footer": {"text": "v6.6.0 | FlowWheel Support | Total: ' . (cfg.stats.feedbackSent + 1) . '"}' 
        . '}]'
    . '}'

    ShowVisualFeedback(_t("⏳ Đang gửi dữ liệu..."))

    success := false
    try {
        if (selectedFeedbackFile != "" && FileExist(selectedFeedbackFile)) {
            ; Send with file attachment
            success := PostMultipart(webhookUrl, selectedFeedbackFile, embedJSON)
        } else {
            ; Send without attachment
            http := ComObject("WinHttp.WinHttpRequest.5.1")
            http.Open("POST", webhookUrl, false)
            http.SetRequestHeader("Content-Type", "application/json")
            http.Send(embedJSON)
            success := (http.Status = 204 || http.Status = 200)
        }
    } catch as err {
        DebugLog("SendToDiscord Error: " . err.Message, "WARN")
        success := false
    }
    
    ; Process result
    if (success) {
        ; Update cooldown and stats
        cfg.feedbackCooldown.lastSentTime := A_TickCount
        cfg.feedbackCooldown.feedbackStep := (feedbackStep >= 3) ? 1 : feedbackStep + 1
        cfg.stats.feedbackSent++
        SaveConfig()
        
        ShowVisualFeedback(_t("✅ Phản hồi của bạn đã được tiếp nhận. Chúng tôi trân trọng sự đóng góp này!"))
        
        ; Clear input fields
        EditCtrl.Value := ""
        ContactCtrl.Value := ""
        selectedFeedbackFile := ""
        
        ; Reset UI (không hiện thông báo)
        ClearAllAttachmentsNoNotify()
    } else {
        ShowVisualFeedback(_t("💬 Cảm ơn bạn đã gửi phản hồi. Chúng tôi trân trọng sự đóng góp này !"))
    }
}

; --- CLEAR ATTACHMENTS WITHOUT NOTIFY ---
ClearAllAttachmentsNoNotify() {
    global selectedFeedbackFile, txtAttachment, feedbackImagePreview, colors
    selectedFeedbackFile := ""
    if (IsSet(txtAttachment) && IsObject(txtAttachment)) {
        txtAttachment.Text := "(Chưa chọn file)"
        txtAttachment.SetFont("c" . colors.textLight)
    }
    if (IsSet(feedbackImagePreview) && IsObject(feedbackImagePreview)) {
        feedbackImagePreview.Value := ""
        feedbackImagePreview.Visible := false
    }
}