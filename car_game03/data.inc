SECTION "HBlank Scroll Position Table",ROM0[$2000]
S0 EQU 128
S1 EQU 80

ScrollPosTbl:
  db S0,S1,S0,S1,S1,S0,S1,S1,S0,S1,S1,S1,S0,S0,S1,S1,S1,S1,S0,S0,S1,S1,S1,S1,S0,S0,S0,S1,S1,S1,S1,S1
  db S0,S1,S0,S1,S1,S0,S1,S1,S0,S1,S1,S1,S0,S0,S1,S1,S1,S1,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S1,S1,S1,S1
  db S1,S0,S1,S0,S1,S1,S0,S1,S1,S0,S1,S1,S1,S0,S0,S1,S1,S1,S1,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S1,S1,S1
  db S1,S0,S1,S0,S1,S1,S0,S1,S1,S0,S0,S1,S1,S1,S0,S0,S1,S1,S1,S1,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S1,S1
  db S1,S0,S1,S0,S1,S1,S0,S1,S1,S0,S0,S1,S1,S1,S0,S0,S1,S1,S1,S1,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S1,S1
  db S1,S0,S1,S0,S1,S0,S1,S1,S0,S1,S1,S0,S0,S1,S1,S1,S0,S0,S1,S1,S1,S1,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0
  db S0,S1,S0,S1,S1,S0,S1,S1,S0,S1,S1,S1,S0,S0,S1,S1,S1,S0,S0,S1,S1,S1,S1,S0,S0,S0,S1,S1,S1,S1,S0,S0
  db S0,S1,S0,S1,S1,S0,S1,S1,S0,S1,S1,S1,S0,S0,S1,S1,S1,S1,S0,S0,S1,S1,S1,S1,S0,S0,S0,S1,S1,S1,S1,S0

SECTION "HBlank Scroll Left Table",ROM0[$2100]
ScrollLeftTbl:
  ;0
  db 7,6,5,4,3,3,3,3,3,3,2,2,2,1,1,1
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  ;1
  db 20,16,12,9,8,7,6,5,4,3,3,2,2,1,1,1
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  ;2
  db 25,20,16,12,9,8,7,6,5,4,3,3,2,2,1,1
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  ;3
  db 30,25,20,16,12,9,8,7,6,5,4,3,3,2,2,1
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  ;4
  db 35,30,25,20,16,12,9,8,7,6,5,4,3,3,2,2
  db 2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,0
  ;5
  db 40,35,30,25,20,16,12,9,8,7,6,5,4,3,3,2
  db 2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,0
  ;6
  db 45,40,35,30,25,20,16,12,9,8,7,6,5,4,3,3
  db 3,2,2,2,1,1,1,1,1,1,1,1,1,1,1,0
  ;7
  db 50,45,40,35,30,25,20,16,12,9,8,7,6,5,4,3
  db 3,2,2,2,1,1,1,1,1,1,1,1,1,1,1,0

SECTION "HBlank Scroll Right Table",ROM0[$2200]
ScrollRightTbl:
  ;0
  db -7,-6,-5,-4,-3,-3,-3,-3,-3,-3,-2,-2,-2,-1,-1,-1
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  ;1
  db -20,-16,-12,-9,-8,-7,-6,-5,-4,-3,-3,-2,-2,-1,-1,-1
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  ;2
  db -25,-20,-16,-12,-9,-8,-7,-6,-5,-4,-3,-3,-2,-2,-1,-1
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  ;3
  db -30,-25,-20,-16,-12,-9,-8,-7,-6,-5,-4,-3,-3,-2,-2,-1
  db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
  ;4
  db -35,-30,-25,-20,-16,-12,-9,-8,-7,-6,-5,-4,-3,-3,-2,-2
  db -2,-2,-2,-2,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0
  ;5
  db -40,-35,-30,-25,-20,-16,-12,-9,-8,-7,-6,-5,-4,-3,-3,-2
  db -2,-2,-2,-2,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0
  ;6
  db -45,-40,-35,-30,-25,-20,-16,-12,-9,-8,-7,-6,-5,-4,-3,-3
  db -3,-2,-2,-2,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0
  ;7
  db -50,-45,-40,-35,-30,-25,-20,-16,-12,-9,-8,-7,-6,-5,-4,-3
  db -3,-2,-2,-2,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0

SECTION "HBlank Scroll LR Table",ROM0[$2300]
ScrollLRTbl:
  ;0
  db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  ;1
  db   0, -3, -5, -8,-10,-13,-15,-18,-20,-23,-26,-28,-31,-33,-36,-38
  db -41,-44,-46,-49,-51,-54,-56,-59,-61,-64,-67,-69,-72,-74,-77,-79
  ;2
  db   0, -2, -4, -6, -8,-10,-11,-13,-15,-17,-19,-21,-23,-25,-27,-29
  db -31,-32,-34,-36,-38,-40,-42,-44,-46,-48,-50,-52,-53,-55,-57,-59
  ;3
  db   0, -2, -3, -5, -6, -8,-10,-11,-13,-14,-16,-17,-19,-21,-22,-24
  db -25,-27,-29,-30,-32,-33,-35,-37,-38,-40,-41,-43,-45,-46,-48,-49
  ;4
  db   0, -1, -3, -4, -5, -6, -8, -9,-10,-11,-13,-14,-15,-17,-18,-19
  db -20,-22,-23,-24,-25,-27,-28,-29,-30,-32,-33,-34,-36,-37,-38,-39
  ;5
  db   0, -1, -2, -3, -4, -5, -6, -7, -8, -9,-10,-10,-11,-12,-13,-14
  db -15,-16,-17,-18,-19,-20,-21,-22,-23,-24,-25,-26,-27,-28,-29,-29
  ;6
  db   0, -1, -1, -2, -2, -3, -4, -4, -5, -6, -6, -7, -7, -8, -9, -9
  db -10,-11,-11,-12,-12,-13,-14,-14,-15,-16,-16,-17,-17,-18,-19,-19
  ;7
  db   0,  0, -1, -1, -1, -2, -2, -2, -2, -3, -3, -3, -4, -4, -4, -5
  db  -5, -5, -5, -6, -6, -6, -7, -7, -7, -8, -8, -8, -8, -9, -9, -9
ScrollLRCenterTbl:
  ;8 center ---
  db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  db  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
  ;9
  db  0, 0, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5
  db  5, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9
  ;10
  db  0, 1, 1, 2, 2, 3, 4, 4, 5, 6, 6, 7, 7, 8, 9, 9
  db 10,11,11,12,12,13,14,14,15,16,16,17,17,18,19,19
  ;11
  db  0, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,10,11,12,13,14
  db 15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,29
  ;12
  db  0, 1, 3, 4, 5, 6, 8, 9,10,11,13,14,15,17,18,19
  db 20,22,23,24,25,27,28,29,30,32,33,34,36,37,38,39
  ;13
  db  0, 2, 3, 5, 6, 8,10,11,13,14,16,17,19,21,22,24
  db 25,27,29,30,32,33,35,37,38,40,41,43,45,46,48,49
  ;14
  db  0, 2, 4, 6, 8,10,11,13,15,17,19,21,23,25,27,29
  db 31,32,34,36,38,40,42,44,46,48,50,52,53,55,57,59
  ;15
  db  0, 3, 5, 8,10,13,15,18,20,23,26,28,31,33,36,38
  db 41,44,46,49,51,54,56,59,61,64,67,69,72,74,77,79

SECTION "Car Speed/Smoke Table",ROM0[$2500]
CarSpeedTbl:
  ;shift wait,loop wait,ScrollRoadSize,RivalWait
  db 10,0,0,13
  db 60,3,ScrollRoadSize,12
  db 50,2,ScrollRoadSize,10
  db 50,1,ScrollRoadSize,8
  db 50,0,ScrollRoadSize,8
  db 30,0,ScrollRoadSize*2,3 ;24

CarSmokeTbl:
  ;0:skip,1:right,2:left,3:left/right
  ;  L               C             R
  ;  0 1 2 3 4 5 6 7 8 9 101112131415
  db 3,3,3,3,3,2,0,0,0,0,0,1,3,3,3,3 ;16
CarSpriteTbl:
  ;Tile Index,Attributes/Flags,Tile Index,Attributes/Flags
  db 0,0,0,0|OAMF_XFLIP ;0 straight
  db 2,0,2,0|OAMF_XFLIP
  db 4,0,6,0 ;2 left
  db 8,0,10,0
  db 12,0,14,0 ;4 right
  db 16,0,18,0 ;24
SoundTbl:
  ;Output level,Frequency low,Hi,0
  db %01000000,$40,%10000000,0
  db %00100000,$60,%10000000,0
  db %00100000,$7F,%10000000,0
  db %00100000,$9F,%10000001,0
  db %00100000,$bf,%10000010,0
  db %00100000,$FF,%10000011,0 ;24
WaveData:
  db $12,$56 ; 1,2,5,6
  db $BC,$DC ; 11,12,13,12
  db $DB,$DD ; 13,11,13,13
  db $CE,$A9 ; 12,14,10,09
  db $76,$65 ; 07,06,06,05 ;10
WaveDataEnd:

RivalCarTbl:
  ;Y,X,Tile Index,flag
  db   0, 0,40,0 ;0
  db  82,84,40,0 ;1
  db  83,84,40,0 ;2
  db  84,84,40,0 ;3
  db  85,84,44,0 ;4
  db  86,84,44,0 ;5
  db  87,84,44,0 ;6
  db  88,80,48,1 ;7
  db  89,80,48,1 ;8
  db  90,80,48,1 ;9
  db  91,80,48,1 ;10
  db  92,80,52,1 ;11
  db  93,80,52,1 ;12
  db  94,80,52,1 ;13
  db  95,80,52,1 ;14
  db  96,80,56,1 ;15
  db  97,80,56,1 ;16
  db  98,80,56,1 ;17
  db  99,80,56,1 ;18
  db 100,80,56,1 ;19
  db 101,80,56,1 ;20
  db 102,80,60,1 ;21
  db 103,80,60,1 ;22
  db 104,80,60,1 ;23
  db 105,80,60,1 ;24
  db 106,80,60,1 ;25
  db 107,80,60,1 ;26
  db 108,80,60,1 ;27
  db 109,80,60,1 ;28
  db 110,80,60,1 ;29
  db 111,80,60,1 ;30
  db 112,80,60,1 ;31 ;128
  ;30

SECTION "Dashboard GB Table",ROM0[$2600]
CounterDBGTbl:
  db 64,65 ;0
  db 66,67 ;1
  db 68,69 ;2
  db 68,70 ;3
  db 71,72 ;4
  db 73,70 ;5
  db 73,74 ;6
  db 75,67 ;7
  db 76,74 ;8
  db 76,70 ;9
  ;236

SECTION "BG Palette Table1",ROM0[$2700]
BGPaletteTbl1:
  dw $5b9e,$7ab4,$4ede,$01f9 ,$5b9e,$16de,$16de,$01f9
  dw $5b7f,$7ada,$4ede,$01f9 ,$5b7f,$16de,$16de,$01f9
  dw $675f,$6ade,$4ede,$01f9 ,$675f,$16de,$16de,$01f9
  dw $6b5c,$4e37,$4ede,$01f9 ,$6b5c,$16de,$16de,$01f9
  dw $5af9,$460c,$4ede,$01f9 ,$5af9,$16de,$16de,$01f9
  dw $0000,$0000,$0000,$0000 ,$0000,$16de,$16de,$0000
  ;160

SECTION "BG Palette Table2",ROM0[$2800]
BGPaletteTbl2:
  dw $5b9e,$7ab4,$4ede,$01f9 ,$675b,$7fff,$56b5,$4e73
  dw $5b7f,$7ada,$4ede,$01f9 ,$56d7,$7fff,$56b5,$4e73
  dw $675f,$6ade,$4ede,$01f9 ,$4a74,$7fff,$56b5,$4e73
  dw $6b5c,$4e37,$4ede,$01f9 ,$39f4,$7fff,$56b5,$4e73
  dw $5af9,$460c,$4ede,$01f9 ,$254b,$7fff,$56b5,$4e73
  dw $0000,$0000,$0000,$0000 ,$0000,$7fff,$56b5,$0000
  ;160

SECTION "Scenario Table",ROM0[$2900]
;Scenario Pattern
SPRC EQU SetSPRivalCar   ; Set Rival Car
SPPL EQU SetSPPalette    ; Set BG/Obj Set Palette 
SPP1 EQU SetSPPalChange1 ; Set BG/Obj Palette Change Bright->Dark
SPP2 EQU SetSPPalChange2 ;
SPP3 EQU SetSPPalChange3 ;
SPP4 EQU SetSPPalChange4 ; Set BG/Obj Palette Change Dark->Bright
;Road Pattern
RPTL EQU SetRoadPLeft    ; Turn Left
RPLS EQU SetRoadPLeftSt  ; Turn Left->Straight
RPTR EQU SetRoadPRight   ; Turn Right
RPRS EQU SetRoadPRightSt ; Turn Right->Straight
RPBU EQU SetRoadPBgUp    ; BG Up
RPBD EQU SetRoadPBgDown  ; BG Down
RPWT EQU SetRoadPWait    ; Wait

ScenarioTbl:
  ;SPRC: addr,palette(H8)|x(L8)|$01
  ;SPPL: addr,palette(16)|$01
  ;SPPA,RPxx: addr,wait(16)|cnt(16)

  ;debug
  ;dw RPWT,$2001
  ;dw RPWT,$ff01
  ;dw SPRC,$1801
  ;dw RPWT,$2001

  dw RPWT,$0101
  dw SPPL,$0001 ;start
  dw RPWT,$ff01
  dw SPRC,$1601
  dw RPWT,$ff01
  dw SPRC,$1C01
  dw RPTL,$0450
  dw RPLS,$0408
  dw SPRC,$0601
  dw RPWT,$7f01

  dw RPTR,$0450
  dw RPRS,$0408
  dw RPBD,$0a18
  dw SPP1,$3200+SPP14Cnt ;SPPADark
  dw SPP2,$0500+SPP23Cnt
  dw RPWT,$1001
  dw SPRC,$1901
  dw RPWT,$6401
  dw SPRC,$0601
  dw RPWT,$6401

  dw SPRC,$1C01
  dw RPWT,$ff01
  dw SPPL,$0101
  dw SPP3,$0500+SPP23Cnt
  dw SPP4,$3200+SPP14Cnt ;SPPABright
  dw RPWT,$3001
  dw SPRC,$1C01
  dw RPTL,$0450
  dw RPLS,$0408
  dw RPWT,$3001 ;30

  dw SPRC,$0C01
  dw RPTR,$0450
  dw RPRS,$0408
  dw RPWT,$3001
  dw SPP1,$3200+SPP14Cnt ;SPPADark
  dw SPP2,$0500+SPP23Cnt
  dw RPWT,$1001
  dw SPRC,$1C01
  dw RPWT,$6401
  dw SPRC,$0401

  dw RPWT,$6401
  dw SPRC,$1901
  dw RPWT,$ff01
  dw SPPL,$0001
  dw SPP3,$0500+SPP23Cnt
  dw SPP4,$3200+SPP14Cnt ;SPPABright
  dw RPWT,$3001
  dw SPRC,$0C01
  dw RPBU,$0a03
  dw RPWT,$1001

  dw RPBU,$0a03
  dw RPWT,$1001
  dw RPBU,$0a03
  dw RPWT,$1001
  dw RPBU,$0a04
  dw RPWT,$1001
  dw RPBU,$0a05
  dw RPWT,$1001
  dw RPBU,$0a06
  dw RPWT,$1001 ;60

  dw RPWT,$3001
  dw RPWT,$0101
  dw RPWT,$0101
  dw RPWT,$0101

BGPalette:
  dw 0
  dw 0
  dw 0
  dw 0

  dw 0
  dw 0
  dw 0
  dw 0

  dw 0
  dw 0
  dw 0
  dw 0

  dw 0
  dw 0
  dw 0
  dw 0

  dw 0
  dw 32767
  dw 0
  dw 31412

  dw 0
  dw 15680
  dw 25492
  dw 32767

ObjPalette:
  dw 15134
  dw 0
  dw 32767
  dw 31

  dw 15134
  dw 0
  dw 32767
  dw 31374

; [Compressed data] | [Uncompressed]| [Source]       | [Created tool]
;---------------------------------------------------------------------
; sprites_comp.bin  | sprites.bin   | sprites.gbr    | GBMB
; tiles_comp.bin    | tiles.bin     | tiles.gbr      | GBTD
; bg_tile0_comp.bin | bg_tile0.bin  | map_editor.txt | GBCMapEditor
; bg_tile1_comp.bin | bg_tile1.bin  | map_editor.txt | GBCMapEditor
;
; - Compressed data creation command.
; php convBin.php 
; *RunLengthEncoder.php is executed inside convBin.php.
;
; - Related documents
; Run-length encode binary data with php and decode it with assembly code.
; https://github.com/emutyworks/Learning-GB-Programming/wiki/RunLengthEncodeDecode

Sprites:
  INCBIN "sprites_comp.bin"
SpritesEnd:

Tiles:
  INCBIN "tiles_comp.bin"
TilesEnd:

BgTileMap0: ; Tile Indexes
  INCBIN "bg_tile0_comp.bin"
BgTileMap0End:

BgTileMap1: ; BG Map Attributes
  INCBIN "bg_tile1_comp.bin"
BgTileMap1End:

;test
;SECTION "HBlank Scroll Up/Down Table"
ScrollUpDnTbl:
	;0
	;db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	;db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	;1
	;db -1,-2,-3,-4,-4,-4,-4,-3,-3,-3,-2,-2,-2,-1,-1,-1
	;db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	;2
	db -1,-2,-3,-4,-5,-6,-7,-8,-8,-8,-8,-7,-7,-6,-6,-5
	db -5,-4,-3,-2,-1,0,0,0,0,0,0,0,0,0,0,0
	;3
	db -1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,-12,-12,-12,-11
	db -11,-10,-9,-8,-7,-6,-5,-5,-3,-3,-2,-2,-1,-1,0,0
	;4
	db -1,-2,-3,-4,-5,-6,-7,-8,-9,-10,-11,-12,-13,-14,-15,-16
	db -15,-13,-11,-10,-8,-8,-8,-8,-8,-8,-8,-7,-5,-3,-1,0

