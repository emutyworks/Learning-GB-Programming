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
; The Cycle-Accurate Game Boy Docs (p25: 7. Joypad)
; https://github.com/AntonioND/giibiiadvance/blob/master/docs/TCAGBD.pdf
;

INCLUDE "hardware.inc"
INCLUDE "equ.inc"
INCLUDE "macro.inc"

SECTION "Header",ROM0[$100]

EntryPoint:
	di
	jr Start

REPT $150 - $104
	db 0
ENDR

SECTION "Start",ROM0[$150]

Start:
	call CopyDMARoutine ; move DMA subroutine to HRAM
	mWaitVBlank

	; Set BG Palette
	ld a,%10000000 ; Palette 0, Auto increment after writing
	ldh [rBCPS],a
	ld c,BGPaletteCnt
	ld hl,BGPalette
	ld de,rBCPD
	mSetPalette

	; Set Object Palette
	ld a,%10000000
	ldh [rOCPS],a
	ld c,ObjPaletteCnt
	ld hl,ObjPalette
	ld de,rOCPD
	mSetPalette

	xor a
	ldh [rLCDC],a
	ldh [rIE],a
	ldh [rIF],a
	ldh [rSTAT],a
	ldh [rSVBK],a
	ld [wJoypad],a
	ld [wButton],a
	ld [wDebug1],a
	ld [wDebug2],a
	ld [wDebug3],a

	; Set Tiles data
	ld hl,_VRAM8000
	ld de,Tiles
	ld bc,TilesEnd - Tiles
	call CopyData
	call SetMapPartTbl

	; Reset Map Indexes/Attributes Table
	ld hl,wMapIndexesTbl
	ld e,MapSize*2
	xor a
.resetMapLoop
	ld [hli],a
	dec e
	jr nz,.resetMapLoop

	; Set Map data
	ld a,HIGH(MapVramX31)
	ld [wMapVram],a
	ld a,LOW(MapVramX31)
	ld [wMapVram+1],a
	ld a,HIGH(InitMapTbl)
	ld [wMapTbl],a
	ld a,LOW(InitMapTbl)
	ld [wMapTbl+1],a

.initMapData
	mSetMapTbl
	mSetVram
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

	ld bc,MapVramDec
	ld a,[wMapVram]
	ld h,a
	ld a,[wMapVram+1]
	ld l,a
	add hl,bc
	ld a,h
	ld [wMapVram],a
	ld a,l
	ld [wMapVram+1],a

	ld bc,MapVramMin
	ld a,l
	cp c
	jp nz,.initMapData
	ld a,h
	cp b
	jp nz,.initMapData

	ld a,LCDCF_ON|LCDCF_BG8000|LCDCF_OBJON|LCDCF_BGON
	ldh [rLCDC],a

	call InitwShadowOAM

	; Set Sprite
	ld a,CarStartY
	ld [wPosY],a
	ld a,CarStartX
	ld [wPosX],a
	ld [wNewPosX],a
	ld bc,CarSpriteTbl
	call SetSprite
	mWaitVBlank
	mSetOAM

	; Set Scroll Potition
	xor a
	ldh [rSCY],a
	ldh [rSCX],a
	ld a,MapPosCnt
	ld [wScrollCnt],a
	ld a,HIGH(MapVramX20)
	ld [wMapVram],a
	ld a,LOW(MapVramX20)
	ld [wMapVram+1],a

	; Set wMapTbl
	ld a,HIGH(MapTbl)
	ld [wMapTbl],a
	ld a,LOW(MapTbl)
	ld [wMapTbl+1],a

MainLoop:
	mCheckJoypad

	ld a,[wJoypad]
	ld e,a
	bit JBitRight,a
	jr z,.left

	ld a,[wPosX]
	inc a
	ld [wNewPosX],a
	jr .next

.left
	ld a,e
	bit JBitLeft,a
	jr z,.next

	ld a,[wPosX]
	dec a
	ld [wNewPosX],a
	jr .next

.next
	mSetMapTbl
	mWaitVBlank

	ld bc,CarSpriteTbl
	call SetSprite
	mSetOAM

	mSetCarPosVram
	mCheckCollision

	;ld a,[wButton]
	;bit JBitButtonA,a
	;jp z,MainLoop

	ldh a,[rSCY]
	dec a
	ldh [rSCY],a

	ld a,[wScrollCnt]
	dec a
	ld [wScrollCnt],a
	or a
	jp nz,MainLoop

	ld a,MapPosCnt
	ld [wScrollCnt],a

	mDecMapVram
	mSetVram
	mCalcMapTbl

	jp MainLoop

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

SetMapPartTbl:
	ld hl,wMapPartTbl
	ld bc,MapPartTblSize
.reset
	xor a
	ld [hli],a
	dec bc
	ld a,b
	or c
	jr nz,.reset

	ld bc,MapPartTbl
	ld hl,wMapPartTbl
.loop
	ld e,0
	ld a,[bc]
	ld d,a
	and %00011111
	ld [hli],a
	;cp BGPriorityTile
	;jr c,.skip1
	;ld e,%10000000 ; BG-to-OAM Priority
.skip1
	ld a,d
	and %00100000 ; Horizontal Flip
	or e
	ld e,a
	ld a,d
	and %11000000
	swap a
	rrca
	rrca
	or e
	inc hl
	ld [hld],a
	inc bc

	ld e,0
	ld a,[bc]
	ld d,a
	and %00011111
	ld [hli],a
	;cp BGPriorityTile
	;jr c,.skip2
	;ld e,%10000000 ; BG-to-OAM Priority
.skip2
	ld a,d
	and %00100000 ; Horizontal Flip
	or e
	ld e,a
	ld a,d
	and %11000000
	swap a
	rrca
	rrca
	or e
	inc hl
	ld [hli],a
	inc bc

	ld de,MapPartTblEnd
	ld a,c
	cp e
	jr nz,.loop
	ld a,b
	cp d
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