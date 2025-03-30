SECTION "HBlank Road Y Position Table",ROM0[$2000]
RoadYPosTbl:
  db S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1
  db S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1
  db S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1
  db S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1
  db S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0
  db S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0
  db S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0
  db S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0,S0,S0,S0,S1,S1,S1,S1,S0

SECTION "Car Sprite Table",ROM0[$2200]
CarSpriteTbl:
  ;X Pos,Tile Index,Attributes/Flags * 3 + 0,0,0,0
  db  8,28,$01, 16,28,$21, 1, 0,$00, 23, 0,$20, 0,0,0,0 ; Center
  db  8,40,$01, 16,44,$01, 1,32,$00, 23,36,$20, 0,0,0,0 ; Right
  db  8,44,$21, 16,40,$21, 1,36,$00, 23,32,$20, 0,0,0,0 ; Left

SECTION "Rival Car Sprite Table",ROM0[$2300]
RCarSpriteTbl:
  ;Y Pos,Add X Pos,Tile Index,Attributes/Flags * 2
  db RY00,8,26,$03, RY00,16,26,$23
  db RY01,8,26,$03, RY01,16,26,$23
  db RY02,8,22,$03, RY02,16,22,$23
  db RY03,8,22,$03, RY03,16,22,$23
  db RY04,8,22,$03, RY04,16,22,$23
  db RY05,8,22,$03, RY05,16,22,$23
  db RY06,8,18,$03, RY06,16,18,$23
  db RY07,8,18,$03, RY07,16,18,$23
  db RY08,8,18,$03, RY08,16,18,$23
  db RY09,8,16,$03, RY09,16,16,$23
  db RY10,8,16,$03, RY10,16,16,$23
  db RY11,8,16,$03, RY11,16,16,$23
  db RY12,8,16,$03, RY12,16,16,$23
  db RY13,8,20,$03, RY13,16,20,$23
  db RY14,8,20,$03, RY14,16,20,$23
  db RY15,8,20,$03, RY15,16,20,$23
  db RY16,8,20,$03, RY16,16,20,$23
  db RY17,8,20,$03, RY17,16,20,$23
  db RY18,8,24,$03, RY18,16,24,$23
  db RY19,8,24,$03, RY19,16,24,$23
  db RY20,8,24,$03, RY20,16,24,$23
  db RY21,8,24,$03, RY21,16,24,$23
  db RY22,8,24,$03, RY22,16,24,$23
  db RY23,8,28,$03, RY23,16,28,$23
  db RY24,8,28,$03, RY24,16,28,$23
  db RY25,8,28,$03, RY25,16,28,$23
  db RY26,8,28,$03, RY26,16,28,$23
  db RY27,8,28,$03, RY27,16,28,$23
  db RY28,8,28,$03, RY28,16,28,$23
  db RY29,8,28,$03, RY29,16,28,$23
  db RY30,8,28,$03, RY30,16,28,$23
  db RY31,8,28,$03, RY31,16,28,$23

  ;"Rival Car Tire Table",ROM0[$2400]
  db RY00,8,26,$03, RY00,16,26,$23
  db RY01,8,26,$03, RY01,16,26,$23
  db RY02,8,22,$03, RY02,16,22,$23
  db RY03,8,22,$03, RY03,16,22,$23
  db RY04,8,22,$03, RY04,16,22,$23
  db RY05,8,22,$03, RY05,16,22,$23
  db RY06,8,18,$03, RY06,16,18,$23
  db RY07,8,18,$03, RY07,16,18,$23
  db RY08,8,18,$03, RY08,16,18,$23
  db RY09,3,12,$02, RY09,21,12,$22
  db RY10,3,12,$02, RY10,21,12,$22
  db RY11,3,12,$02, RY11,21,12,$22
  db RY12,3,12,$02, RY12,21,12,$22
  db RY13,3, 8,$02, RY13,21, 8,$22
  db RY14,3, 8,$02, RY14,21, 8,$22
  db RY15,3, 8,$02, RY15,21, 8,$22
  db RY16,3, 8,$02, RY16,21, 8,$22
  db RY17,3, 8,$02, RY17,21, 8,$22
  db RY18,2, 4,$02, RY18,22, 4,$22
  db RY19,2, 4,$02, RY19,22, 4,$22
  db RY20,2, 4,$02, RY20,22, 4,$22
  db RY21,2, 4,$02, RY21,22, 4,$22
  db RY22,2, 4,$02, RY22,22, 4,$22
  db RY23,1, 0,$02, RY23,23, 0,$22
  db RY24,1, 0,$02, RY24,23, 0,$22
  db RY25,1, 0,$02, RY25,23, 0,$22
  db RY26,1, 0,$02, RY26,23, 0,$22
  db RY27,1, 0,$02, RY27,23, 0,$22
  db RY28,1, 0,$02, RY28,23, 0,$22
  db RY29,1, 0,$02, RY29,23, 0,$22
  db RY30,1, 0,$02, RY30,23, 0,$22
  db RY31,1, 0,$02, RY31,23, 0,$22

BGPalette:
  dw 576
  dw 12684
  dw 32767
  dw 31

  dw 576
  dw 12684
  dw 1023
  dw 32767

  dw 10565
  dw 32234
  dw 32767
  dw 0  

  dw 266
  dw 500
  dw 10565
  dw 0

ObjPalette:
  dw 15855
  dw 0
  dw 29596
  dw 924

  dw 15855
  dw 0
  dw 28
  dw 924

  dw 15855
  dw 0
  dw 29596
  dw 32564

  dw 15855
  dw 0
  dw 32006
  dw 32564

;===================================================================================
;
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
;
;===================================================================================

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

;===================================================================================
;
;adress                      ;[wJoyPadPos]
;RoadXPosTbl:
;$4000                       ;L 1-7|8|9-15 R
;$4040 %0100 0000 %0100 0000 ;%00 01 ;1
;$4080 %0100 0000 %1000 0000 ;%00 10 ;2
;$40c0 %0100 0000 %1100 0000 ;%00 11 ;3
;$4100 %0100 0001 %0000 0000 ;%01 00 ;4
;$4140 %0100 0001 %0100 0000 ;%01 01 ;5
;$4180 %0100 0001 %1000 0000 ;%01 10 ;6
;$41c0 %0100 0001 %1100 0000 ;%01 11 ;7
;-
;$4200 %0100 1000 %1000 0000 ;%10 00 ;8
;-
;$4240 %0100 0010 %0100 0000 ;%10 01 ;9
;$4280 %0100 0010 %1000 0000 ;%10 10 ;10
;$42c0 %0100 0010 %1100 0000 ;%10 11 ;11
;$4300 %0100 0011 %0000 0000 ;%11 00 ;12
;$4340 %0100 0011 %0100 0000 ;%11 01 ;13
;$4380 %0100 0011 %1000 0000 ;%11 10 ;14
;$43c0 %0100 0011 %1100 0000 ;%11 11 ;15
;
;RCarXPosTbl:
;$4400 %0100 0100
;$4500 %0100 0101
;$4600 %0100 0110
;$4700 %0100 0111
;
; - "road_x.inc" data creation command.
; php createRoadXPosTbl.php > road_x.inc
;
;===================================================================================

;SECTION "HBlank Road X Position Table",ROM0[$4000]
;RoadXPosTbl:
;SECTION "Rival Car X Position Table",ROM0[$4400]
;RCarXPosTbl:
INCLUDE "road_x.inc"
