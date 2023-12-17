SoundDataTbl:
; $Cx empty: x = $1-$f
; $Dx octave: x = $0-$5 (2-7)
; $FF end of data
;
; $xx
;  |+ note: $0-$b (C,C#,D,D#,E,F,F#,G,G#,A,A#,B)
;  + volume: $0-$f
;
; Total 22 bytes of data, Uses 97 bytes of WRAM
  db $D3 ;change to 5 octaves
  db $f0 ; volume,note
  db $C1 ;empty count
  db $f0 ; volume,note
  db $f0 ; volume,note
  db $f0 ; volume,note
  db $C1 ;empty count
  db $f4 ; volume,note
  db $C1 ;empty count
  db $f4 ; volume,note
  db $f4 ; volume,note
  db $f4 ; volume,note
  db $C1 ;empty count
  db $f5 ; volume,note
  db $D2 ;change to 4 octaves
  db $Cb ;empty count
  db $f0 ; volume,note
  db $C7 ;empty count
  db $f0 ; volume,note
  db $C7 ;empty count
  db $f5 ; volume,note
  db $C7 ; empty count
  db $FF
