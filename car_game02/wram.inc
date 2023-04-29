SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

SECTION "Map Indexes/Attributes Table",WRAM0[$C0A0]
wMapIndexesTbl: ds MapSize
wMapAttributesTbl: ds MapSize

;SECTION "State",WRAM0
SECTION "State",WRAM0[$C100];debug
wCarDir: ds 1
wCarPosY: ds 1
wCarPosX: ds 1
wCarSpeedY: ds 1
wCarSpeedX: ds 1

wInputWait: ds 1
wMapTbl: ds 2
wJoypad: ds 1
wButton: ds 1

SECTION "Map Part Table",WRAMX[$D000]
wMapPartTbl: ds MapPartTblSize

SECTION "HRAM Variables",HRAM
hOAMDMA:
	ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to