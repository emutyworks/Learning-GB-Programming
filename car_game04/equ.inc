DEF JBitRight      EQU 0
DEF JBitLeft       EQU 1
;DEF JBitUp         EQU 2
;DEF JBitDown       EQU 3
;DEF JBitButtonA    EQU 4
;DEF JBitButtonB    EQU 5

DEF SBY            EQU 16 ; Screen Base Y
DEF SBX            EQU 8 ; Screen Base X
DEF ScrollBaseX    EQU 8*6
DEF CarPosY        EQU SBY+8*15+5
DEF CarPosX        EQU SBX+8*8
DEF CarPosWait     EQU 6

DEF CarPosRightMin EQU 0
DEF CarPosCenter   EQU 3
DEF CarPosLeftMax  EQU 6

DEF JoypadWait     EQU 4
DEF JoypadLeftMin  EQU 1
DEF JoypadRightMax EQU 15

DEF ScrollBgSize   EQU 8*3
DEF ScrollRoadSize EQU 8*8
DEF ScrollMaxSize  EQU 154

DEF SOAMCarTire    EQU 4*2+2

;HBlank Scroll Position Table
DEF S0             EQU 0
DEF S1             EQU 8*8

;Rival Car
DEF RCarPosY       EQU SBY+8*10
DEF RY00           EQU RCarPosY+0
DEF RY01           EQU RCarPosY+1
DEF RY02           EQU RCarPosY+2
DEF RY03           EQU RCarPosY+3
DEF RY04           EQU RCarPosY+4
DEF RY05           EQU RCarPosY+5
DEF RY06           EQU RCarPosY+6
DEF RY07           EQU RCarPosY+7
DEF RY08           EQU RCarPosY+8
DEF RY09           EQU RCarPosY+9
DEF RY10           EQU RCarPosY+10
DEF RY11           EQU RCarPosY+11
DEF RY12           EQU RCarPosY+13
DEF RY13           EQU RCarPosY+15
DEF RY14           EQU RCarPosY+17
DEF RY15           EQU RCarPosY+19
DEF RY16           EQU RCarPosY+21
DEF RY17           EQU RCarPosY+23
DEF RY18           EQU RCarPosY+25
DEF RY19           EQU RCarPosY+27
DEF RY20           EQU RCarPosY+29
DEF RY21           EQU RCarPosY+31
DEF RY22           EQU RCarPosY+33
DEF RY23           EQU RCarPosY+36
DEF RY24           EQU RCarPosY+39
DEF RY25           EQU RCarPosY+42
DEF RY26           EQU RCarPosY+45
DEF RY27           EQU RCarPosY+48
DEF RY28           EQU RCarPosY+51
DEF RY29           EQU RCarPosY+54
DEF RY30           EQU RCarPosY+57
DEF RY31           EQU RCarPosY+60