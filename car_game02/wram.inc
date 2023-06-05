SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

;SECTION "State",WRAM0
SECTION "State",WRAM0[$C100];debug
wCarDir: ds 1
wCarTurn: ds 1
wCarPosY: ds 1
wCarPosX: ds 1
wCarSpeedY: ds 1
wCarSpeedX: ds 1
wCarSpeed: ds 1
wCarShift: ds 1
wTurnWait: ds 1
wDriftWait: ds 1

wSpeedWait: ds 1
wSpeedWaitInit: ds 1
wSpeedWaitCnt: ds 1

wSmoke1Y: ds 1
wSmoke1X: ds 1
wSmoke2Y: ds 1
wSmoke2X: ds 1
wSmoke1Wait: ds 1
wSmoke2Wait: ds 1

wJoypad: ds 1
wButton: ds 1

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to