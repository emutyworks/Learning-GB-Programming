InitSound:
	ld a,%01110111 ; -LLL-RRR Master volume & VIN panning
	ldh [$FF24],a
	ld a,%11111111 ; LLLLRRRR Sound panning
	ldh [$FF25],a
	ld a,%10000000 ; Sound on/off
	ldh [$FF26],a
	ld a,%00000000 ; Channel 1 sweep
	ldh [$FF10],a  ; Bit 6-4 - Sweep pace
	               ; Bit 3   - Sweep increase/decrease
	               ;            0: Addition    (wavelength increases)
	               ;            1: Subtraction (wavelength decreases)
	               ; Bit 2-0 - Sweep slope control (n: 0-7)
	ld a,%10000000 ; Channel 1 length timer & duty cycle
	ldh [$FF11],a  ; Bit 7-6 - Wave duty            (Read/Write)
	               ; Bit 5-0 - Initial length timer (Write Only)
	ld a,%11110011 ; Channel 1 volume & envelope
	ldh [$FF12],a  ; Bit 7-4 - Initial volume of envelope (0-F) (0=No Sound)
	               ; Bit 3   - Envelope direction (0=Decrease, 1=Increase)
	               ; Bit 2-0 - Sweep pace (0=No Sweep)
	ld a,HIGH(Sound01Tbl)
	ld [wSoundTbl],a
	ld a,LOW(Sound01Tbl)
	ld [wSoundTbl+1],a
	ld a,1
	ld [wSoundWait],a
	ret

PlaySound:
	ld a,[wSoundWait]
	dec a
	ld [wSoundWait],a
	ret nz

	ld h,HIGH(MusicalScaleTbl)
	ld a,[wSoundTbl]
	ld d,a
	ld a,[wSoundTbl+1]
	ld e,a
	ld a,[de]
	cp SS
	ret z
	cp SW
	jr z,.setWait

	ld [wSoundWait],a
	inc de
	ld a,[de]
	ld l,a
	ld a,[hli]
	ldh [$FF13],a ; Channel 1 wavelength low
	ld a,[hli]
	or %10000000
	ldh [$FF14],a ; Channel 1 wavelength high & control
	jr .setNextTbl

.setWait
	inc de
	ld a,[de]
	ld [wSoundWait],a
.setNextTbl
	inc de
	ld a,d
	ld [wSoundTbl],a
	ld a,e
	ld [wSoundTbl+1],a
	ret
