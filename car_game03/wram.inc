SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

;SECTION "State",WRAM0
SECTION "State",WRAM0[$C100];debug
wBgYPos: ds 1
wBgXPos: ds 1

wRoadPTbl: ds 1
wRoadPWaitDef: ds 1
wRoadPCnt: ds 1
wRoadPWait: ds 1

wRoadPos: ds 1
wRoadPosWait: ds 1
wVBlankDone: ds 1

wJoypad: ds 1
wButton: ds 1
wCarSpriteY: ds 1
wCarSpriteX: ds 1

SECTION "HRAM Variables",HRAM
hRoadPMode: ds 1
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to