MACRO mSetCar
  ld hl,wShadowOAM
  ld a,[bc]
  cp 0
  jr z,.skip\@
  inc c
  ld d,a
  ld a,[wCarTireRef]
  cp 0
  jr z,.notRef\@
  ld a,d
  ld [hli],a ; Y Pos
  ld a,[bc]
  inc c
  ld [hli],a ; X Pos
  ld a,[bc]
  inc c
  ld [hli],a ; Index
  ld a,[bc]
  ld [hli],a ; Attr
  inc c
  jr .skip\@
.notRef\@
  inc c
  inc c
  inc c
.skip\@
  _mSetCar ;1
  _mSetCarRef ;0
  _mSetCar ;2
  _mSetCar ;3
  _mSetCarRef ;4
.reset\@
  xor a
  ld [hli],a
  inc l
  inc l
  inc l
  ld [hli],a
ENDM

MACRO _mSetCarRef
  ld a,[bc]
  inc c
  ld [hli],a ; Y Pos
  ld a,[bc]
  inc c
  ld [hli],a ; X Pos
  ld a,[bc]
  inc c
  ld d,a
  ld a,[wCarTireRef]
  or d
  ld [hli],a ; Index
  ld a,[bc]
  inc c
  ld [hli],a ; Attr
ENDM

;MACRO _mSetCarSubY
;  ld a,[wCarTireRef]
;  rrca
;  ld d,a
;  ld a,[bc]
;  inc c
;  sub d
;  ld [hli],a ; Y Pos
;  ld a,[bc]
;  inc c
;  ld [hli],a ; X Pos
;  ld a,[bc]
;  inc c
;  ld [hli],a ; Index
;  ld a,[bc]
;  inc c
;  ld [hli],a ; Attr
;ENDM

MACRO _mSetCar
  ld a,[bc]
  inc c
  ld [hli],a ; Y Pos
  ld a,[bc]
  inc c
  ld [hli],a ; X Pos
  ld a,[bc]
  inc c
  ld [hli],a ; Index
  ld a,[bc]
  inc c
  ld [hli],a ; Attr
ENDM

MACRO mSetCarSpriteTbl
  ld bc,CarSprite
  ld hl,wCarSpriteTbl
.loop
  ld a,CarPosY
  ld [hli],a ; Y Pos
  ld a,[bc]
  cp $ff ; $ff = CarSpriteEnd
  jr z,.finish
  inc bc
  ld [hli],a ; X Pos
  ld a,[bc]
  inc bc
  ld d,a
  and %11100000
  ld e,a
  xor d
  rlca
  ld [hli],a ; Index
  ld a,e
  rlca
  rlca
  or e
  and %00100011
  ld [hli],a ; Attr
  jr .loop
.finish
ENDM

MACRO mJoypadWait
  ld a,[wJoypadWait]
  cp 0
  jr z,.next\@
  dec a
  ld [wJoypadWait],a
  jp WaitScrollBG
.next\@
  ld a,JoypadWait
  ld [wJoypadWait],a
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
  ld a,[hl]
  add a,c
  ld [de],a
ENDM

MACRO mTireReflection
  ld a,[wCarTireCnt]
  inc a
  and %00011111
  ld [wCarTireCnt],a
  cp 0
  jr nz,.skip\@
  ld a,[wCarTireRef]
  xor %00000010
  ld [wCarTireRef],a
.skip\@
ENDM