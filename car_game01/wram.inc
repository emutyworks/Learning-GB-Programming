SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

;SECTION "State",WRAM0
SECTION "State",WRAM0[$C100];debug
wMapVram: ds 2
wMapVramPos: ds 1
wWaitCnt: ds 1
wWaitCnt2: ds 1
wMapTblPos: ds 1
wMapTbl0: ds 2
wMapTbl1: ds 2
wScrollCnt: ds 1
;
wPosY: ds 1
wPosX: ds 1

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to