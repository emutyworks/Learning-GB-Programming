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
	ld l,a
	ld h,HIGH(wSCY)
	ld a,[hl]
	ldh [rSCY],a
	ld h,HIGH(wSCX)
	ld a,[hl]
	ldh [rSCX],a
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
	mCopyDMARoutine ; move DMA subroutine to HRAM
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
	ld [wJoypad],a
	ld [wButton],a
	ld [wJoyPadPos],a
	ld [wJoypadWait],a
	ld [wRoadPTbl],a
	ld [wRoadPWaitDef],a
	ld [wRoadPMode],a
	ld [wRoadPCnt],a
	ld [wRoadPWait],a
	ld [wRoadPosWait],a
	ld [wRoadPos],a
	ld [wVBlankDone],a

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

	mInitwShadowOAM

	; Set up the lcdc int
	ld a,STATF_LYC|STATF_MODE00
	ldh [rSTAT],a

	; Enable the interrupts
	ld a,IEF_VBLANK|IEF_LCDC
	ldh [rIE],a
	xor a
	ei
	ldh [rIF],a

	; Set Scroll Table
	ld hl,wSCY
	ld c,ScrollSize
	xor a
	call SetScrollTbl
	ld hl,wSCX
	ld c,ScrollSize
	call SetScrollTbl
	ld hl,wRoadXLR
	ld c,ScrollRoadSize
	call SetScrollTbl

	ld a,StartBgScrollY
	ld c,ScrollBgSize
	ld hl,wBgY
	call SetScrollTbl

	; Set Joypad
	ld a,JoyPadPos
	ld [wJoyPadPos],a
	xor a
	ld hl,wJoyPadXLR
	ld c,ScrollRoadSize
	call SetScrollTbl
	ld hl,wJoyPadPosAddr
	ld a,HIGH(ScrollLRCenterTbl)
	ld [hli],a
	ld a,LOW(ScrollLRCenterTbl)
	ld [hli],a

MainLoop:
	mWaitForVBlankDone ; halt until interrupt occurs
	xor a
	ld [wVBlankDone],a

	;RoadPatternTbl
	ld a,[wRoadPWait]
	cp 0
	jr z,.decRoadPCnt
	dec a
	ld [wRoadPWait],a
	jp .setRoadPos

.decRoadPCnt
	ld a,[wRoadPCnt]
	cp 0
	jp z,.setRoadPTbl
	dec a
	ld [wRoadPCnt],a

	xor a
	ld c,ScrollRoadSize
	ld hl,wRoadXLR
	mSetScrollTbl

	ld a,[wRoadPMode]
	cp RPU
	jr z,.setRoadPUp
	cp RPD
	jr z,.setRoadPDown
	cp RPL
	jr z,.setRoadPLeft
	cp RPR
	jr z,.setRoadPRight
.setRoadPWait
	ld a,[wRoadPWaitDef]
	ld [wRoadPWait],a
	jr .setRoadPos

.setRoadPLeft
	ld a,[wBgX]
	dec a
	ld c,ScrollBgSize
	ld hl,wBgX
	mSetScrollTbl
	ld c,ScrollRoadSize
	ld de,wRoadXLR
	ld hl,ScrollLeftTbl
	mCopyScrollTbl
	jr .setRoadPWait

.setRoadPRight
	ld a,[wBgX]
	inc a
	ld c,ScrollBgSize
	ld hl,wBgX
	mSetScrollTbl
	ld c,ScrollRoadSize
	ld de,wRoadXLR
	ld hl,ScrollRightTbl
	mCopyScrollTbl
	jr .setRoadPWait

.setRoadPUp
	ld a,[wBgY]
	inc a
	ld c,ScrollBgSize
	ld hl,wBgY
	mSetScrollTbl
	jr .setRoadPWait

.setRoadPDown
	ld a,[wBgY]
	dec a
	ld c,ScrollBgSize
	ld hl,wBgY
	mSetScrollTbl
	jr .setRoadPWait

.setRoadPTbl
	ld a,[wRoadPTbl]
	inc a
	and %00001111
	;and %00000011;debug
	ld [wRoadPTbl],a
	rlca
	rlca
	ld l,a
	ld h,HIGH(RoadPatternTbl)
	ld a,[hli]
	ld [wRoadPMode],a
	ld a,[hli]
	ld [wRoadPWaitDef],a
	ld a,[hl]
	ld [wRoadPCnt],a

.setRoadPos
	ld a,[wRoadPosWait]
	cp 0
	jr z,.addRoadPos
	dec a
	ld [wRoadPosWait],a
	jr .skipRoadPos

.addRoadPos:
	ld a,RoadPosWait
	ld [wRoadPosWait],a
	ld a,[wRoadPos]
	add a,ScrollRoadSize
	ld [wRoadPos],a
	ld h,HIGH(ScrollPosTbl)
	ld l,a
	ld de,wRoadY
	ld c,ScrollRoadSize
	mCopyScrollTbl

.skipRoadPos
	ld a,[wJoypadWait]
	cp 0
	jr z,.checkJoypad
	dec a
	ld [wJoypadWait],a
	jp .setSprite

.checkJoypad
	ld a,JoypadWait
	ld [wJoypadWait],a

	mCheckJoypad
	ld a,[wJoypad]
	bit JBitRight,a
	jr nz,.jRight
	bit JBitLeft,a
	jr nz,.jLeft
	jr .setSprite

.jRight
	ld a,[wJoyPadPos]
	cp 15
	jr z,.setSprite
	inc a
	ld [wJoyPadPos],a

	ld a,[wJoyPadPosAddr]
	ld h,a
	ld a,[wJoyPadPosAddr+1]
	ld l,a
	ld de,ScrollRoadSize
	add HL,de
	ld a,h
	ld [wJoyPadPosAddr],a
	ld a,l
	ld [wJoyPadPosAddr+1],a

	ld c,ScrollRoadSize
	ld de,wJoyPadXLR
	mCopyScrollTbl
	jr .setSprite

.jLeft
	ld a,[wJoyPadPos]
	cp 1
	jr z,.setSprite
	dec a
	ld [wJoyPadPos],a

	ld a,[wJoyPadPosAddr]
	ld h,a
	ld a,[wJoyPadPosAddr+1]
	sub ScrollRoadSize
	ld [wJoyPadPosAddr+1],a
	ld l,a
	cp $e0
	jr nz,.setWJoyPadXLR
	dec h
	ld a,h
	ld [wJoyPadPosAddr],a
.setWJoyPadXLR
	ld c,ScrollRoadSize
	ld de,wJoyPadXLR
	mCopyScrollTbl
	jr .setSprite

.setSprite
	ld hl,wShadowOAM
	ld a,CarPosY
	ld e,a
	ld [hli],a ; Y Position
	ld a,CarPosX
	ld [hli],a ; X Position
	ld a,0
	ld [hli],a ; Tile Index
	ld a,0
	ld [hli],a ; Attributes/Flags
	;
	ld a,CarPosY
	ld [hli],a
	ld a,CarPosX+8
	ld [hli],a
	ld a,2
	ld [hli],a
	ld a,0
	ld [hli],a

CalcWSCX:
	ld de,wRoadX
	ld hl,wRoadXLR
	ld c,ScrollRoadSize
.loop
	ld a,[hl]
	ld b,a
	inc h
	ld a,[hli]
	add a,b
	ld [de],a
	dec h
	inc e
	dec c
	jr nz,.loop

SetOAM:
	mWaitVBlank
	mSetOAM
	jp MainLoop

SetScrollTbl:
.loop
	ld [hli],a
	dec c
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

DMARoutine:
	ldh [rDMA],a
	ld a,40
.loop
	dec a
	jr nz,.loop
	ret
DMARoutineEnd:

INCLUDE "data.inc"
INCLUDE "wram.inc"