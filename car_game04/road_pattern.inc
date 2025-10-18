SetRoadPWait:
  ld a,[wRoadPParam]
  ld [wRoadPWait],a
  jp NextLoop

SetRoadPTurnInc:
  mRoadPSetTurn
  ld a,[wRoadPParam]
  ld [wRoadPWait],a

  ld a,[wRoadPCnt]
  cp 0
  jp z,NextLoop

  ld a,[wTurnPos]
  inc a
  ld [wTurnPos],a
  jp NextLoop

SetRoadPTurnDec:
  mRoadPSetTurn
  ld a,[wRoadPParam]
  ld [wRoadPWait],a

  ld a,[wRoadPCnt]
  cp 0
  jp z,NextLoop

  ld a,[wTurnPos]
  dec a
  ld [wTurnPos],a
  jp NextLoop

SetRoadPTurnTest: ;test
  ld a,[wTurnWait]
  dec a
  and %00111111
  ld [wTurnWait],a
  cp 0
  jr nz,.setTurn

  mCheckJoypad
  ld a,[wJoypad]
  bit JBitRight,a
  jr nz,.decTurnPos
  bit JBitLeft,a
  jr nz,.addTurnPos
  jr .setTurn

.addTurnPos
  ld a,[wTurnPos]
  cp TurnPosMaxL
  jr z,.setTurn
  inc a
  ld [wTurnPos],a
  jr .setTurn
.decTurnPos
  ld a,[wTurnPos]
  cp TurnPosMaxR
  jr z,.setTurn
  dec a
  ld [wTurnPos],a

.setTurn
  mRoadPSetTurn
  jp NextLoop
