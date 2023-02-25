;
; I used this Website/Document as a reference to create "main.asm".
;
; Lesson H9- Hello World on the Gameboy and Gameboy Color
; https://www.chibiakumas.com/z80/helloworld.php#LessonH9
;
; Pan Docs
; https://gbdev.io/pandocs/
;

INCLUDE "hardware.inc"

BGPaletteCnt EQU 4*1

MACRO mSetDot
	ld a,b ;4 dotY
	add a,a ;4
	ld l,a ;4
	ld a,c ;4 dotX
	and %11111000 ;4
	rlca ;4
	rlca ;4
	rlca ;4
	add a,l ;4
	ld l,a ;4 = 40

	ld h,HIGH(_VRAM8000) ;8
	ld a,c ;4
	push bc ;16
	ld b,HIGH(SetDotXTbl) ;8
	and %00000111 ;4
	ld c,a ;4
	ld a,[bc] ;8
	ld c,[hl] ;8
	or c ;4
	ld [hl],a ;8
	pop bc ;16 = 84 ; = 124
ENDM

MACRO mResetDot
	ld a,b ;4 dotY
	add a,a ;4
	ld l,a ;4
	ld a,c ;4 dotX
	and %11111000 ;4
	rlca ;4
	rlca ;4
	rlca ;4
	add a,l ;4
	ld l,a ;4 = 40

	ld h,HIGH(_VRAM8000) ;8
	ld a,c ;4
	push bc ;16
	ld b,HIGH(ResetDotXTbl) ;8
	and %00000111 ;4
	ld c,a ;4
	ld a,[bc] ;8
	ld c,[hl] ;8
	and c ;4
	ld [hl],a ;8
	pop bc ;16 = 84 ; = 124
ENDM

SECTION "Header",ROM0[$100]

EntryPoint:
	di
	jp Start

REPT $150 - $104
	db 0
ENDR

SECTION "Start",ROM0[$150]

Start:
	call WaitVBlank

	; Set BG Palette
	ld a,%10000000 ; Palette 0, Auto increment after writing
	ld [rBCPS],a
	ld c,BGPaletteCnt
	ld hl,BGPalette
	ld de,rBCPD
	call SetPalette

	xor a
	ldh [rLCDC],a
	ldh [rIE],a
	ldh [rIF],a
	ldh [rSTAT],a
	ldh [rSCY],a
	ldh [rSCX],a

	; Set Tiles data
	ld hl,_VRAM8000
	ld bc,$0FFF
.setTilesData
	xor a
	ld [hli],a
	dec bc
	ld a,b
	or c
	jr nz,.setTilesData

	; Set Map data
	ld a,1
	ldh [rVBK],a ; BG Map Attributes
	ld hl,_SCRN0
	ld bc,$0BFF
.setMapAttributes
	xor a
	ld [hli],a
	dec bc
	ld a,b
	or c
	jr nz,.setMapAttributes

	xor a
	ldh [rVBK],a ; Tile Indexes
	ld hl,_SCRN0
	ld bc,$0BFF
.setMapIndexes
	ld a,$10
	ld [hli],a
	dec bc
	ld a,b
	or c
	jr nz,.setMapIndexes

	ld hl,$9800
	ld de,BgTileMap0
	ld bc,BgTileMapEnd0 - BgTileMap0
	call CopyData

	ld hl,$9820
	ld de,BgTileMap1
	ld bc,BgTileMapEnd1 - BgTileMap1
	call CopyData

	ld hl,$9840
	ld de,BgTileMap2
	ld bc,BgTileMapEnd2 - BgTileMap2
	call CopyData

	ld hl,$9860
	ld de,BgTileMap3
	ld bc,BgTileMapEnd3 - BgTileMap3
	call CopyData

	; Turn screen on, display background
	ld a,LCDCF_ON|LCDCF_BG8000|LCDCF_OBJOFF|LCDCF_BGON
	ldh [rLCDC],a

	ld c,0 ;8 dotX
MainLoop:
	ld b,0 ;8 dotY
	push bc
	call WaitVBlank
	call ResetLine1
	pop bc
	inc c
.loop
	ld b,0 ;8 dotY
	push bc
	call WaitVBlank
	call SetLine1
	pop bc
	ld a,c
	cp 31
	jr z,.reset
	jp MainLoop

.reset
	call WaitVBlank
	call ResetLine1
	ld c,0 ;dotX
	jp .loop

SetLine1:
	ld e,31 ;8
.loop
	mSetDot
	inc b ;4
	dec e ;4
	jr nz,.loop ;12 = 28
	ret

ResetLine1:
	ld e,31 ;8
.loop
	mResetDot
	inc b ;4
	dec e ;4
	jr nz,.loop ;12 = 28
	ret

SetPalette:
	ld a,[hli]
	ld [de],a
	ld a,[hli]
	ld [de],a
	dec c
	jr nz,SetPalette
	ret

WaitVBlank:
	ldh a,[rLY]
	cp SCRN_Y ; 144 ; Check if the LCD is past VBlank
	jr nz,WaitVBlank
	ret

CopyData:
	ld a,[de] ; Grab 1 byte from the source
	ld [hli],a ; Place it at the destination, incrementing hl
	inc de ; Move to next byte
	dec bc ; Decrement count
	ld a,b ; Check if count is 0, since `dec bc` doesn't update flags
	or c
	jr nz,CopyData
	ret

BgTileMap0: ; dotX 0-7
	db $00,$04,$08,$0C ; dotY 0-31 $9800-$9803
BgTileMapEnd0:

BgTileMap1: ; dotX 8-15
	db $01,$05,$09,$0D ; dotY 0-31 $9820-$9823
BgTileMapEnd1:

BgTileMap2: ; dotX 16-23
	db $02,$06,$0A,$0E ; dotY 0-31 $9840-$9843
BgTileMapEnd2:

BgTileMap3: ; dotX 24-31
	db $03,$07,$0B,$0F ; dotY 0-31 $9860-$9863
BgTileMapEnd3:

SECTION "Color Palette",ROM0
BGPalette:
	; 0
	dw 32767
	dw 31
	dw 32767
	dw 32767

SECTION "Set dotX Table",ROM0[$3100]
SetDotXTbl:
	db %10000000 ; dotX 0
	db %01000000 ; dotX 1
	db %00100000 ; dotX 2
	db %00010000 ; dotX 3
	db %00001000 ; dotX 4
	db %00000100 ; dotX 5
	db %00000010 ; dotX 6
	db %00000001 ; dotX 7

SECTION "Reset dotX Table",ROM0[$3200]
ResetDotXTbl:
	db %01111111 ; dotX 0
	db %10111111 ; dotX 1
	db %11011111 ; dotX 2
	db %11101111 ; dotX 3
	db %11110111 ; dotX 4
	db %11111011 ; dotX 5
	db %11111101 ; dotX 6
	db %11111110 ; dotX 7

SECTION "State",WRAM0[$C000]
wDotY: ds 1
wDotX: ds 1

;_VRAM8000
;dotX 01234567    01234567    01234567    01234567    01234567    01234567    01234567    01234567     VRAM        dotY  BgTileMap
; db %00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0 ; $8000-$800F 0-7   $00
; db %00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0 ; $8010-$801F 8-15  $04
; db %00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0 ; $8020-$802F 16-23 $08
; db %00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0 ; $8030-$803F 24-31 $0C
;       111111      111111      111111      111111      111111      111111      111111      111111
;dotX 89012345    89012345    89012345    89012345    89012345    89012345    89012345    89012345     VRAM        dotY  BgTileMap
; db %00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0 ; $8040-$804F 0-7   $01
; db %00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0 ; $8050-$805F 8-15  $05
; db %00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0 ; $8060-$806F 16-23 $09
; db %00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0 ; $8070-$807F 24-31 $0D
;     11112222    11112222    11112222    11112222    11112222    11112222    11112222    11112222
;dotX 67890123    67890123    67890123    67890123    67890123    67890123    67890123    67890123     VRAM        dotY  BgTileMap
; db %00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0 ; $8080-$808F 0-7   $02
; db %00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0 ; $8090-$809F 8-15  $06
; db %00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0 ; $80A0-$80AF 16-23 $0A
; db %00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0 ; $80B0-$80BF 24-31 $0E
;     22222233    22222233    22222233    22222233    22222233    22222233    22222233    22222233
;dotX 45678901    45678901    45678901    45678901    45678901    45678901    45678901    45678901     VRAM        dotY  BgTileMap
; db %00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0 ; $80C0-$80C0 0-7   $03
; db %00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0 ; $80D0-$80DF 8-15  $07
; db %00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0 ; $80E0-$80EF 16-23 $0B
; db %00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0,%00000000,0 ; $80F0-$80FF 24-31 $0F