; Loop flg
LoopSound        EQU %00000001
LoopSoundBit     EQU 0 ; %00000001
;
OamTblCnt        EQU 4*5
OAMPositionCnt   EQU 5
; Shadow OAM
Light1SA         EQU 3 ; Attributes
Light2SA         EQU 7
Light3SA         EQU 11
Car1S            EQU 4*5
;
SBY              EQU 16 ; Screen Base Y
SBX              EQU 8 ; ScreenBaseX
ScrollMaxY       EQU SBY+8*12
ScrollMaxX       EQU SBX+8*11
ScrollAreaYup    EQU SBY+8*4
ScrollAreaYdown  EQU SBY+8*12
ScrollAreaXleft  EQU SBX+8*4
ScrollAreaXright EQU SBX+8*14
ScreenMaxY       EQU SBY+8*15
ScreenMaxX       EQU SBX+8*17
ScreenMinY       EQU SBY+8
ScreenMinX       EQU SBX+8
Car1StartY       EQU SBY+8*4
Car1StartX       EQU SBX+8*9
CarDataCnt       EQU 16
CarDirectionMax  EQU 7
CarSpeedMax      EQU 3
CarTurnWait      EQU 5
BGPaletteCnt     EQU 4*2
ObjPaletteCnt    EQU 4*5
SoundDataCnt     EQU 3
