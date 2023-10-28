;
; I used this Website/Document as a reference to create it.
;
; Lesson P21 - Sound on the Gameboy and GBC
; https://www.chibiakumas.com/z80/platform3.php#LessonP21
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
	ld [wJoyPadPos],a
	ld [wJoypadWait],a
	ld [wRoadPTbl],a
	ld [wRoadPWaitDef],a
	ld [wRoadPMode],a
	ld [wRoadPCnt],a
	ld [wRoadPWait],a
	ld [wRoadPLRCnt],a
	ld [wRoadPos],a
	ld [wVBlankDone],a
	ld [wMainLoopFlg],a
	ld [wCarSprite],a
	ld [wCarSmoke],a
	ld [wCarSpeed],a
	ld [wCarSpeedWait],a
	ld [wCarGear],a
	ld [wCarGearY],a
	ld [wCarShift],a
	ld [wCarShiftWait],a
	ld [wCarCForce],a
	ld [wCarCForceWait],a
	ld [wCarScroll],a
	ld [wAddScroll],a
	ld [wEngineSound],a
	ld [wSmokeTbl],a

	; Set Sprites/Tiles data
	ld hl,_VRAM ;$8000
	ld de,Sprites
	ld bc,SpritesEnd - Sprites
	call CopyData
	ld hl,_VRAM+$1000 ;$9000
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

	ld a,LCDCF_ON|LCDCB_BLKS|LCDCF_OBJON|LCDCF_BGON|LCDCF_OBJ16
	ldh [rLCDC],a

	mInitwShadowOAM

	; Set up the lcdc int
	ld a,STATF_LYC|STATF_MODE00
	ldh [rSTAT],a

	; Enable the interrupts
	ld a,IEF_VBLANK|IEF_STAT
	ldh [rIE],a
	xor a
	ei
	ldh [rIF],a

	; Init Work RAM
	xor a
	ld hl,wSCY
	ld c,ScrollMaxSize
	call SetScrollTbl
	ld hl,wSCX
	ld c,ScrollMaxSize
	call SetScrollTbl
	ld hl,wRoadYUD
	ld c,ScrollRoadSize
	call SetScrollTbl
	ld hl,wRoadXLR
	ld c,ScrollRoadSize
	call SetScrollTbl
	ld hl,wJoyPadXLR
	ld c,ScrollRoadSize
	call SetScrollTbl

	; Set Work RAM
	ld a,StartBgScrollY
	ld c,ScrollBgSize
	ld hl,wBgY
	call SetScrollTbl

	; Set Joypad
	ld a,JoypadWait
	ld [wJoypadWait],a
	ld a,JoyPadPos
	ld [wJoyPadPos],a
	xor a
	ld hl,wJoyPadXLR
	ld c,ScrollRoadSize
	call SetScrollTbl

	; Set Sound
	ld a,%00010001 ; -LLL-RRR Channel volume
	ldh [$FF24],a
	ld a,%11111111 ; Channel Sound output terminal
	ldh [$FF25],a
	ld a,%10000000 ; Sound on/off
	ldh [$FF26],a

	; Set Wave Data
	ld hl,$FF30
	ld de,WaveData
	ld bc,WaveDataEnd - WaveData
	call CopyData

	ld a,%10000000 ; Wave Output on/off
	ldh [$FF1A],a
	ld a,$FF ; Sound Length
	ldh [$FF1B],a

	ld a,GearHiY
	ld [wCarGearY],a
	ld a,GearHi
	ld [wCarGear],a

MainLoop:
	ld a,[wMainLoopFlg]
	cp 1
	jp z,SetOAM

	mCheckJoypad

	ld a,[wCarSmoke]
	inc a
	and %00000011
	ld [wCarSmoke],a

	;Set Speed
	ld a,[wCarSpeedWait]
	cp 0
	jr z,.setSpeed
	dec a
	ld [wCarSpeedWait],a
	jp SetRoadPos

.setSpeed
	ld a,[wCarSpeed]
	ld [wCarSpeedWait],a
	ld a,[wCarScroll]
	ld [wAddScroll],a
	cp 0
	jp z,SetRoadPos

	;RoadPatternTbl
	ld a,[wRoadPWait]
	cp 0
	jr z,.decRoadPCnt
	dec a
	ld [wRoadPWait],a
	jp SetRoadPos

.decRoadPCnt
	ld a,[wRoadPCnt]
	cp 0
	jp z,SetRoadPTbl
	dec a
	ld [wRoadPCnt],a

	xor a
	ld [wCarCForce],a

	mInitWRoadXLR
	ld a,[wRoadPMode]
	ld l,a
	ld a,[wRoadPMode+1]
	ld h,a
	jp hl

SetRoadPWait:
	ld a,[wRoadPWaitDef]
	ld [wRoadPWait],a
	jp SetRoadPos

;SetRoadPUpDown:
;	ld a,[wRoadPNum]
;	rrca
;	rrca
;	rrca
;	ld h,HIGH(ScrollUpDnTbl)
;	ld l,a
;	ld de,wRoadYUD
;	mCopyScrollRoad
;	jr SetRoadPWait

SetRoadPLeft:
	mSetCarCForceL
	ld a,[wBgX]
	dec a
	ld hl,wBgX
	mSetWBG
	ld de,wRoadXLR
	ld h,HIGH(ScrollLeftTbl)
	ld a,[wRoadPLRCnt]
	ld l,a
	cp $E0
	jr z,.skip
	add a,$20
	ld [wRoadPLRCnt],a
.skip
	mCopyScrollRoad
	jp SetRoadPWait

SetRoadPLeftSt:
	mSetCarCForceL
	ld a,[wBgX]
	dec a
	ld hl,wBgX
	mSetWBG
	ld de,wRoadXLR
	ld h,HIGH(ScrollLeftTbl)
	ld a,[wRoadPLRCnt]
	ld l,a
	cp 0
	jr z,.skip
	sub a,$20
	ld [wRoadPLRCnt],a
.skip
	mCopyScrollRoad
	jp SetRoadPWait

SetRoadPRight:
	mSetCarCForceR
	ld a,[wBgX]
	inc a
	ld hl,wBgX
	mSetWBG
	ld de,wRoadXLR
	ld h,HIGH(ScrollRightTbl)
	ld a,[wRoadPLRCnt]
	ld l,a
	cp $E0
	jr z,.skip
	add a,$20
	ld [wRoadPLRCnt],a
.skip
	mCopyScrollRoad
	jp SetRoadPWait

SetRoadPRightSt:
	mSetCarCForceR
	ld a,[wBgX]
	inc a
	ld hl,wBgX
	mSetWBG
	ld de,wRoadXLR
	ld h,HIGH(ScrollRightTbl)
	ld a,[wRoadPLRCnt]
	ld l,a
	cp 0
	jr z,.skip
	sub a,$20
	ld [wRoadPLRCnt],a
.skip
	mCopyScrollRoad
	jp SetRoadPWait

SetRoadPBgUp:
	ld a,[wBgY]
	inc a
	ld hl,wBgY
	mSetWBG
	jp SetRoadPWait

SetRoadPBgDown:
	ld a,[wBgY]
	dec a
	ld hl,wBgY
	mSetWBG
	jp SetRoadPWait

SetRoadPTbl:
	ld a,[wRoadPTbl]
	inc a
	and %00000111
	ld [wRoadPTbl],a
	rlca
	rlca
	ld l,a
	ld h,HIGH(RoadPatternTbl)
	ld a,[hli]
	ld [wRoadPMode],a
	ld a,[hli]
	ld [wRoadPMode+1],a
	ld a,[hli]
	ld [wRoadPCnt],a
	ld a,[hl]
	ld [wRoadPWaitDef],a

SetRoadPos:
	ld a,[wAddScroll]
	ld d,a
	ld a,[wRoadPos]
	add a,d
	ld [wRoadPos],a
	ld h,HIGH(ScrollPosTbl)
	ld l,a
	ld de,wRoadY
	mCopyScrollRoad
	mCalcWRoadY

	xor a
	ld [wAddScroll],a

	ld a,[wJoypad]
	bit JBitUp,a
	jp nz,.jGearHi
	bit JBitDown,a
	jp nz,.jGearLow
	bit JBitRight,a
	jp nz,.jRight
	bit JBitLeft,a
	jp nz,.jLeft
	jp SetWJoyPadXLR

.jGearHi
	ld a,GearHiY
	ld [wCarGearY],a
	ld a,1
	ld [wCarGear],a
	ld a,[wCarShift]
	cp 0
	jr z,SetWJoyPadXLR
	ld a,GearHiShift
	ld [wCarShift],a
	jr SetWJoyPadXLR
.jGearLow
	ld a,GearLowY
	ld [wCarGearY],a
	xor a
	ld [wCarGear],a
	jr SetWJoyPadXLR

.jRight
	ld a,4
	ld [wCarSprite],a
	ld a,[wCarCForce]
	cp CarCForceRight
	jr z,SetWJoyPadXLR
	mJoypadWait
	ld a,[wJoyPadPos]
	cp 15
	jr z,SetWJoyPadXLR
	inc a
	ld [wJoyPadPos],a
	jr SetWJoyPadXLR
.jLeft
	ld a,2
	ld [wCarSprite],a
	ld a,[wCarCForce]
	cp CarCForceLeft
	jr z,SetWJoyPadXLR
	mJoypadWait
	ld a,[wJoyPadPos]
	cp 1
	jr z,SetWJoyPadXLR
	dec a
	ld [wJoyPadPos],a

SetWJoyPadXLR:
	ld a,[wJoyPadPos]
	ld d,a
	and %00000111
	ld e,a
	xor d
	rrca
	rrca
	rrca
	add a,HIGH(ScrollLRTbl)
	ld h,a
	ld a,e
	rrca
	rrca
	rrca
	ld l,a
	ld de,wJoyPadXLR
	mCopyScrollRoad
	ld hl,CarSmokeTbl
	ld a,[wJoyPadPos]
	add a,l
	ld l,a
	ld a,[hl]
	ld [wSmokeTbl],a

CheckButton:
	ld a,[wJoypad]
	bit JBitButtonA,a
	jr nz,.jButtonA

	ld a,[wCarShiftWait]
	cp 0
	jr nz,DecWCarShiftWait
	ld a,[wCarShift]
	cp 0
	jr z,.setShift
	dec a
	ld [wCarShift],a
	jr .setShift

.jButtonA
	ld a,[wCarGear]
	cp GearLow
	jr z,.setLowShift

	ld a,[wCarShiftWait]
	cp 0
	jr nz,DecWCarShiftWait
	ld a,[wCarShift]
	cp CarShiftMax
	jr z,.setShift
	inc a
	jr .setWCarShift

.setLowShift
	ld a,GearLowShift
.setWCarShift
	ld [wCarShift],a

.setShift
	mCarShift
	mSetEngineSound
	jr SetSprite

DecWCarShiftWait:
	dec a
	ld [wCarShiftWait],a

SetSprite:
	ld a,[wCarSprite]
	ld c,a
	ld a,[wCarShift]
	cp 0
	jr z,.draw
	ld a,[wCarSmoke]
	ld d,a
	cp 0
	jr z,.draw
	inc c
.draw
	ld a,c
	rlca
	rlca
	ld c,a
	ld b,HIGH(CarSpriteTbl)
	ld hl,wShadowOAM
	;smoke
	ld a,d
	cp 0
	jr nz,.drawCar
	ld a,[wSmokeTbl]
	sub 1
	jr c,.drawCForceSmoke ; (255) 0 skip
	jr z,.setSmokeRight ; (0) 1 right
	ld d,a
	ld a,CarPosY
	ld [hli],a ; Y Position
	ld a,CarPosX-3
	ld [hli],a ; X Position
	ld a,20
	ld [hli],a ; Tile Index
	ld a,0
	ld [hli],a ; Attributes/Flags
	ld a,d
	cp 2 ; (3) left/right
	jr nz,.drawCForceSmoke
.setSmokeRight
	ld a,CarPosY
	ld [hli],a
	ld a,CarPosX+8+3
	ld [hli],a
	ld a,20
	ld [hli],a
	ld a,0|OAMF_XFLIP
	ld [hli],a
.drawCForceSmoke
	ld a,[wCarCForce]
	cp 0
	jr z,.drawCar
	ld a,CarPosY
	ld [hli],a
	ld a,CarPosX-1
	ld [hli],a
	ld a,22
	ld [hli],a
	ld a,0
	ld [hli],a
	ld a,CarPosY
	ld [hli],a
	ld a,CarPosX+8+1
	ld [hli],a
	ld a,22
	ld [hli],a
	ld a,0|OAMF_XFLIP
	ld [hli],a
.drawCar
	;gear
	ld a,[wCarGearY]
	ld [hli],a
	ld a,8*8
	ld [hli],a
	ld a,24
	ld [hli],a
	ld a,0
	ld [hli],a
	;speed
	ld a,[wCarShift]
	rlca
	ld d,a
	ld a,150
	sub d
	ld [hli],a
	ld a,8*7
	ld [hli],a
	ld a,26
	ld [hli],a
	ld a,0
	ld [hli],a
	;car
	ld a,CarPosY
	ld [hli],a
	ld a,CarPosX
	ld [hli],a
	ld a,[bc]
	ld [hli],a
	inc c
	ld a,[bc]
	ld [hli],a
	inc c
	ld a,CarPosY
	ld [hli],a
	ld a,CarPosX+8
	ld [hli],a
	ld a,[bc]
	ld [hli],a
	inc c
	ld a,[bc]
	ld [hli],a
	;reset
	xor a
	ld [hli],a
	ld [hli],a
	inc l
	inc l
	ld [hli],a
	ld [hli],a
	inc l
	inc l
	ld [hli],a
	ld [hli],a
	inc l
	inc l
	ld [hli],a
	ld [hl],a

	mCalcWSCX

	ld a,1
	ld [wMainLoopFlg],a
	jp MainLoop

SetOAM:
	ld a,[wVBlankDone]
	cp 1
	jp nz,MainLoop
	xor a
	ld [wVBlankDone],a
	ld [wMainLoopFlg],a
	ld [wCarSprite],a

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