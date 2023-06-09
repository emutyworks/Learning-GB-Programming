JBitRight      EQU 0
JBitLeft       EQU 1
JBitButtonA    EQU 0

SBY            EQU 16 ; Screen Base Y
SBX            EQU 8 ; Screen Base X
CarStartY      EQU SBY+8*4
CarStartX      EQU SBX+8*6
CarMaxShift    EQU 5

ScrollRightPos EQU SBX+8*15-16
ScrollRightSC  EQU 8*12
ScrollLeftPos  EQU SBX+8*5
ScrollLeftSC   EQU 0

ScrollDownPos  EQU SBY+8*14-16
ScrollDownSC   EQU 8*14
ScrollUpPos    EQU SBY+8*4
ScrollUpSC     EQU 0

TurnWait       EQU 5
DriftWait      EQU 30

Smoke1Wait     EQU 10
Smoke2Wait     EQU 20

BGPaletteCnt   EQU 4*5
ObjPaletteCnt  EQU 4*2