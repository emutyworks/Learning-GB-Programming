SECTION "Data",ROM0[$2000]
SoundRegCalcTbl:
  db %00111111 ; FF20 %xx543210 Initial length timer
  db %00001111 ; FF21 %7654xxxx Initial volume
  db %00000001 ;      %xxxx3xxx Env dir
  db %00000111 ;      %xxxxx210 Sweep pace
  db %00001111 ; FF22 %7654xxxx Clock shift
  db %00000001 ;      %xxxx3xxx LFSR width
  db %00000111 ;      %xxxxx210 Clock divider

BGPalette:
  dw 0
  dw 31
  dw 25492
  dw 32767

ObjPalette:
  dw 0
  dw 31
  dw 25492
  dw 32767

  dw 0
  dw 25492
  dw 31
  dw 32767

Sprites:
  INCBIN "sprites.bin"
SpritesEnd:

Tiles:
  INCBIN "tiles.bin"
TilesEnd:

BgTileMap0: ; Tile Indexes
  INCLUDE "bg_tile0.inc"
BgTileMap0End:

BgTileMap1: ; BG Map Attributes
  INCLUDE "bg_tile1.inc"
BgTileMap1End:

