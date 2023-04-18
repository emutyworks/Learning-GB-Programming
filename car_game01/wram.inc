SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

SECTION "Map Indexes/Attributes Table",WRAM0[$C0A0]
wMapIndexesTbl: ds MapSize
wMapAttributesTbl: ds MapSize

;SECTION "State",WRAM0
SECTION "State",WRAM0[$C100];debug
wOneEighthY: ds 1
wOneEighthYOld: ds 1
wMapTbl: ds 2

wCarColWait: ds 1
wCarPosY: ds 1
wCarPosX: ds 1
wNewCarPosX: ds 1

wEnemyPosY: ds 1
wEnemyPosX: ds 1
wEnemyWaitCnt: ds 1

wJoypad: ds 1
wButton: ds 1

SECTION "Map Part Table",WRAMX[$D000]
wMapPartTbl: ds MapPartTblSize

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to