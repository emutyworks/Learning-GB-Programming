;
; I used this Website/Document as a reference to create it.
;
; Run-length encoding
; https://en.wikipedia.org/wiki/Run-length_encoding
;
; Lesson H9- Hello World on the Gameboy and Gameboy Color
; https://www.chibiakumas.com/z80/helloworld.php#LessonH9
;
; Pan Docs
; https://gbdev.io/pandocs/
;

INCLUDE "hardware.inc"

SECTION "Header",ROM0[$100]

EntryPoint:
	di
	jr Start

REPT $150 - $104
	db 0
ENDR

SECTION "Start",ROM0[$150]

Start:
	call WaitVBlank

	; Set BG Palette
	ld a,%10000000 ; Palette 0, Auto increment after writing
	ldh [rBCPS],a
	ld c,2
	ld hl,BGPalette
	ld de,rBCPD
	call SetPalette

	xor a
	ldh [rLCDC],a
	ldh [rIE],a
	ldh [rIF],a
	ldh [rSTAT],a
	ldh [rSVBK],a
	ldh [rSCY],a
	ldh [rSCX],a

	; Set Tiles data
	ld hl,_VRAM+$1000 ;$9000
	ld de,Tiles
	ld bc,TilesEnd - Tiles
	call CopyData

	; Set Map data (Decompression version)
	ld a,1
	ldh [rVBK],a ; BG Map Attributes
	ld hl,_SCRN0 ; write address
	ld de,BgTileMap1 ; data address
	ld bc,BgTileMap1End-1 ; data end address
	call CopyDecompressionData
	xor a
	ldh [rVBK],a ; Tile Indexes
	ld hl,_SCRN0
	ld de,BgTileMap0
	ld bc,BgTileMap0End-1
	call CopyDecompressionData

	; Set Map data (No decompression version)
	;ld a,1
	;ldh [rVBK],a ; BG Map Attributes
	;ld hl,_SCRN0
	;ld de,BgTileMap1
	;ld bc,BgTileMap1End - BgTileMap1
	;call CopyData
	;xor a
	;ldh [rVBK],a ; Tile Indexes
	;ld hl,_SCRN0
	;ld de,BgTileMap0
	;ld bc,BgTileMap0End - BgTileMap0
	;call CopyData

	ld a,LCDCF_ON|LCDCF_BGON
	ldh [rLCDC],a

MainLoop:
	jp MainLoop

CopyDecompressionData:
	;ld hl,<write address>
	;ld de,<data address>
	;ld bc,<data end address>
.start
	ld a,[de]
	inc de
	ld [hli],a
	push bc
.loop
	ld b,a
	ld a,[de]
	cp b
	jr z,.next
	inc de
	ld [hli],a
	jr .loop
.next
	inc de
	ld [hli],a
	ld a,[de]
	inc de
	sub 2
	jr z,.skip
	ld c,a
	ld a,b
.copy
	ld [hli],a
	dec c
	jr nz,.copy
.skip
	pop bc
	ld a,b
	cp d
	jr nz,.start
	ld a,c
	cp e
	jr nc,.start
	ret

WaitVBlank:
.loop
	ldh a,[rLY]
	cp SCRN_Y ; 144 ; Check if the LCD is past VBlank
	jr nz,.loop
	ret

SetPalette:
.loop
	ld a,[hli]
	ld [de],a
	ld a,[hli]
	ld [de],a
	dec c
	jr nz,.loop
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

BGPalette:
	dw 0
	dw 8456
	dw 24311
	dw 32767

	dw 0
	dw 8456
	dw 32767
	dw 24311

SECTION "BG Data",ROM0[$2000]
BgTileMap0: ; Tile Indexes
	;INCBIN "bg_tile0_1024.bin" ; 1024 bytes
	INCBIN "bg_tile0_compress.bin" ; 337 bytes
BgTileMap0End:

BgTileMap1: ; BG Map Attributes
	;INCBIN "bg_tile1_1024.bin" ; 1024 bytes
	INCBIN "bg_tile1_compress.bin" ; 151 bytes
BgTileMap1End:

Tiles:
	INCBIN "tiles.bin"
TilesEnd: