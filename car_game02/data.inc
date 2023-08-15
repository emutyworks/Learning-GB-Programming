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
	dw 0
	dw 8456
	dw 24311
	dw 32767
	; 1
	dw 0
	dw 8456
	dw 32767
	dw 24311

ObjPalette:
	; 0
	dw 15134
	dw 0
	dw 32767
	dw 31

SECTION "Car Sprite Table",ROM0[$2100]
	;14,15,00,01,02
	;13          03
	;12          04
	;11          05
	;10,09,08,07,06
CarSpriteTbl: ; AddY,AddX,Tile Index,Attributes/Flags
	; 00
	db 0,0,20,0
	db 0,8,22,0
	db 0,0,0,OAMF_PRI|0
	db 0,8,2,OAMF_PRI|0
	; 01
	db 0,0,24,0
	db 0,8,26,0
	db 0,0,4,OAMF_PRI|0
	db 0,8,6,OAMF_PRI|0
	; 02
	db 0,0,28,0
	db 0,8,30,0
	db 0,0,8,OAMF_PRI|0
	db 0,8,10,OAMF_PRI|0
	; 03
	db 0,0,32,0
	db 0,8,34,0
	db 0,0,12,OAMF_PRI|0
	db 0,8,14,OAMF_PRI|0
	; 04
	db 0,0,36,0
	db 0,8,38,0
	;db 0,0,16,OAMF_PRI|0
	;db 0,8,18,OAMF_PRI|0
	db 0,0,16,0
	db 0,8,18,0
	; 05
	db 255,0,32,OAMF_YFLIP|0
	db 255,8,34,OAMF_YFLIP|0
	db 255,0,12,OAMF_PRI|OAMF_PRI|OAMF_YFLIP|0
	db 255,8,14,OAMF_PRI|OAMF_PRI|OAMF_YFLIP|0
	; 06
	db 255,0,28,OAMF_YFLIP|0
	db 255,8,30,OAMF_YFLIP|0
	db 255,0,8,OAMF_PRI|OAMF_YFLIP|0
	db 255,8,10,OAMF_PRI|OAMF_YFLIP|0
	; 07
	db 255,0,24,OAMF_YFLIP|0
	db 255,8,26,OAMF_YFLIP|0
	db 255,0,4,OAMF_PRI|OAMF_YFLIP|0
	db 255,8,6,OAMF_PRI|OAMF_YFLIP|0
	; 08
	db 255,0,20,OAMF_YFLIP|0
	db 255,8,22,OAMF_YFLIP|0
	db 255,0,0,OAMF_PRI|OAMF_YFLIP|0
	db 255,8,2,OAMF_PRI|OAMF_YFLIP|0
	; 09
	db 255,255,26,OAMF_YFLIP|OAMF_XFLIP|0
	db 255,7,24,OAMF_YFLIP|OAMF_XFLIP|0
	db 255,255,6,OAMF_PRI|OAMF_YFLIP|OAMF_XFLIP|0
	db 255,7,4,OAMF_PRI|OAMF_YFLIP|OAMF_XFLIP|0
	; 10
	db 255,255,30,OAMF_YFLIP|OAMF_XFLIP|0
	db 255,7,28,OAMF_YFLIP|OAMF_XFLIP|0
	db 255,255,10,OAMF_PRI|OAMF_YFLIP|OAMF_XFLIP|0
	db 255,7,8,OAMF_PRI|OAMF_YFLIP|OAMF_XFLIP|0
	; 11
	db 255,255,34,OAMF_YFLIP|OAMF_XFLIP|0
	db 255,7,32,OAMF_YFLIP|OAMF_XFLIP|0
	db 255,255,14,OAMF_PRI|OAMF_YFLIP|OAMF_XFLIP|0
	db 255,7,12,OAMF_PRI|OAMF_YFLIP|OAMF_XFLIP|0
	; 12
	db 0,255,38,OAMF_XFLIP|0
	db 0,7,36,OAMF_XFLIP|0
	db 0,255,18,OAMF_PRI|OAMF_XFLIP|0
	db 0,7,16,OAMF_PRI|OAMF_XFLIP|0
	; 13
	db 0,255,34,OAMF_XFLIP|0
	db 0,7,32,OAMF_XFLIP|0
	db 0,255,14,OAMF_PRI|OAMF_XFLIP|0
	db 0,7,12,OAMF_PRI|OAMF_XFLIP|0
	; 14
	db 0,255,30,OAMF_XFLIP|0
	db 0,7,28,OAMF_XFLIP|0
	db 0,255,10,OAMF_PRI|OAMF_XFLIP|0
	db 0,7,8,OAMF_PRI|OAMF_XFLIP|0
	; 15
	db 0,255,26,OAMF_XFLIP|0
	db 0,7,24,OAMF_XFLIP|0
	db 0,255,6,OAMF_PRI|OAMF_XFLIP|0
	db 0,7,4,OAMF_PRI|OAMF_XFLIP|0

SECTION "Map VRAM Address Table",ROM0[$2200]
MapVramTbl:;MapY
	dw $9800 ; 0
	dw $9820 ; 1
	dw $9840 ; 2
	dw $9860 ; 3
	dw $9880 ; 4
	dw $98A0 ; 5
	dw $98C0 ; 6
	dw $98E0 ; 7
	dw $9900 ; 8
	dw $9920 ; 9
	dw $9940 ; 10
	dw $9960 ; 11
	dw $9980 ; 12
	dw $99A0 ; 13
	dw $99C0 ; 14
	dw $99E0 ; 15
	dw $9A00 ; 16
	dw $9A20 ; 17
	dw $9A40 ; 18
	dw $9A60 ; 19
	dw $9A80 ; 20
	dw $9AA0 ; 21
	dw $9AC0 ; 22
	dw $9AE0 ; 23
	dw $9B00 ; 24
	dw $9B20 ; 25
	dw $9B40 ; 26
	dw $9B60 ; 27
	dw $9B80 ; 28
	dw $9BA0 ; 29
	dw $9BC0 ; 30
	dw $9BE0 ; 31

SECTION "Direction Jump Table",ROM0[$2300]
DirJpTbl:
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
