JBitRight      EQU 0
JBitLeft       EQU 1
JBitButtonA    EQU 0

SBY            EQU 16 ; Screen Base Y
SBX            EQU 8 ; Screen Base X
CarPosY        EQU SBY+8*12
CarPosX        EQU SBX+8*9

StartBgScrollY EQU 232
RoadPosWait    EQU 0
JoypadWait     EQU 3
JoyPadPos      EQU 8 ; L 1-7|8|9-15 R

ScrollSize     EQU 8*18
ScrollBgSize   EQU 8*3
ScrollRoadSize EQU 8*4

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
