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

; Amount to be bet (0-26*)
; 10 ($2000) or more supposedly prevents automated kicks.
; If PlayLegit is enabled, the range goes to 27.
BetAmount = 10

; Delay in milliseconds:
; InputDelay can't go much lower than 16, and 25-100 is much more reliable.
; Increase InputDelay if the game doesn't register this script's inputs.
; RaceDelay can't go much lower than 33000, and 35000 is much more reliable.
; Increase RaceDelay if this script isn't waiting long enough between rounds.
; TabDelay is how long this script will wait after focusing the game.
; If the game is run in borderless windowed mode, this can be shorter.
InputDelay = 50
RaceDelay = 35000
FocusDelay = 5000

; Fun options
RandomizeChosenHorse = 0
RandomizeBetAmount = 0
PlayLegit = 0

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

; Title of the game window:
; It will grab any window with this text in the title.
; Ensure windows such as its Steam properties aren't open.
WindowTitle = Steal The Car Five

; Error Text:
ErrorInvalidChosenHorse = Horse %ChosenHorse% doesn't exist. Valid values are 1 to 6.
ErrorLowBetAmount = BetAmount %BetAmount% is too low. Why did you think that would work?
ErrorGameNotRunning = Unable to locate the game. Ensure WindowTitle is configured correctly.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; End of Config
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

GetCoordinate(Coordinate1, Coordinate2, Modifier) {
	Random, Coordinate, Coordinate1, Coordinate2
	return Coordinate * Modifier
}

XModifier := WindowWidth / BaseWindowWidth
YModifier := WindowHeight / BaseWindowHeight

SetMouseDelay, %InputDelay%
SetKeyDelay, %InputDelay%, %InputDelay%
Hotkey, %HotkeyStart%, Main
Hotkey, %HotkeyStop%, Stop
Hotkey, %HotkeyDebugReload%, DebugReload
Hotkey, %HotkeyAbort%, Abort

If (ChosenHorse < 1 or ChosenHorse > 6) {
	MsgBox, %ErrorInvalidChosenHorse%
	ExitApp
}
If (BetAmount < 0) {
	MsgBox, %ErrorLowBetAmount%
	ExitApp
}

return

Main:
If (WinExist(WindowTitle)) {
	FormatTime, StartTime
	LoopCount = 0
	FocusCount = 0
	ContinueLoop = 1
	While (ContinueLoop) {
		If (WinExist(WindowTitle)) {
			If (not WinActive(WindowTitle)) {
				WinActivate
				Sleep, %FocusDelay%
				FocusCount++
			}
			If (RandomizeChosenHorse) {
				Random, ChosenHorse, 1, 6
			}
			If (RandomizeBetAmount) {
				Random, BetAmount, 0, 27
			}
			SingleEventX := GetCoordinate(BaseSingleEventX1, BaseSingleEventX2, XModifier)
			SingleEventY := GetCoordinate(BaseSingleEventY1, BaseSingleEventY2, YModifier)
			ChosenHorseX := GetCoordinate(BaseFirstHorseX1, BaseFirstHorseX2, XModifier)
			ChosenHorseY := GetCoordinate(BaseFirstHorseY1, BaseFirstHorseY2, YModifier) + (ChosenHorse - 1) * (BaseFirstHorseY2 - BaseFirstHorseY1)
			IncreaseBetX := GetCoordinate(BaseIncreaseBetX1, BaseIncreaseBetX2, XModifier)
			IncreaseBetY := GetCoordinate(BaseIncreaseBetY1, BaseIncreaseBetY2, YModifier)
			PlaceBetX := GetCoordinate(BasePlaceBetX1, BasePlaceBetX2, XModifier)
			PlaceBetY := GetCoordinate(BasePlaceBetY1, BasePlaceBetY2, YModifier)
			SendEvent {Click %SingleEventX%, %SingleEventY%}{Click %ChosenHorseX%, %ChosenHorseY%}{Click %IncreaseBetX%, %IncreaseBetY%, %BetAmount%}
			If (PlayLegit) {
				SendEvent {Click %PlaceBetX%, %PlaceBetY%}
			}
			Else {
				SendEvent {Click down}{Click %PlaceBetX%, %PlaceBetY%, 0}
			}
			Sleep, %RaceDelay%
			SendEvent {Click up}{Backspace}
			LoopCount++
		}
		Else {
			MsgBox, %ErrorGameNotRunning%
			ContinueLoop = 0
		}
	}
	FormatTime, CurrentTime
	MsgBox, This script has been running since %StartTime% and has looped %LoopCount% time(s). It is currently %CurrentTime%. It had to focus the game %FocusCount% time(s).
}
Else {
	MsgBox, %ErrorGameNotRunning%
}
return

Stop:
ContinueLoop = 0
return

DebugReload:
SendEvent {Click up}
Reload
return

Abort:
SendEvent {Click up}
ExitApp
return
