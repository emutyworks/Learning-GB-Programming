JBitRight      EQU 0
JBitLeft       EQU 1
JBitButtonA    EQU 4
JBitButtonB    EQU 5

SBY            EQU 16 ; Screen Base Y
SBX            EQU 8 ; Screen Base X
CarPosY        EQU SBY+8*12
CarPosX        EQU SBX+8*9
CarShiftMax    EQU 5

StartBgScrollY EQU 0
JoypadWait     EQU 5
JoyPadPos      EQU 8 ; L 1-7|8|9-15 R

ScrollSize     EQU 8*18
ScrollBgSize   EQU 8*3
ScrollRoadSize EQU 8*4
ScrollMaxSize  EQU 154

BGPaletteCnt   EQU 4*4
ObjPaletteCnt  EQU 4*2

; HBlank Scroll Position Table
S0 EQU 128
S1 EQU 80

; Road Pattern Table
RPRR EQU 0 ; Road Right
RPRL EQU 1 ; Road Left
RPRS EQU 2 ; Road Straight
RPBU EQU 3 ; BG Up
RPBD EQU 4 ; BG Down
RPUD EQU 5 ; Road Up/Down