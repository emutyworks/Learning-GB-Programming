MACRO mCopyScrollRoad
REPT ScrollRoadSize-1
  ld a,[hli]
  ld [de],a
  inc e
ENDR
  ld a,[hl]
  ld [de],a
ENDM

MACRO mSetCar
  ld hl,wShadowOAM
  ld a,CarPosX
  ld d,a
REPT 3
  ld a,CarPosY
  ld [hli],a ; Y Position
  ld a,[bc]
  add a,d
  ld [hli],a ; X Position
  inc c
  ld a,[wCarTireRef]
  ld e,a
  ld a,[bc]
  or e
  ld [hli],a ; Tile Index
  inc c
  ld a,[bc]
  ld [hli],a ; Attributes/Flags
  inc c
ENDR
  ld a,CarPosY
  ld [hli],a
  ld a,[bc]
  add a,d
  ld [hli],a
  inc c
  ld a,[wCarTireRef]
  ld e,a
  ld a,[bc]
  or e
  ld [hli],a
  inc c
  ld a,[bc]
  ld [hli],a
ENDM

MACRO mSetRCar
  ld hl,wShadowOAM + 4*4
  ld a,[bc]
  ld [hli],a ; Y Position
  inc c
  ld a,[bc]
  add a,d
  ld [hli],a ; X Position
  inc c
  ld a,[bc]
  ld [hli],a ; Tile Index
  inc c
  ld a,[bc]
  ld [hli],a ; Attributes/Flags
  inc c
  ld a,[bc]
  ld [hli],a
  inc c
  ld a,[bc]
  add a,d
  ld [hli],a
  inc c
  ld a,[bc]
  ld [hli],a
  inc c
  ld a,[bc]
  ld [hli],a
;
  inc b
  ld a,[wRCarSpriteTblLo]
  ld c,a
  ld a,[bc]
  ld [hli],a
  inc c
  ld a,[bc]
  add a,d
  ld [hli],a
  inc c
  ld a,[wCarTireRef]
  ld e,a
  ld a,[bc]
  or e
  ld [hli],a
  inc c
  ld a,[bc]
  ld [hli],a
  inc c
  ld a,[bc]
  ld [hli],a
  inc c
  ld a,[bc]
  add a,d
  ld [hli],a
  inc c
  ld a,[wCarTireRef]
  ld e,a
  ld a,[bc]
  or e
  ld [hli],a
  inc c
  ld a,[bc]
  ld [hli],a
ENDM

MACRO mJoypadWait
  ld a,[wJoypadWait]
  cp 0
  jr z,.next\@
  dec a
  ld [wJoypadWait],a
  jp SetRoadScroll
.next\@
  ld a,JoypadWait
  ld [wJoypadWait],a
ENDM