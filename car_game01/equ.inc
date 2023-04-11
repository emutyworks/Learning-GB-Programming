JBitRight      EQU 0
JBitLeft       EQU 1
JBitButtonA    EQU 0

MapPosCnt      EQU 8
MapVramPosMax  EQU 31
MapSize        EQU 20
MapTblSize     EQU 10
MapPartTblSize EQU 2048

SBY            EQU 16 ; Screen Base Y
SBX            EQU 8 ; Screen Base X
CarBaseY       EQU 8*11
CarStartY      EQU SBY+CarBaseY
CarStartX      EQU SBX+8*9
CarVibration   EQU 2

BGPaletteCnt   EQU 4*3
ObjPaletteCnt  EQU 4*1

BGPriorityTile EQU $1E
BGDontColTile  EQU $03

MapVramX31     EQU $9BE0 ; $9800+$20*31
MapVramX20     EQU $9A80 ; $9800+$20*20
MapVramDec     EQU $FFE0
MapVramMin     EQU $97E0 ; $9800-$20

SetMapTblEnd      EQU LOW($C0A0+MapSize*2-1) ; $C0A0 = wMapIndexesTbl
WMapIndexesEnd    EQU LOW($C0A0+MapSize)
WMapAttributesEnd EQU LOW($C0A0+MapSize*2)