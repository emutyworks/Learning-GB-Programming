SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

SECTION "Map Indexes/Attributes Table",WRAM0[$C0A0]
wMapIndexesTbl: ds MapSize
wMapAttributesTbl: ds MapSize

;SECTION "State",WRAM0
SECTION "State",WRAM0[$C100];debug
wDebug1: ds 1
wDebug2: ds 1
wDebug3: ds 1
wCarPosVram: ds 2
wJoypad: ds 1
wButton: ds 1

wMapTbl: ds 2
wMapVram: ds 2
wScrollCnt: ds 1
wPosY: ds 1
wPosX: ds 1
wNewPosX: ds 1

SECTION "Map Part Table",WRAMX[$D000]
wMapPartTbl: ds MapPartTblSize

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to