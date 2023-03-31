;
; I used this Website/Document as a reference to create "main.asm".
;
; Lesson H9- Hello World on the Gameboy and Gameboy Color
; https://www.chibiakumas.com/z80/helloworld.php#LessonH9
;
; Pan Docs
; https://gbdev.io/pandocs/
;
; OAM DMA tutorial
; https://gbdev.gg8.se/wiki/articles/OAM_DMA_tutorial
;

INCLUDE "hardware.inc"
INCLUDE "equ.inc"

MACRO mSetMapWorkTbl
	ld a,[hli]
	add a
	ld c,a
	ld a,[bc]
	ld [de],a
	inc c
	inc e
	ld a,[bc]
	ld [de],a
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
	call CopyDMARoutine ; move DMA subroutine to HRAM
	call WaitVBlank

	; Set BG Palette
	ld a,%10000000 ; Palette 0, Auto increment after writing
	ld [rBCPS],a
	ld c,BGPaletteCnt
	ld hl,BGPalette
	ld de,rBCPD
	call SetPalette

	; Set Object Palette
	ld a,%10000000
	ld [rOCPS],a
	ld c,ObjPaletteCnt
	ld hl,ObjPalette
	ld de,rOCPD
	call SetPalette

	xor a
	ldh [rLCDC],a
	ldh [rIE],a
	ldh [rIF],a
	ldh [rSTAT],a

	; Set Tiles data
	ld hl,_VRAM8000
	ld de,Tiles
	ld bc,TilesEnd - Tiles
	call CopyData

	; Reset Map Indexes/Attributes Table
	ld hl,wMapIndexesTbl
	ld e,MapSize*2
	xor a
.resetMapLoop
	ld [hli],a
	dec e
	jr nz,.resetMapLoop

	; Set Map data
	ld a,31
	ld [wMapVramPos],a
	ld a,HIGH(InitMapTbl)
	ld [wMapTbl],a
	ld a,LOW(InitMapTbl)
	ld [wMapTbl+1],a

	ld e,32
.initMapData
	push de
	call SetMapTbl
	call setVram
	pop de
	ld bc,MapTblSize
	ld a,[wMapTbl]
	ld h,a
	ld a,[wMapTbl+1]
	ld l,a
	add hl,bc
	ld a,h
	ld [wMapTbl],a
	ld a,l
	ld [wMapTbl+1],a
	dec e
	jr nz,.initMapData

	ld a,LCDCF_ON|LCDCF_BG8000|LCDCF_OBJON|LCDCF_BGON
	ldh [rLCDC],a

	call InitwShadowOAM

	; Set Sprite
	ld a,CarStartY
	ld [wPosY],a
	ld a,CarStartX
	ld [wPosX],a
	ld bc,CarSpriteTbl
	call SetSprite
	call WaitVBlank
	call SetOAM

	ld a,WaitCnt
	ld [wWaitCnt],a
	ld a,WaitCnt2
	ld [wWaitCnt2],a

	;Set Scroll Potition
	xor a
	ldh [rSCY],a
	ldh [rSCX],a
	ld a,20
	ld [wMapVramPos],a
	ld a,MapPosCnt
	ld [wScrollCnt],a

	;set wMapTbl
	ld a,HIGH(MapTbl)
	ld [wMapTbl],a
	ld a,LOW(MapTbl)
	ld [wMapTbl+1],a

MainLoop:
	call WaitVBlank
	call SetScroll
	jp MainLoop

SetScroll:
	ld a,[wWaitCnt]
	dec a
	ld [wWaitCnt],a
	ret nz

	ld a,WaitCnt
	ld [wWaitCnt],a
	ldh a,[rSCY]
	dec a
	ldh [rSCY],a

	ld a,[wScrollCnt]
	dec a
	ld [wScrollCnt],a
	or a
	ret nz
	ld a,MapPosCnt
	ld [wScrollCnt],a
	call SetMapTbl
	call WaitVBlank
	call setVram
	call calcMapTbl
	ret

SetMapTbl:
	call SetMapWorkTbl
	ld hl,wMapIndexesTbl
	ld bc,wMapWorkTbl
	ld d,MapSize
.loop
	ld a,[bc]
	and %00011111
	ld [hl],a

	ld a,l
	add a,MapSize
	ld l,a

	ld a,[bc]
	and %00100000
	ld e,a ; Horizontal Flip
	ld a,[bc]
	and %11000000
	swap a
	rrca
	rrca
	or e
	ld [hl],a

	ld a,l
	sub a,MapSize
	ld l,a
	inc l
	inc bc
	dec d
	jr nz,.loop
	ret

setVram:
	call SetMapVram
	ld a,[wMapVram]
	ld h,a
	ld a,[wMapVram+1]
	ld l,a
	ld e,MapSize
	xor a
	ldh [rVBK],a ; Tile Indexes
	ld bc,wMapIndexesTbl
.indexesLoop
	ld a,[bc]
	ld [hli],a
	inc bc
	dec e
	jr nz,.indexesLoop

	ld a,[wMapVram]
	ld h,a
	ld a,[wMapVram+1]
	ld l,a
	ld e,MapSize

	ld a,1
	ldh [rVBK],a ; Attributes
	ld bc,wMapAttributesTbl
.attributesLoop
	ld a,[bc]
	ld [hli],a
	inc bc
	dec e
	jr nz,.attributesLoop
	ret

calcMapTbl:
	ld a,[wWaitCnt2]
	or a
	jr z,.calc
	dec a
	ld [wWaitCnt2],a
	ret
.calc
	ld a,WaitCnt2
	ld [wWaitCnt2],a

	ld a,[wMapTbl]
	ld h,a
	ld a,[wMapTbl+1]
	ld l,a
	ld bc,MapTblEnd-MapTblSize

	ld a,l
	cp c
	jr nz,.next
	ld a,h
	cp b
	jr nz,.next

	ld a,HIGH(MapTbl)
	ld [wMapTbl],a
	ld a,LOW(MapTbl)
	ld [wMapTbl+1],a
	ret

.next
	ld bc,MapTblSize
	add hl,bc
	ld a,h
	ld [wMapTbl],a
	ld a,l
	ld [wMapTbl+1],a
	ret

SetMapWorkTbl:
	ld a,[wMapTbl]
	ld h,a
	ld a,[wMapTbl+1]
	ld l,a

	ld de,wMapWorkTbl
	ld b,HIGH(MapPartTbl)
	;
	mSetMapWorkTbl
	inc e
	mSetMapWorkTbl
	inc e
	mSetMapWorkTbl
	inc e
	mSetMapWorkTbl
	inc e
	mSetMapWorkTbl
	inc e
	mSetMapWorkTbl
	inc e
	mSetMapWorkTbl
	inc e
	mSetMapWorkTbl
	inc e
	mSetMapWorkTbl
	inc e
	mSetMapWorkTbl
	ret

SetMapVram:
	ld h,HIGH(MapVramTbl)
	ld a,[wMapVramPos]
	add a
	ld l,a
	ld a,[hli]
	ld [wMapVram+1],a
	ld a,[hl]
	ld [wMapVram],a

	ld a,[wMapVramPos]
	cp 0
	jr z,.next
	dec a
	ld [wMapVramPos],a
	ret
.next
	ld a,MapVramPosMax
	ld [wMapVramPos],a
	ret

SetSprite:
	ld hl,wShadowOAM
	ld e,4 ; Sprite pattern count
.loop
	ld a,[wPosY]
	ld d,a
	ld a,[bc]
	add a,d
	ld [hli],a ; Y Position
	inc c
	ld a,[wPosX]
	ld d,a
	ld a,[bc]
	add a,d
	ld [hli],a ; X Position
	inc c
	ld a,[bc]
	ld [hli],a ; Tile Index
	inc c
	ld a,[bc]
	ld [hli],a ; Attributes/Flags
	inc c
	dec e
	jr nz,.loop
	ret

SetPalette:
	ld a,[hli]
	ld [de],a
	ld a,[hli]
	ld [de],a
	dec c
	jr nz,SetPalette
	ret

SetOAM:
	; call the DMA subroutine we copied to HRAM
	; which then copies the bytes to the OAM and sprites begin to draw
	ld a,HIGH(wShadowOAM)
	call hOAMDMA
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

CopyDMARoutine:
	ld hl,DMARoutine
	ld b,DMARoutineEnd - DMARoutine ; Number of bytes to copy
	ld c,LOW(hOAMDMA) ; Low byte of the destination address
.loop
	ld a,[hli]
	ldh [c],a
	inc c
	dec b
	jr nz,.loop
	ret

DMARoutine:
	ldh [rDMA],a
	ld a,40
.loop
	dec a
	jr nz,.loop
	ret
DMARoutineEnd:

InitwShadowOAM:
	ld hl,wShadowOAM
	ld c,4*40
	xor a
.loop
	ld [hli],a
	dec c
	jr nz,.loop
	ret

INCLUDE "data.inc"
INCLUDE "wram.inc"