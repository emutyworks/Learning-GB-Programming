SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

;SECTION "State",WRAM0
SECTION "State",WRAM0[$C100];debug
wCarSpriteY: ds 1
wCarSpriteX: ds 1
wNewCarSpriteY: ds 1
wNewCarSpriteX: ds 1
wNewRSCY: ds 1
wNewRSCX: ds 1
wNewSmokeY: ds 1
wNewSmokeX: ds 1

wCarDir: ds 1
wCarTurn: ds 1
wCarSpeedY: ds 1
wCarSpeedX: ds 1
wCarSpeed: ds 1
wCarShift: ds 1
wTurnWait: ds 1
wDriftWait: ds 1

wSpeedWait: ds 1
wSpeedWaitInit: ds 1
wSpeedWaitCnt: ds 1

wSmokeY: ds 1
wSmokeX: ds 1
wSmokeAddY: ds 1
wSmokeAddX: ds 1
wSmokeWait: ds 1

wJoypad: ds 1
wButton: ds 1

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to