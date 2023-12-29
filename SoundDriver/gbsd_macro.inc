MACRO mSetSoundData
  ld a,[wSQ\1SoundData]
  ld b,a
  ld a,[wSQ\1SoundData+1]
  ld c,a
.next\@
  ldh a,[hEmptyCnt\1]
  cp 0
  jr nz,.decEmpty\@
  ld a,[bc]
  cp GBSD_ENDDATA
  jr z,.endData\@
  inc bc
  cp GBSD_ENVELOPE
  jr z,.setEnvelope\@
  ld d,a
  and %00001111
  ld e,a ;low
  xor d
  ld d,a ;hi
  cp GBSD_NOTE
  jr z,.setNote\@
  cp GBSD_EMPTY
  jr z,.setEmpty\@
  cp GBSD_OCTAVE
  jr z,.setMusicalScalePos\@
  ; Set Note/Volume
  ldh a,[rAUD\1ENV]
  and %00001111
  swap e
  or e
  ldh [rAUD\1ENV],a
  swap d
  ld e,d
.setNote\@
  ldh a,[hMusicalScalePos\1]
  add a,e
  ld h,HIGH(wMusicalScaleTbl)
  rlca
  ld l,a
  ld a,[hli]
  ldh [rAUD\1LOW],a ; Frequency low byte
  ld a,[hli]
  or %10000000 ; Initial (when set, sound restarts)
  ldh [rAUD\1HIGH],a ; Frequency high byte
  jr .exit\@
.setMusicalScalePos\@
  ld d,HIGH(MusicalScalePosTbl)
  ld a,LOW(MusicalScalePosTbl)
  add a,e
  ld e,a
  ld a,[de]
  ldh [hMusicalScalePos\1],a
  jr .next\@
.setEnvelope\@
  ld a,[bc]
  inc bc
  ldh [rAUD\1ENV],a
  jr .next\@
.decEmpty\@
  dec a
  ldh [hEmptyCnt\1],a
  jr .exit\@
.setEmpty\@
  ld a,e
  cp 0
  jr z,.exit\@
  ldh [hEmptyCnt\1],a
  jr .exit\@
.endData\@
  ;xor a
  ;ldh [rAUD1ENV],a
.exit\@
  ld a,b
  ld [wSQ\1SoundData],a
  ld a,c
  ld [wSQ\1SoundData+1],a
ENDM