JBitRight      EQU 0
JBitLeft       EQU 1
JBitUp         EQU 2
JBitDown       EQU 3
JBitButtonA    EQU 4
JBitButtonB    EQU 5
JBitSelect     EQU 6
JBitStart      EQU 7
JoypadWait     EQU 10

SBY            EQU 16 ; Screen Base Y
SBX            EQU 8 ; Screen Base X

SValueY        EQU SBY+8*1
SValueX        EQU SBX
UseMaxOAM      EQU 22

RegAddr        EQU _SCRN1+32
WaveAddr       EQU _SCRN0+32*6+16
Wave2Max       EQU 16
Wave2NumMax    EQU Wave2Max*2
Wave2GraphMax  EQU 16*8
Wave2CurPosY   EQU SBY+8*14+1
Wave2CurPosX   EQU SBX+8

ResetWaveAddr  EQU _SCRN0+32*6+31
ResetBGTile    EQU 47

BGPaletteCnt   EQU 4*2
ObjPaletteCnt  EQU 4*2