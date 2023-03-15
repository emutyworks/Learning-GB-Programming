Tiles:
	INCBIN "tiles.bin"
TilesEnd:

BgTileMap0: ; Tile Indexes
	INCBIN "map.bin"
BgTileMapEnd0:

BgTileMap1: ; BG Map Attributes
	;0 0   1   2   3   4   5    6  7   8   9   10  11  12  13  14  15
	db $01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	;  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;1
	db $01,$00,$00,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;2
	db $00,$00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;3
	db $00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;4
	db $00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;5
	db $00,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;6
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;7
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;8
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;9
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,%01000001,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;10
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;11
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;12
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;13
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;14
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;15
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;16
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01,$01,$01,$01,$01
	db $01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;17
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$01,$01
	db $01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;18
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;19
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;20
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;21
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;22
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;23
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;24
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;25
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;26
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;27
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;28
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;29
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;30
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	;31
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
BgTileMapEnd1:

SECTION "Car Sprite Table",ROM0[$3000]
CarSpriteTbl: ; AddY,AddX,Tile Index,Attributes/Flags
	; Upward
	db 0,0,126,%10000000
	db 0,8,126,%10100000
	db 8,0,127,%10000000
	db 8,8,127,%10100000
	; Upward right
	db 0,0,118,%10000000
	db 0,8,117,%10000000
	db 8,0,119,%10000000
	db 8,8,118,%11100000
	; Rightward
	db 0,0,124,%10000000
	db 0,8,125,%10000000
	db 8,0,124,%11000000
	db 8,8,125,%11000000
	; Downward right
	db 0,0,119,%11000000
	db 0,8,118,%10100000
	db 8,0,118,%11000000
	db 8,8,117,%11000000
	; Downward
	db 0,0,127,%11000000
	db 0,8,127,%11100000
	db 8,0,126,%11000000
	db 8,8,126,%11100000
	; Downward left
	db 0,0,118,%10000000
	db 0,8,119,%11100000
	db 8,0,117,%11100000
	db 8,8,118,%11100000
	; Leftward
	db 0,0,125,%10100000
	db 0,8,124,%10100000
	db 8,0,125,%11100000
	db 8,8,124,%11100000
	; Upward left
	db 0,0,117,%10100000
	db 0,8,118,%10100000
	db 8,0,118,%11000000
	db 8,8,119,%10100000

SECTION "Color Palette",ROM0
BGPalette:
	; 0
	dw 15134
	dw 23391
	dw 10840
	dw 3472
	; 1
	dw 15134
	dw 8456
	dw 24311
	dw 32767

ObjPalette:
	; 0
	dw 15134
	dw 0
	dw 32767
	dw 31
	; 1
	dw 15134
	dw 0
	dw 32767
	dw 1023
	; 2
	dw 15134
	dw 0
	dw 32767
	dw 512
	; 3
	dw 15134
	dw 0
	dw 32767
	dw 31744
	; 4
	dw 0
	dw 0
	dw 0
	dw 32767

LightPalette:
	db 2,1,4
	db 2,4,0
	db 4,1,0
	db 2,1,0

SECTION "Engine Sound Table",ROM0[$3100]
; ver.04 Wave Output
SoundTbl: ; Output level,Frequency low,Hi
	db %01000000,$60,%10000000
	db %00100000,$A0,%10000000
	db %00100000,$FF,%10000001
	db %00100000,$FF,%10000010

WaveData:
	db $12,$56 ; 1,2,5,6
	db $BC,$DC ; 11,12,13,12
	db $DB,$DD ; 13,11,13,13
	db $CE,$A9 ; 12,14,10,09
	db $76,$65 ; 07,06,06,05
WaveDataEnd:

SECTION "Car SpeedUp Table",ROM0[$3200]
CarSpeedUpTbl:
	db 0
	db 20
	db 50
	db 20

SECTION "Car SpeedDown Table",ROM0[$3300]
CarSpeedDownTbl:
	db 0
	db 30
	db 50
	db 20

SECTION "Init OAM Table",ROM0[$3400]
InitOamTbl: ; Y,X,Index,Attributes
	db SBY+8*3+4,SBX+8*13+5,25 ,2         ; light1
	db SBY+8*4+4,SBX+8*13+5,25 ,1         ; light2
	db SBY+8*5+4,SBX+8*13+5,25 ,0         ; light3
	db SBY+2    ,SBX+8*13+2,26 ,1         ; Horn1
	db SBY+8*8+6,SBX+8*13+2,26 ,%01000001 ; Horn2

SECTION "Sound Table",ROM0[$3500]
INCLUDE "sound_tbl.inc"

SECTION "Collision Map",ROM0[$3600]
CollisionMap:
; right|left end               1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2
;    0 8 162432404856647280889604122028364452606876849200081624324048 Sprite X
;    0 1 2 3 4 5 6 7 8 9 10111213141516171819202122232425262728293031 Dex
;    000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F Hex      Sprite Y
	db 1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$0000 0  0 
	db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ;$0020 1  8  - lower end
	db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1 ;$0040 2  16 - top end
	db 1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$0060 3  24
	db 1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$0080 4  32
	db 1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$00A0 5  40
	db 1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$00C0 6  48
	db 1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$00E0 7  56
	db 1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$0100 8  64
	db 1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$0120 9  72
	db 1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$0140 10 80
	db 1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0 ;$0160 11 88
	db 1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 ;$0180 12 96
	db 1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 ;$01A0 13 104
	db 1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 ;$01C0 14 112
	db 1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 ;$01E0 15 120
	db 1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 ;$0200 16 128
	db 1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 ;$0220 17 136
	db 1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 ;$0240 18 144
	db 1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 ;$0260 19 152
	db 1,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0 ;$0280 20 160
	db 1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0 ;$02A0 21 168
	db 1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$02C0 22 176
	db 1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$02E0 23 184
	db 1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$0300 24 192
	db 1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$0320 25 200
	db 1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$0340 26 208
	db 1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$0360 27 216
	db 1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$0380 28 224
	db 1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$03A0 29 232
	db 1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$03C0 30 240
	db 1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ;$03E0 31 248