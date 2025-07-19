MACRO mSetCar
  ld hl,wShadowOAM
  ld d,CarPosX
.loop\@
  ld a,CarPosY
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
  ;
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
  inc c
  ;
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
  ; Set RCarXPosTbl
  ld a,[wRCarYPosTbl+\1]
  ld c,a
  ld a,[wJoyPadPos]
  ld d,a
  and %00001000
  ld e,a
  xor d
  swap a
  rlca
  add a,c
  ld c,a
  ld a,e
  swap a
  rlca
  or %00100000
  ld b,a
  ld a,[bc]
  ld d,a

  ; Set RCarSpriteTbl
  ld b,HIGH(RCarYPosTbl)
  ld a,[wRCarYPosTbl+\1]
  rlca
  ld c,a
  ld a,[bc]
  ld [wRCarYPos],a
  inc c
  ld a,[bc]
  rlca
  rlca
  rlca
  rlca
  ld c,a

  ld a,[wJoyPadPos]
  ld b,a
  ld a,[wRCarXPos+\1]
  cp b
  jr c,.setRight\@
  jr nz,.setLeft\@
.setCenter\@
  ld b,HIGH(RCarCSpriteTbl)
  jr .drawOAMcnt\@
.setLeft\@
  ld b,HIGH(RCarLSpriteTbl)
  jr .drawOAMcnt\@
.setRight\@
  ld b,HIGH(RCarRSpriteTbl)

.drawOAMcnt\@
  ld a,[bc]
  ld e,a
  inc c
  cp 4
  jr nz,.setRCar\@
  dec e

  ld a,[wCarTireRef]
  cp 0
  jr z,.setRCar\@
  dec e
  ld a,3
  add a,c
  ld c,a

.setRCar\@
  ld a,[wRCarYPos+\1]
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
  jr nz,.setRCar\@
  ;
  ld a,[wRCarYPos+\1]
  ld [hli],a
  ld a,[bc] ; X Position
  cp 0
  jr z,.reset\@
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
  ;
  ld a,[wRCarYPos+\1]
  ld [hli],a
  ld a,[bc] ; X Position
  cp 0
  jr z,.reset\@
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
.reset\@
  xor a
REPT 2
  ld [hli],a ; X Position
  inc l ; Tile Index
  inc l ; Attributes/Flags
  inc l ; Y Position
ENDR
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