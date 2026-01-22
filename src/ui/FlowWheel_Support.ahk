; ============================================================================
; FLOWWHEEL - SUPPORT SYSTEM (Integration file)
; ============================================================================

; This file integrates all support-related functions
; Note: Most support functions are already in FlowWheel_Webhook.ahk
; This file serves as a bridge for the UI

; --- INITIALIZE SUPPORT SYSTEM ---
InitializeSupportSystem() {
    ; Ensure feedback cooldown properties exist
    if (!cfg.HasOwnProp("feedbackCooldown")) {
        cfg.feedbackCooldown := {
            lastSentTime: 0,
            feedbackStep: 1
        }
    }
    
    ; Ensure feedback stats exist
    if (!cfg.stats.HasOwnProp("feedbackSent")) {
        cfg.stats.feedbackSent := 0
    }
    
    DebugLog("Support system initialized")
}

; --- GET FEEDBACK STATS ---
GetFeedbackStats() {
    return {
        sent: cfg.stats.feedbackSent,
        cooldownStep: cfg.feedbackCooldown.feedbackStep
    }
}

; --- VALIDATE FEEDBACK INPUT ---
ValidateFeedbackInput(content, filePath := "") {
    ; Check if content or file is provided
    if (Trim(content) == "" && filePath == "") {
        return [false, _t("Vui lòng nhập nội dung hoặc đính kèm file!")]
    }
    
    ; Check file size if file is provided
    if (filePath != "" && FileExist(filePath)) {
        fileSize := FileGetSize(filePath) / 1024 / 1024 ; MB
        if (fileSize > 8) {
            return [false, _t("File quá lớn! Discord giới hạn 8MB")]
        }
    }
    
    return [true, ""]
}

; --- UPDATE FEEDBACK UI ---
UpdateFeedbackUI(txtControl, imageControl, filePath) {
    if (filePath != "") {
        SplitPath(filePath, &fileName)
        if (IsSet(txtControl) && IsObject(txtControl)) {
            txtControl.Text := "📎 " . fileName
            txtControl.SetFont("cBlue")
        }
        
        ; Preview image if it's an image file
        if (IsSet(imageControl) && IsObject(imageControl)) {
            ext := StrLower(SubStr(filePath, -3))
            if (ext = ".png" || ext = ".jpg" || ext = "jpeg" || ext = ".bmp" || ext = ".gif") {
                try {
                    imageControl.Value := filePath
                    imageControl.Visible := true
                    imageControl.Move(40, 335, 200, 120)
                }
            } else {
                imageControl.Visible := false
            }
        }
    } else {
        if (IsSet(txtControl) && IsObject(txtControl)) {
            txtControl.Text := _t("(Chưa chọn file)")
            txtControl.SetFont("c" . colors.textLight)
        }
        if (IsSet(imageControl) && IsObject(imageControl)) {
            imageControl.Value := ""
            imageControl.Visible := false
        }
    }
}