SECTION "Data",ROM0[$2000]
SoundSelectTbl:
  dw SSEL0
  dw SSEL1
  dw SSEL2
  dw SSEL3
  dw SSEL4
  dw SSEL5
  dw SSEL6

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

