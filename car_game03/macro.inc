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

MACRO mResetShadowOAM
  ld a,l
  rrca
  rrca
  ld c,a
  ld a,UseMaxOAM
  sub c
  cp 0
  jr z,.skip\@
  ld c,a
  xor a
.loop\@
  ld [hli],a
  ld [hli],a
  inc l
  inc l
  dec c
  jr nz,.loop\@
.skip\@
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

MACRO mSetCarCForceL
  ld a,[wCarShift]
  cp 4
  jr z,.shift4\@
  cp 5
  jr z,.shift5\@
  jr .skip\@
.shift4\@
  ld a,CarCForceLeft
  ld [wCarCForce],a
  ld a,[wJoypad]
  bit JBitLeft,a
  jr nz,.skip\@
  jr .setPos\@
.shift5\@
  ld a,CarCForceLeft
  ld [wCarCForce],a
  ld a,[wJoypad]
  bit JBitLeft,a
  jr z,.setPos2\@
.setPos\@
  ld a,[wCarCForceWait]
  cp 0
  jr z,.setPos2\@
  dec a
  ld [wCarCForceWait],a
  jr .skip\@
.setPos2\@
  ld a,[wJoyPadPos]
  cp 15
  jp z,.skip\@
  inc a
  ld [wJoyPadPos],a
  ld a,CarCForceWait
  ld [wCarCForceWait],a
.skip\@
ENDM

MACRO mSetCarCForceR
  ld a,[wCarShift]
  cp 4
  jr z,.shift4\@
  cp 5
  jr z,.shift5\@
  jr .skip\@
.shift4\@
  ld a,CarCForceRight
  ld [wCarCForce],a
  ld a,[wJoypad]
  bit JBitRight,a
  jr nz,.skip\@
  jr .setPos\@
.shift5\@
  ld a,CarCForceRight
  ld [wCarCForce],a
  ld a,[wJoypad]
  bit JBitRight,a
  jr z,.setPos2\@
.setPos\@
  ld a,[wCarCForceWait]
  cp 0
  jr z,.setPos2\@
  dec a
  ld [wCarCForceWait],a
  jr .skip\@
.setPos2\@
  ld a,[wJoyPadPos]
  cp 1
  jp z,.skip\@
  dec a
  ld [wJoyPadPos],a
  ld a,CarCForceWait
  ld [wCarCForceWait],a
.skip\@
ENDM

MACRO mJoypadWait
  ld a,[wCarShift]
  cp 0
  jp z,SetWJoyPadXLR
  ld a,[wJoypadWait]
  cp 0
  jr z,.next\@
  dec a
  ld [wJoypadWait],a
  jp SetWJoyPadXLR
.next\@
  ld a,JoypadWait
  ld [wJoypadWait],a
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
  ld a,[hl]
  ld [wRivalWaitDef],a
ENDM

MACRO mSetEngineSound
  ld a,[wEngineSound]
  ld c,a
  ld a,[wCarShift]
  cp c
  jr z,.exit\@
  ld [wEngineSound],a
  rlca
  rlca
  ld hl,SoundTbl
  add a,l
  ld l,a
  ld a,[hli]
  ldh [rAUD3LEVEL],a ; Output level
  ld a,[hli]
  ldh [rAUD3LOW],a ; Frequency low
  ld a,[hl]
  ldh [rAUD3HIGH],a ; Frequency hi
.exit\@
ENDM

MACRO mSetRivalCarSprite
  ld a,[wRivalTblZ+\1]
  cp 0
  jr z,.skip\@
  ld [wRivalPosZ],a
  ld a,[wRivalTblX+\1]
  ld [wRivalPosX],a
  ld a,[wRivalTblPal+\1]
  ld [wRivalPal],a
  call SetRivalCarSprite
.skip\@
ENDM

MACRO mSetPalette
  ld a,[hli]
  ld [de],a
  ld a,[hli]
  ld [de],a
ENDM

MACRO mJpScenario
  ld a,[wSPoint]
  ld l,a
  ld a,[wSPoint+1]
  ld h,a
  jp hl
ENDM

MACRO mSetLCDC
  ld a,LCDCF_ON|LCDCF_OBJON|LCDCF_BGON|LCDCF_OBJ16
ENDM