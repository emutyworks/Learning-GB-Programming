JBitRight      EQU 0
JBitLeft       EQU 1
JBitButtonA    EQU 0

SBY            EQU 16 ; Screen Base Y
SBX            EQU 8 ; Screen Base X
CarStartY      EQU SBY+8*12
CarStartX      EQU SBX+8*9

StartBgPos     EQU 8*7-1
EndBgPos       EQU 8*10-2
StartBgScrollY EQU 232

StartRoadPos   EQU 8*10-1
EndRoadPos     EQU 8*14-1
RoadPosWait    EQU 0

BGPaletteCnt   EQU 4*4
ObjPaletteCnt  EQU 4*1

; HBlank Scroll Position Table
S0 EQU 96
S1 EQU 64

; Road Pattern Table
RPS EQU 0 ; Straight
RPU EQU 1 ; Up
RPD EQU 2 ; Down
RPL EQU 3 ; Left
RPR EQU 4 ; Right