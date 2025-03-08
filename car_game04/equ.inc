;DEF JBitRight      EQU 0
;DEF JBitLeft       EQU 1
;DEF JBitUp         EQU 2
;DEF JBitDown       EQU 3
;DEF JBitButtonA    EQU 4
;DEF JBitButtonB    EQU 5

DEF SBY            EQU 16 ; Screen Base Y
DEF SBX            EQU 8 ; Screen Base X
DEF ScrollBaseX    EQU 8*6
DEF CarPosY        EQU SBY+8*15+6
DEF CarPosX        EQU SBX+8*8

DEF ScrollBgSize   EQU 8*3
DEF ScrollRoadSize EQU 8*8
DEF ScrollMaxSize  EQU 154

DEF SOAMCarTire    EQU 4*2+2