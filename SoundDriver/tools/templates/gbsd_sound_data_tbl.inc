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
; *Total {{TOTAL_BYTES}} bytes of data.
SQ1SoundDataTbl:
{{DATA_SQ1}}

SQ2SoundDataTbl:
{{DATA_SQ2}}

; - Data format
; $D0-$D5: Set Octave (2-7)
; $E0-$Ef: Set Empty (1-16)
; $F0-$Fb: Set Note (C,C#,D,D#,E,F,F#,G,G#,A,A#,B)
; $FF: End of data
WavSoundDataTbl:
{{DATA_WAV}}

WaveData:
{{DATA_WAVE_DATA}}
WaveDataEnd: