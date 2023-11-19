SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

;State
wJoyPadPos: ds 1
wJoypadWait: ds 1
wRoadPTbl: ds 1
wRoadPCnt: ds 1
wRoadPWait: ds 1
wRoadPLRCnt: ds 1
wRoadPos: ds 1
wSPoint: ds 2
wSParam: ds 1
wJoypad: ds 1
wVBlankDone: ds 1
wMainLoopFlg: ds 1
wCarSprite: ds 1
wCarSmoke: ds 1
wCarSpeed: ds 1
wCarSpeedWait: ds 1
wCarGear: ds 1
wCarGearY: ds 1
wCarShift: ds 1
wCarShiftWait: ds 1
wCarCForce: ds 1
wCarCForceWait: ds 1
wCarScroll: ds 1
wAddScroll: ds 1
wEngineSound: ds 1
wSmokeTbl: ds 1
wRivalY: ds 1
wRivalX: ds 1
wRivalWaitDef: ds 1
wRivalWait: ds 1
wRivalPosZ: ds 1
wRivalPosX: ds 1
wRivalPal: ds 1
wRivalTbl: ds 1
wRivalCnt: ds 1

SECTION "Rival Car Scenario Table",WRAM0[$C100]
wRivalTblZ: ds 4
wRivalTblX: ds 4
wRivalTblPal: ds 4
;244

SECTION "rSCY Table",WRAM0[$C200]
wSCY: ds 55
wBgY: ds ScrollBgSize ;24
wRoadY: ds ScrollRoadSize ;32
ds 43 ;154

;wRoadYUD: ds ScrollRoadSize ;32
;70

SECTION "rSCX Table",WRAM0[$C300]
wSCX: ds 55
wBgX: ds ScrollBgSize
wRoadX: ds ScrollRoadSize
ds 43
;102

SECTION "RoadXLR",WRAM0[$C400]
wRoadXLR: ds ScrollRoadSize ;32
;224
SECTION "JoyPadXLR",WRAM0[$C500]
wJoyPadXLR: ds ScrollRoadSize ;32
;224

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to