MACRO mGetCarCollision
;call mGetCarCollision ;24cycles
	rrca ;1byte
	rrca ;1
	rrca ;1
	and %00011111 ;2
	add a,l ;1
	ld l,a ;1
	xor a ;1
	ldh [rVBK],a ;2
	ld a,[hl] ;1 = 11bytes
;ret ;16cycles = 40cycles
ENDM

MACRO mGetCarColSubTbl
	ld hl,CarColSubTbl
	add a,l
	ld l,a
	ld c,[hl]
ENDM

MACRO mCheckCollision
	ld a,[wCarPosVram]
	ld h,a
	ld a,[wCarPosVram+1]
	ld l,a
	push hl

	; Check Upper left
	ld a,[wNewPosX]
	ld e,a
	sub 7 ; wNewPosX-7 Upper left
	ld d,a
	mGetCarCollision
	cp BGDontColTile
	jr c,.upperRight\@
	
	mGetCarColSubTbl
	ld a,d
	add c
	pop hl
	push hl
	mGetCarCollision
	cp BGDontColTile
	jr c,.upperRight\@

	ld a,[wNewPosX]
	add CarVibration
	ld [wNewPosX],a
	jr .update\@

.upperRight\@
	; Check Upper Right
	pop hl
	push hl
	ld a,e
	add a,6 ; wNewPosX+7 Upper Right
	ld d,a
	mGetCarCollision
	cp BGDontColTile
	jr c,.update\@

	mGetCarColSubTbl
	ld a,d
	sub c
	pop hl
	push hl
	mGetCarCollision
	cp BGDontColTile
	jr c,.update\@
	
	ld a,[wNewPosX]
	sub CarVibration
	ld [wNewPosX],a
	jr .update\@

.update\@
	ld a,[wNewPosX]
	ld [wPosX],a
	pop hl
ENDM

MACRO mSetCarPosVram
	ldh a,[rSCY]
	add a,CarBaseY
	rrca
	rrca
	rrca
	and %00011111
	ld hl,MapVramTbl
	add a,a
	ld l,a
	ld a,[hli]
	ld [wCarPosVram+1],a
	ld a,[hl]
	ld [wCarPosVram],a
ENDM

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

MACRO mSetMapTbl
	ld a,[wMapTbl] ;16
	ld h,a ;4
	ld a,[wMapTbl+1] ;16
	ld l,a ;4
	ld bc,wMapIndexesTbl ;12
	ld de,wMapPartTbl ;12 = 64
.loop\@
	ld a,[hli] ;8 hl=wMapTbl
	push hl ;16
	ld h,0 ;8
	ld l,a ;4
	add hl,hl ;8
	add hl,hl ;8
	add hl,de ;8
	ld a,[hli] ;8 wMapPartTbl 1
	ld [bc],a ;8 wMapIndexesTbl 1
	inc c ;4
	ld a,[hli] ;8 wMapPartTbl 2
	ld [bc],a ;8 wMapIndexesTbl 2
	ld a,c ;4
	add a,MapSize-1 ;8 bc+19
	ld c,a ;4
	ld a,[hli] ;8 wMapPartTbl 3
	ld [bc],a ;8 wMapAttributesTbl 1
	inc c ;4
	ld a,[hli] ;8 wMapPartTbl 4
	ld [bc],a ;8 wMapAttributesTbl 2
	ld a,c ;4
	cp SetMapTblEnd ;8
	jr z,.loopEnd ;12

	sub MapSize-1 ;8 bc-19
	ld c,a ;4
	pop hl ;12
	jr .loop\@ ;12 = 208*10+64 = 2144
.loopEnd
	pop hl ;12 = 2156
ENDM

MACRO mSetVram
	ld a,[wMapVram] ;16
	ld d,a ;4
	ld a,[wMapVram+1] ;16
	ld e,a ;4
	ld h,d ;4
	ld l,e ;4
	xor a ;4
	ldh [rVBK],a ;12 Tile Indexes
	ld bc,wMapIndexesTbl ;12 = 76
.loop\@
	ld a,[bc] ;8
	ld [hli],a ;8
  inc c ;4
	ld a,c ;4
	cp WMapIndexesEnd ;8
	jr nz,.loop\@ ;12 = 44

	ld h,d ;4
	ld l,e ;4
	ld a,1 ;8
	ldh [rVBK],a ;12 Attributes
	ld bc,wMapAttributesTbl ;12 = 40
.loop2\@
	ld a,[bc] ;8
	ld [hli],a ;8
  inc c ;4
	ld a,c ;4
	cp WMapAttributesEnd ;8
	jr nz,.loop2\@ ;12 = 44+76+44+40 = 204
ENDM

MACRO mCalcMapTbl
	ld a,[wMapTbl]
	ld h,a
	ld a,[wMapTbl+1]
	ld l,a
	ld bc,MapTblEnd-MapTblSize

	ld a,l
	cp c
	jr nz,.next\@
	ld a,h
	cp b
	jr nz,.next\@

	ld a,HIGH(MapTbl)
	ld [wMapTbl],a
	ld a,LOW(MapTbl)
	ld [wMapTbl+1],a
	jr .next2\@

.next\@
	ld bc,MapTblSize
	add hl,bc
	ld a,h
	ld [wMapTbl],a
	ld a,l
	ld [wMapTbl+1],a
.next2\@
ENDM

MACRO mDecMapVram
	ld bc,MapVramDec ;12
	ld a,[wMapVram] ;16
	ld h,a ;4
	ld a,[wMapVram+1] ;16
	ld l,a ;4
	add hl,bc ;8 = 60

	ld bc,MapVramMin ;12
	ld a,l ;4
	cp c ;4
	jr nz,.next\@ ;12 = 32+60 = 92
	ld a,h ;4
	cp b ;4
	jr nz,.next\@ ;12 = 20+32+60 = 112

	ld a,HIGH(MapVramX31) ;8
	ld [wMapVram],a ;16
	ld a,LOW(MapVramX31) ;8
	ld [wMapVram+1],a ;16 = 48+112=160
	jr .next2\@ ;12

.next\@
	ld a,h ;4
	ld [wMapVram],a ;16
	ld a,l ;4
	ld [wMapVram+1],a ;16 = 40+92=132, 40+112=152
.next2\@
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

MACRO mSetPalette
.loop\@
	ld a,[hli]
	ld [de],a
	ld a,[hli]
	ld [de],a
	dec c
	jr nz,.loop\@
ENDM
