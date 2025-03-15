SECTION "HBlank Scroll Position Table",ROM0[$2000]
RoadPosTbl:
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
  ;X Pos,Tile Index,Attributes/Flags
  db  8,28,$01
  db 16,28,$21
  db  1, 0,$00
  db 23, 0,$20

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

SECTION "Rival Car Tire Table",ROM0[$2400]
RCarTireTbl:
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