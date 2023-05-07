SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

SECTION "Map Indexes/Attributes Table",WRAM0[$C0A0]
wMapIndexesTbl: ds MapSize
wMapAttributesTbl: ds MapSize

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
wTurnWait1: ds 1
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

wMapTbl: ds 2
wJoypad: ds 1
wButton: ds 1

SECTION "Map Part Table",WRAMX[$D000]
wMapPartTbl: ds MapPartTblSize

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to