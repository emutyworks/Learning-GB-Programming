MACRO mCheckJoypad
	;wJoypad
	;%76543210
	; |||||||+ Right
	; ||||||+- Left
	; |||||+-- Up
	; ||||+--- Down
	; |||+---- A
	; ||+----- B
	; |+------ Select
	; +------- Start
	ld a,P1F_4
	ldh [rP1],a ; Select P14
	ldh a,[rP1]
	ldh a,[rP1] ; Wait a few cycles
	cpl ; Complement A
	and %00001111 ; Get only first 4 bits
	swap a
	ld b,a
	ld a,P1F_5
	ldh [rP1],a ; Select P15
	ldh a,[rP1]
	ldh a,[rP1]
	ldh a,[rP1]
	ldh a,[rP1]
	ldh a,[rP1]
	ldh a,[rP1] ; Wait a few MORE cycles
	cpl
	and %00001111
	or a,b ; Put A and B together
	ld [wJoypad],a
	ld a,P1F_4|P1F_5 ; Deselect P14 and P15.
	ldh [rP1],a
ENDM

MACRO mWaitVBlank
.loop\@
	ldh a,[rLY]
	cp SCRN_Y ; 144 ; Check if the LCD is past VBlank
	jr nz,.loop\@
ENDM

MACRO mSetOAM
	; call the DMA subroutine we copied to HRAM
	; which then copies the bytes to the OAM and sprites begin to draw
	ld a,HIGH(wShadowOAM)
	call hOAMDMA
ENDM

MACRO mInitwShadowOAM
	ld hl,wShadowOAM
	ld c,4*40
	xor a
.loop\@
	ld [hli],a
	dec c
	jr nz,.loop\@
ENDM

MACRO mCopyDMARoutine
	ld hl,DMARoutine
	ld b,DMARoutineEnd - DMARoutine ; Number of bytes to copy
	ld c,LOW(hOAMDMA) ; Low byte of the destination address
.loop\@
	ld a,[hli]
	ldh [c],a
	inc c
	dec b
	jr nz,.loop\@
ENDM

MACRO mInitWRoadXLR
	xor a
	ld hl,wRoadXLR
REPT ScrollRoadSize
	ld [hli],a
ENDR
ENDM

MACRO mCopyScrollRoad
REPT ScrollRoadSize-1
	ld a,[hli]
	ld [de],a
	inc e
ENDR
	ld a,[hl]
	ld [de],a
ENDM

MACRO mSetWBG
REPT ScrollBgSize
	ld [hli],a
ENDR
ENDM

MACRO mCalcWRoadY
	ld hl,wRoadYUD
	ld de,wRoadY
REPT ScrollRoadSize-1
	ld c,[hl]
	ld a,[de]
	add a,c
	ld [de],a
	inc l
	inc e
ENDR
	ld c,[hl]
	ld a,[de]
	add a,c
	ld [de],a
ENDM

MACRO mCalcWSCX
	ld de,wRoadX
	ld hl,wRoadXLR
REPT ScrollRoadSize-1
	ld c,[hl]
	inc h
	ld a,[hli]
	add a,c
	ld [de],a
	dec h
	inc e
ENDR
	ld c,[hl]
	inc h
	ld a,[hli]
	add a,c
	ld [de],a
ENDM

MACRO mJoypadWait
	ld a,[wJoypadWait]
	cp 0
	jr z,.next\@
	dec a
	ld [wJoypadWait],a
	jp SetSprite
.next\@
	ld a,JoypadWait
	ld [wJoypadWait],a
ENDM

MACRO mCarShiftWait
	ld a,[wCarShiftWait]
	cp 0
	jr nz,DecWCarShiftWait
	ld a,[wCarShift]
ENDM

MACRO mCarShift
	ld h,HIGH(CarSpeedTbl)
	rlca
	rlca
	ld l,a
	ld a,[hli]
	ld [wCarShiftWait],a
	ld a,[hli]
	ld [wCarSpeed],a
	ld a,[hli]
	ld [wCarScroll],a
ENDM

MACRO mSetEngineSound
	ld a,[wEngineSound]
	ld c,a
	ld a,[wCarShift]
	cp c
	jr z,.exit\@
	ld [wEngineSound],a
	ld h,HIGH(SoundTbl)
	rlca
	rlca
	ld l,a
	ld a,[hli]
	ldh [$FF1C],a ; Output level
	ld a,[hli]
	ldh [$FF1D],a ; Frequency low
	ld a,[hl]
	ldh [$FF1E],a ; Frequency hi
.exit\@
ENDM