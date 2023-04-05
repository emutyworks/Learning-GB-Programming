SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

SECTION "Map Indexes/Attributes Table",WRAM0[$C0A0]
wMapIndexesTbl: ds MapSize
wMapAttributesTbl: ds MapSize

;SECTION "State",WRAM0
SECTION "State",WRAM0[$C100];debug
wMapTbl: ds 2
wMapVram: ds 2
;wMapVramPos: ds 1
wWaitCnt: ds 1
wScrollCnt: ds 1
wPosY: ds 1
wPosX: ds 1

SECTION "Map Part Table",WRAMX[$D000]
wMapPartTbl: ds MapPartTblSize

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to