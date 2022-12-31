InitSound:
	ld a,%01110111 ; -LLL-RRR Channel volume
	ldh [$FF24],a
	ld a,%11111111 ; Channel Sound output terminal
	ldh [$FF25],a
	ld a,%10000000 ; Sound on/off
	ldh [$FF26],a
	ld a,%00000000 ; Channel 1 sweep
	ldh [$FF10],a
	ld a,%10000000 ; Channel 1 length timer & duty cycle
	ldh [$FF11],a
	ld a,%11110011 ; Channel 1 volume & envelope
	ldh [$FF12],a
	;
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
