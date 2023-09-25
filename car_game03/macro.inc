MACRO mCheckJoypad
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
	ld [wButton],a
	;swap a
	;ld b,a
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
	;or a,b ; Put A and B together
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

MACRO mWaitForVBlankDone
.waitloop\@
	halt ; halt until interrupt occurs (low power)
	ld a,[wVBlankDone]
	and a
	jr z,.waitloop\@
ENDM

;MACRO mSetScrollTbl
;.loop\@
;	ld [hli],a
;	dec c
;	jr nz,.loop\@
;ENDM

;MACRO mCopyScrollTbl
;.loop\@
;	ld a,[hli]
;	ld [de],a
;	inc e
;	dec c
;	jr nz,.loop\@
;ENDM