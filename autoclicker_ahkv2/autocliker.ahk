#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; ===== GLOBALS =====
global isRunning := false
global spamKeys := ["LButton"]
global keyIndex := 1
global toggleHotkey := ""
global cornerRadius := 16
global borderSize := 2
global btnMargin := 20
global btnSpacing := 10
global miniGui := "" ; small square
global miniDotPic := "" ; Picture control for the dot
global minW := 420, minH := 400
global rightMargin := 6

; ===== GUI =====
mainGui := Gui("+AlwaysOnTop -Caption +MinSize", "⚡ AutoClicker")
mainGui.BackColor := "2B2B2B"
mainGui.SetFont("s10 cFFFFFF", "Segoe UI")
mainGui.MinSize := minW "x" minH

panel := mainGui.AddText("Background1E1E1E")

; ===== HEADER & DRAG =====
dragHeader := mainGui.AddText("Background333333 Center", "⚡ AutoClicker")
dragHeader.SetFont("s11 Bold cFFFFFF")
dragHeader.OnEvent("Click", (*) => PostMessage(0xA1, 2,, mainGui.Hwnd))

; Minimize button top-right
minBtn := mainGui.AddText("Background333333 Center", "-")
minBtn.SetFont("s11 Bold cFFFFFF")
minBtn.OnEvent("Click", MinimizeGui)

; ===== SPAM KEYS =====
label := mainGui.AddText("Center cAAAAAA", "Keys to spam (comma separated):")
keyInput := mainGui.AddEdit("Background2A2A2A cFFFFFF Center", "LButton")

; ===== START / STOP BUTTONS =====
startBtn := mainGui.AddButton("Background55AA55 cFFFFFF", "▶ START")
stopBtn  := mainGui.AddButton("BackgroundAA5555 cFFFFFF", "⏸ STOP")
startBtn.SetFont("s10 Bold")
stopBtn.SetFont("s10 Bold")
startBtn.OnEvent("Click", StartClicker)
stopBtn.OnEvent("Click", StopClicker)

statusText := mainGui.AddText("Center cFF5555", "Status: OFF")
sep1 := mainGui.AddText("Background444444")

; ===== HOTKEY =====
hotkeyLabel := mainGui.AddText("Center cAAAAAA", "Toggle hotkey:")
hotkeyInput := mainGui.AddEdit("Background2A2A2A cFFFFFF Center", "F8")
setHotkeyBtn    := mainGui.AddButton("Background55AA55 cFFFFFF", "Set hotkey")
removeHotkeyBtn := mainGui.AddButton("BackgroundAA5555 cFFFFFF", "Remove hotkey")
setHotkeyBtn.SetFont("s10 Bold")
removeHotkeyBtn.SetFont("s10 Bold")
setHotkeyBtn.OnEvent("Click", SetToggleHotkey)
removeHotkeyBtn.OnEvent("Click", RemoveToggleHotkey)

hotkeyStatus := mainGui.AddText("Center cAAAAAA", "Current hotkey: None")
sep2 := mainGui.AddText("Background444444")
exitBtn  := mainGui.AddButton("BackgroundAA2222 cFFFFFF", "Exit")
exitBtn.SetFont("s10 Bold")
exitBtn.OnEvent("Click", (*) => ExitApp())

; ===== EVENTS =====
mainGui.OnEvent("Size", GuiResized)
mainGui.Show("w" minW " h" minH)
ApplyRoundedCorners(mainGui.Hwnd)

SetTimer(ClickLoop, 1)

; ===== CLICK LOOP =====
ClickLoop() {
	global isRunning, spamKeys, keyIndex
	if !isRunning
		return
	Send "{" spamKeys[keyIndex] "}"
	keyIndex := (keyIndex >= spamKeys.Length) ? 1 : keyIndex + 1
}

; ===== LOGIC =====
StartClicker(*) {
	global isRunning, spamKeys, keyInput, statusText
	if keyInput.Value = ""
		return
	spamKeys := StrSplit(keyInput.Value, ",")
	keyIndex := 1
	isRunning := true
	statusText.Text := "Status: ON"
	statusText.SetFont("c55FF55")
	UpdateMiniIndicator()
}

StopClicker(*) {
	global isRunning, statusText
	isRunning := false
	statusText.Text := "Status: OFF"
	statusText.SetFont("cFF5555")
	UpdateMiniIndicator()
}

SetToggleHotkey(*) {
	global toggleHotkey, hotkeyInput, hotkeyStatus
	if toggleHotkey != ""
		Hotkey(toggleHotkey, "Off")
	toggleHotkey := hotkeyInput.Value
	if toggleHotkey != ""
		Hotkey(toggleHotkey, ToggleByHotkey, "On")
	hotkeyStatus.Text := "Current hotkey: " (toggleHotkey != "" ? toggleHotkey : "None")
}

RemoveToggleHotkey(*) {
	global toggleHotkey, hotkeyStatus
	if toggleHotkey != "" {
		Hotkey(toggleHotkey, "Off")
		toggleHotkey := ""
	}
	hotkeyStatus.Text := "Current hotkey: None"
}

ToggleByHotkey(*) {
	global isRunning
	isRunning ? StopClicker() : StartClicker()
}

; ===== MINIMIZE / MINI GUI =====
MinimizeGui(*) {
	global mainGui, miniGui, miniDotPic, isRunning, cornerRadius

	mainGui.Hide()

	guiW := 100
	guiH := 30

	miniGui := Gui("+AlwaysOnTop -Caption +ToolWindow", "Mini AutoClicker")
	miniGui.BackColor := "2B2B2B"
	miniGui.SetFont("s10 cFFFFFF", "Segoe UI")

	; ===== FULL BACKGROUND PANEL for dragging =====
	bg := miniGui.AddText("Background2B2B2B")
	bg.Move(0, 0, guiW - 20, guiH)
	bg.OnEvent("Click", (*) => PostMessage(0xA1, 2,, miniGui.Hwnd))  ; drag

	; ===== LEFT: lightning logo =====
	logo := miniGui.AddText("Center Background2B2B2B", "⚡")
	logo.SetFont("s12 Bold cFFFFFF")
	logo.Move(5, 0, 20, guiH)

	; ===== CENTER: GDI-drawn dot indicator =====
	dotSize := 10
	miniDotPic := miniGui.AddPicture("x" (guiW//2 - dotSize//2) " y" (guiH//2 - dotSize//2) " w" dotSize " h" dotSize)
	miniDotPic.BackColor := "2B2B2B"
	DrawMiniDot(isRunning ? "55FF55" : "FF5555")

	; ===== RIGHT: + restore button =====
	restoreBtn := miniGui.AddText("Center Background2B2B2B", "+")
	restoreBtn.SetFont("s12 Bold cFFFFFF")
	restoreBtn.Move(guiW - 25, 0, 20, guiH)
	restoreBtn.OnEvent("Click", RestoreGui)

	miniGui.Show("w" guiW " h" guiH)
	ApplyRoundedCorners(miniGui.Hwnd)
}

; ===== Draw Mini Dot =====
DrawMiniDot(colorHex) {
	global miniDotPic
	if !IsObject(miniDotPic)
		return

	dotSize := 10
	bgColor := 0x2B2B2B

	hBitmap := CreateDIBSection(dotSize, dotSize)
	hDC := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
	hOldBmp := DllCall("SelectObject", "Ptr", hDC, "Ptr", hBitmap)

	; Fill background (matches GUI exactly)
	hBgBrush := DllCall("CreateSolidBrush", "UInt", bgColor, "Ptr")
	hOldBrush := DllCall("SelectObject", "Ptr", hDC, "Ptr", hBgBrush)
	DllCall("Rectangle"
	, "Ptr", hDC
	, "Int", 0
	, "Int", 0
	, "Int", dotSize
	, "Int", dotSize)

	DllCall("SelectObject", "Ptr", hDC, "Ptr", hOldBrush)
	DllCall("DeleteObject", "Ptr", hBgBrush)

	; Dot color
	colorValue := HexToBGR(colorHex)
	hBrush := DllCall("CreateSolidBrush", "UInt", colorValue, "Ptr")
	hOldBrush := DllCall("SelectObject", "Ptr", hDC, "Ptr", hBrush)

	hPen := DllCall("CreatePen", "Int", 0, "Int", 1, "UInt", colorValue, "Ptr")
	hOldPen := DllCall("SelectObject", "Ptr", hDC, "Ptr", hPen)

	margin := 1
	DllCall("Ellipse", "Ptr", hDC
		, "Int", margin
		, "Int", margin
		, "Int", dotSize - margin
		, "Int", dotSize - margin)

	; Cleanup
	DllCall("SelectObject", "Ptr", hDC, "Ptr", hOldPen)
	DllCall("DeleteObject", "Ptr", hPen)
	DllCall("SelectObject", "Ptr", hDC, "Ptr", hOldBrush)
	DllCall("DeleteObject", "Ptr", hBrush)
	DllCall("SelectObject", "Ptr", hDC, "Ptr", hOldBmp)
	DllCall("DeleteDC", "Ptr", hDC)

	miniDotPic.Value := "HBITMAP:" hBitmap
}


; Helper function to create a DIB section
CreateDIBSection(w, h) {
	bi := Buffer(40, 0)
	NumPut("UInt", 40, bi, 0)           ; biSize
	NumPut("Int", w, bi, 4)              ; biWidth
	NumPut("Int", -h, bi, 8)             ; biHeight (negative for top-down)
	NumPut("UShort", 1, bi, 12)          ; biPlanes
	NumPut("UShort", 32, bi, 14)         ; biBitCount

	hDC := DllCall("GetDC", "Ptr", 0, "Ptr")
	hBitmap := DllCall("CreateDIBSection", "Ptr", hDC, "Ptr", bi, "UInt", 0, "Ptr*", 0, "Ptr", 0, "UInt", 0, "Ptr")
	DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)

	return hBitmap
}

; Helper function to convert hex string to BGR value
HexToBGR(hexStr) {
	; Remove any # prefix if present
	hexStr := StrReplace(hexStr, "#", "")

	; Parse RGB components
	r := "0x" SubStr(hexStr, 1, 2)
	g := "0x" SubStr(hexStr, 3, 2)
	b := "0x" SubStr(hexStr, 5, 2)

	; Convert to BGR format (Windows GDI uses BGR)
	return (b << 16) | (g << 8) | r
}

RestoreGui(*) {
	global mainGui, miniGui, miniDotPic
	if IsObject(miniGui) {
		miniGui.Destroy()
		miniGui := ""
		miniDotPic := ""
	}
	mainGui.Show()
}

UpdateMiniIndicator() {
	global miniDotPic, isRunning
	if IsObject(miniDotPic) {
		DrawMiniDot(isRunning ? "55FF55" : "FF5555")
	}
}

; ===== RESIZE =====
GuiResized(gui, minMax, w, h) {
	global panel, dragHeader, minBtn
	global label, keyInput
	global startBtn, stopBtn
	global statusText, sep1
	global hotkeyLabel, hotkeyInput
	global setHotkeyBtn, removeHotkeyBtn
	global hotkeyStatus
	global sep2, exitBtn
	global btnMargin, btnSpacing, borderSize, rightMargin
	global minW, minH

	w := (w < minW ? minW : w)
	h := (h < minH ? minH : h)

	panel.Move(borderSize, borderSize, w, h)
	dragHeader.Move(0,0,w-30-rightMargin,34)
	minBtn.Move(w - 30 - rightMargin,0,30 + rightMargin,34)

	; Center texts horizontally by setting x = margin, width = w-margin*2, and using Center style
	label.Move(20, 50, w-40)
	keyInput.Move(20, 72, w-40)

	btnW := (w - btnMargin*2 - btnSpacing)//2
	btnH := 30
	btnY := 110
	startBtn.Move(btnMargin, btnY, btnW, btnH)
	stopBtn.Move(btnMargin+btnW+btnSpacing, btnY, btnW, btnH)

	statusText.Move(20, 155, w-40)
	sep1.Move(20, 185, w-40, 2)

	hotkeyLabel.Move(20, 200, w-40)
	hotkeyInput.Move(20, 222, w-40)

	btnY2 := 260
	setHotkeyBtn.Move(btnMargin, btnY2, btnW, btnH)
	removeHotkeyBtn.Move(btnMargin+btnW+btnSpacing, btnY2, btnW, btnH)

	hotkeyStatus.Move(20, 300, w-40)
	sep2.Move(20, 330, w-40, 2)
	exitBtn.Move(20, 350, w-40, btnH)

	ApplyRoundedCorners(gui.Hwnd)
}

; ===== ROUNDED WINDOW =====
ApplyRoundedCorners(hwnd) {
	global cornerRadius
	WinGetPos ,, &w, &h, hwnd
	rgn := DllCall("CreateRoundRectRgn",
		"int", 0, "int", 0,
		"int", w, "int", h,
		"int", cornerRadius, "int", cornerRadius,
		"ptr"
	)
	DllCall("SetWindowRgn", "ptr", hwnd, "ptr", rgn, "int", true)
}

+Esc::ExitApp