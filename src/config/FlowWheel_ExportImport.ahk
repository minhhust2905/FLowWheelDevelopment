; ============================================================================
; FLOWWHEEL - CONFIG EXPORT/IMPORT
; ============================================================================

; --- EXPORT CONFIGURATION ---
ExportConfig() {
    ; Determine source config file
    sourceFile := A_ScriptDir . "\..\resources\config\flowwheel.ini"
    if !FileExist(sourceFile)
        sourceFile := A_ScriptDir . "\..\resources\flowwheel.ini"
    
    ; Ask for save location
    selectedFile := FileSelect("S16", A_ScriptDir . "\flowwheel_backup.ini", _t("Export FlowWheel Config"), "INI Files (*.ini)")
    if (selectedFile) {
        try {
            ; Ensure file extension
            if !InStr(selectedFile, ".ini")
                selectedFile .= ".ini"
            
            ; Copy config file
            FileCopy(sourceFile, selectedFile, 1)
            ShowVisualFeedback(_t("✓ Config exported successfully!"))
        } catch as err {
            MsgBox(_t("Export failed: ") . err.Message, _t("Export Error"), "Icon!")
        }
    }
}

; --- IMPORT CONFIGURATION ---
ImportConfig() {
    ; Ask for file to import
    selectedFile := FileSelect(3, A_ScriptDir, _t("Import FlowWheel Config"), "INI Files (*.ini)")
    if (selectedFile) {
        ; Confirmation dialog
        result := MsgBox(_t("This will overwrite your current settings. Continue?"), _t("Import Config"), "YesNo Icon!")
        if (result = "Yes") {
            try {
                ; Determine destination config file
                destFile := A_ScriptDir . "\..\resources\config\flowwheel.ini"
                if !FileExist(A_ScriptDir . "\..\resources\config")
                    destFile := A_ScriptDir . "\..\resources\flowwheel.ini"
                
                ; Copy config file
                FileCopy(selectedFile, destFile, 1)
                
                ; Reload config and UI
                LoadConfig()
                CreateTrayMenu()
                ShowVisualFeedback(_t("✓ Config imported! Reloading..."))
                
                ; Schedule reload
                SetTimer(() => Reload(), -1000)
            } catch as err {
                MsgBox(_t("Import failed: ") . err.Message, _t("Import Error"), "Icon!")
            }
        }
    }
}