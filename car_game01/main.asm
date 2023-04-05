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
	jr Start

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
	ldh [rSVBK],a

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
	call SetMapTbl
	call setVram
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
	jr nz,.initMapData
	ld a,h
	cp b
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

	;Set Scroll Potition
	xor a
	ldh [rSCY],a
	ldh [rSCX],a
	ld a,MapPosCnt
	ld [wScrollCnt],a
	ld a,HIGH(MapVramX20)
	ld [wMapVram],a
	ld a,LOW(MapVramX20)
	ld [wMapVram+1],a

	;set wMapTbl
	ld a,HIGH(MapTbl)
	ld [wMapTbl],a
	ld a,LOW(MapTbl)
	ld [wMapTbl+1],a

MainLoop:
	call WaitVBlank
	call SetScroll
	jr MainLoop

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
	call DecMapVram
	call setVram
	call calcMapTbl
	ret

SetMapTbl:
	ld a,[wMapTbl] ;16
	ld h,a ;4
	ld a,[wMapTbl+1] ;16
	ld l,a ;4
	ld bc,wMapIndexesTbl ;12
	ld e,MapSize/2 ;8 = 60
.loop
	ld a,[hli] ;8 hl=wMapTbl
	push hl ;16
	ld h,0 ;8
	ld l,a ;4
	add hl,hl ;8
	add hl,hl ;8
	push de ;16
	ld de,wMapPartTbl ;12
	add hl,de ;8
	pop de ;12
	ld a,[hli] ;8 wMapPartTbl 1
	ld [bc],a ;8 wMapIndexesTbl 1
	inc bc ;8
	ld a,[hli] ;8 wMapPartTbl 2
	ld [bc],a ;8 wMapIndexesTbl 2
	ld a,c ;4
	add a,MapSize-1 ;8 bc+19
	ld c,a ;4
	ld a,[hli] ;8 wMapPartTbl 3
	ld [bc],a ;8 wMapAttributesTbl 1
	inc bc ;8
	ld a,[hli] ;8 wMapPartTbl 4
	ld [bc],a ;8 wMapAttributesTbl 2
	ld a,c ;4
	sub MapSize-1 ;8 bc-19
	ld c,a ;4

	pop hl ;12
	dec e ;4
	jr nz,.loop ;12 = 240*10 = 2400
	ret ;12 = 2412

setVram:
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

DecMapVram:
	ld bc,$FFE0 ;12
	ld a,[wMapVram] ;16
	ld h,a ;4
	ld a,[wMapVram+1] ;16
	ld l,a ;4
	add hl,bc ;8 = 60

	ld bc,$97E0 ;12
	ld a,l ;4
	cp c ;4
	jr nz,.next ;12 = 32+60 = 92
	ld a,h ;4
	cp b ;4
	jr nz,.next ;12 = 20+32+60 = 112

	ld a,$9B ;8
	ld [wMapVram],a ;16
	ld a,$E0 ;8
	ld [wMapVram+1],a ;16 = 48+112=160
	ret

.next
	ld a,h ;4
	ld [wMapVram],a ;16
	ld a,l ;4
	ld [wMapVram+1],a ;16 = 40+92=132, 40+112=152
	ret


;SetMapVram:
;	ld h,HIGH(MapVramTbl) ;8
;	ld a,[wMapVramPos] ;16
;	add a,a ;4
;	ld l,a ;4
;	ld a,[hli] ;8
;	ld [wMapVram+1],a ;16
;	ld a,[hl] ;8
;	ld [wMapVram],a ;16 = 80
;
;	ld a,[wMapVramPos] ;16
;	cp 0 ;4
;	jr z,.next ;12
;	dec a ;4
;	ld [wMapVramPos],a ;16 = 52+80 = 132
;	ret
;.next
;	ld a,MapVramPosMax ;8
;	ld [wMapVramPos],a ;16 = 24+52+80 = 156
;	ret

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
	cp BGPriorityTile
	jr c,.skip1
	ld e,%10000000 ; BG-to-OAM Priority
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
	cp BGPriorityTile
	jr c,.skip2
	ld e,%10000000 ; BG-to-OAM Priority
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