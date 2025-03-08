SECTION "HBlank Scroll Position Table",ROM0[$2000]
DEF S0 EQU 0
DEF S1 EQU 8*8

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
  db  8,8,$01
  db 16,8,$21
  db  0,0,$00
  db 24,0,$20

SECTION "Rival Car Sprite Table",ROM0[$2300]
DEF RY EQU SBY+8*10

RCarSpriteTbl:
;Y Pos,Add X Pos,Tile Index,Attributes/Flags * 2
db RY+0,0,0,0, RY+0,0,0,0
db RY+0,0,0,0, RY+0,0,0,0
db RY+8*3,8,10,$03, RY+8*3,16,10,$23

SECTION "Rival Car Tire Table",ROM0[$2400]
RCarTireTbl:
;Tile Index,Attributes/Flags * 2
db RY+0,0,0,0, RY+0,0,0,0
db RY+0,0,0,0, RY+0,0,0,0
db RY+8*3,1,4,$02, RY+8*3,23,4,$22

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
  dw 22688
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