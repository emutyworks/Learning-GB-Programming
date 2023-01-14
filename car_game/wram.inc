SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

SECTION "OAM Position",WRAM0[$C100]
wOAMPosition: ds 2*40 ; Y,X

;SECTION "State",WRAM0
SECTION "State",WRAM0[$C200];debug
wCarDirection: ds 1
wCollisionY: ds 1
wCollisionX: ds 1
wPosY: ds 1
wPosX: ds 1
wNextSCY: ds 1
wNextSCX: ds 1
wNextPosY: ds 1
wNextPosX: ds 1
;
wJoypad: ds 1
wButton: ds 1
wCarSpeed: ds 1
wCarSpeedUpWait: ds 1
wCarSpeedDownWait: ds 1
wCarTurnWait: ds 1
;wCarDirection: ds 1
wCarPattern: ds 1
;
wEngineSound: ds 1
wSoundTbl: ds 2
wSoundWait: ds 1
;
wLoopFlg: ds 1
wLightPalette: ds 2

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to