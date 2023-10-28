SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

SECTION "State",WRAM0
wJoyPadPos: ds 1
wJoypadWait: ds 1
wRoadPTbl: ds 1
wRoadPWaitDef: ds 1
wRoadPMode: ds 2
wRoadPCnt: ds 1
wRoadPWait: ds 1
wRoadPLRCnt: ds 1

wRoadPos: ds 1
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

SECTION "rSCY Table",WRAM0[$C100]
wSCY: ds 55
wBgY: ds ScrollBgSize ;24
wRoadY: ds ScrollRoadSize ;32
ds 43 ;154

wRoadYUD: ds ScrollRoadSize ;32
;69

SECTION "rSCX Table",WRAM0[$C200]
wSCX: ds 55
wBgX: ds ScrollBgSize
wRoadX: ds ScrollRoadSize
ds 43
;101

SECTION "RoadXLR",WRAM0[$C300]
wRoadXLR: ds ScrollRoadSize ;32
;224
SECTION "JoyPadXLR",WRAM0[$C400]
wJoyPadXLR: ds ScrollRoadSize ;32
;224

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to