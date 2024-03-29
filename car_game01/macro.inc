MACRO mDecEnemyCar
	ld a,[wEnemyPosY]
	dec a
	dec a
	dec a
	ld [wEnemyPosY],a
ENDM

MACRO mIncEnemyCar
	ld a,[wEnemyWaitCnt]
	cp 0
	jr z,.move\@
	dec a
	ld [wEnemyWaitCnt],a
	jr .skip\@
.move\@
	ld a,EnemyWaitCnt
	ld [wEnemyWaitCnt],a
	ld a,[wEnemyPosY]
	inc a
	ld [wEnemyPosY],a
.skip\@
ENDM

MACRO mInitEnemyCar
	ld a,EnemyWaitCnt
	ld [wEnemyWaitCnt],a
	ld a,EnemyStartY
	ld [wEnemyPosY],a
	ld a,EnemyStartX
	ld [wEnemyPosX],a
	ld bc,CarSpriteTbl
	call SetEnemySprite
ENDM

MACRO mGetCarCollision
	rrca
	rrca
	rrca
	and %00011111
	add a,l
	ld l,a
	xor a
	ldh [rVBK],a
	ld a,[hl]
ENDM

MACRO mGetCarColSubTbl
	ld hl,CarColSubTbl
	add a,l
	ld l,a
	ld c,[hl]
ENDM

MACRO mSetWCarColWait
ld a,CarColWait
ld [wCarColWait],a
ENDM

MACRO mCheckCollision
	ld h,d
	ld l,e
	push hl

	; Check Upper left
	ld a,[wNewCarPosX]
	ld e,a
	sub 7 ; wNewCarPosX-7 Upper left
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

	mSetWCarColWait
	ld a,[wNewCarPosX]
	add CarVibration
	ld [wNewCarPosX],a
	jp .update\@

.upperRight\@
	; Check Upper Right
	pop hl
	push hl
	ld a,e
	add a,6 ; wNewCarPosX+7 Upper Right
	ld d,a
	mGetCarCollision
	cp BGDontColTile
	jr c,.checkEnemy\@

	mGetCarColSubTbl
	ld a,d
	sub c
	pop hl
	push hl
	mGetCarCollision
	cp BGDontColTile
	jr c,.checkEnemy\@
	
	mSetWCarColWait
	ld a,[wNewCarPosX]
	sub CarVibration
	ld [wNewCarPosX],a
	jr .update\@

.checkEnemy\@
	ld a,[wEnemyPosY]
	cp CarStartY-12
	jr c,.update\@

	ld a,[wEnemyPosY]
	cp CarStartY+13
	jr nc,.update\@

	ld a,[wEnemyPosX]
	sub 13
	ld c,a
	ld a,[wCarPosX]
	cp c
	jr c,.update\@

	ld a,[wEnemyPosX]
	add 14
	ld c,a
	ld a,[wCarPosX]
	cp c
	jr nc,.update\@

	mSetWCarColWait

	ld a,[wEnemyPosX]
	add 6
	ld c,a
	ld a,[wCarPosX]
	cp c
	jr c,.sub\@

	ld a,[wNewCarPosX]
	add CarVibration
	ld [wNewCarPosX],a
	jr .update\@

.sub\@
	ld a,[wNewCarPosX]
	sub CarVibration
	ld [wNewCarPosX],a

.update\@
	ld a,[wNewCarPosX]
	ld [wCarPosX],a
	pop hl
ENDM

MACRO mOneEighth
	rrca ;4
	rrca ;4
	rrca ;4
	and %00011111 ;8
	ld [wOneEighthY],a ;16 = 36
ENDM

MACRO mSetCarPosVram
	ld a,[wOneEighthY]
	add a,CarBaseY
	and %00011111
	ld hl,MapVramTbl
	add a,a
	ld l,a
	ld a,[hli]
	ld e,a ;l
	ld a,[hl]
	ld d,a ;h
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
	jr z,.loopEnd ;8/12 = 168*10+12 = 1692

	sub MapSize-1 ;8 bc-19
	ld c,a ;4
	pop hl ;12
	jr .loop\@ ;8/12 = 32*10+12 = 332
.loopEnd
	pop hl ;12 = 1692+332+12 = 2036
ENDM

MACRO mDecMapVram
	ld a,[wOneEighthY] ;16
	ld [wOneEighthYOld],a ;16
	add MapVramPosInit ;8
	and %00011111 ;4
	ld h,HIGH(MapVramTbl) ;8
	add a,a ;4
	ld l,a ;4
	ld a,[hli] ;8
	ld e,a ;4 l
	ld a,[hl] ;8
	ld d,a ;4 h = 84
ENDM

MACRO mSetVram
	ld h,d ;4
	ld l,e ;4
	xor a ;4
	ldh [rVBK],a ;12 Tile Indexes
	ld bc,wMapIndexesTbl ;12 = 36
.loop\@
	ld a,[bc] ;8
	ld [hli],a ;8
  inc c ;4
	ld a,c ;4
	cp WMapIndexesEnd ;8
	jr nz,.loop\@ ;12/8 = 40*20+12 = 812

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
	jr nz,.loop2\@ ;12/8 = 40*20+12 = 812+36+812+40 = 1700
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