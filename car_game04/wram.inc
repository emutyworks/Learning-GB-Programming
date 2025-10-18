SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

State:
wTurnPos: ds 1
wTurnWait: ds 1

wRoadPTbl: ds 1
wRoadPParam: ds 1
wRoadPWait: ds 1
wRoadPCnt: ds 1
wRoadPAddr: ds 2

wJoypad: ds 1
wJoyPadPos: ds 1
wJoypadWait: ds 1
;wPosY: ds 1
;wPosX: ds 1
wCarPos: ds 1
wCarPosWait: ds 1
wCarTireCnt: ds 1
wCarTireRef: ds 1
wRoadCnt: ds 1
wRoadHi: ds 1
wRoadLo: ds 1
;wRCarYPosTbl: ds 4
;wRCarYPos: ds 4
;wRCarXPosTbl: ds 4
;wRCarXPos: ds 4
wScrollWait: ds 1
StateEnd:

SECTION "rSCY Table",WRAM0[$C100]
wSCY: ds 8*7-1
wBgY: ds ScrollBgSize ;24
wRoadY: ds ScrollRoadSize ;64
wRoadXLR: ds ScrollRoadSize ;64
;49

SECTION "rSCX Table",WRAM0[$C200]
wSCX: ds 8*7-1
wBgX: ds ScrollBgSize ;24
wRoadX: ds ScrollRoadSize ;64
wJoyPadXLR: ds ScrollRoadSize ;64
;49

SECTION "Car Sprite Table",WRAM0[$C300]
wCarSpriteTbl: ds 256

SECTION "HRAM Variables",HRAM
hOAMDMA:
  ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to