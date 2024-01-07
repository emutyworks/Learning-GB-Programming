SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

;State
wPosY: ds 1
wPosX: ds 1
wHex: ds 1
wAttr: ds 1
wJoypad: ds 1
wJoyPadPos: ds 1
wJoypadWait: ds 1
wVBlankDone: ds 1
wMainLoopFlg: ds 1
wFF20: ds 1
wFF21: ds 1
wFF22: ds 1

SECTION "Sound Value",WRAM0[$C100]
wSValueTbl:
wLengthTimer: ds 1
wVolume: ds 1
wEnv: ds 1
wSweep: ds 1
wShift: ds 1
wLFSR: ds 1
wDivider: ds 1

SECTION "HRAM Variables",HRAM
hOAMDMA:
  ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to