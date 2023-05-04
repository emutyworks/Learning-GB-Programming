SECTION "Map Table",ROM0[$2000]
MapPartTbl:
	;#### Before compression (2 bytes total) ####
	;%76543210
	; oooooooo Tile Indexes (0-255)
	;%76543210
	; -o------ BG Map Attributes: Vertical Flip
	; --o----- BG Map Attributes: Horizontal Flip
	; -----ooo BG Map Attributes: BG Palette (0-7)
	;
	;#### After compression (1 byte total) ####
	;%76543210
	; ---xxxxx Tile Indexes (0-31)
	; --x----- BG Map Attributes: Horizontal Flip (--o-----)
	; xx------ BG Map Attributes: BG Palette (------oo)
	;
	;%0000 $0 BG Palette 0
	;%0100 $4 BG Palette 1
	;%1000 $8 BG Palette 2
	;%1100 $C BG Palette 3
	;%0010 $2 BG Palette 0 + Horizontal Flip
	;%0110 $6 BG Palette 1 + Horizontal Flip
	;%1010 $A BG Palette 2 + Horizontal Flip
	;%1110 $E BG Palette 3 + Horizontal Flip
	db $01,$01,$00,$00,$00,$00,$9E,$9F,$9F,$BF,$9F,$BE,$00,$00,$00,$00
	db $01,$04,$24,$01,$01,$07,$65,$40,$40,$45,$27,$01,$00,$00,$00,$00
	db $07,$65,$45,$27,$01,$06,$66,$40,$40,$46,$26,$01,$00,$00,$00,$00
	db $06,$66,$46,$26,$01,$05,$67,$40,$40,$47,$25,$01,$00,$00,$00,$00
	db $05,$67,$47,$25,$44,$44,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	db $04,$40,$40,$24,$64,$01,$01,$44,$00,$00,$00,$00,$00,$00,$00,$00
MapPartTblEnd:

;MapTbl:
;MapTblEnd:

InitMapTbl:
	db $00,$00,$08,$01,$01,$01,$29,$00,$00,$00
	db $00,$00,$10,$01,$01,$01,$0C,$0D,$00,$00
	db $00,$00,$18,$01,$01,$01,$14,$15,$00,$00
	db $00,$00,$20,$01,$01,$01,$1C,$1D,$00,$00
	db $00,$00,$28,$01,$01,$01,$01,$09,$00,$00
	db $00,$0A,$0B,$01,$01,$01,$01,$11,$00,$00
	db $00,$00,$28,$01,$01,$01,$01,$09,$00,$00
	db $00,$00,$20,$01,$01,$01,$1C,$1D,$00,$00
	db $00,$00,$18,$01,$01,$01,$14,$15,$00,$00
	db $00,$00,$10,$01,$01,$01,$0C,$0D,$00,$00
	db $00,$00,$08,$01,$01,$01,$29,$00,$00,$00
	db $00,$00,$10,$01,$01,$01,$21,$00,$00,$00
	db $00,$00,$18,$01,$01,$01,$19,$00,$00,$00
	db $00,$00,$10,$01,$01,$01,$21,$00,$00,$00
	db $22,$22,$22,$22,$22,$22,$22,$22,$22,$22
	db $2A,$00,$00,$00,$00,$00,$00,$00,$00,$2B
	db $2A,$00,$00,$00,$00,$00,$00,$00,$00,$2B
	db $2A,$00,$00,$00,$00,$00,$00,$00,$00,$2B
	db $2A,$00,$00,$00,$00,$00,$00,$00,$00,$2B
	db $2A,$00,$00,$00,$00,$00,$00,$00,$00,$2B
	db $2A,$00,$00,$00,$00,$00,$00,$00,$00,$2B
	db $2A,$00,$00,$00,$00,$00,$00,$00,$00,$2B
	db $2A,$00,$00,$00,$00,$00,$00,$00,$00,$2B
	db $2A,$00,$00,$00,$00,$00,$00,$00,$00,$2B
	db $2A,$00,$00,$00,$00,$00,$00,$00,$00,$2B
	db $2A,$00,$00,$00,$00,$00,$00,$00,$00,$2B
	db $2A,$00,$00,$00,$00,$00,$00,$00,$00,$2B
	db $2A,$00,$00,$00,$00,$00,$00,$00,$00,$2B
	db $2A,$00,$00,$00,$00,$00,$00,$00,$00,$2B
	db $2A,$00,$00,$00,$00,$00,$00,$00,$00,$2B
	db $2A,$00,$00,$00,$00,$00,$00,$00,$00,$2B
	db $22,$22,$22,$22,$22,$22,$22,$22,$22,$22
InitMapTblEnd:

SECTION "Car Sprite Table",ROM0[$3000]
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

BGPalette:
	dw 15134
	dw 8456
	dw 24311
	dw 24311

	dw 24311
	dw 8456
	dw 24311
	dw 24311

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
	dw 31744

SECTION "Map VRAM Address Table",ROM0[$3200]
MapVramTbl:;MapX
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

SECTION "Direction Jump Table",ROM0[$3300]
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

Message1:
db 32,33,34,35,36,37,38,39,41,42,43,44,45
Message1End: