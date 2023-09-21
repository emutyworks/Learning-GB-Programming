SECTION "HBlank Scroll Position Table",ROM0[$2000]
ScrollPosTbl:
	;0
	db S0,S1,S0,S1,S0,S1,S1,S0,S1,S1,S0,S0,S1,S1,S0,S0
	db S1,S1,S1,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S1,S1
	;1
	db S1,S0,S1,S0,S1,S0,S1,S1,S0,S1,S1,S0,S0,S1,S1,S0
	db S0,S1,S1,S1,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S1
	;2
	db S1,S0,S1,S0,S1,S1,S0,S1,S1,S0,S1,S1,S0,S0,S1,S1
	db S0,S0,S1,S1,S1,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1
	;3
	db S0,S1,S0,S1,S0,S1,S1,S0,S1,S1,S0,S1,S1,S0,S0,S1
	db S1,S0,S0,S1,S1,S1,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1
	;4
	db S0,S1,S0,S1,S0,S1,S1,S0,S1,S1,S0,S1,S1,S0,S0,S1
	db S1,S0,S0,S1,S1,S1,S0,S0,S1,S1,S1,S1,S0,S0,S0,S1
	;5
	db S0,S1,S0,S1,S0,S1,S1,S0,S1,S1,S0,S0,S1,S1,S0,S0
	db S1,S1,S0,S0,S1,S1,S1,S0,S0,S1,S1,S1,S1,S0,S0,S0
	;6
	db S1,S0,S1,S0,S1,S0,S1,S1,S0,S1,S1,S0,S0,S1,S1,S0
	db S1,S1,S0,S0,S1,S1,S1,S0,S0,S1,S1,S1,S1,S1,S0,S0
	;7
	db S1,S0,S1,S0,S1,S0,S1,S1,S0,S1,S1,S0,S0,S1,S1,S0
	db S1,S1,S0,S0,S1,S1,S1,S0,S0,S0,S1,S1,S1,S1,S1,S0

SECTION "HBlank Scroll Left Table",ROM0[$2100]
ScrollLeftTbl:
	db 50,45,40,35,30,25,20,16,12,9,8,7,6,5,4,3
	db 2,2,2,1,0,0,0,0,0,0,0,0,0,0,0,0

SECTION "HBlank Scroll Right Table",ROM0[$2200]
ScrollRightTbl:
	db -50,-45,-40,-35,-30,-25,-20,-16,-12,-9,-8,-7,-6,-5,-4,-3
	db -2,-2,-2,-1,0,0,0,0,0,0,0,0,0,0,0,0

SECTION "Road Pattern Table",ROM0[$2300]
RoadPatternTbl:
	; mode,wait,cnt,0
	;db RPS,20,10,0 ;debug
	;db RPS,20,10,0
	;db RPS,20,10,0
	;db RPS,20,10,0

	;db RPD,10,8,0
	;db RPU,10,8,0
	;db RPL,4,40,0
	;db RPR,4,40,0

	db RPD,10,24,0 ;0
	db RPS,20,10,0 ;1 start
	db RPU,25,8,0 ;2
	db RPS,10,24,0 ;3
	db RPU,25,8,0 ;4
	db RPS,10,10,0 ;5
	db RPU,15,8,0 ;6
	db RPS,10,10,0 ;7
	db RPL,2,255,0 ;8
	db RPS,20,10,0 ;9
	db RPR,8,100,0 ;10
	db RPS,1,1,0 ;11
	db RPS,1,1,0 ;12
	db RPS,1,1,0 ;13
	db RPS,1,1,0 ;14
	db RPS,20,10,0 ;15

BGPalette:
	dw 23454
	dw 31412
	dw 5854
	dw 505

	dw 23454
	dw 31412
	dw 5854
	dw 20190

	dw 0
	dw 31412
	dw 5854
	dw 505

	dw 23454
	dw 505
	dw 31412
	dw 5854

ObjPalette:
	dw 15134
	dw 0
	dw 32767
	dw 31

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
