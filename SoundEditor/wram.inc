SECTION "Shadow OAM",WRAM0[$C000]
wShadowOAM: ds 4*40 ; This is the buffer we'll write sprite data to

;State
wPosY: ds 1
wPosX: ds 1
wHex: ds 1
wJoypad: ds 1
wJoyPadPos: ds 1
wJoypadWait: ds 1
wVBlankDone: ds 1
wMainLoopFlg: ds 1

wMode: ds 1
wFF10: ds 1
wFF11: ds 1
wFF12: ds 1
wFF13: ds 1
wFF14: ds 1
wFF1B: ds 1
wFF1C: ds 1
wFF1D: ds 1
wFF1E: ds 1
wFF20: ds 1
wFF21: ds 1
wFF22: ds 1

;Sound Value
wSValueTbl: ds 2
wSRegCalcTbl: ds 2
wSValueMax: ds 1
wPlayFlg: ds 1

wSValue0Tbl:
wLengthTimer0: ds 1
wVolume0: ds 1
wEnv0: ds 1
wSweep0: ds 1
wShift0: ds 1
wLFSR0: ds 1
wDivider0: ds 1

wSValue1Tbl:
wPace1: ds 1
wDir1: ds 1
wStep1: ds 1
wDuty1: ds 1
wLengthTimer1: ds 1
wVolume1: ds 1
wEnv1: ds 1
wSweep1: ds 1
wOctave1: ds 1
wNote1: ds 1

wSValue2Tbl:
wLengthTimer2: ds 1
wLevel2: ds 1
wOctave2: ds 1
wNote2: ds 1
wWaveCur: ds 1
wWave2GraphAddrL: ds 1

SECTION "Wave Num",WRAM0[$C1E0]
wWave2Num: ds Wave2NumMax
SECTION "Wave Graph",WRAM0[$C200]
wWave2Graph: ds Wave2GraphMax

SECTION "HRAM Variables",HRAM
hOAMDMA:
  ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to