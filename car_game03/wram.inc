SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

SECTION "State",WRAM0
wJoyPadPos: ds 1
wJoyPadPosAddr: ds 2
wJoypadWait: ds 1
wRoadPTbl: ds 1
wRoadPWaitDef: ds 1
wRoadPMode: ds 1
wRoadPCnt: ds 1
wRoadPNum: ds 1
wRoadPWait: ds 1
wRoadPosWait: ds 1
wRoadPos: ds 1
wJoypad: ds 1
wButton: ds 1

wVBlankDone: ds 1
wMainLoopFlg: ds 1

SECTION "rSCY Table",WRAM0[$C100]
wSCY: ds 55
wBgY: ds ScrollBgSize ;24
wRoadY: ds ScrollRoadSize ;32
ds 43 ;154

wRoadYUD: ds ScrollRoadSize

SECTION "rSCX Table",WRAM0[$C200]
wSCX: ds 55
wBgX: ds ScrollBgSize
wRoadX: ds ScrollRoadSize
ds 43

SECTION "RoadXLR",WRAM0[$C300]
wRoadXLR: ds ScrollRoadSize
SECTION "JoyPadXLR",WRAM0[$C400]
wJoyPadXLR: ds ScrollRoadSize

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to