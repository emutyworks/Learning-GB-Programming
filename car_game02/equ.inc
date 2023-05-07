JBitRight      EQU 0
JBitLeft       EQU 1
JBitButtonA    EQU 0

MapSize        EQU 20
MapTblSize     EQU 10
MapPartTblSize EQU 2048

SBY            EQU 16 ; Screen Base Y
SBX            EQU 8 ; Screen Base X
CarStartY      EQU SBY+8*14
CarStartX      EQU SBX+8*10
CarMaxShift    EQU 5

TurnWait       EQU 4
DriftWait      EQU 25

Smoke1Wait     EQU 10
Smoke2Wait     EQU 20

BGPaletteCnt   EQU 4*3
ObjPaletteCnt  EQU 4*2

BGPriorityTile EQU $1E
BGDontColTile  EQU $03

SetMapTblEnd      EQU LOW($C0A0+MapSize*2-1) ; $C0A0 = wMapIndexesTbl
WMapIndexesEnd    EQU LOW($C0A0+MapSize)
WMapAttributesEnd EQU LOW($C0A0+MapSize*2)