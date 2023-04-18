JBitRight      EQU 0
JBitLeft       EQU 1
JBitButtonA    EQU 0

MapVramPosInit EQU 20 ; $9800+$20*20
MapSize        EQU 20
MapTblSize     EQU 10
MapPartTblSize EQU 2048

SBY            EQU 16 ; Screen Base Y
SBX            EQU 8 ; Screen Base X
CarBaseY       EQU 11
CarStartY      EQU SBY+8*CarBaseY
CarStartX      EQU SBX+8*8
CarVibration   EQU 3
CarColWait     EQU 20

EnemyStartY    EQU SBY+8*3
EnemyStartX    EQU SBX+8*8
EnemyWaitCnt   EQU 2

BGPaletteCnt   EQU 4*3
ObjPaletteCnt  EQU 4*2

BGPriorityTile EQU $1E
BGDontColTile  EQU $03

SetMapTblEnd      EQU LOW($C0A0+MapSize*2-1) ; $C0A0 = wMapIndexesTbl
WMapIndexesEnd    EQU LOW($C0A0+MapSize)
WMapAttributesEnd EQU LOW($C0A0+MapSize*2)