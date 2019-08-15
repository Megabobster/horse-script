; Default AHK stuff. I don't know what this does.

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start of Config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Start/Stop Hotkeys:
; HotkeyStart will start this script. Make sure you have the game running and you're at the right screen.
; HotkeyStop will stop this script after the round has completed.
; HotkeyDebugReload will reload this script. This is mostly for debugging.
; HotkeyAbort will exit and kill this script. You might need to mash it a few times.
HotkeyStart = Numpad0
HotkeyStop = Numpad1
HotkeyDebugReload = Numpad2
HotkeyAbort = Numpad3

; Game Window Size:
; I haven't tested it, but this script should work on resolutions other than 1920x1080.
; However, it might not work on aspect ratios other than 16:9.
WindowWidth = 1920
WindowHeight = 1080

; Horse to choose (1-6):
; I believe the first horse gives the highest rates.
ChosenHorse = 1

; Delay in milliseconds:
; These are the most reliable values I was able to find.
; ClickDelay can't go much lower than 16, and 25-100 is much more reliable.
; Increase ClickDelay if the game doesn't register this script's clicks.
; RaceDelay can't go much lower than 33000, and 35000 is much more reliable.
; Increase RaceDelay if this script isn't waiting long enough between rounds.
ClickDelay = 25
RaceDelay = 35000

; These are measurements of the boundaries of each button at 1920x1080.
; Do not edit these unless you know what you're doing.
BaseWindowWidth = 1920
BaseWindowHeight = 1080
BaseSingleEventX1 = 1200
BaseSingleEventX2 = 1688
BaseSingleEventY1 = 854
BaseSingleEventY2 = 958
BaseFirstHorseX1 = 48
BaseFirstHorseX2 = 621
BaseFirstHorseY1 = 275
BaseFirstHorseY2 = 395
BaseIncreaseBetX1 = 1488
BaseIncreaseBetX2 = 1553
BaseIncreaseBetY1 = 487
BaseIncreaseBetY2 = 552
BasePlaceBetX1 = 964
BasePlaceBetX2 = 1593
BasePlaceBetY1 = 737
BasePlaceBetY2 = 843
BaseBetAgainX1 = 716
BaseBetAgainX2 = 1204
BaseBetAgainY1 = 944
BaseBetAgainY2 = 1048

; Title of the game window:
; It will grab any window with this text in the title.
; Ensure windows such as its Steam properties aren't open.
GameWindowTitle = Steal The Car Five

; Error Text:
ErrorInvalidHorse = Horse %ChosenHorse% doesn't exist. Valid numbers are 1 to 6.
ErrorGameNotRunning = Unable to locate the game. Please ensure GameWindowTitle is configured correctly.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of Config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetAdjustedCoordinate(Coordinate1, Coordinate2, Modifier) {
	return (Coordinate1 + Coordinate2) / 2 * Modifier
}

XModifier := WindowWidth / BaseWindowWidth
YModifier := WindowHeight / BaseWindowHeight

SingleEventX := GetAdjustedCoordinate(BaseSingleEventX1, BaseSingleEventX2, XModifier)
SingleEventY := GetAdjustedCoordinate(BaseSingleEventY1, BaseSingleEventY2, YModifier)
ChosenHorseX := GetAdjustedCoordinate(BaseFirstHorseX1, BaseFirstHorseX2, XModifier)
ChosenHorseY := GetAdjustedCoordinate(BaseFirstHorseY1, BaseFirstHorseY2, YModifier) + (ChosenHorse - 1) * (BaseFirstHorseY2 - BaseFirstHorseY1)
IncreaseBetX := GetAdjustedCoordinate(BaseIncreaseBetX1, BaseIncreaseBetX2, XModifier)
IncreaseBetY := GetAdjustedCoordinate(BaseIncreaseBetY1, BaseIncreaseBetY2, YModifier)
PlaceBetX := GetAdjustedCoordinate(BasePlaceBetX1, BasePlaceBetX2, XModifier)
PlaceBetY := GetAdjustedCoordinate(BasePlaceBetY1, BasePlaceBetY2, YModifier)
BetAgainX := GetAdjustedCoordinate(BaseBetAgainX1, BaseBetAgainX2, XModifier)
BetAgainY := GetAdjustedCoordinate(BaseBetAgainY1, BaseBetAgainY2, YModifier)

SetMouseDelay, %ClickDelay%
Hotkey, %HotkeyStart%, RaceLoop
Hotkey, %HotkeyStop%, Stop
Hotkey, %HotkeyDebugReload%, DebugReload
Hotkey, %HotkeyAbort%, Abort

if (ChosenHorse < 1 or ChosenHorse > 6) {
	MsgBox, %ErrorInvalidHorse%
	ExitApp
}

return

RaceLoop:
continue = 1
While (continue) {
	if (WinExist(GameWindowTitle)) {
		If (not WinActive(GameWindowTitle)) {
			WinActivate
		}
		SendEvent {Click %SingleEventX%, %SingleEventY%}{Click %ChosenHorseX%, %ChosenHorseY%}{Click %IncreaseBetX%, %IncreaseBetY%, down}{Click %PlaceBetX%, %PlaceBetY%, 0}
		Sleep, %RaceDelay%
		SendEvent {Click up}{Click %BetAgainX%, %BetAgainY%}
	} else {
		MsgBox, %ErrorGameNotRunning%
		continue = 0
	}
}
return

Stop:
continue = 0
return

DebugReload:
SendEvent {Click up}
Reload
return

Abort:
SendEvent {Click up}
ExitApp
return
