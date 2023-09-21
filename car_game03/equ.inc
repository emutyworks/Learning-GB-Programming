JBitRight      EQU 0
JBitLeft       EQU 1
JBitButtonA    EQU 0

SBY            EQU 16 ; Screen Base Y
SBX            EQU 8 ; Screen Base X
CarStartY      EQU SBY+8*12
CarStartX      EQU SBX+8*9

StartBgPos     EQU 8*7-1
StartRoadPos   EQU 8*10-1 ;EndBgPos
EndRoadPos     EQU 8*14-1
StartBgScrollY EQU 232
RoadPosWait    EQU 0

BGPaletteCnt   EQU 4*4
ObjPaletteCnt  EQU 4*1

; HBlank Scroll Position Table
S0 EQU 96
S1 EQU 64

; Road Pattern Table
RPR EQU 0 ; Right
RPL EQU 1 ; Left
RPS EQU 2 ; Straight
RPU EQU 3 ; Up
RPD EQU 4 ; Down
