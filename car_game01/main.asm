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

	; Set Map data
	ld a,1
	ldh [rVBK],a ; Attributes
	ld hl,_SCRN0
	ld de,BgTileMap1
	ld bc,BgTileMapEnd1 - BgTileMap1
	call CopyData
	xor a
	ldh [rVBK],a ; Tile Indexes
	ld hl,_SCRN0
	ld de,BgTileMap0
	ld bc,BgTileMapEnd0 - BgTileMap0
	call CopyData

	; Turn screen on, display background
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
	ld [wMapTblPos],a
	ld a,20

	ld a,20
	ld [wMapVramPos],a
	ld a,MapPosCnt
	ld [wScrollCnt],a

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
	ret

SetMapTbl:
	call SetMapVram
	call CalcMapTbl

	ld a,[wMapTbl0]
	ld b,a
	ld a,[wMapTbl0+1]
	ld c,a

	ld a,[wMapVram]
	ld h,a
	ld a,[wMapVram+1]
	ld l,a

	ld e,MapTblSize

	xor a
	ldh [rVBK],a ; Tile Indexes
.loop0
	ld a,[bc]
	ld [hli],a
	inc bc
	dec e
	jr nz,.loop0

	ld a,1
	ldh [rVBK],a ; Attributes

	ld a,[wMapTbl1]
	ld b,a
	ld a,[wMapTbl1+1]
	ld c,a

	ld a,[wMapVram]
	ld h,a
	ld a,[wMapVram+1]
	ld l,a

	ld e,MapTblSize
.loop1
	ld a,[bc]
	ld [hli],a
	inc bc
	dec e
	jr nz,.loop1

	ld a,[wWaitCnt2]
	or a
	jr z,SetMapTblPos
	dec a
	ld [wWaitCnt2],a
	ret

SetMapTblPos:
	ld a,WaitCnt2
	ld [wWaitCnt2],a

	ld a,[wMapTblPos]
	cp MapTblMax
	jr z,.reset
	inc a
	ld [wMapTblPos],a
	ret

.reset
	xor a
	ld [wMapTblPos],a
	ret

CalcMapTbl:
	ld a,[wMapTblPos]
	or a
	jr z,.skip

	ld hl,MapTbl0
	ld bc,MapTblSize
.loop0
	add hl,bc
	dec a
	jr nz,.loop0

	ld a,h
	ld [wMapTbl0],a
	ld a,l
	ld [wMapTbl0+1],a

	ld a,[wMapTblPos]
	ld hl,MapTbl1
	ld bc,MapTblSize
.loop1
	add hl,bc
	dec a
	jr nz,.loop1

	ld a,h
	ld [wMapTbl1],a
	ld a,l
	ld [wMapTbl1+1],a
	ret

.skip
	ld a,HIGH(MapTbl0)
	ld [wMapTbl0],a
	ld a,LOW(MapTbl0)
	ld [wMapTbl0+1],a

	ld a,HIGH(MapTbl1)
	ld [wMapTbl1],a
	ld a,LOW(MapTbl1)
	ld [wMapTbl1+1],a
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
	;call WaitVBlank
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