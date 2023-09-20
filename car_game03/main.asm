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

SECTION "VBlank Handler",ROM0[$40]
	push af
	ld a,1
	ld [wVBlankDone],a
	pop af
	reti

SECTION	"HBlank Handler",ROM0[$48]
HBlankHandler:
	push af
	push hl
	ldh a,[rLY]
	cp StartBgPos
	jr c,.road
	cp EndBgPos
	jr nc,.road
	ldh a,[hBgXPos]
	ldh [rSCX],a
	ldh a,[hBgYPos]
	jr .reset2

.road
	sub StartRoadPos
	jr c,.reset
	cp EndRoadPos
	jr nc,.reset
	ld h,HIGH(ScrollLeftTbl)
	ld l,a
	ldh a,[hRoadPMode]
	cp RPL
	jr z,.left
	cp RPR
	jr z,.right
	jr .road2
.right
	inc h
	ld a,[hl]
	ldh [rSCX],a
	dec h
	jr .road2
.left:
	ld a,[hl]
	ldh [rSCX],a
.road2:
	dec h
	ldh a,[hRoadPos]
	add a,l
	ld l,a
	ld a,[hl]
	jr .reset2

.reset:
	xor a
	ldh [rSCX],a
.reset2:
	ldh [rSCY],a
	pop hl
	pop af
	reti

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
	call SetPalette

	; Set Object Palette
	ld a,%10000000
	ldh [rOCPS],a
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
	ldh [rSCY],a
	ldh [rSCX],a
	ldh [hRoadPMode],a
	ldh [hRoadPos],a
	ldh [hBgYPos],a
	ldh [hBgXPos],a
	ld [wJoypad],a
	ld [wButton],a
	ld [wCarSpriteY],a
	ld [wCarSpriteX],a
	ld [wVBlankDone],a
	ld [wRoadPosWait],a
	ld [wRoadPTbl],a
	ld [wRoadPWaitDef],a
	ld [wRoadPCnt],a
	ld [wRoadPWait],a

	; Set Sprites/Tiles data
	ld hl,_VRAM8000
	ld de,Sprites
	ld bc,SpritesEnd - Sprites
	call CopyData
	ld hl,_VRAM9000
	ld de,Tiles
	ld bc,TilesEnd - Tiles
	call CopyData

	; Set Map data
	ld a,1
	ldh [rVBK],a ; BG Map Attributes
	ld hl,_SCRN0
	ld de,BgTileMap1
	ld bc,BgTileMap1End - BgTileMap1
	call CopyData
	xor a
	ldh [rVBK],a ; Tile Indexes
	ld hl,_SCRN0
	ld de,BgTileMap0
	ld bc,BgTileMap0End - BgTileMap0
	call CopyData

	ld a,LCDCF_ON|LCDCB_BG8000|LCDCF_OBJON|LCDCF_BGON|LCDCF_OBJ16
	ldh [rLCDC],a

	; Set up the lcdc int
	ld a,STATF_LYC|STATF_MODE00
	ldh [rSTAT],a

	; Enable the interrupts
	ld a,IEF_VBLANK|IEF_LCDC
	ldh [rIE],a
	xor a
	ei
	ldh [rIF],a

	; Set Car Sprite
	ld a,CarStartY
	ld [wCarSpriteY],a
	ld a,CarStartX
	ld [wCarSpriteX],a

	; set BG Scroll
	ld a,StartBgScrollY
	ldh [hBgYPos],a

MainLoop:
	call WaitForVBlankDone ; halt until interrupt occurs
	xor a
	ld [wVBlankDone],a

	;RoadPatternTbl
	ld a,[wRoadPWait]
	cp 0
	jr z,.decRoadPCnt
	dec a
	ld [wRoadPWait],a
	jr .setRoadPos

.decRoadPCnt:
	ld a,[wRoadPCnt]
	cp 0
	jr z,.setRoadPTbl
	dec a
	ld [wRoadPCnt],a
	ldh a,[hRoadPMode]
	cp RPU
	jr z,.setRoadPUp
	cp RPD
	jr z,.setRoadPDown
	cp RPL
	jr z,.setRoadPLeft
	cp RPR
	jr z,.setRoadPRight
.setRoadPWait:
	ld a,[wRoadPWaitDef]
	ld [wRoadPWait],a
	jr .setRoadPos

.setRoadPLeft:
	ldh a,[hBgXPos]
	dec a
	ldh [hBgXPos],a
	jr .setRoadPWait

.setRoadPRight:
	ldh a,[hBgXPos]
	inc a
	ldh [hBgXPos],a
	jr .setRoadPWait

.setRoadPUp:
	ldh a,[hBgYPos]
	inc a
	ldh [hBgYPos],a
	jr .setRoadPWait

.setRoadPDown:
	ldh a,[hBgYPos]
	dec a
	ldh [hBgYPos],a
	jr .setRoadPWait

.setRoadPTbl:
	ld a,[wRoadPTbl]
	inc a
	and %00001111
	ld [wRoadPTbl],a
	rlca
	rlca
	ld l,a
	ld h,HIGH(RoadPatternTbl)
	ld a,[hli]
	ldh [hRoadPMode],a
	ld a,[hli]
	ld [wRoadPWaitDef],a
	ld a,[hl]
	ld [wRoadPCnt],a

.setRoadPos:
	ld a,[wRoadPosWait]
	cp 0
	jr z,.addRoadPos
	dec a
	ld [wRoadPosWait],a
	jr .skipRoadPos

.addRoadPos:
	ld a,RoadPosWait
	ld [wRoadPosWait],a
	ldh a,[hRoadPos]
	add a,$20
	ldh [hRoadPos],a

.skipRoadPos:
	mCheckJoypad
	ld a,[wJoypad]
	bit JBitRight,a
	jr nz,.jRight
	bit JBitLeft,a
	jr nz,.jLeft
	jr .setSprite

.jRight:
	ld a,[wCarSpriteX]
	inc a
	ld [wCarSpriteX],a
	jr .setSprite

.jLeft:
	ld a,[wCarSpriteX]
	dec a
	ld [wCarSpriteX],a
	jr .setSprite

.setSprite:
	ld hl,wShadowOAM
	ld a,[wCarSpriteY]
	ld e,a
	ld [hli],a ; Y Position
	ld a,[wCarSpriteX]
	ld [hli],a ; X Position
	ld a,0
	ld [hli],a ; Tile Index
	ld a,0
	ld [hli],a ; Attributes/Flags
	;
	ld a,[wCarSpriteY]
	ld [hli],a
	ld a,[wCarSpriteX]
	add a,8
	ld [hli],a
	;ld a,0
	ld a,2
	ld [hli],a
	;ld a,0|OAMF_XFLIP
	ld a,0
	ld [hli],a

SetOAM:
	mWaitVBlank
	mSetOAM
	jp MainLoop

WaitForVBlankDone:
.waitloop:
	halt ; halt until interrupt occurs (low power)
	ld a,[wVBlankDone]
	and a
	jr z,.waitloop
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