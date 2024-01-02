MACRO mSetSQxSoundData
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
  ldh [rAUD\1LOW],a
  ld a,[hli]
  or %10000000
  ldh [rAUD\1HIGH],a
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

MACRO mSetWavSoundData
  ld a,[wWavSoundData]
  ld b,a
  ld a,[wWavSoundData+1]
  ld c,a
.next\@
  ldh a,[hEmptyCnt3]
  cp 0
  jr nz,.decEmpty\@
  ld a,[bc]
  cp GBSD_ENDDATA
  jr z,.endData\@
  inc bc
  ld d,a
  and %00001111
  ld e,a ;low
  xor d
  ld d,a ;hi
  cp GBSD_NOTE
  jr z,.setNote\@
  cp GBSD_EMPTY
  jr z,.setEmpty\@
  ; Set Octave
  ld d,HIGH(MusicalScalePosTbl)
  ld a,LOW(MusicalScalePosTbl)
  add a,e
  ld e,a
  ld a,[de]
  ldh [hMusicalScalePos3],a
  jr .next\@
.setNote\@
  ldh a,[hMusicalScalePos3]
  add a,e
  ld h,HIGH(wMusicalScaleTbl)
  rlca
  ld l,a
  ld a,[hli]
  ldh [rAUD3LOW],a
  ld a,[hli]
  or %10000000
  ldh [rAUD3HIGH],a
  jr .exit\@
.decEmpty\@
  dec a
  ldh [hEmptyCnt3],a
  jr .exit\@
.setEmpty\@
  ld a,e
  cp 0
  jr z,.exit\@
  ldh [hEmptyCnt3],a
  jr .exit\@
.endData\@
  xor a
  ldh [rAUD3ENA],a
.exit\@
  ld a,b
  ld [wWavSoundData],a
  ld a,c
  ld [wWavSoundData+1],a
ENDM

MACRO mSetNoiSoundData
  ld a,[wNoiSoundData]
  ld b,a
  ld a,[wNoiSoundData+1]
  ld c,a
.next\@
  ldh a,[hEmptyCnt4]
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
  cp GBSD_SHIFT
  jr z,.setClockShift\@
  cp GBSD_EMPTY
  jr z,.setEmpty\@
  cp GBSD_DIVIDER
  jr z,.setClockDivider\@
  jr .exit\@
.setClockShift\@
  ldh a,[hClockDivider]
  swap e
  or e
  ldh [rAUD4POLY],a
  ld a,%10000000
  ldh [rAUD4GO],a
  jr .exit\@
.setClockDivider\@
  ld a,e
  ldh [hClockDivider],a
  jr .next\@
.setEnvelope\@
  ld a,[bc]
  inc bc
  ldh [rAUD4ENV],a
  jr .next\@
.decEmpty\@
  dec a
  ldh [hEmptyCnt4],a
  jr .exit\@
.setEmpty\@
  ld a,e
  cp 0
  jr z,.exit\@
  ldh [hEmptyCnt4],a
  jr .exit\@
.endData\@
  ;xor a
  ;ldh [rAUD1ENV],a
.exit\@
  ld a,b
  ld [wNoiSoundData],a
  ld a,c
  ld [wNoiSoundData+1],a
ENDM
