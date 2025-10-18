;MACRO mSetRoadPAddr
;  ld a,LOW(\1)
;  ld [wRoadPAddr],a
;  ld a,HIGH(\1)
;  ld [wRoadPAddr+1],a
;ENDM

MACRO mRoadPCnt
  ld a,[wRoadPWait]
  cp 0
  jr z,.decRoadPCnt\@
  dec a
  ld [wRoadPWait],a
  jp NextLoop
.decRoadPCnt\@
  ld a,[wRoadPCnt]
  cp 0
  jr z,SetRoadPTbl
  dec a
  ld [wRoadPCnt],a
  ;ld c,a ; copy wRoadPCnt

  ld a,[wRoadPAddr]
  ld l,a
  ld a,[wRoadPAddr+1]
  ld h,a
  jp hl
ENDM

MACRO mSetRoadPTbl
  ld a,[wRoadPTbl]
  inc a
  and %00001111 ;test
  ld [wRoadPTbl],a
  rlca
  rlca
  ld l,a
  ld h,HIGH(RoadPatternTbl)
  ld a,[hli]
  ld e,a
  ld [wRoadPAddr],a
  ld a,[hli]
  ld d,a
  ld [wRoadPAddr+1],a
  ld a,[hli]
  ;ld c,a ; copy wRoadPCnt
  ld [wRoadPCnt],a
  ld a,[hl]
  ;ld b,a ; copy wRoadPParam
  ld [wRoadPParam],a
  ld l,e
  ld h,d
  jp hl
ENDM

MACRO mRoadPSetTurn
  ld a,[wTurnPos]
  rlca
  ld de,TurnAddrTbl
  add a,e
  ld e,a
  ld a,[de]
  cp TurnPosCenter
  jr z,.setZero\@
  ld l,a
  inc e
  ld a,[de]
  ld h,a
  ld de,wRoadXLR
REPT TurnTblSize-1
  ld a,[hli]
  ld [de],a
  inc e
ENDR
  ld a,[hl]
  ld [de],a
  jr .nextLoop\@

.setZero\@
  ld hl,wRoadXLR
  ld c,TurnTblSize
  xor a
.loop\@
  ld [hli],a
  dec c
  jr nz,.loop\@
.nextLoop\@
ENDM
