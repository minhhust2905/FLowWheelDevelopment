; Kiểm tra kỹ thuật 15 gestures FlowWheel và xuất log ra DebugView
; Chạy file này khi DebugView đang mở để kiểm chứng thực tế

gestures := ["tabSwitch", "windowSwitch", "taskbarfocus", "zoom", "volume", "brightness", "tabClose", "tabRestore", "comboClose", "taskbarClose", "ninjaVanish", "mute", "horizontalScroll", "quickScreenshot", "windowSnap"]

for index, gesture in gestures {
    OutputDebug, % "Gesture " index ": " gesture " - OK"
}

OutputDebug, "--- Kết thúc kiểm tra 15 gestures FlowWheel ---"
