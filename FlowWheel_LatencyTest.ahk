
MsgBox "Nhấn OK để bắt đầu kiểm tra 3 phương pháp giảm độ trễ."

; --- Phương pháp 1: Sleep 10 ---
start1 := A_TickCount
Sleep 10
end1 := A_TickCount
latency1 := end1 - start1

; --- Phương pháp 2: Tăng độ chính xác timer hệ thống ---
DllCall("Winmm.dll\timeBeginPeriod", "UInt", 1)
start2 := A_TickCount
Sleep 10
end2 := A_TickCount
DllCall("Winmm.dll\timeEndPeriod", "UInt", 1)
latency2 := end2 - start2

; --- Phương pháp 3: Vòng lặp kiểm tra thời gian ---
start3 := A_TickCount
while (A_TickCount - start3 < 10) {
	; Chờ đủ 10ms
}
end3 := A_TickCount
latency3 := end3 - start3

MsgBox "Kết quả:\n" 
	. "1. Sleep 10: " latency1 " ms\n"
	. "2. Sleep 10 + tăng timer: " latency2 " ms\n"
	. "3. Vòng lặp 10ms: " latency3 " ms"