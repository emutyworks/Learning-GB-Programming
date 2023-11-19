JBitRight      EQU 0
JBitLeft       EQU 1
JBitUp         EQU 2
JBitDown       EQU 3
JBitButtonA    EQU 4
JBitButtonB    EQU 5

SBY            EQU 16 ; Screen Base Y
SBX            EQU 8 ; Screen Base X
UseMaxOAM      EQU 16
CarPosY        EQU SBY+8*12
CarPosX        EQU SBX+8*9
CarShiftMax    EQU 5
CarCForceWait  EQU 10
CarCForceLeft  EQU 1
CarCForceRight EQU 2

GearHi         EQU 1
GearHiY        EQU 139
GearHiShift    EQU 3
GearLow        EQU 0
GearLowY       EQU 145
GearLowShift   EQU 4

StartBgScrollY EQU 0
JoypadWait     EQU 7
JoyPadPos      EQU 8 ; L 1-7|8|9-15 R

ScrollSize     EQU 8*18
ScrollBgSize   EQU 8*3
ScrollRoadSize EQU 8*4
ScrollMaxSize  EQU 154

BGPaletteCnt   EQU 4*4
ObjPaletteCnt  EQU 4*2