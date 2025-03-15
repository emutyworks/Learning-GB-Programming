DEF JBitRight      EQU 0
DEF JBitLeft       EQU 1
DEF JBitUp         EQU 2
DEF JBitDown       EQU 3
DEF JBitButtonA    EQU 4
DEF JBitButtonB    EQU 5

DEF SBY            EQU 16 ; Screen Base Y
DEF SBX            EQU 8 ; Screen Base X
DEF UseMaxOAM      EQU 16
DEF CarPosY        EQU SBY+8*12
DEF CarPosX        EQU SBX+8*9
DEF CarShiftMax    EQU 5
DEF CarCForceWait  EQU 10
DEF CarCForceLeft  EQU 1
DEF CarCForceRight EQU 2

DEF GearHi         EQU 1
DEF GearHiY        EQU 128
DEF GearHiShift    EQU 3
DEF GearLow        EQU 0
DEF GearLowY       EQU 145
DEF GearLowShift   EQU 4

;StartBgScrollY EQU -8*4
DEF StartBgScrollY EQU 0
DEF JoypadWait     EQU 7
DEF JoyPadPos      EQU 8 ; L 1-7|8|9-15 R

DEF ScrollSize     EQU 8*18
DEF ScrollBgSize   EQU 8*3
DEF ScrollRoadSize EQU 8*4
DEF ScrollMaxSize  EQU 154

;Scenario Pattern
DEF SPP14Cnt       EQU 7
DEF SPP23Cnt       EQU 16