JBitRight      EQU 0
JBitLeft       EQU 1
JBitUp         EQU 2
JBitDown       EQU 3
JBitButtonA    EQU 4
JBitButtonB    EQU 5
JoypadWait     EQU 7

SBY            EQU 16 ; Screen Base Y
SBX            EQU 8 ; Screen Base X

SValueY        EQU SBY+8*1
SValueX        EQU SBX
SValueMax      EQU 7
SRegPosX       EQU SBX+8*9
SReg20PosY     EQU SBY+8*1
SReg21PosY     EQU SBY+8*2
SReg22PosY     EQU SBY+8*5

BGPaletteCnt   EQU 4*1
ObjPaletteCnt  EQU 4*2