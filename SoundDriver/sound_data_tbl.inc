SoundDataTbl:
  ; - Generating "sound_data_tbl.inc".
  ; php tools/convDMF2Hex.php tools/test.dmf
  ;
  ; - Data format
  ; $C0,$xx: Set Envelope
  ; $D0-$D5: Set Octave (2-7)
  ; $E0-$Ef: Set Empty (1-16)
  ; $xx: Set Volume/Note
  ;  |+ $0-$f Volume (0-15)
  ;  +- $0-$b Note (C,C#,D,D#,E,F,F#,G,G#,A,A#,B)
  ; $F0-$Fb: Set Note
  ; $FF: End of data
  ;
  ; *Total 25 bytes of data.
  db $C0,$f1 ; Set Envelope
  db $D3 ; Set Octave
  db $F0
  db $E0 ; Set Empty
  db $F0
  db $F0
  db $F0
  db $E0 ; Set Empty
  db $F4
  db $E0 ; Set Empty
  db $F4
  db $F4
  db $F4
  db $E0 ; Set Empty
  db $F5
  db $D2 ; Set Octave
  db $Ea ; Set Empty
  db $F0
  db $E6 ; Set Empty
  db $F0
  db $E6 ; Set Empty
  db $F5
  db $E6 ; Set Empty
  db $FF
