SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

SECTION "Map Indexes/Attributes Table",WRAM0[$C100]
wMapIndexesTbl: ds MapTblSize
wMapAttributesTbl: ds MapTblSize

SECTION "State",WRAM0
;SECTION "State",WRAM0[$C200];debug
wMapVram: ds 2
wMapVramPos: ds 1
wWaitCnt: ds 1
wWaitCnt2: ds 1
wMapTblPos: ds 1
wScrollCnt: ds 1
;
wPosY: ds 1
wPosX: ds 1

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to