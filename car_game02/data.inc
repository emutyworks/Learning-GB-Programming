SECTION "Car Speed Table",ROM0[$2000]
CarSpeedTbl:; Wait, Count
	db 7,7
	db 5,10
	db 3,10
	db 2,30
	db 1,50
	db 0,200

BGPalette:
	; 0
	dw 15134
	dw 0
	dw 32767
	dw 31
	; 1
	dw 15134
	dw 23391
	dw 10840
	dw 3472
	; 2
	dw 15134
	dw 8456
	dw 24311
	dw 32767
	; 3
	dw 15134
	dw 0
	dw 32767
	dw 1023
	; 4
	dw 15134
	dw 0
	dw 32767
	dw 512
	; 5
	dw 15134
	dw 0
	dw 32767
	dw 31744

ObjPalette:
	; 0
	dw 15134
	dw 0
	dw 32767
	dw 31
	; 1
	dw 15134
	dw 8456
	dw 24311
	dw 32767

SECTION "Car Sprite Table",ROM0[$2100]
CarSpriteTbl: ; AddY,AddX,Tile Index,Attributes/Flags
	; 0
	db 0,0,126,0
	db 0,8,126,OAMF_XFLIP
	db 8,0,127,0
	db 8,8,127,OAMF_XFLIP
	; 1
	db 0,0,113,0
	db 0,8,115,0
	db 8,0,114,0
	db 8,8,116,0
	; 2
	db 0,0,121,0
	db 0,8,120,0
	db 8,0,123,0
	db 8,8,122,0
	; 3
	db 0,0,109,0
	db 0,8,111,0
	db 8,0,110,0
	db 8,8,112,0
	; 4
	db 0,0,124,0
	db 0,8,125,0
	db 8,0,124,OAMF_YFLIP
	db 8,8,125,OAMF_YFLIP
	; 5
	db 0,0,110,OAMF_YFLIP
	db 0,8,112,OAMF_YFLIP
	db 8,0,109,OAMF_YFLIP
	db 8,8,111,OAMF_YFLIP
	; 6
	db 0,0,123,OAMF_YFLIP
	db 0,8,122,OAMF_YFLIP
	db 8,0,121,OAMF_YFLIP
	db 8,8,120,OAMF_YFLIP
	; 7
	db 0,0,114,OAMF_YFLIP
	db 0,8,116,OAMF_YFLIP
	db 8,0,113,OAMF_YFLIP
	db 8,8,115,OAMF_YFLIP
	; 8
	db 0,0,127,OAMF_YFLIP
	db 0,8,127,OAMF_YFLIP|OAMF_XFLIP
	db 8,0,126,OAMF_YFLIP
	db 8,8,126,OAMF_YFLIP|OAMF_XFLIP
	;9
	db 0,0,116,OAMF_YFLIP|OAMF_XFLIP
	db 0,8,114,OAMF_YFLIP|OAMF_XFLIP
	db 8,0,115,OAMF_YFLIP|OAMF_XFLIP
	db 8,8,113,OAMF_YFLIP|OAMF_XFLIP
	; 10
	db 0,0,122,OAMF_YFLIP|OAMF_XFLIP
	db 0,8,123,OAMF_YFLIP|OAMF_XFLIP
	db 8,0,120,OAMF_YFLIP|OAMF_XFLIP
	db 8,8,121,OAMF_YFLIP|OAMF_XFLIP
	;11
	db 0,0,112,OAMF_YFLIP|OAMF_XFLIP
	db 0,8,110,OAMF_YFLIP|OAMF_XFLIP
	db 8,0,111,OAMF_YFLIP|OAMF_XFLIP
	db 8,8,109,OAMF_YFLIP|OAMF_XFLIP
	; 12
	db 0,0,125,OAMF_XFLIP
	db 0,8,124,OAMF_XFLIP
	db 8,0,125,OAMF_YFLIP|OAMF_XFLIP
	db 8,8,124,OAMF_YFLIP|OAMF_XFLIP
	;13
	db 0,0,111,OAMF_XFLIP
	db 0,8,109,OAMF_XFLIP
	db 8,0,112,OAMF_XFLIP
	db 8,8,110,OAMF_XFLIP
	; 14
	db 0,0,120,OAMF_XFLIP
	db 0,8,121,OAMF_XFLIP
	db 8,0,122,OAMF_XFLIP
	db 8,8,123,OAMF_XFLIP
	;15
	db 0,0,115,OAMF_XFLIP
	db 0,8,113,OAMF_XFLIP
	db 8,0,116,OAMF_XFLIP
	db 8,8,114,OAMF_XFLIP

SECTION "Direction Jump Table",ROM0[$2200]
DirJpTbl:
	;14,15,00,01,02
	;13          03
	;12          04
	;11          05
	;10,09,08,07,06
	dw Dir00
	dw Dir01
	dw Dir02
	dw Dir03
	dw Dir04
	dw Dir05
	dw Dir06
	dw Dir07
	dw Dir08
	dw Dir09
	dw Dir10
	dw Dir11
	dw Dir12
	dw Dir13
	dw Dir14
	dw Dir15

Tiles:
	INCBIN "tiles.bin"
TilesEnd:

BgTileMap0: ; Tile Indexes
	INCLUDE "bg_tile0.inc"
BgTileMap0End:

BgTileMap1: ; BG Map Attributes
	INCLUDE "bg_tile1.inc"
BgTileMap1End:
