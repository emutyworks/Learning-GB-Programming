SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

State:
wJoypad: ds 1
wJoyPadPos: ds 1
wJoypadWait: ds 1
wVBlankDone: ds 1
wMainLoopFlg: ds 1
wPosY: ds 1
wPosX: ds 1
wCarPos: ds 1
wCarTireCnt: ds 1
wCarTireRef: ds 1
wRCarSpriteTblLo: ds 1
wRoadCnt: ds 1
wRoadHi: ds 1
wRoadLo: ds 1

wRCarTblCnt: ds 1;test
StateEnd:

SECTION "Rival Car Table",WRAM0[$C100]
;RCarSpriteTbl Pos, X Pos
wRCarTbl: ds 2

SECTION "rSCY Table",WRAM0[$C200]
wSCY: ds 8*7-1
wBgY: ds ScrollBgSize ;24
wRoadY: ds ScrollRoadSize ;64
ds 10+1 ;=154
;102

SECTION "rSCX Table",WRAM0[$C300]
wSCX: ds 8*7-1
wBgX: ds ScrollBgSize ;24
wRoadX: ds ScrollRoadSize ;64
ds 10+1 ;=154
;102

SECTION "HRAM Variables",HRAM
hOAMDMA:
  ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to