InitSoundDriver:
	ld a,%01110111     ; -LLL-RRR Master volume & VIN panning
	ldh [rAUDVOL],a
	ld a,%11111111     ; LLLLRRRR Sound panning
	ldh [rAUDTERM],a
	ld a,%10000000     ; x------- Sound on/off
	ldh [rAUDENA],a
	ld a,%00000000     ; Channel 1 sweep
	ldh [rAUD1SWEEP],a ; Bit 6-4 - Sweep pace
	                   ; Bit 3   - Sweep increase/decrease
	                   ;            0: Addition    (wavelength increases)
	                   ;            1: Subtraction (wavelength decreases)
	                   ; Bit 2-0 - Sweep slope control (n: 0-7)
	ld a,%00000000     ; Channel 1 length timer & duty cycle
	ldh [rAUD1LEN],a   ; Bit 7-6 - Wave duty            (Read/Write)
	                   ; Bit 5-0 - Initial length timer (Write Only)
	ld a,%00000000     ; Channel 1 volume & envelope
	ldh [rAUD1ENV],a   ; Bit 7-4 - Initial volume of envelope (0-F) (0=No Sound)
	                   ; Bit 3   - Envelope direction (0=Decrease, 1=Increase)
	                   ; Bit 2-0 - Sweep pace (0=No Sweep)
	ret

PlaySound:
	ld a,[de]
	cp $FF
	jr z,.soundOff
	cp 0
	jr z,.skip
	or %00000100
	ldh [rAUD1ENV],a
	inc de
	ld a,[de]
	inc de
	ld h,HIGH(MusicalScaleTbl)
	rlca
	ld l,a
	ld a,[hli]
	ldh [rAUD1LOW],a ; Channel 1 wavelength low
	ld a,[hli]
	or %10000000
	ldh [rAUD1HIGH],a ; Channel 1 wavelength high & control
	ret

.skip
	inc de
	inc de
	ret

.soundOff
	xor a
	ldh [rAUD1ENV],a
	ret
