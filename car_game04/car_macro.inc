MACRO mCopyScrollRoad
REPT ScrollRoadSize-1
  ld a,[hli]
  ld [de],a
  inc e
ENDR
  ld a,[hl]
  ld [de],a
ENDM

MACRO mSetCarTire
  ld hl,wShadowOAM + SOAMCarTire
  ld a,[wCarTireRef]
  ld e,a
  ld [hli],a ; Tile Index 0/2
  ld a,l
  add a,3
  ld l,a
  ld a,e
  ld [hli],a ; Tile Index 0/2
  inc l
ENDM

MACRO mInitSetCar
  ld e,4
.loop\@
  ld a,[wPosY]
  ld [hli],a ; Y Position
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
  dec e
  jr nz,.loop\@
ENDM

MACRO mSetRCar
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
ENDM

MACRO mSetRCarTire
  ld a,[bc]
  ld [hli],a ; Y Position
  inc c
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
