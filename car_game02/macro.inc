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

MACRO mSetCarSprite
	ld a,[wCarSpeedY] ;16
	ld d,a ;4
	cp 0 ;8 not move 
	jr z,.colCarPosX\@ ;8/12 = 40
	; up/down
	ld a,[wCarSpriteY] ;16
	add a,d ;4
	ld [wNewCarSpriteY],a ;16 = 72

.colCarPosX\@
	ld a,[wCarSpeedX] ;16
	ld d,a ;4
	cp 0 ;8 not move
	jp z,.checkCollision\@ ;12/16 = 44
	; left/right
	ld a,[wCarSpriteX] ;16
	add a,d ;4
	ld [wNewCarSpriteX],a ;16 = 76 = 148

.checkCollision\@
	ld a,[wNewCarSpriteY]
	ld d,a
	ldh a,[rSCY]
	add a,d
	sub SBY
	mOneEighth
	ld h,HIGH(MapVramTbl)
	add a,a
	ld l,a
	ld a,[hli]
	ld d,a
	ld a,[wNewCarSpriteX]
	sub SBX
	ld e,a
	ldh a,[rSCX]
	add a,e
	mOneEighth
	add a,d
	ld c,a
	ld a,[hl]
	ld l,c
	ld h,a
	ld a,[hli]
	ld d,a
	ld a,[hl]
	or d
	ld d,a
	ld bc,$1F
	add hl,bc
	ld a,[hli]
	or d
	ld d,a
	ld a,[hl]
	or d
	cp 0
	jr z,.setPos\@

;	ld a,$ff
;	ld [wCarShift],a
;	xor a
;	ld [wSpeedWait],a
;	ld [wSpeedWaitInit],a
;	ld [wSpeedWaitCnt],a

	ld a,[wSmokeAddY]
	ld d,a
	ld a,[wCarSpriteY]
	add a,d
	ld [wCarSpriteY],a

	ld a,[wSmokeAddX]
	ld d,a
	ld a,[wCarSpriteX]
	add a,d
	ld [wCarSpriteX],a
	jp .setSprite\@

.setPos\@
	ld a,[wSmokeAddY]
	ld e,a
	ld a,[wCarSpeedY]
	ld d,a
	cp 0 ; not move
	jr z,.setCarPosX\@
	cp 1 ; down
	jr z,.checkDownMove\@
	; up
	ldh a,[rSCY]
	cp ScrollUpSC
	jr z,.addCarPosY\@
	ld a,[wCarSpriteY]
	cp ScrollUpPos
	jr nc,.addCarPosY\@
	ldh a,[rSCY]
	add a,d
	ldh [rSCY],a
	mAddWSmokeY
	jr .setCarPosX\@

.checkDownMove\@
	ld a,[wCarSpriteY]
	cp ScrollDownPos
	jr nc,.scrollDown\@
	add a,d
	ld [wCarSpriteY],a
	jr .setCarPosX\@

.scrollDown\@
	ldh a,[rSCY]
	cp ScrollDownSC
	jr z,.addCarPosY\@
	add a,d
	ldh [rSCY],a
	mAddWSmokeY
	jr .setCarPosX\@

.addCarPosY\@
	ld a,[wCarSpriteY]
	add a,d
	ld [wCarSpriteY],a

.setCarPosX\@
	ld a,[wSmokeAddX]
	ld e,a
	ld a,[wCarSpeedX]
	ld d,a
	cp 0 ; not move
	jp z,.setSprite\@
	cp 1 ; right
	jr z,.checkRightMove\@
	; left
	ldh a,[rSCX]
	cp ScrollLeftSC
	jr z,.addCarPosX\@
	ld a,[wCarSpriteX]
	cp ScrollLeftPos
	jr nc,.addCarPosX\@
	ldh a,[rSCX]
	add a,d
	ldh [rSCX],a
	mAddWSmokeX
	jr .setSprite\@

.checkRightMove\@
	ld a,[wCarSpriteX]
	cp ScrollRightPos
	jr nc,.scrollRight\@
	add a,d
	ld [wCarSpriteX],a
	jr .setSprite\@

.scrollRight\@
	ldh a,[rSCX]
	cp ScrollRightSC
	jr z,.addCarPosX\@
	add a,d
	ldh [rSCX],a
	mAddWSmokeX
	jr .setSprite\@

.addCarPosX\@
	ld a,[wCarSpriteX]
	add a,d
	ld [wCarSpriteX],a

.setSprite\@
	ld a,[wCarTurn]
	rlca
	rlca
	rlca
	ld b,HIGH(CarSpriteTbl)
	ld c,a
	ld hl,wShadowOAM

	ld a,[wCarSpriteY]
	ld d,a
	ld a,[bc]
	add a,d
	ld [hli],a ; Y Position
	inc c
	ld a,[wCarSpriteX]
	ld e,a
	ld a,[bc]
	add a,e
	ld [hli],a ; X Position
	inc c
	ld a,[bc]
	ld [hli],a ; Tile Index
	inc c
	ld a,[bc]
	ld [hli],a ; Attributes/Flags
	inc c
	ld a,[bc]
	add a,d
	ld [hli],a
	inc c
	ld a,[bc]
	add a,e
	ld [hli],a
	inc c
	ld a,[bc]
	ld [hli],a
	inc c
	ld a,[bc]
	ld [hli],a

	; Set Smoke
	ld a,[wSmokeY]
	ld d,a
	ld [hli],a
	ld a,[wSmokeX]
	ld e,a
	ld [hli],a
	ld a,20
	ld [hli],a
	xor a
	ld [hli],a
	;
	ld a,d
	ld [hli],a
	ld a,e
	add a,8
	ld [hli],a
	ld a,22
	ld [hli],a
	xor a
	ld [hli],a

	ld a,[wSmokeWait]
	cp 0
	jr z,.resetSmoke\@
	dec a
	ld [wSmokeWait],a
	jr SetOAM
.resetSmoke\@
	xor a
	ld [wSmokeY],a
	ld [wSmokeX],a
ENDM

MACRO mAddWSmokeY
	ld a,[wSmokeY]
	add a,e
	ld [wSmokeY],a
ENDM

MACRO mAddWSmokeX
	ld a,[wSmokeX]
	add a,e
	ld [wSmokeX],a
ENDM

MACRO mOneEighth
	rrca
	rrca
	rrca
	and %00011111
ENDM