	org 64
	.core.CPC_PRIV_BASE EQU 40448
	.core.CPC_PRIV_SIZE EQU 1024
	.core.CPC_STACK_TOP EQU 42496
	.core.CPC_MEM_TOP EQU 42619
.core.__START_PROGRAM:
	di
	ld sp, .core.CPC_STACK_TOP
	call .core.CPC_INIT_00_BOOTSTRAP
	call .core.CPC_INIT_FP_CALC
	call .core.__MEM_INIT
	jp .core.__MAIN_PROGRAM__
.core.ZXBASIC_USER_DATA:
	; Defines HEAP SIZE
.core.ZXBASIC_HEAP_SIZE EQU 4768
	; Defines HEAP ADDRESS
.core.ZXBASIC_MEM_HEAP EQU 35680
	; Defines USER DATA Length in bytes
.core.ZXBASIC_USER_DATA_LEN EQU .core.ZXBASIC_USER_DATA_END - .core.ZXBASIC_USER_DATA
	.core.__LABEL__.ZXBASIC_USER_DATA_LEN EQU .core.ZXBASIC_USER_DATA_LEN
	.core.__LABEL__.ZXBASIC_USER_DATA EQU .core.ZXBASIC_USER_DATA
__Play_ContextPtr:
	DEFB 00, 00
__Play_NoteLengthsInTicks:
	DEFW .LABEL.__LABEL97
__Play_NoteLengthsInTicks.__DATA__.__PTR__:
	DEFW __Play_NoteLengthsInTicks.__DATA__
	DEFW __Play_NoteLengthsInTicks.__LBOUND__
	DEFW 0
__Play_NoteLengthsInTicks.__DATA__:
	DEFB 06h
	DEFB 09h
	DEFB 0Ch
	DEFB 12h
	DEFB 18h
	DEFB 24h
	DEFB 30h
	DEFB 48h
	DEFB 96
	DEFB 04h
	DEFB 08h
	DEFB 10h
.LABEL.__LABEL97:
	DEFW 0000h
	DEFB 01h
__Play_NoteLengthsInTicks.__LBOUND__:
	DEFW 0001h
__Play_NoteDividers:
	DEFW .LABEL.__LABEL98
__Play_NoteDividers.__DATA__.__PTR__:
	DEFW __Play_NoteDividers.__DATA__
	DEFW 0
	DEFW 0
__Play_NoteDividers.__DATA__:
	DEFB 0EEh
	DEFB 0Eh
	DEFB 18h
	DEFB 0Eh
	DEFB 4Dh
	DEFB 0Dh
	DEFB 8Eh
	DEFB 0Ch
	DEFB 0DAh
	DEFB 0Bh
	DEFB 2Fh
	DEFB 0Bh
	DEFB 8Fh
	DEFB 0Ah
	DEFB 0F7h
	DEFB 09h
	DEFB 68h
	DEFB 09h
	DEFB 0E1h
	DEFB 08h
	DEFB 61h
	DEFB 08h
	DEFB 0E9h
	DEFB 07h
	DEFB 77h
	DEFB 07h
	DEFB 0Ch
	DEFB 07h
	DEFB 0A7h
	DEFB 06h
	DEFB 47h
	DEFB 06h
	DEFB 0EDh
	DEFB 05h
	DEFB 98h
	DEFB 05h
	DEFB 47h
	DEFB 05h
	DEFB 0FCh
	DEFB 04h
	DEFB 0B4h
	DEFB 04h
	DEFB 70h
	DEFB 04h
	DEFB 31h
	DEFB 04h
	DEFB 0F4h
	DEFB 03h
	DEFB 0BCh
	DEFB 03h
	DEFB 86h
	DEFB 03h
	DEFB 53h
	DEFB 03h
	DEFB 24h
	DEFB 03h
	DEFB 0F6h
	DEFB 02h
	DEFB 0CCh
	DEFB 02h
	DEFB 0A4h
	DEFB 02h
	DEFB 7Eh
	DEFB 02h
	DEFB 5Ah
	DEFB 02h
	DEFB 38h
	DEFB 02h
	DEFB 18h
	DEFB 02h
	DEFB 0FAh
	DEFB 01h
	DEFB 0DEh
	DEFB 01h
	DEFB 0C3h
	DEFB 01h
	DEFB 0AAh
	DEFB 01h
	DEFB 92h
	DEFB 01h
	DEFB 7Bh
	DEFB 01h
	DEFB 66h
	DEFB 01h
	DEFB 52h
	DEFB 01h
	DEFB 3Fh
	DEFB 01h
	DEFB 2Dh
	DEFB 01h
	DEFB 1Ch
	DEFB 01h
	DEFB 0Ch
	DEFB 01h
	DEFB 0FDh
	DEFB 00h
	DEFB 0EFh
	DEFB 00h
	DEFB 0E1h
	DEFB 00h
	DEFB 0D5h
	DEFB 00h
	DEFB 0C9h
	DEFB 00h
	DEFB 0BEh
	DEFB 00h
	DEFB 0B3h
	DEFB 00h
	DEFB 0A9h
	DEFB 00h
	DEFB 9Fh
	DEFB 00h
	DEFB 96h
	DEFB 00h
	DEFB 8Eh
	DEFB 00h
	DEFB 86h
	DEFB 00h
	DEFB 7Fh
	DEFB 00h
	DEFB 77h
	DEFB 00h
	DEFB 71h
	DEFB 00h
	DEFB 6Ah
	DEFB 00h
	DEFB 64h
	DEFB 00h
	DEFB 5Fh
	DEFB 00h
	DEFB 59h
	DEFB 00h
	DEFB 54h
	DEFB 00h
	DEFB 50h
	DEFB 00h
	DEFB 4Bh
	DEFB 00h
	DEFB 47h
	DEFB 00h
	DEFB 43h
	DEFB 00h
	DEFB 3Fh
	DEFB 00h
	DEFB 3Ch
	DEFB 00h
	DEFB 38h
	DEFB 00h
	DEFB 35h
	DEFB 00h
	DEFB 32h
	DEFB 00h
	DEFB 2Fh
	DEFB 00h
	DEFB 2Dh
	DEFB 00h
	DEFB 2Ah
	DEFB 00h
	DEFB 28h
	DEFB 00h
	DEFB 26h
	DEFB 00h
	DEFB 24h
	DEFB 00h
	DEFB 22h
	DEFB 00h
	DEFB 20h
	DEFB 00h
	DEFB 1Eh
	DEFB 00h
	DEFB 1Ch
	DEFB 00h
	DEFB 1Bh
	DEFB 00h
	DEFB 19h
	DEFB 00h
	DEFB 18h
	DEFB 00h
	DEFB 16h
	DEFB 00h
	DEFB 15h
	DEFB 00h
	DEFB 14h
	DEFB 00h
	DEFB 13h
	DEFB 00h
	DEFB 12h
	DEFB 00h
	DEFB 11h
	DEFB 00h
	DEFB 10h
	DEFB 00h
	DEFB 0Fh
	DEFB 00h
	DEFB 0Eh
	DEFB 00h
	DEFB 0Dh
	DEFB 00h
	DEFB 0Dh
	DEFB 00h
	DEFB 0Ch
	DEFB 00h
	DEFB 0Bh
	DEFB 00h
	DEFB 0Bh
	DEFB 00h
	DEFB 0Ah
	DEFB 00h
	DEFB 09h
	DEFB 00h
	DEFB 09h
	DEFB 00h
	DEFB 08h
	DEFB 00h
	DEFB 08h
	DEFB 00h
.LABEL.__LABEL98:
	DEFW 0000h
	DEFB 02h
__Play_NoteIndexes:
	DEFW .LABEL.__LABEL99
__Play_NoteIndexes.__DATA__.__PTR__:
	DEFW __Play_NoteIndexes.__DATA__
	DEFW __Play_NoteIndexes.__LBOUND__
	DEFW 0
__Play_NoteIndexes.__DATA__:
	DEFB 09h
	DEFB 0Bh
	DEFB 00h
	DEFB 02h
	DEFB 04h
	DEFB 05h
	DEFB 07h
.LABEL.__LABEL99:
	DEFW 0000h
	DEFB 01h
__Play_NoteIndexes.__LBOUND__:
	DEFW 0041h
__Play_EnvelopeShapes:
	DEFW .LABEL.__LABEL100
__Play_EnvelopeShapes.__DATA__.__PTR__:
	DEFW __Play_EnvelopeShapes.__DATA__
	DEFW 0
	DEFW 0
__Play_EnvelopeShapes.__DATA__:
	DEFB 00h
	DEFB 04h
	DEFB 0Bh
	DEFB 0Dh
	DEFB 08h
	DEFB 0Ch
	DEFB 0Eh
	DEFB 0Ah
.LABEL.__LABEL100:
	DEFW 0000h
	DEFB 01h
.core.ZXBASIC_USER_DATA_END:
.core.__MAIN_PROGRAM__:
	ld hl, .LABEL.__LABEL0
	call .core.__LOADSTR
	push hl
	ld hl, .LABEL.__LABEL0
	call .core.__LOADSTR
	push hl
	ld hl, .LABEL.__LABEL1
	call .core.__LOADSTR
	push hl
	call _Play
	ld hl, 0
	ld b, h
	ld c, l
.core.__END_PROGRAM:
	jp .core.__CPC_END
__Play_AyWrite:
#line 253 "src/lib/arch/cpc/stdlib/play.bas"
		pop hl
		pop bc
		ld c, b
		call .core.__CPC_AY_WRITE
		jp (hl)
#line 260 "src/lib/arch/cpc/stdlib/play.bas"
__Play_AyWrite__leave:
	ret
_Play:
	push ix
	ld ix, 0
	add ix, sp
	ld hl, -33
	add hl, sp
	ld sp, hl
	ld (hl), 0
	ld bc, 32
	ld d, h
	ld e, l
	inc de
	ldir
	ld hl, -33
	ld de, .LABEL.__LABEL88
	ld bc, 78
	call .core.__ALLOC_LOCAL_ARRAY
	ld hl, 0
	push hl
	push ix
	pop hl
	ld de, -33
	add hl, de
	call .core.__ARRAY
	ld (ix-13), l
	ld (ix-12), h
#line 509 "src/lib/arch/cpc/stdlib/play.bas"
		call .core.__FW_CALL
		defw $BCA7
#line 513 "src/lib/arch/cpc/stdlib/play.bas"
#line 516 "src/lib/arch/cpc/stdlib/play.bas"
		di
#line 519 "src/lib/arch/cpc/stdlib/play.bas"
	ld l, (ix-13)
	ld h, (ix-12)
	ld (__Play_ContextPtr), hl
	push hl
	push ix
	pop hl
	ld de, 4
	add hl, de
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
	ld hl, (__Play_ContextPtr)
	ld de, 26
	add hl, de
	ld (__Play_ContextPtr), hl
	push hl
	push ix
	pop hl
	ld de, 6
	add hl, de
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
	ld hl, (__Play_ContextPtr)
	ld de, 26
	add hl, de
	ld (__Play_ContextPtr), hl
	push hl
	push ix
	pop hl
	ld de, 8
	add hl, de
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
	ld l, (ix-13)
	ld h, (ix-12)
	ld (__Play_ContextPtr), hl
	ld (ix-4), 0
	jp .LABEL.__LABEL2
.LABEL.__LABEL5:
	ld hl, (__Play_ContextPtr)
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld (ix-21), l
	ld (ix-20), h
	ld l, (ix-21)
	ld h, (ix-20)
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld (ix-19), l
	ld (ix-18), h
	ld l, (ix-21)
	ld h, (ix-20)
	inc hl
	inc hl
	ld (ix-21), l
	ld (ix-20), h
	ld hl, (__Play_ContextPtr)
	push hl
	ld l, (ix-21)
	ld h, (ix-20)
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
	ld hl, (__Play_ContextPtr)
	ld de, 16
	add hl, de
	push hl
	ld l, (ix-21)
	ld h, (ix-20)
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
	ld hl, (__Play_ContextPtr)
	inc hl
	inc hl
	push hl
	ld l, (ix-21)
	ld h, (ix-20)
	push hl
	ld l, (ix-19)
	ld h, (ix-18)
	ex de, hl
	pop hl
	add hl, de
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
	ld a, 5
	push af
	call _Play.SetOctave
	ld hl, (__Play_ContextPtr)
	ld de, 14
	add hl, de
	push hl
	ld a, 15
	pop hl
	ld (hl), a
	ld hl, (__Play_ContextPtr)
	ld de, 6
	add hl, de
	push hl
	ld a, (__Play_NoteLengthsInTicks.__DATA__ + 4)
	ld l, a
	ld h, 0
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
	ld hl, (__Play_ContextPtr)
	ld de, 8
	add hl, de
	push hl
	ld a, (__Play_NoteLengthsInTicks.__DATA__ + 4)
	ld l, a
	ld h, 0
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
	ld hl, (__Play_ContextPtr)
	ld de, 4
	add hl, de
	push hl
	ld hl, 0
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
	ld hl, (__Play_ContextPtr)
	ld de, 12
	add hl, de
	push hl
	xor a
	pop hl
	ld (hl), a
	ld hl, (__Play_ContextPtr)
	ld de, 10
	add hl, de
	push hl
	xor a
	pop hl
	ld (hl), a
	ld hl, (__Play_ContextPtr)
	ld de, 13
	add hl, de
	push hl
	xor a
	pop hl
	ld (hl), a
	ld hl, (__Play_ContextPtr)
	ld de, 15
	add hl, de
	push hl
	xor a
	pop hl
	ld (hl), a
	ld hl, (__Play_ContextPtr)
	ld de, 26
	add hl, de
	ld (__Play_ContextPtr), hl
.LABEL.__LABEL6:
	inc (ix-4)
.LABEL.__LABEL2:
	ld a, (ix-4)
	push af
	ld a, 2
	pop hl
	cp h
	jp nc, .LABEL.__LABEL5
.LABEL.__LABEL4:
	ld (ix-2), 0
	ld (ix-1), 120
	call _Play.UpdateMicroticksPerTick
	ld a, 56
	push af
	call _Play.SetChipMixer
.LABEL.__LABEL7:
	ld (ix-6), 0
	ld (ix-5), 0
	ld (ix-11), 0
	ld l, (ix-13)
	ld h, (ix-12)
	ld (__Play_ContextPtr), hl
	ld (ix-4), 0
	jp .LABEL.__LABEL10
.LABEL.__LABEL13:
	ld hl, (__Play_ContextPtr)
	ld de, 4
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	push hl
	ld de, 0
	pop hl
	call .core.__EQ16
	or a
	jp z, .LABEL.__LABEL16
.LABEL.__LABEL17:
	call _Play.ReadChar
	ld a, (ix-3)
	or a
	jp nz, .LABEL.__LABEL19
	ld hl, (__Play_ContextPtr)
	ld de, 13
	add hl, de
	push hl
	ld a, 1
	pop hl
	ld (hl), a
	xor a
	push af
	ld a, (ix-4)
	push af
	call _Play.SetChipVolume
	jp .LABEL.__LABEL18
.LABEL.__LABEL19:
	ld a, (ix-3)
	sub 38
	jp nz, .LABEL.__LABEL21
	xor a
	push af
	ld a, (ix-4)
	push af
	call _Play.SetChipVolume
	jp .LABEL.__LABEL18
.LABEL.__LABEL21:
	ld a, (ix-3)
	sub 97
	ccf
	sbc a, a
	push af
	ld a, (ix-3)
	push af
	ld a, 103
	pop hl
	sub h
	ccf
	sbc a, a
	ld h, a
	pop af
	or a
	jr z, .LABEL.__LABEL89
	ld a, h
.LABEL.__LABEL89:
	push af
	ld a, (ix-3)
	sub 65
	ccf
	sbc a, a
	push af
	ld a, (ix-3)
	push af
	ld a, 71
	pop hl
	sub h
	ccf
	sbc a, a
	ld h, a
	pop af
	or a
	jr z, .LABEL.__LABEL90
	ld a, h
.LABEL.__LABEL90:
	pop de
	or d
	jp z, .LABEL.__LABEL23
	ld hl, (__Play_ContextPtr)
	ld de, 11
	add hl, de
	ld a, (hl)
	ld (ix-7), a
	ld a, (ix-3)
	sub 97
	ccf
	jp nc, .LABEL.__LABEL26
	ld a, (ix-7)
	sub 12
	ld (ix-7), a
	ld a, (ix-3)
	sub 32
	ld (ix-3), a
.LABEL.__LABEL26:
	ld a, (ix-7)
	push af
	ld a, (ix-3)
	ld l, a
	ld h, 0
	push hl
	ld hl, __Play_NoteIndexes
	call .core.__ARRAY
	pop af
	add a, (hl)
	push af
	ld hl, (__Play_ContextPtr)
	ld de, 12
	add hl, de
	pop af
	add a, (hl)
	ld (ix-7), a
	ld hl, (__Play_ContextPtr)
	ld de, 12
	add hl, de
	push hl
	xor a
	pop hl
	ld (hl), a
	ld a, (ix-7)
	ld l, a
	ld h, 0
	push hl
	ld hl, __Play_NoteDividers
	call .core.__ARRAY
	ld e, (hl)
	inc hl
	ld d, (hl)
	ex de, hl
	push hl
	ld a, (ix-4)
	push af
	call _Play.SetChipTonePitchDivider
	ld a, (ix-4)
	or a
	jp nz, .LABEL.__LABEL28
	ld a, (ix-7)
	cpl
	push af
	ld h, 127
	pop af
	and h
	srl a
	srl a
	push af
	call _Play.SetChipNoisePitchDivider
.LABEL.__LABEL28:
	ld hl, (__Play_ContextPtr)
	ld de, 14
	add hl, de
	ld a, (hl)
	ld (ix-10), a
	push af
	ld a, (ix-4)
	push af
	call _Play.SetChipVolume
	ld a, (ix-10)
	sub 16
	jp nz, .LABEL.__LABEL30
	ld (ix-11), 1
.LABEL.__LABEL30:
	jp .LABEL.__LABEL18
.LABEL.__LABEL23:
	ld a, (ix-3)
	sub 36
	jp nz, .LABEL.__LABEL31
	ld hl, (__Play_ContextPtr)
	ld de, 12
	add hl, de
	push hl
	ld hl, (__Play_ContextPtr)
	ld de, 12
	add hl, de
	ld a, (hl)
	dec a
	pop hl
	ld (hl), a
	jp .LABEL.__LABEL32
.LABEL.__LABEL31:
	ld a, (ix-3)
	sub 35
	jp nz, .LABEL.__LABEL33
	ld hl, (__Play_ContextPtr)
	ld de, 12
	add hl, de
	push hl
	ld hl, (__Play_ContextPtr)
	ld de, 12
	add hl, de
	ld a, (hl)
	inc a
	pop hl
	ld (hl), a
	jp .LABEL.__LABEL34
.LABEL.__LABEL33:
	ld a, (ix-3)
	sub 48
	ccf
	sbc a, a
	push af
	ld a, (ix-3)
	push af
	ld a, 57
	pop hl
	sub h
	ccf
	sbc a, a
	ld h, a
	pop af
	or a
	jr z, .LABEL.__LABEL91
	ld a, h
.LABEL.__LABEL91:
	or a
	jp z, .LABEL.__LABEL35
	ld hl, (__Play_ContextPtr)
	push hl
	ld hl, (__Play_ContextPtr)
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	dec hl
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
	call _Play.ReadNumber
	ld l, (ix-17)
	ld h, (ix-16)
	push hl
	ld hl, __Play_NoteLengthsInTicks
	call .core.__ARRAY
	ld a, (hl)
	ld l, a
	ld h, 0
	ld (ix-23), l
	ld (ix-22), h
	ld hl, (__Play_ContextPtr)
	ld de, 8
	add hl, de
	push hl
	ld l, (ix-23)
	ld h, (ix-22)
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
	ld l, (ix-17)
	ld h, (ix-16)
	push hl
	ld de, 10
	pop hl
	or a
	sbc hl, de
	ccf
	jp nc, .LABEL.__LABEL37
	ld hl, (__Play_ContextPtr)
	ld de, 10
	add hl, de
	push hl
	ld a, 3
	pop hl
	ld (hl), a
	jp .LABEL.__LABEL38
.LABEL.__LABEL37:
	ld hl, (__Play_ContextPtr)
	ld de, 6
	add hl, de
	push hl
	ld l, (ix-23)
	ld h, (ix-22)
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
.LABEL.__LABEL38:
	jp .LABEL.__LABEL36
.LABEL.__LABEL35:
	ld a, (ix-3)
	sub 95
	jp nz, .LABEL.__LABEL39
	call _Play.ReadNumber
	ld l, (ix-17)
	ld h, (ix-16)
	push hl
	ld hl, __Play_NoteLengthsInTicks
	call .core.__ARRAY
	ld a, (hl)
	ld l, a
	ld h, 0
	ld (ix-23), l
	ld (ix-22), h
	ld hl, (__Play_ContextPtr)
	ld de, 10
	add hl, de
	push hl
	ld a, 1
	pop hl
	ld (hl), a
	ld hl, (__Play_ContextPtr)
	ld de, 8
	add hl, de
	push hl
	ld hl, (__Play_ContextPtr)
	ld de, 8
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	push hl
	ld l, (ix-23)
	ld h, (ix-22)
	ex de, hl
	pop hl
	add hl, de
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
	ld hl, (__Play_ContextPtr)
	ld de, 6
	add hl, de
	push hl
	ld l, (ix-23)
	ld h, (ix-22)
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
	jp .LABEL.__LABEL40
.LABEL.__LABEL39:
	ld a, (ix-3)
	sub 40
	jp nz, .LABEL.__LABEL41
	ld hl, (__Play_ContextPtr)
	ld de, 15
	add hl, de
	ld a, (hl)
	ld (ix-8), a
	push af
	ld h, 4
	pop af
	cp h
	jp nc, .LABEL.__LABEL44
	inc (ix-8)
	ld a, (ix-8)
	add a, a
	add a, 16
	ld l, a
	ld h, 0
	ld (ix-27), l
	ld (ix-26), h
	ld hl, (__Play_ContextPtr)
	ld de, 15
	add hl, de
	push hl
	ld a, (ix-8)
	pop hl
	ld (hl), a
	ld l, (ix-27)
	ld h, (ix-26)
	ex de, hl
	ld hl, (__Play_ContextPtr)
	add hl, de
	push hl
	ld hl, (__Play_ContextPtr)
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
.LABEL.__LABEL44:
	jp .LABEL.__LABEL42
.LABEL.__LABEL41:
	ld a, (ix-3)
	sub 41
	jp nz, .LABEL.__LABEL45
	ld hl, (__Play_ContextPtr)
	ld de, 15
	add hl, de
	ld a, (hl)
	ld (ix-8), a
	add a, a
	add a, 16
	ld l, a
	ld h, 0
	ld (ix-27), l
	ld (ix-26), h
	ld l, (ix-27)
	ld h, (ix-26)
	ex de, hl
	ld hl, (__Play_ContextPtr)
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld (ix-25), l
	ld (ix-24), h
	ld l, (ix-25)
	ld h, (ix-24)
	push hl
	ld de, 0
	pop hl
	call .core.__EQ16
	or a
	jp z, .LABEL.__LABEL47
	dec (ix-8)
	ld hl, (__Play_ContextPtr)
	ld de, 15
	add hl, de
	push hl
	ld a, (ix-8)
	pop hl
	ld (hl), a
	jp .LABEL.__LABEL48
.LABEL.__LABEL47:
	ld hl, (__Play_ContextPtr)
	push hl
	ld l, (ix-25)
	ld h, (ix-24)
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
	ld a, (ix-8)
	push af
	xor a
	pop hl
	cp h
	jp nc, .LABEL.__LABEL50
	ld l, (ix-27)
	ld h, (ix-26)
	ex de, hl
	ld hl, (__Play_ContextPtr)
	add hl, de
	push hl
	ld hl, 0
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
.LABEL.__LABEL50:
.LABEL.__LABEL48:
	jp .LABEL.__LABEL46
.LABEL.__LABEL45:
	ld a, (ix-3)
	sub 79
	jp nz, .LABEL.__LABEL51
	call _Play.ReadNumber
	ld l, (ix-17)
	ld h, (ix-16)
	ld a, l
	push af
	call _Play.SetOctave
	jp .LABEL.__LABEL52
.LABEL.__LABEL51:
	ld a, (ix-3)
	sub 86
	jp nz, .LABEL.__LABEL53
	call _Play.ReadNumber
	ld hl, (__Play_ContextPtr)
	ld de, 14
	add hl, de
	push hl
	ld l, (ix-17)
	ld h, (ix-16)
	ld a, l
	pop hl
	ld (hl), a
	jp .LABEL.__LABEL54
.LABEL.__LABEL53:
	ld a, (ix-3)
	sub 85
	jp nz, .LABEL.__LABEL55
	ld hl, (__Play_ContextPtr)
	ld de, 14
	add hl, de
	push hl
	ld a, 16
	pop hl
	ld (hl), a
	jp .LABEL.__LABEL56
.LABEL.__LABEL55:
	ld a, (ix-3)
	sub 88
	jp nz, .LABEL.__LABEL57
	call _Play.ReadNumber
	ld l, (ix-17)
	ld h, (ix-16)
	push hl
	call _Play.SetChipEnvelopePeriod
	jp .LABEL.__LABEL58
.LABEL.__LABEL57:
	ld a, (ix-3)
	sub 87
	jp nz, .LABEL.__LABEL59
	call _Play.ReadNumber
	ld l, (ix-17)
	ld h, (ix-16)
	push hl
	ld hl, __Play_EnvelopeShapes
	call .core.__ARRAY
	ld a, (hl)
	ld (ix-2), a
	jp .LABEL.__LABEL60
.LABEL.__LABEL59:
	ld a, (ix-3)
	sub 77
	jp nz, .LABEL.__LABEL61
	call _Play.ReadNumber
	ld l, (ix-17)
	ld h, (ix-16)
	call .core.__BNOT16
	ld a, l
	push af
	call _Play.SetChipMixer
	jp .LABEL.__LABEL62
.LABEL.__LABEL61:
	ld a, (ix-3)
	sub 84
	jp nz, .LABEL.__LABEL63
	call _Play.ReadNumber
	ld a, (ix-4)
	or a
	jp nz, .LABEL.__LABEL66
	ld l, (ix-17)
	ld h, (ix-16)
	ld a, l
	ld (ix-1), a
	call _Play.UpdateMicroticksPerTick
.LABEL.__LABEL66:
	jp .LABEL.__LABEL64
.LABEL.__LABEL63:
	ld a, (ix-3)
	sub 72
	jp nz, .LABEL.__LABEL68
	ld (ix-9), 1
	jp .LABEL.__LABEL12
.LABEL.__LABEL68:
.LABEL.__LABEL64:
.LABEL.__LABEL62:
.LABEL.__LABEL60:
.LABEL.__LABEL58:
.LABEL.__LABEL56:
.LABEL.__LABEL54:
.LABEL.__LABEL52:
.LABEL.__LABEL46:
.LABEL.__LABEL42:
.LABEL.__LABEL40:
.LABEL.__LABEL36:
.LABEL.__LABEL34:
.LABEL.__LABEL32:
.LABEL.__LABEL24:
.LABEL.__LABEL22:
.LABEL.__LABEL20:
	jp .LABEL.__LABEL17
.LABEL.__LABEL18:
	ld hl, (__Play_ContextPtr)
	ld de, 10
	add hl, de
	ld a, (hl)
	push af
	xor a
	pop hl
	cp h
	jp nc, .LABEL.__LABEL69
	ld hl, (__Play_ContextPtr)
	ld de, 10
	add hl, de
	push hl
	ld hl, (__Play_ContextPtr)
	ld de, 10
	add hl, de
	ld a, (hl)
	dec a
	pop hl
	ld (hl), a
	jp .LABEL.__LABEL70
.LABEL.__LABEL69:
	ld hl, (__Play_ContextPtr)
	ld de, 8
	add hl, de
	push hl
	ld hl, (__Play_ContextPtr)
	ld de, 6
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
.LABEL.__LABEL70:
	ld hl, (__Play_ContextPtr)
	ld de, 4
	add hl, de
	push hl
	ld hl, (__Play_ContextPtr)
	ld de, 8
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
	inc (ix-5)
.LABEL.__LABEL16:
	ld hl, (__Play_ContextPtr)
	ld de, 4
	add hl, de
	push hl
	ld hl, (__Play_ContextPtr)
	ld de, 4
	add hl, de
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	dec hl
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
	ld a, (ix-6)
	push af
	ld hl, (__Play_ContextPtr)
	ld de, 13
	add hl, de
	pop af
	add a, (hl)
	ld (ix-6), a
	ld hl, (__Play_ContextPtr)
	ld de, 26
	add hl, de
	ld (__Play_ContextPtr), hl
.LABEL.__LABEL14:
	inc (ix-4)
.LABEL.__LABEL10:
	ld a, (ix-4)
	push af
	ld a, 2
	pop hl
	cp h
	jp nc, .LABEL.__LABEL13
.LABEL.__LABEL12:
	ld a, (ix-11)
	or a
	jp z, .LABEL.__LABEL72
	ld a, (ix-2)
	push af
	call _Play.SetChipEnvelopeShape
.LABEL.__LABEL72:
	ld a, (ix-9)
	or a
	jp z, .LABEL.__LABEL74
	ld (ix-4), 0
	jp .LABEL.__LABEL75
.LABEL.__LABEL78:
	xor a
	push af
	ld a, (ix-4)
	push af
	call _Play.SetChipVolume
.LABEL.__LABEL79:
	inc (ix-4)
.LABEL.__LABEL75:
	ld a, (ix-4)
	push af
	ld a, 2
	pop hl
	cp h
	jp nc, .LABEL.__LABEL78
.LABEL.__LABEL77:
	jp .LABEL.__LABEL8
.LABEL.__LABEL74:
	ld l, (ix-15)
	ld h, (ix-14)
	ld de, -113
	add hl, de
	push hl
	ld a, (ix-5)
	ld l, a
	ld h, 0
	ld de, 185
	call .core.__MUL16_FAST
	ex de, hl
	pop hl
	or a
	sbc hl, de
	call _Play.Wait
.LABEL.__LABEL9:
	ld a, (ix-6)
	sub 3
	jp nz, .LABEL.__LABEL7
.LABEL.__LABEL8:
#line 783 "src/lib/arch/cpc/stdlib/play.bas"
		ei
#line 786 "src/lib/arch/cpc/stdlib/play.bas"
_Play__leave:
	ex af, af'
	exx
	ld l, (ix+4)
	ld h, (ix+5)
	call .core.__MEM_FREE
	ld l, (ix+6)
	ld h, (ix+7)
	call .core.__MEM_FREE
	ld l, (ix+8)
	ld h, (ix+9)
	call .core.__MEM_FREE
	ld l, (ix-31)
	ld h, (ix-30)
	call .core.__MEM_FREE
	ex af, af'
	exx
	ld sp, ix
	pop ix
	exx
	pop hl
	pop bc
	pop bc
	ex (sp), hl
	exx
	ret
_Play.ReadChar:
	push ix
	ld ix, 0
	add ix, sp
	ld hl, (__Play_ContextPtr)
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	push hl
	ld hl, (__Play_ContextPtr)
	inc hl
	inc hl
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ex de, hl
	pop hl
	call .core.__EQ16
	or a
	jp z, .LABEL.__LABEL81
	ld (ix-3), 0
	jp _Play.ReadChar__leave
.LABEL.__LABEL81:
	ld hl, (__Play_ContextPtr)
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	ld a, (hl)
	ld (ix-3), a
	ld hl, (__Play_ContextPtr)
	push hl
	ld hl, (__Play_ContextPtr)
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	inc hl
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
_Play.ReadChar__leave:
	ld sp, ix
	pop ix
	ret
_Play.ReadNumber:
	push ix
	ld ix, 0
	add ix, sp
	ld (ix-17), 0
	ld (ix-16), 0
.LABEL.__LABEL82:
	call _Play.ReadChar
	ld a, (ix-3)
	sub 48
	ccf
	sbc a, a
	push af
	ld a, (ix-3)
	push af
	ld a, 57
	pop hl
	sub h
	ccf
	sbc a, a
	ld h, a
	pop af
	or a
	jr z, .LABEL.__LABEL92
	ld a, h
.LABEL.__LABEL92:
	or a
	jp z, .LABEL.__LABEL84
	ld l, (ix-17)
	ld h, (ix-16)
	ld de, 10
	call .core.__MUL16_FAST
	push hl
	ld a, (ix-3)
	ld l, a
	ld h, 0
	ex de, hl
	pop hl
	add hl, de
	ld de, -48
	add hl, de
	ld (ix-17), l
	ld (ix-16), h
	jp .LABEL.__LABEL85
.LABEL.__LABEL84:
	ld a, (ix-3)
	or a
	jp z, .LABEL.__LABEL87
	ld hl, (__Play_ContextPtr)
	push hl
	ld hl, (__Play_ContextPtr)
	ld a, (hl)
	inc hl
	ld h, (hl)
	ld l, a
	dec hl
	ex de, hl
	pop hl
	ld (hl), e
	inc hl
	ld (hl), d
.LABEL.__LABEL87:
	jp .LABEL.__LABEL83
.LABEL.__LABEL85:
	jp .LABEL.__LABEL82
.LABEL.__LABEL83:
_Play.ReadNumber__leave:
	ld sp, ix
	pop ix
	ret
_Play.SetOctave:
	push ix
	ld ix, 0
	add ix, sp
	ld hl, (__Play_ContextPtr)
	ld de, 11
	add hl, de
	push hl
	ld a, (ix+5)
	ld h, 12
	call .core.__MUL8_FAST
	pop hl
	ld (hl), a
_Play.SetOctave__leave:
	ld sp, ix
	pop ix
	exx
	pop hl
	ex (sp), hl
	exx
	ret
_Play.UpdateMicroticksPerTick:
	push ix
	ld ix, 0
	add ix, sp
	ld a, (ix-1)
	call .core.__U8TOFREG
	ld hl, 06DDBh
	push hl
	ld hl, 0622Eh
	push hl
	ld h, 093h
	push hl
	call .core.__DIVF
	call .core.__FTOU32REG
	ld (ix-15), l
	ld (ix-14), h
_Play.UpdateMicroticksPerTick__leave:
	ld sp, ix
	pop ix
	ret
_Play.Wait:
#line 444 "src/lib/arch/cpc/stdlib/play.bas"
		proc
		local loop
		ld bc, 1
		or a
loop:
		sbc hl, bc
		jr nz, loop
		endp
#line 456 "src/lib/arch/cpc/stdlib/play.bas"
_Play.Wait__leave:
	ret
_Play.SetChipTonePitchDivider:
	push ix
	ld ix, 0
	add ix, sp
	ld l, (ix+6)
	ld h, (ix+7)
	push hl
	ld de, 255
	pop hl
	call .core.__BAND16
	ld a, l
	push af
	ld a, (ix+5)
	add a, a
	call __Play_AyWrite
	ld l, (ix+6)
	ld h, (ix+7)
	ld b, 8
.LABEL.__LABEL93:
	srl h
	rr l
	djnz .LABEL.__LABEL93
.LABEL.__LABEL94:
	ld a, l
	push af
	ld a, (ix+5)
	add a, a
	inc a
	call __Play_AyWrite
_Play.SetChipTonePitchDivider__leave:
	ld sp, ix
	pop ix
	exx
	pop hl
	pop bc
	ex (sp), hl
	exx
	ret
_Play.SetChipNoisePitchDivider:
	push ix
	ld ix, 0
	add ix, sp
	ld a, (ix+5)
	push af
	ld a, 6
	call __Play_AyWrite
_Play.SetChipNoisePitchDivider__leave:
	ld sp, ix
	pop ix
	exx
	pop hl
	ex (sp), hl
	exx
	ret
_Play.SetChipVolume:
	push ix
	ld ix, 0
	add ix, sp
	ld a, (ix+7)
	push af
	ld a, (ix+5)
	add a, 8
	call __Play_AyWrite
_Play.SetChipVolume__leave:
	ld sp, ix
	pop ix
	exx
	pop hl
	pop bc
	ex (sp), hl
	exx
	ret
_Play.SetChipEnvelopeShape:
	push ix
	ld ix, 0
	add ix, sp
	ld a, (ix+5)
	push af
	ld a, 13
	call __Play_AyWrite
_Play.SetChipEnvelopeShape__leave:
	ld sp, ix
	pop ix
	exx
	pop hl
	ex (sp), hl
	exx
	ret
_Play.SetChipEnvelopePeriod:
	push ix
	ld ix, 0
	add ix, sp
	ld l, (ix+4)
	ld h, (ix+5)
	push hl
	ld de, 255
	pop hl
	call .core.__BAND16
	ld a, l
	push af
	ld a, 11
	call __Play_AyWrite
	ld l, (ix+4)
	ld h, (ix+5)
	ld b, 8
.LABEL.__LABEL95:
	srl h
	rr l
	djnz .LABEL.__LABEL95
.LABEL.__LABEL96:
	ld a, l
	push af
	ld a, 12
	call __Play_AyWrite
_Play.SetChipEnvelopePeriod__leave:
	ld sp, ix
	pop ix
	exx
	pop hl
	ex (sp), hl
	exx
	ret
_Play.SetChipMixer:
	push ix
	ld ix, 0
	add ix, sp
	ld a, (ix+5)
	push af
	ld h, 63
	pop af
	and h
	push af
	ld a, 7
	call __Play_AyWrite
_Play.SetChipMixer__leave:
	ld sp, ix
	pop ix
	exx
	pop hl
	ex (sp), hl
	exx
	ret
.LABEL.__LABEL0:
	DEFW 0000h
.LABEL.__LABEL1:
	DEFW 0008h
	DEFB 4Fh
	DEFB 34h
	DEFB 20h
	DEFB 63h
	DEFB 64h
	DEFB 65h
	DEFB 66h
	DEFB 67h
	;; --- end of user code ---
#line 1 "src/lib/arch/cpc/runtime/arith/divf.asm"
#line 1 "src/lib/arch/cpc/runtime/stackf.asm"
	; stackf.asm -- FP calculator stack push/pop
	;
	; Ported from src/lib/arch/zx81sd/runtime/stackf.asm. Replaces zx48k's
	; stackf.asm, which defines __FPSTACK_PUSH/__FPSTACK_POP as FIXED Spectrum
	; ROM addresses ($2AB6h STK-STORE, $2BF1h STK-FETCH). On the CPC those
	; addresses don't exist, so these are ordinary relocatable routines built
	; on fp_calc.asm's own FP number stack (same 5-byte format).
#line 1 "src/lib/arch/cpc/runtime/fp_calc.asm"
	; ===========================================================================
	; fp_calc.asm -- Floating-point calculator for the Amstrad CPC (RST 6, &0030)
	;
	; Ported from src/lib/arch/zx81sd/runtime/fp_calc.asm (commit 9c2d154b),
	; itself a re-implementation of the ZX Spectrum 48K ROM's CALCULATE engine
	; ($335B and the routines it depends on) from a commented disassembly, using
	; the ROM's own 5-byte float format and Lxxxx labels (kept only as readable
	; cross-reference identifiers -- they are relocatable here, not real ROM
	; addresses). On the CPC, RST 6 (&0030) replaces the Spectrum's RST $28h,
	; since &0028 belongs to the firmware (RST 5 FIRM JUMP) -- see
	; cpc-port-notes.md Sec5 Q1. Every `rst 30h` in the zx48k-derived FP runtime
	; files (addf.asm, subf.asm, mulf.asm, negf.asm, cmp/*.asm, bool/*.asm,
	; math/*.asm, str.asm, printf.asm, val.asm...) now reaches real code here.
	;
; Float format (5 bytes), identical to the Spectrum ROM's:
;   Small integer: byte1=$00, byte2=sign($00/$FF), byte3=lo, byte4=hi, byte5=$00
;   Full float:    byte1=biased exponent(+$80), byte2..5=32-bit mantissa,
	;                   with byte2 bit 7 used as the sign (the implicit mantissa
	;                   bit is always 1 except when overloaded for the sign)
	; ===========================================================================
#line 1 "src/lib/arch/cpc/runtime/sysvars.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC system variables
	;
	; zx48k's own sysvars.asm and the runtime files ported from it hard-code
	; Spectrum sysvar addresses ($5C00-$5CB5), which are ordinary program RAM
	; on the CPC (inside the code/data area, $0040 up); using them as-is would
	; silently corrupt the compiled program. This file relocates them into the
	; private runtime block instead ($9E00-$A1FF, 1 KB -- see
	; .core.CPC_PRIV_BASE / CPC_PRIV_SIZE, emitted as EQUs by
	; src/arch/cpc/backend/main.py's prologue).
	;
	; This file only defines the *names and offsets*; CPC_INIT_00_BOOTSTRAP
	; (bootstrap.asm) fills them in at runtime.
	;
; Layout ($9E00 + offset), all byte offsets from SYSVAR_BASE:
	;
	;   Offset  Size  Name               Note
	;   ------  ----  -----------------  ---------------------------------
	;   $00     2     CHARS              pointer to charset (8x8 cells);
	;                                     unused by print.asm now (the
	;                                     firmware draws its own glyphs) but
	;                                     kept for zx48k source parity
	;   $02     2     UDG                pointer to UDG charset (ditto)
	;   $04     2     COORDS             last PLOT/graphics coords (X,Y)
	;   $06     1     FLAGS2             screen flags (OVER/BOLD/ITALIC)
	;   $07     1     ECHO_E             reserved, unused for now
	;   $08     2     DFCC               unused by print.asm now (no VRAM
	;                                     pointer to track -- the firmware
	;                                     owns screen addressing); kept so
	;                                     any stray reference still assembles
	;   $0A     2     DFCCL              ditto, unused
;   $0C     2     S_POSN             vestigial: __LOAD_S_POSN/
	;                                     __SAVE_S_POSN (sposn.asm) now read
	;                                     the firmware's own live cursor via
	;                                     TXT_GET_CURSOR/TXT_SET_CURSOR
	;                                     instead of caching it here. Kept
	;                                     zeroed by bootstrap.asm; nothing
	;                                     reads or writes it any more
	;   $0E     1     ATTR_P             permanent attribute (INK/PAPER/etc.)
	;   $0F     1     MASK_P             permanent transparency mask -- kept
	;                                     immediately after ATTR_P because
	;                                     ink.asm/paper.asm/bright.asm/
	;                                     flash.asm (byte-for-byte zx48k)
	;                                     reach it with a plain `inc de`/
	;                                     `inc hl` from ATTR_P
	;   $10     1     ATTR_T             temporary attribute (same encoding
	;                                     as ATTR_P; see the bit layout below)
	;   $11     1     MASK_T             temporary transparency mask, same
	;                                     adjacency rule as MASK_P
	;   $12     1     P_FLAG             permanent print flags (OVER/INVERSE)
	;   $13     1     TV_FLAG            flags controlling output to screen
	;   $14     8     MEM0               scratch buffer; print.asm reuses it
	;                                     to stash a control code's first
	;                                     parameter byte across two
	;                                     __PRINTCHAR calls (AT's row, TAB's
	;                                     first byte) now that it doesn't need
	;                                     it for character bitmap generation
	;   $1C     2     SCREEN_ADDR        pointer to the screen bitmap base
	;   $1E     2     SCREEN_ATTR_ADDR   placeholder -- the CPC has no
	;                                    per-cell attribute byte in memory
	;                                    the way the Spectrum does
	;   $20     1     ERR_NR             error code (-1 = no error)
	;   $21     2     FRAMES             software frame counter
	;   $23     2     RANDOM_SEED_LOW    RNG seed, low 16 bits
	;   $25     8     ARRAY_SCRATCH      LBOUND_PTR/UBOUND_PTR/RET_ADDR/
	;                                    TMP_ARR_PTR (2 bytes each)
	;   $2D     2     CHR_SCRATCH        return-address scratch for CHR$()
	;   $2F     4     DIVF_SCRATCH       TMP (2B) + ERR_SP (2B) for float
	;                                    division
	;   $33     2     FW_BC              firmware's BC' shadow (fwcall.asm's
	;                                    gate); seeded from the live BC' by
	;                                    CPC_INIT_00_BOOTSTRAP before
	;                                    anything else can disturb it
	;   $35     1     IN_FW              "inside the firmware gate" flag,
	;                                    set/cleared by fwcall.asm around
	;                                    every call; for a future IM1
	;                                    front-end (Sec6.1 stage 2) to tell
	;                                    a firmware call from user code
	;   $36     6     MODF16_SCRATCH     return addr + divider DE/HL for
	;                                    MOD16.16, kept separate from
	;                                    ARRAY_SCRATCH (the two must not alias)
	;   $3C     1     PRINT_STATE        print.asm's control-code state
;                                    machine: 0 = idle, nonzero = "the
	;                                    next __PRINTCHAR byte is a parameter
	;                                    for control code N" (see print.asm)
	;   $3D     2     PPC                current line number, for BREAK
	;                                    (break.asm); matches zx48k's PPC
	;                                    23621 by name/role only -- our
	;                                    error.asm doesn't print it (no ROM
	;                                    error formatter here), it's kept
	;                                    only so CHECK_BREAK's calling
	;                                    convention matches zx48k's exactly
	;                                    (see break.asm)
;   $3F     2     FP_STKBOT          fp_calc.asm: base of the FP number
	;                                    stack (ROM STKBOT $5C63)
;   $41     2     FP_STKEND          fp_calc.asm: next free slot in the
	;                                    FP number stack (ROM STKEND $5C65).
	;                                    MUST stay immediately followed by
	;                                    FP_BREG -- see the note in
	;                                    fp_calc.asm (ENT-TABLE loads both
	;                                    with one `ld bc,(FP_STKEND+1)`)
;   $43     1     FP_BREG            fp_calc.asm: literal currently being
	;                                    executed (ROM BREG $5C67)
;   $44     2     FP_MEM             fp_calc.asm: pointer to the MEM
	;                                    area, 6 cells of 5 bytes (ROM MEM
	;                                    $5C68)
;   $46     60    FP_CALC_STACK      fp_calc.asm: the FP number stack
	;                                    itself (12 numbers max)
;   $82     30    FP_MEM_AREA        fp_calc.asm: the MEM area (6 cells)
;   $A0     8     PEN_MAP            colour.asm: Spectrum colour 0-7 ->
	;                                    pen of the current screen mode
;   $A8     1     GFX_XSHIFT         colour.asm: mode pixel x -> firmware
;                                    virtual x shift (mode 0: 2, 1: 1,
;                                    2: 0)
;   $A9     1     TXT_COLS           colour.asm: text columns of the
	;                                    current mode (20/40/80)
;   $AA     1     GRA_PEN_CUR        gfx.asm: graphics pen last given to
	;                                    the firmware ($FF = unknown)
;   $AB     1     GRA_MODE_CUR       gfx.asm: graphics write mode last
	;                                    given to the firmware ($FF = unknown)
;   $AC     9     SOUND_BLK          beep.asm: SOUND_QUEUE block (the
	;                                    firmware reads it, so it must be in
	;                                    the central 32K -- it is)
;   $B5     10    CIRC_VARS          circle.asm: centre X/Y, x, y, d
;   $BF     1     PAUSE_TICK         pause.asm: last 300 Hz tick count
	;   $C0    17     (free)             was the cpcbuild library's state; the
	;                                    library now keeps it in its own storage
;   $D1     16    SND_ENV            fwsound.asm: volume envelope data
	;                                    buffer for SOUND_AMPL_ENVELOPE
;   $E1     2     GM_VEC             isr.asm: game-mode handler address
	;                                    (0 = normal mode; framehook.asm)
;   $E3     2     FH_ADDR            framehook.asm: frame hook routine
	;                                    (0 = none)
;   $E5     4     FH_FRAMES          framehook.asm: frames counted
;   $E9     1     GM_COUNT           framehook.asm: interrupts since the
	;                                    last frame (game mode)
;   $EA     9     FH_BLOCK           framehook.asm: KL_NEW_FRAME_FLY event
	;                                    block (must be in central RAM)
	;   ------  ----
	;   $F3     (243 bytes used)
	;
	; --- ATTR_P / ATTR_T bit layout (one byte, same shape as zx48k's) ------
	;
	;   bit   Meaning
	;   ---   ------------------------------------------------------------
;   0-2   ink: a Spectrum colour 0-7 (ink.asm, unchanged from zx48k),
	;         turned into a pen of the current mode through PEN_MAP
	;         (colour.asm) whenever it reaches the firmware
;   3-5   paper: a Spectrum colour 0-7, mapped the same way
	;   6     BRIGHT flag (bright.asm) -- accepted, ignored (notes.md Q5)
	;   7     FLASH flag (flash.asm) -- accepted, ignored (notes.md Q5)
	;
	; $F3 bytes used out of CPC_PRIV_SIZE ($400 = 1024). CPC_SYSVARS_USED
	; below lets it be compared against .core.CPC_PRIV_SIZE by eye whenever
	; this table grows.
	    push namespace core
	SYSVAR_BASE         EQU .core.CPC_PRIV_BASE
	CHARS               EQU SYSVAR_BASE + $00   ; DW -- pointer to charset (8x8 cells)
	UDG                 EQU SYSVAR_BASE + $02   ; DW -- pointer to UDG charset
	COORDS              EQU SYSVAR_BASE + $04   ; DW -- last PLOT/graphics coordinates (X,Y)
	FLAGS2              EQU SYSVAR_BASE + $06   ; DB -- screen flags (OVER/BOLD/ITALIC)
	ECHO_E              EQU SYSVAR_BASE + $07   ; DB -- (reserved, unused for now)
	DFCC                EQU SYSVAR_BASE + $08   ; DW -- unused (no VRAM pointer to track)
	DFCCL               EQU SYSVAR_BASE + $0A   ; DW -- unused (ditto)
	S_POSN              EQU SYSVAR_BASE + $0C   ; DW -- vestigial, see table above
	ATTR_P              EQU SYSVAR_BASE + $0E   ; DB -- permanent attribute (INK/PAPER/etc.)
	MASK_P              EQU SYSVAR_BASE + $0F   ; DB -- permanent transparency mask
	ATTR_T              EQU SYSVAR_BASE + $10   ; DB -- temporary attribute
	MASK_T              EQU SYSVAR_BASE + $11   ; DB -- temporary transparency mask
	P_FLAG              EQU SYSVAR_BASE + $12   ; DB -- permanent print flags (OVER/INVERSE)
	TV_FLAG             EQU SYSVAR_BASE + $13   ; DB -- flags controlling output to screen
	MEM0                EQU SYSVAR_BASE + $14   ; 8B -- scratch buffer, see table above
	SCREEN_ADDR         EQU SYSVAR_BASE + $1C   ; DW -- pointer to the screen bitmap base
	SCREEN_ATTR_ADDR    EQU SYSVAR_BASE + $1E   ; DW -- placeholder, see table above
	ERR_NR              EQU SYSVAR_BASE + $20   ; DB -- error code (-1 = no error)
	FRAMES              EQU SYSVAR_BASE + $21   ; DW -- software frame counter
	RANDOM_SEED_LOW     EQU SYSVAR_BASE + $23   ; DW -- RNG seed, low 16 bits
	ARRAY_SCRATCH       EQU SYSVAR_BASE + $25   ; 8B -- LBOUND_PTR/UBOUND_PTR/RET_ADDR/TMP_ARR_PTR
	CHR_SCRATCH         EQU SYSVAR_BASE + $2D   ; 2B -- return-address scratch for CHR$()
	DIVF_SCRATCH        EQU SYSVAR_BASE + $2F   ; 4B -- TMP (2B) + ERR_SP (2B) for float division
	FW_BC               EQU SYSVAR_BASE + $33   ; 2B -- firmware's BC' shadow (fwcall.asm)
	IN_FW               EQU SYSVAR_BASE + $35   ; 1B -- "inside firmware gate" flag (fwcall.asm)
	MODF16_SCRATCH      EQU SYSVAR_BASE + $36   ; 6B -- return addr + divider DE/HL for MOD16.16
	PRINT_STATE         EQU SYSVAR_BASE + $3C   ; 1B -- print.asm's control-code state machine
	PPC                 EQU SYSVAR_BASE + $3D   ; DW -- current line number (break.asm CHECK_BREAK)
	; --- fp_calc.asm's own sysvars (equivalent to the ROM's STKBOT/STKEND/
	; BREG/MEM $5C63-$5C69) -- kept contiguous and in this exact order, see
	; the table above and fp_calc.asm's own header.
	FP_STKBOT           EQU SYSVAR_BASE + $3F   ; DW -- base of the FP number stack
	FP_STKEND           EQU SYSVAR_BASE + $41   ; DW -- next free slot in the FP number stack
	FP_BREG             EQU SYSVAR_BASE + $43   ; DB -- literal currently being executed
	FP_MEM              EQU SYSVAR_BASE + $44   ; DW -- pointer to the MEM area (6 cells x 5B)
	FP_CALC_STACK       EQU SYSVAR_BASE + $46   ; 60B -- the FP number stack (12 numbers max)
	FP_CALC_STACK_END   EQU FP_CALC_STACK + 60
	FP_MEM_AREA         EQU SYSVAR_BASE + $82   ; 30B -- the MEM area (6 cells x 5B)
	PEN_MAP             EQU SYSVAR_BASE + $A0   ; 8B -- Spectrum colour -> pen (colour.asm)
	GFX_XSHIFT          EQU SYSVAR_BASE + $A8   ; DB -- mode pixel x -> virtual x shift
	TXT_COLS            EQU SYSVAR_BASE + $A9   ; DB -- text columns in the current mode
	GRA_PEN_CUR         EQU SYSVAR_BASE + $AA   ; DB -- cached graphics pen ($FF = unknown)
	GRA_MODE_CUR        EQU SYSVAR_BASE + $AB   ; DB -- cached graphics write mode ($FF = unknown)
	SOUND_BLK           EQU SYSVAR_BASE + $AC   ; 9B -- SOUND_QUEUE block (beep.asm)
	CIRC_VARS           EQU SYSVAR_BASE + $B5   ; 10B -- CIRCLE state (circle.asm)
	PAUSE_TICK          EQU SYSVAR_BASE + $BF   ; DB -- PAUSE's last tick count (pause.asm)
	; $C0-$D0 are free (17 bytes).
	SND_ENV             EQU SYSVAR_BASE + $D1   ; 16B -- envelope data buffer (fwsound.asm)
	GM_VEC              EQU SYSVAR_BASE + $E1   ; DW -- game-mode handler (0 = normal; isr.asm)
	FH_ADDR             EQU SYSVAR_BASE + $E3   ; DW -- frame hook routine (0 = none)
	FH_FRAMES           EQU SYSVAR_BASE + $E5   ; 4B -- frames counted (framehook.asm)
	GM_COUNT            EQU SYSVAR_BASE + $E9   ; DB -- interrupts since last frame (game mode)
	FH_BLOCK            EQU SYSVAR_BASE + $EA   ; 9B -- frame-flyback event block (framehook.asm)
; --- Bare-metal text (txtbare.asm, Phase 6 B2): $100-$13F and $200-$21F,
	; clear of the sysvars above so parallel additions there cannot collide.
	; PAL_SHADOW reuses the 17 free bytes at $C0 (bare mode keeps no firmware
	; ink table, so BORDER reads the pen colours from here).
	PAL_SHADOW          EQU SYSVAR_BASE + $C0   ; 17B -- colour (0-26) of pens 0-15 and the border
	BT_MODE             EQU SYSVAR_BASE + $100  ; DB -- current screen mode 0-3
	BT_BPC              EQU SYSVAR_BASE + $101  ; DB -- screen bytes per glyph row (4/2/1)
	BT_PPB              EQU SYSVAR_BASE + $102  ; DB -- pixels per screen byte (2/4/8)
	BT_MASK             EQU SYSVAR_BASE + $103  ; DB -- pen number mask (15/3/1)
	BT_FILL             EQU SYSVAR_BASE + $104  ; DB -- screen byte of an all-paper row (scroll fill)
BT_MX               EQU SYSVAR_BASE + $105  ; DB -- mode 2: ink mask xor paper mask
BT_MP               EQU SYSVAR_BASE + $106  ; DB -- mode 2: paper mask
	BT_BUF              EQU SYSVAR_BASE + $108  ; 8B -- SCREEN$ glyph bitmap being matched
	BT_TRAMP            EQU SYSVAR_BASE + $120  ; 32B -- font copy routine (runs with the lower ROM in)
	BT_PIX              EQU SYSVAR_BASE + $140  ; 64B -- SCREEN$ cell pixels (pen numbers)
	BT_TBL              EQU SYSVAR_BASE + $200  ; 16B, page aligned -- screen byte per glyph-bit group
; --- cpcbuild's cpcplus library (Phase 7 P3), both modes: $300-$37F. The
	; ASIC register page replaces RAM at &4000-&7FFF while it is paged in, so the
	; code that pages it in (page in, copy, page out) cannot live in the
	; program, which may reach into that range; the library copies its small
	; routines here at start-up (#init, lib/cpcplus/plus.asm) and bounces data
	; through PL_BUF. Free in both memory maps (the firmware layout's $9E00 block
	; and the bare layout's $BC00 block have no other users above $F3 / $21F).
	; PL_TRAMP2 ($380-$3F5) holds the library's second routine block (the fast
; paths for raster handlers). Free elsewhere: $F3-$FF, $220-$2FF and $3F6-$3FF
	; in bare mode ($F3-$2FF and $3F6-$3FF in firmware mode).
; CPC_EXIT_VEC (bare mode only, $1F0-$1F1): a routine __CPC_RESET calls
	; before it resets the machine (END), 0 = none. A library that leaves
; hardware state behind (cpcplus's raster interrupts: PRI stops the
	; firmware's six interrupts per frame) points it at its cleanup.
	CPC_EXIT_VEC        EQU SYSVAR_BASE + $1F0  ; DW -- cleanup routine called by END's reset (bare mode), 0 = none
	PL_TRAMP            EQU SYSVAR_BASE + $300  ; 64B -- paged-access routines (plus.asm copies them here)
	PL_BUF              EQU SYSVAR_BASE + $340  ; 64B -- bounce buffer for data between the ASIC page and RAM at &4000-&7FFF
	PL_TRAMP2           EQU SYSVAR_BASE + $380  ; 118B -- cpcplus fast-path routines (raster handlers; plus.asm copies them here)
	CPC_SYSVARS_USED    EQU $F3                 ; bytes used above; compare by eye against
	                                             ; .core.CPC_PRIV_SIZE when this table grows
; --- Screen constants (CPC mode 1: 40 columns x 25 rows) ----------------
; The column count follows the screen mode at run time (TXT_COLS above:
	; 20/40/80); these constants are the boot-time mode 1 values. Only the
	; row count is the same in every mode.
	; SCR_COLS keeps zx48k's own "columns + 1" convention (see zx48k's
; sysvars.asm: SCR_COLS EQU 33 for 32 visible columns). SCR_COLS_VISIBLE
	; is the plain visible-column count, used by print.asm/sposn.asm's
	; explicit 0-39 range checks and arithmetic, where the "+1" convention
	; would just have to be undone again.
	SCR_COLS            EQU 41      ; columns + 1 (40 columns visible)
	SCR_COLS_VISIBLE    EQU 40      ; columns visible (0-39, 0-based)
	SCR_ROWS            EQU 25      ; rows visible (0-24, 0-based)
	SCR_SIZE            EQU (SCR_ROWS << 8) + SCR_COLS
	    pop namespace
#line 23 "src/lib/arch/cpc/runtime/fp_calc.asm"
#line 1 "src/lib/arch/cpc/runtime/error.asm"
	; Simple error control routines
	;
; Phase-2 (cpc-port-notes.md Phase 2 decisions / docs/notes.md): a
	; runtime error prints "Error n" (n = the ERROR_* code below, in
	; decimal) through the firmware, starting on a fresh line, then waits
	; for a key, then resets to BASIC's Ready prompt. This replaces the
	; Phase 1 hang-in-place trap for real errors; __CPC_NOT_IMPLEMENTED
	; (stub.asm) still hangs, unchanged, for genuinely unimplemented
	; stubs -- those two cases must stay visibly different. __STOP keeps
; the zx48k contract: store the code in ERR_NR and return. ERROR_*
	; constants keep their zx48k values (just numbers, not addresses).
	;
	; The message is printed with TXT_OUTPUT (&BB5A) directly, through the
	; gate (fwcall.asm) -- not print.asm, which isn't implemented yet
	; (print.asm's own TODO) and shouldn't be a dependency of the error
	; path anyway. TXT_OUTPUT's entry/exit are the same as far as this file
; needs: A = the character/control code to output, and (confirmed
	; against the Firmware Guide, cpc-port-notes.md Sec6.4) *all* registers
	; preserved -- so BC/DE/HL survive every call below without saving them
	; around each one.
	;
; Phase-3 printer echo (-D __CPC_PRINTER_ECHO__, cpcbuild's cpcrun.py):
	; every character this file sends to the screen is mirrored to the
	; printer via MC_PRINT_CHAR (&BD2B), through the gate, same as
	; print.asm's __PRN_ECHO (duplicated here as __ERR_PRN_ECHO rather than
	; including print.asm -- see the paragraph above). The screen still gets
	; CR+LF for a fresh line; the printer gets a bare LF (print.asm's
; decision: a clean, diffable text file). And in this mode the whole
	; point is that a *failing* test still reaches END, so __ERROR must not
; block on a keypress: it skips the key flush/wait and goes straight
	; to `rst 0` once "Error n" has been echoed.
#line 1 "src/lib/arch/cpc/runtime/fwcall.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC firmware call gate
	;
	; Every firmware jumpblock entry goes through RST 1 LOW JUMP, which uses
	; B' = &7F (gate array port) and C' = current ROM/mode config, and the
	; 300 Hz interrupt handler also uses BC' and branches on AF' carry
	; ("already inside an interrupt"). Compiled code clobbers both freely
	; (SUB epilogues pop into BC'; div8/div16/float pushes use AF'). So every
; firmware call goes through this gate: with interrupts off it sets IN_FW,
	; restores BC' from the FW_BC shadow and clears AF' carry, makes the call
	; with interrupts on, then (off again) captures BC' back (mode/ROM
	; changes) and clears IN_FW. Outside the gate interrupts go through
	; isr.asm, which does the same register hand-over for the firmware's
	; interrupt handler; IN_FW tells it the firmware's registers are already
	; loaded. The gate always returns with interrupts on.
	;
	; Usage (A, F, BC, DE, HL go in as set and come back as the firmware left
; them, flags included):
	;
	;     call .core.__FW_CALL        ; or .core.__FW_CALL_IX for CAS_* entries,
	;     defw $BB5A                  ; which corrupt IX (Boriel's frame pointer)
	;
	; Clobbers BC', DE', HL', AF' (never meaningful to compiled code across a
	; call). Not re-entrant (the interrupt handler never calls it).
; Cost: about 220 T-states plus the firmware routine.
; Bare-metal mode (-D CPC_BAREMETAL): there is no firmware, so the gate is
	; not defined at all. Anything that still calls the firmware fails to
	; build with "undefined label __FW_CALL" -- that is how firmware-only
	; features (LOAD/SAVE, firmware sound, direct firmware calls in asm) are
	; refused in bare mode.
	    push namespace core
__FW_CALL:
	    PROC
	    di                  ; IN_FW and BC' must change together (isr.asm)
	    exx                 ; alternate bank is scratch; caller's regs stay put
	    pop  hl             ; HL -> defw after the call
	    ld   e, (hl)
	    inc  hl
	    ld   d, (hl)        ; DE = firmware entry
	    inc  hl
	    push hl             ; return past the defw
	    ld   (__FW_CALL_TARGET + 1), de
	    ld   hl, IN_FW
	    ld   (hl), 1
	    ld   bc, (FW_BC)    ; becomes BC' after the exx below
	    ex   af, af'
	    or   a              ; AF' carry clear, or the ISR takes its nested path
	    ex   af, af'
	    exx
	    ei
__FW_CALL_TARGET:
	    call $FFFF          ; operand patched above
	    di
	    exx
	    ld   (FW_BC), bc    ; keep mode/ROM changes for the next call
	    ld   hl, IN_FW
	    ld   (hl), 0
	    exx
	    ei
	    ret
	    ENDP
__FW_CALL_IX:
	    PROC
	    di
	    exx
	    pop  hl
	    ld   e, (hl)
	    inc  hl
	    ld   d, (hl)
	    inc  hl
	    push hl
	    ld   (__FW_CALL_IX_TARGET + 1), de
	    ld   hl, IN_FW
	    ld   (hl), 1
	    ld   bc, (FW_BC)
	    ex   af, af'
	    or   a
	    ex   af, af'
	    exx
	    ei
	    push ix
__FW_CALL_IX_TARGET:
	    call $FFFF
	    pop  ix
	    di
	    exx
	    ld   (FW_BC), bc
	    ld   hl, IN_FW
	    ld   (hl), 0
	    exx
	    ei
	    ret
	    ENDP
	    pop namespace
#line 104 "src/lib/arch/cpc/runtime/fwcall.asm"
#line 34 "src/lib/arch/cpc/runtime/error.asm"
#line 1 "src/lib/arch/cpc/runtime/bootstrap.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC bootstrap -- captures FW_BC, initialises the private
	; runtime block's sysvars, and sets the initial screen mode
	;
	; Registered with #init, so the compiler inserts
	; "call .core.CPC_INIT_00_BOOTSTRAP" in the prologue (src/arch/cpc/
	; backend/main.py's emit_prologue()).
	;
	; Forced into every program via common.REQUIRES (backend/main.py's
; Backend.init()) rather than pulled in transitively: this must run
	; even in programs with no PRINT/arrays/etc. that would otherwise never
	; #include sysvars.asm.
	;
; Naming: #init calls are emitted in sorted label order (sorted() over
	; the raw strings passed to every #init directive -- see
	; src/arch/z80/backend/main.py's emit_prologue and
	; src/zxbc/zxbparser.py's preproc_line_init). FW_BC must be captured from
	; the live BC' before anything else can disturb it (see fwcall.asm's
	; header), which means this routine must be the first #init call, full
	; stop -- not just first among the cpc runtime's own files, but first
	; against anything any future #include might add. ".core.CPC_INIT_FP_CALC"
	; (fp_calc.asm) would otherwise sort before ".core.CPC_INIT_SYSVARS" (F <
; S), so the routine is named CPC_INIT_00_BOOTSTRAP: the "00_" digit
	; prefix sorts before any plausible future "CPC_INIT_<LETTER>..." name
	; (digits are below uppercase letters in ASCII), which is a stronger
	; guarantee than just renaming past today's one clash. Nothing else
	; references the old CPC_INIT_SYSVARS name.
#line 33 "src/lib/arch/cpc/runtime/bootstrap.asm"
#line 1 "src/lib/arch/cpc/runtime/isr.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC interrupt front-end
	;
	; Compiled code runs with interrupts on. The firmware's 300 Hz handler
	; needs BC' = its own value (B' = &7F, the Gate Array port; C' = the
	; ROM/mode configuration) and AF' carry clear (carry set means "interrupt
	; inside an interrupt"), but compiled code uses the alternate registers
	; freely (SUB epilogues, 32-bit/float pushes, the FP calculator). So the
; RAM vector at &0038 is pointed here: this handler saves both register
	; banks, hands the firmware its BC' (the FW_BC shadow, fwcall.asm) and a
	; clear AF' carry, runs the original handler, keeps any change it made
	; to BC', and restores everything.
	;
	; The RAM vector is only seen while the lower ROM is off, i.e. while our
	; code (or firmware code running from RAM) executes. With the lower ROM
	; on, the ROM's own &0038 goes straight to the firmware.
	;
	; Inside a firmware call (IN_FW = 1, set by the gate) the alternate
	; registers already hold the firmware's values, so the handler jumps
	; straight to the original. IN_FW also stays 1 while the original runs
; from here: it ends with "ei; ret", so an interrupt can arrive before
	; our "di", and the firmware's registers are still loaded then.
	;
	; The original handler (RAM &B941 on the 6128, &B939 on the 464; the
	; same code in both ROMs) is read from the vector at boot.
	;
; Game mode (framehook.asm, opt-in): when GM_VEC is non-zero, interrupts
	; outside firmware calls go to the handler it points to instead of the
	; firmware, which then only runs during firmware calls. GM_VEC is zero
	; (normal mode) unless a program switches game mode on.
	;
; Cost: about 250 T-states on top of the firmware's handler, 300 times
	; a second. See cpcbuild docs/phase4d-design.md.
#line 64 "src/lib/arch/cpc/runtime/isr.asm"
	    push namespace core
	; __CPC_ISR_INSTALL -- points the RAM vector at &0038 to __CPC_ISR,
	; keeping the original jump target. Call with interrupts off (the
	; bootstrap does, before its first firmware call).
; Firmware entries called: none. Registers clobbered: AF, HL.
__CPC_ISR_INSTALL:
	    ld   hl, ($0039)
	    ld   (__CPC_ISR_ORIG + 1), hl
	    ld   a, $C3             ; JP nn
	    ld   ($0038), a
	    ld   hl, __CPC_ISR
	    ld   ($0039), hl
	    ret
	; __CPC_ISR -- the IM 1 handler (entered with interrupts off).
; Registers clobbered: none.
__CPC_ISR:
	    push af
	    ld   a, (IN_FW)
	    or   a
	    jr   nz, __CPC_ISR_DIRECT
	    ld   a, (GM_VEC + 1)
	    or   a
    jr   nz, __CPC_ISR_GAME ; game mode (framehook.asm): skip the firmware
	    inc  a                  ; A = 1
	    ld   (IN_FW), a         ; an interrupt during the chain goes direct
	    push bc
	    push de
	    push hl
	    push ix                 ; event routines may use IX/IY
	    push iy
	    ex   af, af'
	    push af                 ; the program's AF'
	    exx
	    push bc                 ; the program's BC', DE', HL'
	    push de
	    push hl
	    ld   bc, (FW_BC)        ; the firmware's BC'
	    exx
	    or   a                  ; AF' (active now) carry clear
	    ex   af, af'
	    call __CPC_ISR_ORIG     ; returns with interrupts on
	    di
	    exx
	    ld   (FW_BC), bc        ; keep a ROM/mode change
	    pop  hl
	    pop  de
	    pop  bc
	    exx
	    pop  af
	    ex   af, af'            ; the program's AF' back
	    pop  iy
	    pop  ix
	    pop  hl
	    pop  de
	    pop  bc
	    xor  a
	    ld   (IN_FW), a
	    pop  af
	    ei
	    ret
; Game mode: jump to the handler in GM_VEC with HL as it was and the
	; program's AF still on the stack (the handler ends "pop af; ei; ret").
__CPC_ISR_GAME:
	    push hl
	    ld   hl, (GM_VEC)
	    ex   (sp), hl
	    ret
__CPC_ISR_DIRECT:
	    pop  af
__CPC_ISR_ORIG:
	    jp   $FFFF              ; patched by __CPC_ISR_INSTALL
	    pop namespace
#line 143 "src/lib/arch/cpc/runtime/isr.asm"
#line 37 "src/lib/arch/cpc/runtime/bootstrap.asm"
#line 1 "src/lib/arch/cpc/runtime/colour.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC -- Spectrum colours to pens, and the per-mode screen
	; variables (cpcbuild/docs/notes.md, 2026-10-01, question 4)
	;
	; INK/PAPER/BORDER take Spectrum colours 0-7 (black, blue, red,
	; magenta, green, cyan, yellow, white). A CPC mode has 2, 4 or 16 pens
	; instead, so each colour goes through PEN_MAP, a fixed per-mode table
; picking the pen whose *firmware default* colour is nearest:
	;
	;   Spectrum   0  1  2  3  4  5  6  7
;   mode 0     5  6  3  7 12  2  1  4   exact: black, bright blue, bright
	;                                       red, bright magenta, bright green,
	;                                       bright cyan, bright yellow,
	;                                       bright white
	;   mode 1     0  0  3  3  2  2  1  1   blue, yellow, cyan, red palette
	;   mode 2     0  0  0  0  1  1  1  1   blue, yellow palette (by brightness)
	;
	; So the default "white on black" is the CPC's own yellow on blue in
	; mode 1. SetInk (cpc.bas) changes a pen's colour, not this table.
	;
	; The same mode switch also sets GFX_XSHIFT (mode pixels to firmware
	; virtual coordinates, gfx.asm) and TXT_COLS (print.asm/sposn.asm), and
	; forgets the graphics pen/write-mode cache (gfx.asm), since the
	; firmware's mode change resets its graphics state.
	    push namespace core
	; __CPC_SET_MODE_VARS -- A = screen mode (0-3; 3 is the undocumented
	; 4-pen 160x200 hardware mode, treated as mode 0 geometry with mode 1
	; pens). Loads PEN_MAP, GFX_XSHIFT and TXT_COLS for that mode and marks
	; the graphics pen/mode cache unknown. Called by the bootstrap (mode 1)
	; and by cpc.bas's Mode after SCR_SET_MODE.
; Firmware entry called: none (memory only).
; Registers clobbered: AF, BC, DE, HL.
__CPC_SET_MODE_VARS:
	    PROC
	    LOCAL __SMV_MAPS, __SMV_PARAMS
	    and  3
	    ld   l, a
	    ld   h, 0
	    add  hl, hl
	    add  hl, hl
	    add  hl, hl             ; HL = mode * 8
	    ld   de, __SMV_MAPS
	    add  hl, de
	    ld   de, PEN_MAP
	    ld   bc, 8
	    ldir                    ; A (the mode) survives
	    add  a, a
	    ld   e, a
	    ld   d, 0
	    ld   hl, __SMV_PARAMS
	    add  hl, de
	    ld   a, (hl)
	    ld   (GFX_XSHIFT), a
	    inc  hl
	    ld   a, (hl)
	    ld   (TXT_COLS), a
	    ld   a, $FF
	    ld   (GRA_PEN_CUR), a
	    ld   (GRA_MODE_CUR), a
	    ret
__SMV_MAPS:
	    DEFB 5, 6, 3, 7, 12, 2, 1, 4    ; mode 0
	    DEFB 0, 0, 3, 3, 2, 2, 1, 1     ; mode 1
	    DEFB 0, 0, 0, 0, 1, 1, 1, 1     ; mode 2
	    DEFB 0, 0, 3, 3, 2, 2, 1, 1     ; mode 3
__SMV_PARAMS:                       ; GFX_XSHIFT, TXT_COLS
    DEFB 2, 20                      ; mode 0: 160 pixels, 20 columns
    DEFB 1, 40                      ; mode 1: 320 pixels, 40 columns
    DEFB 0, 80                      ; mode 2: 640 pixels, 80 columns
	    DEFB 2, 20                      ; mode 3
	    ENDP
	; __INK_TO_PEN -- A = Spectrum colour (bits 0-2 used) -> A = pen of the
	; current mode.
; Firmware entry called: none.
; Registers clobbered: AF.
__INK_TO_PEN:
	    push hl
	    and  7
	    ld   hl, PEN_MAP
	    add  a, l
	    ld   l, a
	    adc  a, h
	    sub  l
	    ld   h, a
	    ld   a, (hl)
	    pop  hl
	    ret
	    pop namespace
#line 38 "src/lib/arch/cpc/runtime/bootstrap.asm"
	    push namespace core
	; CPC_INIT_00_BOOTSTRAP -- captures FW_BC, zero-fills the private
	; runtime block ($9E00-$A1FF, .core.CPC_PRIV_BASE for
	; .core.CPC_PRIV_SIZE bytes), installs the interrupt front-end, sets the
	; few sysvars that need a non-zero default, then sets screen MODE 1
	; through the firmware gate (which turns interrupts on for good).
	;
	; FW_BC is captured first, before the zero-fill, but can't be written
	; to its sysvar slot yet -- that slot is about to be zeroed along with
; the rest of the block. So it's parked on the stack (already valid:
	; the prologue sets SP before calling #init routines) and only written
	; out to FW_BC once the zero-fill is done.
	;
; Firmware entry called: SCR_SET_MODE (&BC0E, via the gate, once
	; FW_BC/IN_FW exist) -- see fwcall.asm for what that call clobbers.
; Registers clobbered: AF, BC, DE, HL (and, transiently, BC'/DE'/HL').
CPC_INIT_00_BOOTSTRAP:
	    PROC
	    ; Capture the firmware's BC' immediately -- see the header above
	    ; and fwcall.asm's contract. Parked on the stack, not yet in FW_BC.
	    exx
	    push bc
	    exx
	    ; Zero-fill the whole private block; sysvars set below simply
	    ; overwrite their own zeroed slot. This also zeroes FW_BC's and
	    ; IN_FW's slots -- the captured value is still safe on the stack.
	    ld   hl, .core.CPC_PRIV_BASE
	    ld   (hl), 0
	    ld   de, .core.CPC_PRIV_BASE + 1
	    ld   bc, .core.CPC_PRIV_SIZE - 1
	    ldir
	    ; Now write the captured FW_BC out to its (freshly-zeroed) slot.
	    ; IN_FW stays 0, which the zero-fill already set.
	    pop  bc
	    ld   (FW_BC), bc
	    ; Our interrupt front-end (isr.asm) goes in before anything enables
    ; interrupts: the first firmware call below returns with them on,
	    ; and they stay on from then on.
	    call __CPC_ISR_INSTALL
    ; ERR_NR: -1 means "no error", not 0 (matches the ZX Spectrum manual's
	    ; convention).
	    ld   a, $FF
	    ld   (ERR_NR), a
    ; Initial permanent attribute: INK 7 / PAPER 0 (white on black), which
	    ; colour.asm maps to the firmware's own default pens, pen 1 on pen 0
	    ; in mode 1 (yellow on blue). Set here, not by print.asm, because
	    ; PLOT/DRAW/CIRCLE use it too in programs that never PRINT; left at 0
	    ; it would be black on black, i.e. invisible.
	    ld   a, 7
	    ld   (ATTR_P), a
    ; SCREEN_ADDR: mode 1 screen base. SCREEN_ATTR_ADDR is left zeroed --
	    ; see the placeholder note in sysvars.asm.
	    ld   hl, $C000
	    ld   (SCREEN_ADDR), hl
	    ; Cursor at the top-left of the text window.
	    ld   hl, 0
	    ld   (S_POSN), hl
	    ; Screen mode 1 (40x25, 4 colours). SCR_SET_MODE also resets the
	    ; text/graphics windows to full-screen, the graphics origin, and
	    ; the current stream -- and, confirmed in the emulator (see
	    ; cpc-port-notes.md Phase 2 results), clears the screen and homes
	    ; the firmware's own text cursor, even though the Firmware Guide's
	    ; own entry for &BC0E doesn't spell that out explicitly.
	    ld   a, 1
	    call .core.__FW_CALL
	    defw $BC0E
	    ld   a, 1
    call __CPC_SET_MODE_VARS    ; colour.asm: pen map, widths for mode 1
    ; Empty the key buffer: the RETURN that submitted RUN"<prog> can
	    ; still be in it, and the first INKEY$ or PAUSE would see it.
	    jp   __CPC_FLUSH_KEYS
	    ENDP
	; __CPC_FLUSH_KEYS -- discards every character waiting in the firmware's
	; key buffer. KM_FLUSH (&BD3D) does this on the 664/6128 only, so this
	; reads characters with KM_READ_CHAR (&BB09, every model) until it
	; reports none (Carry clear).
; Registers clobbered: AF (main); BC', DE', HL', AF' (the gate).
__CPC_FLUSH_KEYS:
	    call .core.__FW_CALL
	    defw $BB09
	    jr   c, __CPC_FLUSH_KEYS
	    ret
	; __CPC_WAIT_KEY -- flushes stale keys, then waits for a new keypress
	; (KM_WAIT_KEY, &BB18). END and runtime errors use it so the program's
	; last screen stays visible until a key is pressed (notes.md question 1).
; Registers clobbered: AF (main); BC', DE', HL', AF' (the gate).
__CPC_WAIT_KEY:
	    call __CPC_FLUSH_KEYS
	    call .core.__FW_CALL
	    defw $BB18
	    ret
	; __CPC_END -- the single choke point for a *clean* END (src/arch/cpc/
	; backend/generic.py's _end emits "jp .core.__CPC_END" for every END in
	; the program, instead of a bare RST 0). Reaching address 0 by itself
; doesn't prove the program reached END: a crash that happens to reset
	; the machine, or a runtime error (error.asm's __ERROR, also RST 0 after
	; printing "Error n"), lands there too. This is forced into every build
	; (bootstrap.asm is in common.REQUIRES unconditionally -- see the file
	; header), so it's the one place a distinguishing marker can live for
	; every program, not just ones that happen to #include some other file.
	;
	; Under -D __CPC_PRINTER_ECHO__ (cpcbuild's cpcrun.py test harness),
	; sends __CPC_END_MARKER -- a line containing only "\x04END" -- to the
	; printer via MC_PRINT_CHAR (&BD2B), through the gate, before the RST 0.
	; \x04 (ASCII EOT) as the first byte makes the line unlike anything a
	; Boriel program can PRINT (print.asm's control-code table drops or
	; diverts every code below 32 except 6/8/13-23) and unlike the
	; "NOT IMPLEMENTED" (stub.asm) / "Error n" (error.asm) text the same
	; transcript can otherwise contain, so cpcrun.py can grep for it
	; unambiguously and strip it from the reported transcript.
	;
	; Without the flag it waits for a key first (__CPC_WAIT_KEY), so the
	; program's output stays on screen (notes.md question 1), then resets.
	;
; Firmware entries called: MC_PRINT_CHAR (&BD2B) in printer-echo builds;
; KM_READ_CHAR/KM_WAIT_KEY otherwise. Registers clobbered: none (never
	; returns).
#line 176 "src/lib/arch/cpc/runtime/bootstrap.asm"
__CPC_END:
#line 203 "src/lib/arch/cpc/runtime/bootstrap.asm"
	    call __CPC_WAIT_KEY
	    di
	    rst  0
#line 207 "src/lib/arch/cpc/runtime/bootstrap.asm"
	    pop namespace
#line 210 "src/lib/arch/cpc/runtime/bootstrap.asm"
#line 36 "src/lib/arch/cpc/runtime/error.asm"
#line 39 "src/lib/arch/cpc/runtime/error.asm"
	    push namespace core
	; Error code definitions (as in ZX spectrum manual)
; Set error code with:
	;    ld a, ERROR_CODE
	;    ld (ERR_NR), a
	ERROR_Ok                EQU    -1
	ERROR_SubscriptWrong    EQU     2
	ERROR_OutOfMemory       EQU     3
	ERROR_OutOfScreen       EQU     4
	ERROR_NumberTooBig      EQU     5
	ERROR_InvalidArg        EQU     9
	ERROR_IntOutOfRange     EQU    10
	ERROR_NonsenseInBasic   EQU    11
	ERROR_InvalidFileName   EQU    14
	ERROR_InvalidColour     EQU    19
	ERROR_BreakIntoProgram  EQU    20
	ERROR_TapeLoadingErr    EQU    26
__ERR_STR: DEFB "Error ", 0
#line 87 "src/lib/arch/cpc/runtime/error.asm"
#line 88 "src/lib/arch/cpc/runtime/error.asm"
; Raises a runtime error: stores the code, prints "Error n" on a fresh
	; line, waits for a keypress, then resets to BASIC's Ready prompt (END's
	; own reset, generic.py's _end -- see cpc-port-notes.md Sec6.5).
	;
	; This never returns to the caller.
	;
; Firmware entries called (all through the gate): TXT_OUTPUT (&BB5A),
	; KM_READ_CHAR (&BB09) until the key buffer is empty, then KM_WAIT_KEY
; (&BB18), both via bootstrap.asm's __CPC_WAIT_KEY. (Not KM_FLUSH: that
	; is 664/6128 only, and the 464 is supported.) The flush discards
	; whatever is in the key buffer first -- most obviously the RETURN that submitted
	; RUN"<prog>" itself, which would otherwise satisfy KM_WAIT_KEY without
	; a real keypress -- so the wait below is for a new key, not a stale
	; one. Verified end to end in the emulator (cpc-port-notes.md Phase 2
; results): "Error n" prints, the machine sits at KM_WAIT_KEY, and a
	; keypress resets it to BASIC's Ready prompt. The firmware's own
	; key-scan interrupt handler fills in the keypress while we're blocked
	; inside KM_WAIT_KEY. Interrupts go off just before the reset, so our
	; &0038 vector (isr.asm) is never used while the firmware rebuilds it.
; Registers clobbered: none (never returns).
	; __ERR_SCR -- A = character to the screen only; __ERR_OUT -- to the
	; screen and, under -D __CPC_PRINTER_ECHO__, the printer. Both preserve
	; BC, DE, HL (the callers keep the error number and digits there).
	; __ERR_RESET -- the machine reset after an error.
#line 239 "src/lib/arch/cpc/runtime/error.asm"
; Firmware: TXT_OUTPUT (&BB5A, preserves every register) through the gate.
__ERR_SCR:
	    call .core.__FW_CALL
	    defw $BB5A
	    ret
__ERR_OUT:
	    call .core.__FW_CALL
	    defw $BB5A
#line 250 "src/lib/arch/cpc/runtime/error.asm"
	    ret
__ERR_RESET:
	    di
	    rst  0
#line 255 "src/lib/arch/cpc/runtime/error.asm"
__ERROR:
	    PROC
	    ld   (ERR_NR), a
	    ld   c, a           ; stash the error number (survives TXT_OUTPUT
	                        ; and the gate -- see the file header)
    ; Fresh line: CR then LF (cpc-port-notes.md Phase 2 decisions --
	    ; the same translation print.asm applies to Boriel's newline code
	    ; 13, spelled out here since the error path doesn't use print.asm).
	    ; Printer echo gets the LF only, not the CR (print.asm's decision).
	    ld   a, 13
	    call __ERR_SCR
	    ld   a, 10
	    call __ERR_OUT
	    ; "Error "
	    ld   hl, __ERR_STR
__ERROR_MSG_LOOP:
	    ld   a, (hl)
	    or   a
	    jr   z, __ERROR_MSG_DONE
	    inc  hl
	    call __ERR_OUT
	    jr   __ERROR_MSG_LOOP
__ERROR_MSG_DONE:
	    ld   a, c
	    call __PRINT_DECIMAL_A
#line 291 "src/lib/arch/cpc/runtime/error.asm"
	    ; Flush stale keys, then wait for a real one (bootstrap.asm).
	    call __CPC_WAIT_KEY
	    jp   __ERR_RESET    ; reset to BASIC's Ready prompt
#line 295 "src/lib/arch/cpc/runtime/error.asm"
	    ENDP
	; Sets the error system variable, but keeps running.
	; Usually this instruction if followed by the END intermediate instruction.
__STOP:
	    ld (ERR_NR), a
	    ret
	; __PRINT_DECIMAL_A -- prints A (0-255) in decimal via TXT_OUTPUT,
	; through the gate, with no leading zeros ("0" alone for zero). A tiny
; local printer: error.asm deliberately doesn't pull in print.asm (see
	; the file header), and the alternative -- str.asm's %d-style formatter
	; -- is built on print.asm too.
	;
	; TXT_OUTPUT (and the gate around it) preserve every register, so B/C/D/E
	; are usable as plain scratch across each individual call below.
; Registers clobbered: AF, BC, DE, HL.
__PRINT_DECIMAL_A:
	    PROC
	    LOCAL __PDA_DIGIT, __PDA_SUB, __PDA_DONE, __PDA_SKIP
	    ld   d, 0            ; D = 1 once a non-zero digit has been printed
	    ld   b, 100
	    call __PDA_DIGIT
	    ld   b, 10
	    call __PDA_DIGIT
	    ld   b, 1
	    ld   d, 1            ; the units digit always prints, even if 0
	    call __PDA_DIGIT
	    ret
	; A = remaining value (in/out), B = place value (in), D = "seen a
	; digit yet" flag (in/out). C is scratch.
__PDA_DIGIT:
	    ld   c, 0
__PDA_SUB:
	    cp   b
	    jr   c, __PDA_DONE
	    sub  b
	    inc  c
	    jr   __PDA_SUB
__PDA_DONE:
	    ld   e, a            ; stash the remainder (survives the gate call)
	    ld   a, c
	    or   d
	    jr   z, __PDA_SKIP    ; no digit seen yet and this one is 0 -- skip
	    ld   d, 1
	    ld   a, c
	    add  a, '0'
	    call __ERR_OUT
__PDA_SKIP:
	    ld   a, e             ; remainder becomes the input for the next digit
	    ret
	    ENDP
	    pop namespace
#line 24 "src/lib/arch/cpc/runtime/fp_calc.asm"
	; Included unconditionally by any FP runtime file (not only when the
; program declares FLOAT), so it must be self-sufficient: stackf.asm
	; (source of __FPSTACK_PUSH/__FPSTACK_POP) is included here rather than
	; relying on the includer to do it too.
	; CPC_INIT_FP_CALC -- writes `jp FP_CALC_ENTRY` at &0030-&0032 (so every
	; `rst 30h` in the FP runtime files reaches FP_CALC_ENTRY below -- &0000-
	; &003F is ordinary RAM while the lower ROM is paged out, see
	; cpc-port-notes.md Sec6.2) and points the calculator's own sysvars at
	; their buffers in the private block (sysvars.asm). Both are safe to (re)do
; here even though CPC_INIT_00_BOOTSTRAP already zero-filled the block:
	; this #init sorts after it (see bootstrap.asm's naming note).
; Firmware entry called: none. Registers clobbered: AF, HL.
	    push namespace core
	; CPC_RST6_VECTOR is the fixed address of the RST 6 vector itself, not a
; relocatable name: RST 6 always executes the 3 bytes at &0030, wherever
	; this file happens to be assembled into the program.
	CPC_RST6_VECTOR EQU $0030
	; ---------------------------------------------------------------------------
	; Entry point -- replaces RST $28h (reached via `rst 30h`, RST 6)
	; ---------------------------------------------------------------------------
FP_CALC_ENTRY:
	    jp L335B
CPC_INIT_FP_CALC:
	    PROC
	    ld   hl, FP_CALC_ENTRY
	    ld   a, $C3        ; JP opcode
	    ld   (CPC_RST6_VECTOR), a
	    ld   (CPC_RST6_VECTOR + 1), hl
	    ld   hl, FP_CALC_STACK
	    ld   (FP_STKBOT), hl
	    ld   (FP_STKEND), hl
	    ld   hl, FP_MEM_AREA
	    ld   (FP_MEM), hl
	    ret
	    ENDP
	; ---------------------------------------------------------------------------
	; Our own TEST-ROOM -- replaces TEST-ROOM ($1F05, which checked free space
	; against the SP stack pointer). Here the FP number stack is a fixed
	; buffer (FP_CALC_STACK..FP_CALC_STACK_END in sysvars.asm), so this only
	; has to check that FP_STKEND + BC stays inside it.
; Input: BC = bytes required. Exits with BC intact if there is room.
	; ---------------------------------------------------------------------------
CALC_TEST_ROOM:
	    push hl
	    push de
	    ld   hl, (FP_STKEND)
	    add  hl, bc
	    ld   de, FP_CALC_STACK_END
	    or   a
	    sbc  hl, de
	    pop  de
	    pop  hl
	    jr   c, CALC_TEST_ROOM_OK
	    ld   a, ERROR_OutOfMemory
	    jp   __ERROR
CALC_TEST_ROOM_OK:
	    ret
	; ---------------------------------------------------------------------------
	; THE 'TEST FIVE SPACES' SUBROUTINE ($33A9 TEST-5-SP)
	; ---------------------------------------------------------------------------
L33A9:
	    push de
	    push hl
	    ld   bc, 5
	    call CALC_TEST_ROOM
	    pop  hl
	    pop  de
	    ret
	; ---------------------------------------------------------------------------
	; STACK-NUM ($33B4) -- pushes a 5-byte number pointed to by HL
	; ---------------------------------------------------------------------------
L33B4:
	    ld   de, (FP_STKEND)
	    call L33C0
	    ld   (FP_STKEND), de
	    ret
	; ---------------------------------------------------------------------------
	; MOVE-FP / duplicate (literal $31, $33C0)
	; ---------------------------------------------------------------------------
L33C0:
	    call L33A9
	    ldir
	    ret
	; ---------------------------------------------------------------------------
	; stk-data (literal $34, $33C6) / STK-CONST ($33C8) / STK-ZEROS ($33F1)
	; ---------------------------------------------------------------------------
L33C6:
	    ld   h, d
	    ld   l, e
L33C8:
	    call L33A9
	    exx
	    push hl
	    exx
	    ex   (sp), hl
	    push bc
	    ld   a, (hl)
	    and  $C0
	    rlca
	    rlca
	    ld   c, a
	    inc  c
	    ld   a, (hl)
	    and  $3F
	    jr   nz, L33DE
	    inc  hl
	    ld   a, (hl)
L33DE:
	    add  a, $50
	    ld   (de), a
	    ld   a, 5
	    sub  c
	    inc  hl
	    inc  de
	    ld   b, 0
	    ldir
	    pop  bc
	    ex   (sp), hl
	    exx
	    pop  hl
	    exx
	    ld   b, a
	    xor  a
L33F1:
	    dec  b
	    ret  z
	    ld   (de), a
	    inc  de
	    jr   L33F1
	; ---------------------------------------------------------------------------
	; SKIP-CONS ($33F7 / $33F8)
	; ---------------------------------------------------------------------------
L33F7:
	    and  a
L33F8:
	    ret  z
	    push af
	    push de
	    ld   de, 0
	    call L33C8
	    pop  de
	    pop  af
	    dec  a
	    jr   L33F8
	; ---------------------------------------------------------------------------
	; LOC-MEM ($3406)
	; ---------------------------------------------------------------------------
L3406:
	    ld   c, a
	    rlca
	    rlca
	    add  a, c
	    ld   c, a
	    ld   b, 0
	    add  hl, bc
	    ret
	; ---------------------------------------------------------------------------
	; get-mem-xx (literales $E0-$FF, $340F)
	; ---------------------------------------------------------------------------
L340F:
	    push de
	    ld   hl, (FP_MEM)
	    call L3406
	    call L33C0
	    pop  hl
	    ret
	; ---------------------------------------------------------------------------
	; stk-const-xx (literales $A0-$BF, $341B) + tabla de constantes
	; ---------------------------------------------------------------------------
L341B:
	    ld   h, d
	    ld   l, e
	    exx
	    push hl
	    ld   hl, L32C5
	    exx
	    call L33F7
	    call L33C8
	    exx
	    pop  hl
	    exx
	    ret
	; ---------------------------------------------------------------------------
	; st-mem-xx (literales $C0-$DF, $342D)
	; ---------------------------------------------------------------------------
L342D:
	    push hl
	    ex   de, hl
	    ld   hl, (FP_MEM)
	    call L3406
	    ex   de, hl
	    call L33C0
	    ex   de, hl
	    pop  hl
	    ret
	; ---------------------------------------------------------------------------
	; exchange (literal $01, $343C)
	; ---------------------------------------------------------------------------
L343C:
	    ld   b, 5
L343E:
	    ld   a, (de)
	    ld   c, (hl)
	    ex   de, hl
	    ld   (de), a
	    ld   (hl), c
	    inc  hl
	    inc  de
	    djnz L343E
	    ex   de, hl
	    ret
	; ---------------------------------------------------------------------------
	; series generator (literals $80-$9F, $3449) -- used by SIN/COS/EXP/LN/etc,
	; each supplying its own coefficient table (see FASE 4 below)
	; ---------------------------------------------------------------------------
L3449:
	    ld   b, a
	    call L335E
	    defb $31            ;;duplicate       x,x
	    defb $0F            ;;addition        x+x
	    defb $C0            ;;st-mem-0        x+x
	    defb $02            ;;delete          .
	    defb $A0            ;;stk-zero        0
	    defb $C2            ;;st-mem-2        0
L3453:
	    defb $31            ;;duplicate       v,v.
	    defb $E0            ;;get-mem-0       v,v,x+2
	    defb $04            ;;multiply        v,v*x+2
	    defb $E2            ;;get-mem-2       v,v*x+2,v
	    defb $C1            ;;st-mem-1
	    defb $03            ;;subtract
	    defb $38            ;;end-calc
	    call L33C6
	    call L3362
	    defb $0F            ;;addition
	    defb $01            ;;exchange
	    defb $C2            ;;st-mem-2
	    defb $02            ;;delete
	    defb $35            ;;dec-jr-nz
	    defb (L3453 - $) & 0FFh   ;;back to G-LOOP
	    defb $E1            ;;get-mem-1
	    defb $03            ;;subtract
	    defb $38            ;;end-calc
	    ret
	; ---------------------------------------------------------------------------
	; abs (literal $2A, $346A) / negate (literal $1B, $346E) / sgn (literal $29,
	; $3492)
	; ---------------------------------------------------------------------------
L346A:
	    ld   b, $FF
	    jr   L3474
L346E:
	    call L34E9
	    ret  c
	    ld   b, 0
L3474:
	    ld   a, (hl)
	    and  a
	    jr   z, L3483
	    inc  hl
	    ld   a, b
	    and  $80
	    or   (hl)
	    rla
	    ccf
	    rra
	    ld   (hl), a
	    dec  hl
	    ret
L3483:
	    push de
	    push hl
	    call L2D7F
	    pop  hl
	    ld   a, b
	    or   c
	    cpl
	    ld   c, a
	    call L2D8E
	    pop  de
	    ret
L3492:
	    call L34E9
	    ret  c
	    push de
	    ld   de, 1
	    inc  hl
	    rl   (hl)
	    dec  hl
	    sbc  a, a
	    ld   c, a
	    call L2D8E
	    pop  de
	    ret
	; ---------------------------------------------------------------------------
	; INT-FETCH ($2D7F) / INT-STORE ($2D8E)
	; ---------------------------------------------------------------------------
L2D7F:
	    inc  hl
	    ld   c, (hl)
	    inc  hl
	    ld   a, (hl)
	    xor  c
	    sub  c
	    ld   e, a
	    inc  hl
	    ld   a, (hl)
	    adc  a, c
	    xor  c
	    ld   d, a
	    ret
L2D8E:
	    push hl
	    ld   (hl), 0
	    inc  hl
	    ld   (hl), c
	    inc  hl
	    ld   a, e
	    xor  c
	    sub  c
	    ld   (hl), a
	    inc  hl
	    ld   a, d
	    adc  a, c
	    xor  c
	    ld   (hl), a
	    inc  hl
	    ld   (hl), 0
	    pop  hl
	    ret
	; ---------------------------------------------------------------------------
	; PREP-ADD ($2F9B)
	; ---------------------------------------------------------------------------
L2F9B:
	    ld   a, (hl)
	    ld   (hl), 0
	    and  a
	    ret  z
	    inc  hl
	    bit  7, (hl)
	    set  7, (hl)
	    dec  hl
	    ret  z
	    push bc
	    ld   bc, 5
	    add  hl, bc
	    ld   b, c
	    ld   c, a
	    scf
L2FAF:
	    dec  hl
	    ld   a, (hl)
	    cpl
	    adc  a, 0
	    ld   (hl), a
	    djnz L2FAF
	    ld   a, c
	    pop  bc
	    ret
	; ---------------------------------------------------------------------------
	; FETCH-TWO ($2FBA)
	; ---------------------------------------------------------------------------
L2FBA:
	    push hl
	    push af
	    ld   c, (hl)
	    inc  hl
	    ld   b, (hl)
	    ld   (hl), a
	    inc  hl
	    ld   a, c
	    ld   c, (hl)
	    push bc
	    inc  hl
	    ld   c, (hl)
	    inc  hl
	    ld   b, (hl)
	    ex   de, hl
	    ld   d, a
	    ld   e, (hl)
	    push de
	    inc  hl
	    ld   d, (hl)
	    inc  hl
	    ld   e, (hl)
	    push de
	    exx
	    pop  de
	    pop  hl
	    pop  bc
	    exx
	    inc  hl
	    ld   d, (hl)
	    inc  hl
	    ld   e, (hl)
	    pop  af
	    pop  hl
	    ret
	; ---------------------------------------------------------------------------
	; SHIFT-FP ($2FDD) / ADD-BACK ($3004)
	; ---------------------------------------------------------------------------
L2FDD:
	    and  a
	    ret  z
	    cp   $21
	    jr   nc, L2FF9
	    push bc
	    ld   b, a
L2FE5:
	    exx
	    sra  l
	    rr   d
	    rr   e
	    exx
	    rr   d
	    rr   e
	    djnz L2FE5
	    pop  bc
	    ret  nc
	    call L3004
	    ret  nz
L2FF9:
	    exx
	    xor  a
L2FFB:
	    ld   l, 0
	    ld   d, a
	    ld   e, l
	    exx
	    ld   de, 0
	    ret
L3004:
	    inc  e
	    ret  nz
	    inc  d
	    ret  nz
	    exx
	    inc  e
	    jr   nz, L300D
	    inc  d
L300D:
	    exx
	    ret
	; ---------------------------------------------------------------------------
	; subtract (literal $03, $300F) / addition (literal $0F, $3014)
	; ---------------------------------------------------------------------------
L300F:
	    ex   de, hl
	    call L346E
	    ex   de, hl
L3014:
	    ld   a, (de)
	    or   (hl)
	    jr   nz, L303E
	    push de
	    inc  hl
	    push hl
	    inc  hl
	    ld   e, (hl)
	    inc  hl
	    ld   d, (hl)
	    inc  hl
	    inc  hl
	    inc  hl
	    ld   a, (hl)
	    inc  hl
	    ld   c, (hl)
	    inc  hl
	    ld   b, (hl)
	    pop  hl
	    ex   de, hl
	    add  hl, bc
	    ex   de, hl
	    adc  a, (hl)
	    rrca
	    adc  a, 0
	    jr   nz, L303C
	    sbc  a, a
	    ld   (hl), a
	    inc  hl
	    ld   (hl), e
	    inc  hl
	    ld   (hl), d
	    dec  hl
	    dec  hl
	    dec  hl
	    pop  de
	    ret
L303C:
	    dec  hl
	    pop  de
L303E:
	    call L3293
	    exx
	    push hl
	    exx
	    push de
	    push hl
	    call L2F9B
	    ld   b, a
	    ex   de, hl
	    call L2F9B
	    ld   c, a
	    cp   b
	    jr   nc, L3055
	    ld   a, b
	    ld   b, c
	    ex   de, hl
L3055:
	    push af
	    sub  b
	    call L2FBA
	    call L2FDD
	    pop  af
	    pop  hl
	    ld   (hl), a
	    push hl
	    ld   l, b
	    ld   h, c
	    add  hl, de
	    exx
	    ex   de, hl
	    adc  hl, bc
	    ex   de, hl
	    ld   a, h
	    adc  a, l
	    ld   l, a
	    rra
	    xor  l
	    exx
	    ex   de, hl
	    pop  hl
	    rra
	    jr   nc, L307C
	    ld   a, 1
	    call L2FDD
	    inc  (hl)
	    jr   z, L309F
L307C:
	    exx
	    ld   a, l
	    and  $80
	    exx
	    inc  hl
	    ld   (hl), a
	    dec  hl
	    jr   z, L30A5
	    ld   a, e
	    neg
	    ccf
	    ld   e, a
	    ld   a, d
	    cpl
	    adc  a, 0
	    ld   d, a
	    exx
	    ld   a, e
	    cpl
	    adc  a, 0
	    ld   e, a
	    ld   a, d
	    cpl
	    adc  a, 0
	    jr   nc, L30A3
	    rra
	    exx
	    inc  (hl)
L309F:
	    jp   z, L31AD
	    exx
L30A3:
	    ld   d, a
	    exx
L30A5:
	    xor  a
	    jp   L3155
	; ---------------------------------------------------------------------------
	; HL-HL*DE ($30A9) / PREP-M/D ($30C0)
	; ---------------------------------------------------------------------------
L30A9:
	    push bc
	    ld   b, 16
	    ld   a, h
	    ld   c, l
	    ld   hl, 0
L30B1:
	    add  hl, hl
	    jr   c, L30BE
	    rl   c
	    rla
	    jr   nc, L30BC
	    add  hl, de
	    jr   c, L30BE
L30BC:
	    djnz L30B1
L30BE:
	    pop  bc
	    ret
L30C0:
	    call L34E9
	    ret  c
	    inc  hl
	    xor  (hl)
	    set  7, (hl)
	    dec  hl
	    ret
	; ---------------------------------------------------------------------------
	; multiply (literal $04, $30CA)
	; ---------------------------------------------------------------------------
L30CA:
	    ld   a, (de)
	    or   (hl)
	    jr   nz, L30F0
	    push de
	    push hl
	    push de
	    call L2D7F
	    ex   de, hl
	    ex   (sp), hl
	    ld   b, c
	    call L2D7F
	    ld   a, b
	    xor  c
	    ld   c, a
	    pop  hl
	    call L30A9
	    ex   de, hl
	    pop  hl
	    jr   c, L30EF
	    ld   a, d
	    or   e
	    jr   nz, L30EA
	    ld   c, a
L30EA:
	    call L2D8E
	    pop  de
	    ret
L30EF:
	    pop  de
L30F0:
	    call L3293
	    xor  a
	    call L30C0
	    ret  c
	    exx
	    push hl
	    exx
	    push de
	    ex   de, hl
	    call L30C0
	    ex   de, hl
	    jr   c, L315D
	    push hl
	    call L2FBA
	    ld   a, b
	    and  a
	    sbc  hl, hl
	    exx
	    push hl
	    sbc  hl, hl
	    exx
	    ld   b, $21
	    jr   L3125
L3114:
	    jr   nc, L311B
	    add  hl, de
	    exx
	    adc  hl, de
	    exx
L311B:
	    exx
	    rr   h
	    rr   l
	    exx
	    rr   h
	    rr   l
L3125:
	    exx
	    rr   b
	    rr   c
	    exx
	    rr   c
	    rra
	    djnz L3114
	    ex   de, hl
	    exx
	    ex   de, hl
	    exx
	    pop  bc
	    pop  hl
	    ld   a, b
	    add  a, c
	    jr   nz, L313B
	    and  a
L313B:
	    dec  a
	    ccf
L313D:
	    rla
	    ccf
	    rra
	    jp   p, L3146
	    jr   nc, L31AD
	    and  a
L3146:
	    inc  a
	    jr   nz, L3151
	    jr   c, L3151
	    exx
	    bit  7, d
	    exx
	    jr   nz, L31AD
L3151:
	    ld   (hl), a
	    exx
	    ld   a, b
	    exx
L3155:
	    jr   nc, L316C
	    ld   a, (hl)
	    and  a
L3159:
	    ld   a, $80
	    jr   z, L315E
L315D:
	    xor  a
L315E:
	    exx
	    and  d
	    call L2FFB
	    rlca
	    ld   (hl), a
	    jr   c, L3195
	    inc  hl
	    ld   (hl), a
	    dec  hl
	    jr   L3195
L316C:
	    ld   b, $20
L316E:
	    exx
	    bit  7, d
	    exx
	    jr   nz, L3186
	    rlca
	    rl   e
	    rl   d
	    exx
	    rl   e
	    rl   d
	    exx
	    dec  (hl)
	    jr   z, L3159
	    djnz L316E
	    jr   L315D
L3186:
	    rla
	    jr   nc, L3195
	    call L3004
	    jr   nz, L3195
	    exx
	    ld   d, $80
	    exx
	    inc  (hl)
	    jr   z, L31AD
L3195:
	    push hl
	    inc  hl
	    exx
	    push de
	    exx
	    pop  bc
	    ld   a, b
	    rla
	    rl   (hl)
	    rra
	    ld   (hl), a
	    inc  hl
	    ld   (hl), c
	    inc  hl
	    ld   (hl), d
	    inc  hl
	    ld   (hl), e
	    pop  hl
	    pop  de
	    exx
	    pop  hl
	    exx
	    ret
L31AD:
	    ld   a, ERROR_NumberTooBig
	    jp   __ERROR
	; ---------------------------------------------------------------------------
	; division (literal $05, $31AF)
	; ---------------------------------------------------------------------------
L31AF:
	    call L3293
	    ex   de, hl
	    xor  a
	    call L30C0
	    jr   c, L31AD
	    ex   de, hl
	    call L30C0
	    ret  c
	    exx
	    push hl
	    exx
	    push de
	    push hl
	    call L2FBA
	    exx
	    push hl
	    ld   h, b
	    ld   l, c
	    exx
	    ld   h, c
	    ld   l, b
	    xor  a
	    ld   b, $DF
	    jr   L31E2
L31D2:
	    rla
	    rl   c
	    exx
	    rl   c
	    rl   b
	    exx
L31DB:
	    add  hl, hl
	    exx
	    adc  hl, hl
	    exx
	    jr   c, L31F2
L31E2:
	    sbc  hl, de
	    exx
	    sbc  hl, de
	    exx
	    jr   nc, L31F9
	    add  hl, de
	    exx
	    adc  hl, de
	    exx
	    and  a
	    jr   L31FA
L31F2:
	    and  a
	    sbc  hl, de
	    exx
	    sbc  hl, de
	    exx
L31F9:
	    scf
L31FA:
	    inc  b
	    jp   m, L31D2
	    push af
	    jr   z, L31E2
	    ld   e, a
	    ld   d, c
	    exx
	    ld   e, c
	    ld   d, b
	    pop  af
	    rr   b
	    pop  af
	    rr   b
	    exx
	    pop  bc
	    pop  hl
	    ld   a, b
	    sub  c
	    jp   L313D
	; ---------------------------------------------------------------------------
	; Integer truncation towards zero (literal $3A, $3214)
	; ---------------------------------------------------------------------------
L3214:
	    ld   a, (hl)
	    and  a
	    ret  z
	    cp   $81
	    jr   nc, L3221
	    ld   (hl), 0
	    ld   a, $20
	    jr   L3272
L3221:
	    cp   $91
	    jr   nz, L323F
	    inc  hl
	    inc  hl
	    inc  hl
	    ld   a, $80
	    and  (hl)
	    dec  hl
	    or   (hl)
	    dec  hl
	    jr   nz, L3233
	    ld   a, $80
	    xor  (hl)
L3233:
	    dec  hl
	    jr   nz, L326C
	    ld   (hl), a
	    inc  hl
	    ld   (hl), $FF
	    dec  hl
	    ld   a, $18
	    jr   L3272
L323F:
	    jr   nc, L326D
	    push de
	    cpl
	    add  a, $91
	    inc  hl
	    ld   d, (hl)
	    inc  hl
	    ld   e, (hl)
	    dec  hl
	    dec  hl
	    ld   c, 0
	    bit  7, d
	    jr   z, L3252
	    dec  c
L3252:
	    set  7, d
	    ld   b, 8
	    sub  b
	    add  a, b
	    jr   c, L325E
	    ld   e, d
	    ld   d, 0
	    sub  b
L325E:
	    jr   z, L3267
	    ld   b, a
L3261:
	    srl  d
	    rr   e
	    djnz L3261
L3267:
	    call L2D8E
	    pop  de
	    ret
L326C:
	    ld   a, (hl)
L326D:
	    sub  $A0
	    ret  p
	    neg
L3272:
	    push de
	    ex   de, hl
	    dec  hl
	    ld   b, a
	    srl  b
	    srl  b
	    srl  b
	    jr   z, L3283
L327E:
	    ld   (hl), 0
	    dec  hl
	    djnz L327E
L3283:
	    and  $07
	    jr   z, L3290
	    ld   b, a
	    ld   a, $FF
L328A:
	    sla  a
	    djnz L328A
	    and  (hl)
	    ld   (hl), a
L3290:
	    ex   de, hl
	    pop  de
	    ret
	; ---------------------------------------------------------------------------
	; RE-ST-TWO ($3293) / RESTK-SUB ($3296) / re-stack (literal $3D, $3297)
	; ---------------------------------------------------------------------------
L3293:
	    call L3296
L3296:
	    ex   de, hl
L3297:
	    ld   a, (hl)
	    and  a
	    ret  nz
	    push de
	    call L2D7F
	    xor  a
	    inc  hl
	    ld   (hl), a
	    dec  hl
	    ld   (hl), a
	    ld   b, $91
	    ld   a, d
	    and  a
	    jr   nz, L32B1
	    or   e
	    ld   b, d
	    jr   z, L32BD
	    ld   d, e
	    ld   e, b
	    ld   b, $89
L32B1:
	    ex   de, hl
L32B2:
	    dec  b
	    add  hl, hl
	    jr   nc, L32B2
	    rrc  c
	    rr   h
	    rr   l
	    ex   de, hl
L32BD:
	    dec  hl
	    ld   (hl), e
	    dec  hl
	    ld   (hl), d
	    dec  hl
	    ld   (hl), b
	    pop  de
	    ret
	; ---------------------------------------------------------------------------
	; THE 'TABLE OF CONSTANTS' ($32C5-$32D6)
	; ---------------------------------------------------------------------------
L32C5:  ;;stk-zero
	    defb $00, $B0, $00
L32C8:  ;;stk-one
	    defb $40, $B0, $00, $01
L32CC:  ;;stk-half
	    defb $30, $00
L32CE:  ;;stk-pi/2
	    defb $F1, $49, $0F, $DA, $A2
L32D3:  ;;stk-ten
	    defb $40, $B0, $00, $0A
	; ---------------------------------------------------------------------------
	; THE 'TABLE OF ADDRESSES' ($32D7) -- tbl-addrs
	;
	; Entries for unsupported operations (strings, USR, PEEK, IN, CODE, LEN,
	; READ-IN, VAL$) point at CALC_UNSUPPORTED, which raises a clear error if
; that literal is ever generated (it shouldn't be: the ZX BASIC compiler
	; never emits these literals for this runtime -- see the literals actually
	; used across arith/cmp/bool/math/*.asm).
	; ---------------------------------------------------------------------------
L32D7:
	    defw L368F         ; $00 jump-true
	    defw L343C         ; $01 exchange
	    defw L33A1         ; $02 delete
	    defw L300F         ; $03 subtract
	    defw L30CA         ; $04 multiply
	    defw L31AF         ; $05 division
	    defw L3851          ; $06 to-power
	    defw L351B         ; $07 or
	    defw L3524         ; $08 no-&-no
	    defw L353B         ; $09 no-l-eql
	    defw L353B         ; $0A no-gr-eql
	    defw L353B         ; $0B nos-neql
	    defw L353B         ; $0C no-grtr
	    defw L353B         ; $0D no-less
	    defw L353B         ; $0E nos-eql
	    defw L3014         ; $0F addition
	    defw CALC_UNSUPPORTED ; $10 str-&-no
	    defw CALC_UNSUPPORTED ; $11 str-l-eql
	    defw CALC_UNSUPPORTED ; $12 str-gr-eql
	    defw CALC_UNSUPPORTED ; $13 strs-neql
	    defw CALC_UNSUPPORTED ; $14 str-grtr
	    defw CALC_UNSUPPORTED ; $15 str-less
	    defw CALC_UNSUPPORTED ; $16 strs-eql
	    defw CALC_UNSUPPORTED ; $17 strs-add
	    defw CALC_UNSUPPORTED ; $18 val$
	    defw CALC_UNSUPPORTED ; $19 usr-$
	    defw CALC_UNSUPPORTED ; $1A read-in
	    defw L346E          ; $1B negate
	    defw CALC_UNSUPPORTED ; $1C code
    defw CALC_UNSUPPORTED ; $1D val (pendiente: parseo numerico propio)
	    defw CALC_UNSUPPORTED ; $1E len
	    defw L37B5          ; $1F sin
	    defw L37AA          ; $20 cos
	    defw L37DA          ; $21 tan
	    defw L3833          ; $22 asn
	    defw L3843          ; $23 acs
	    defw L37E2          ; $24 atn
	    defw L3713          ; $25 ln
	    defw L36C4          ; $26 exp
	    defw L36AF          ; $27 int
	    defw L384A          ; $28 sqr
	    defw L3492          ; $29 sgn
	    defw L346A          ; $2A abs
	    defw CALC_UNSUPPORTED ; $2B peek
	    defw CALC_UNSUPPORTED ; $2C in
	    defw CALC_UNSUPPORTED ; $2D usr-no
	    defw CALC_UNSUPPORTED ; $2E str$ (pendiente)
	    defw CALC_UNSUPPORTED ; $2F chr$
	    defw L3501          ; $30 not
	    defw L33C0          ; $31 duplicate
	    defw L36A0          ; $32 n-mod-m
	    defw L3686          ; $33 jump
	    defw L33C6          ; $34 stk-data
	    defw L367A          ; $35 dec-jr-nz
	    defw L3506          ; $36 less-0
	    defw L34F9          ; $37 greater-0
	    defw L369B          ; $38 end-calc
	    defw L3783          ; $39 get-argt
	    defw L3214          ; $3A truncate
	    defw L33A2          ; $3B fp-calc-2
	    defw CALC_UNSUPPORTED ; $3C e-to-fp
	    defw L3297          ; $3D re-stack
	    defw L3449          ; series-xx    $80-$9F
	    defw L341B          ; stk-const-xx $A0-$BF
	    defw L342D          ; st-mem-xx    $C0-$DF
	    defw L340F          ; get-mem-xx   $E0-$FF
CALC_UNSUPPORTED:
	    ld   a, ERROR_InvalidArg
	    jp   __ERROR
	; ---------------------------------------------------------------------------
	; THE 'CALCULATE' SUBROUTINE ($335B) -- main engine
	; ---------------------------------------------------------------------------
L335B:
	    call L35BF
L335E:
	    ld   a, b
	    ld   (FP_BREG), a
L3362:
	    exx
	    ex   (sp), hl
	    exx
L3365:
	    ld   (FP_STKEND), de
	    exx
	    ld   a, (hl)
	    inc  hl
L336C:
	    push hl
	    and  a
	    jp   p, L3380
	    ld   d, a
	    and  $60
	    rrca
	    rrca
	    rrca
	    rrca
	    add  a, $7C
	    ld   l, a
	    ld   a, d
	    and  $1F
	    jr   L338E
L3380:
	    cp   $18
	    jr   nc, L338C
	    exx
	    ld   bc, $FFFB
	    ld   d, h
	    ld   e, l
	    add  hl, bc
	    exx
L338C:
	    rlca
	    ld   l, a
L338E:
	    ld   de, L32D7
	    ld   h, 0
	    add  hl, de
	    ld   e, (hl)
	    inc  hl
	    ld   d, (hl)
	    ld   hl, L3365
	    ex   (sp), hl
	    push de
	    exx
	    ld   bc, (FP_STKEND + 1)    ; C=STKEND_hi, B=FP_BREG (ver nota en sysvars.asm)
	    ret
	; ---------------------------------------------------------------------------
	; delete (literal $02) -- a plain RET; also an indirect-jump target
	; ---------------------------------------------------------------------------
L33A1:
	    ret
	; ---------------------------------------------------------------------------
	; fp-calc-2 (literal $3B) -- single-literal re-entry
	; ---------------------------------------------------------------------------
L33A2:
	    pop  af
	    ld   a, (FP_BREG)
	    exx
	    jr   L336C
	; ---------------------------------------------------------------------------
	; STK-PNTRS ($35BF)
	; ---------------------------------------------------------------------------
L35BF:
	    ld   hl, (FP_STKEND)
	    ld   de, $FFFB
	    push hl
	    add  hl, de
	    pop  de
	    ret
	; ---------------------------------------------------------------------------
	; jump-true (literal $00) / jump (literal $33) / dec-jr-nz (literal $35)
	; ---------------------------------------------------------------------------
L368F:
	    inc  de
	    inc  de
	    ld   a, (de)
	    dec  de
	    dec  de
	    and  a
	    jr   nz, L3686
	    exx
	    inc  hl
	    exx
	    ret
L367A:
	    exx
	    push hl
	    ld   hl, FP_BREG
	    dec  (hl)
	    pop  hl
	    jr   nz, L3687
	    inc  hl
	    exx
	    ret
L3686:
	    exx
L3687:
	    ld   e, (hl)
	    ld   a, e
	    rla
	    sbc  a, a
	    ld   d, a
	    add  hl, de
	    exx
	    ret
	; ---------------------------------------------------------------------------
	; end-calc (literal $38)
	; ---------------------------------------------------------------------------
L369B:
	    pop  af
	    exx
	    ex   (sp), hl
	    exx
	    ret
	; ---------------------------------------------------------------------------
	; n-mod-m (literal $32) -- implemented as a small calculator program
	; ---------------------------------------------------------------------------
L36A0:
	    rst  30h
	    defb $C0, $02, $31, $E0, $05, $27, $E0, $01, $C0, $04, $03, $E0, $38
	    ret
	; ---------------------------------------------------------------------------
	; int (literal $27) -- implemented as a small calculator program
	; ---------------------------------------------------------------------------
L36AF:
	    rst  30h
	    defb $31            ;;duplicate
	    defb $36            ;;less-0
	    defb $00            ;;jump-true
	    defb (L36B7 - $) & 0FFh  ;;a X-NEG
	    defb $3A            ;;truncate
	    defb $38            ;;end-calc
	    ret
L36B7:
	    defb $31            ;;duplicate
	    defb $3A            ;;truncate
	    defb $C0            ;;st-mem-0
	    defb $03            ;;subtract
	    defb $E0            ;;get-mem-0
	    defb $01            ;;exchange
	    defb $30            ;;not
	    defb $00            ;;jump-true
	    defb (L36C2 - $) & 0FFh  ;;a EXIT
	    defb $A1            ;;stk-one
	    defb $03            ;;subtract
L36C2:
	    defb $38            ;;end-calc
	; ---------------------------------------------------------------------------
	; TEST-ZERO ($34E9) / GREATER-0 (literal $37) / NOT (literal $30) /
	; less-0 (literal $36) / SIGN-TO-C / FP-0/1
	; ---------------------------------------------------------------------------
L34E9:
	    push hl
	    push bc
	    ld   b, a
	    ld   a, (hl)
	    inc  hl
	    or   (hl)
	    inc  hl
	    or   (hl)
	    inc  hl
	    or   (hl)
	    ld   a, b
	    pop  bc
	    pop  hl
	    ret  nz
	    scf
	    ret
L34F9:
	    call L34E9
	    ret  c
	    ld   a, $FF
	    jr   L3507
L3501:
	    call L34E9
	    jr   L350B
L3506:
	    xor  a
L3507:
	    inc  hl
	    xor  (hl)
	    dec  hl
	    rlca
L350B:
	    push hl
	    ld   a, 0
	    ld   (hl), a
	    inc  hl
	    ld   (hl), a
	    inc  hl
	    rla
	    ld   (hl), a
	    rra
	    inc  hl
	    ld   (hl), a
	    inc  hl
	    ld   (hl), a
	    pop  hl
	    ret
	; ---------------------------------------------------------------------------
	; or (literal $07) / no-&-no (literal $08)
	; ---------------------------------------------------------------------------
L351B:
	    ex   de, hl
	    call L34E9
	    ex   de, hl
	    ret  c
	    scf
	    jr   L350B
L3524:
	    ex   de, hl
	    call L34E9
	    ex   de, hl
	    ret  nc
	    and  a
	    jr   L350B
	; ---------------------------------------------------------------------------
	; numeric comparisons (literals $09-$0E, $353B) -- numeric branch only;
	; string comparisons via the calculator are not supported by this runtime.
	; ---------------------------------------------------------------------------
L353B:
	    ld   a, b
	    sub  8
	    bit  2, a
	    jr   nz, L3543
	    dec  a
L3543:
	    rrca
	    jr   nc, L354E
	    push af
	    push hl
	    call L343C
	    pop  de
	    ex   de, hl
	    pop  af
L354E:
	    rrca
	    push af
	    call L300F
	    jr   L358C
	; ---------------------------------------------------------------------------
	; END-TESTS ($358C)
	; ---------------------------------------------------------------------------
L358C:
	    pop  af
	    push af
	    call c, L3501
	    pop  af
	    push af
	    call nc, L34F9
	    pop  af
	    rrca
	    call nc, L3501
	    ret
	; ===========================================================================
	; SIN/COS/TAN/ASN/ACS/ATN/LN/EXP/SQR
	;
	; Like "int" or "n-mod-m" above, these are small calculator programs
	; (rst 30h + literal bytes), identical to the ROM's, built on the series
	; generator (L3449/L3453) above. Only the jump-true/jump offsets were
; recomputed (same formula used throughout this file: (target - $) & 0FFh),
	; and the ROM's "RST 08h ; DEFB <code>" (ERROR-1) was replaced with this
	; runtime's own error mechanism (ERROR_xxx + jp __ERROR).
	; ===========================================================================
	; ---------------------------------------------------------------------------
	; STACK-A ($2D28) / STACK-BC ($2D2B) -- pushes A (or BC) as a small integer
	; ---------------------------------------------------------------------------
L2D28:
	    ld   c, a
	    ld   b, 0
L2D2B:
	    xor  a
	    ld   e, a
	    ld   d, c
	    ld   c, b
	    ld   b, a
	    call __FPSTACK_PUSH
	    rst  30h
	    defb $38            ;;end-calc (recomputes HL/DE after the push)
	    and  a
	    ret
	; ---------------------------------------------------------------------------
	; FP-TO-BC ($2DA2) -- collects the last FP-stack value into BC (rounding)
	; ---------------------------------------------------------------------------
L2DA2:
	    rst  30h
	    defb $38            ;;end-calc -> HL apunta al ultimo valor
	    ld   a, (hl)
	    and  a
	    jr   z, L2DAD
	    rst  30h
	    defb $A2            ;;stk-half
	    defb $0F            ;;addition
	    defb $27            ;;int
	    defb $38            ;;end-calc
L2DAD:
	    rst  30h
	    defb $02            ;;delete
	    defb $38            ;;end-calc
	    push hl
	    push de
	    ex   de, hl
	    ld   b, (hl)
	    call L2D7F
	    xor  a
	    sub  b
	    bit  7, c
	    ld   b, d
	    ld   c, e
	    ld   a, e
	    pop  de
	    pop  hl
	    ret
	; ---------------------------------------------------------------------------
	; FP-TO-A ($2DD5) -- like FP-TO-BC but returns A, with overflow in carry
	; ---------------------------------------------------------------------------
L2DD5:
	    call L2DA2
	    ret  c
	    push af
	    dec  b
	    inc  b
	    jr   z, L2DE1
	    pop  af
	    scf
	    ret
L2DE1:
	    pop  af
	    ret
	; ---------------------------------------------------------------------------
	; get-argt (literal $39, $3783) -- reduces the sin/cos argument to -1..+1
	; ---------------------------------------------------------------------------
L3783:
	    rst  30h
	    defb $3D            ;;re-stack
	    defb $34            ;;stk-data
    defb $EE            ;;Exponent: $7E, Bytes: 4
	    defb $22, $F9, $83, $6E
	    defb $04            ;;multiply
	    defb $31            ;;duplicate
	    defb $A2            ;;stk-half
	    defb $0F            ;;addition
	    defb $27            ;;int
	    defb $03            ;;subtract
	    defb $31            ;;duplicate
	    defb $0F            ;;addition
	    defb $31            ;;duplicate
	    defb $0F            ;;addition
	    defb $31            ;;duplicate
	    defb $2A            ;;abs
	    defb $A1            ;;stk-one
	    defb $03            ;;subtract
	    defb $31            ;;duplicate
	    defb $37            ;;greater-0
	    defb $C0            ;;st-mem-0
	    defb $00            ;;jump-true
	    defb (L37A1 - $) & 0FFh    ;;a ZPLUS
	    defb $02            ;;delete
	    defb $38            ;;end-calc
	    ret
L37A1:
	    defb $A1            ;;stk-one
	    defb $03            ;;subtract
	    defb $01            ;;exchange
	    defb $36            ;;less-0
	    defb $00            ;;jump-true
	    defb (L37A8 - $) & 0FFh    ;;a YNEG
	    defb $1B            ;;negate
L37A8:
	    defb $38            ;;end-calc
	    ret
	; ---------------------------------------------------------------------------
	; cos (literal $20, $37AA) -- falls into sin/C-ENT (shared code)
	; ---------------------------------------------------------------------------
L37AA:
	    rst  30h
	    defb $39            ;;get-argt
	    defb $2A            ;;abs
	    defb $A1            ;;stk-one
	    defb $03            ;;subtract
	    defb $E0            ;;get-mem-0
	    defb $00            ;;jump-true
	    defb (L37B7 - $) & 0FFh    ;;a C-ENT
	    defb $1B            ;;negate
	    defb $33            ;;jump
	    defb (L37B7 - $) & 0FFh    ;;a C-ENT
	; ---------------------------------------------------------------------------
	; sin (literal $1F, $37B5) / C-ENT ($37B7, shared with cos)
	; ---------------------------------------------------------------------------
L37B5:
	    rst  30h
	    defb $39            ;;get-argt
L37B7:
	    defb $31            ;;duplicate
	    defb $31            ;;duplicate
	    defb $04            ;;multiply
	    defb $31            ;;duplicate
	    defb $0F            ;;addition
	    defb $A1            ;;stk-one
	    defb $03            ;;subtract
	    defb $86            ;;series-06
	    defb $14, $E6
	    defb $5C, $1F, $0B
	    defb $A3, $8F, $38, $EE
	    defb $E9, $15, $63, $BB, $23
	    defb $EE, $92, $0D, $CD, $ED
	    defb $F1, $23, $5D, $1B, $EA
	    defb $04            ;;multiply
	    defb $38            ;;end-calc
	    ret
	; ---------------------------------------------------------------------------
	; tan (literal $21, $37DA) -- sin(x) / cos(x)
	; ---------------------------------------------------------------------------
L37DA:
	    rst  30h
	    defb $31            ;;duplicate
	    defb $1F            ;;sin
	    defb $01            ;;exchange
	    defb $20            ;;cos
	    defb $05            ;;division
	    defb $38            ;;end-calc
	    ret
	; ---------------------------------------------------------------------------
	; atn (literal $24, $37E2)
	; ---------------------------------------------------------------------------
L37E2:
	    call L3297          ; re-stack
	    ld   a, (hl)
	    cp   $81
	    jr   c, L37F8       ; SMALL
	    rst  30h
	    defb $A1            ;;stk-one
	    defb $1B            ;;negate
	    defb $01            ;;exchange
	    defb $05            ;;division
	    defb $31            ;;duplicate
	    defb $36            ;;less-0
	    defb $A3            ;;stk-pi/2
	    defb $01            ;;exchange
	    defb $00            ;;jump-true
	    defb (L37FA - $) & 0FFh    ;;a CASES
	    defb $1B            ;;negate
	    defb $33            ;;jump
	    defb (L37FA - $) & 0FFh    ;;a CASES
L37F8:
	    rst  30h
	    defb $A0            ;;stk-zero
L37FA:
	    defb $01            ;;exchange
	    defb $31            ;;duplicate
	    defb $31            ;;duplicate
	    defb $04            ;;multiply
	    defb $31            ;;duplicate
	    defb $0F            ;;addition
	    defb $A1            ;;stk-one
	    defb $03            ;;subtract
	    defb $8C            ;;series-0C
	    defb $10, $B2
	    defb $13, $0E
	    defb $55, $E4, $8D
	    defb $58, $39, $BC
	    defb $5B, $98, $FD
	    defb $9E, $00, $36, $75
	    defb $A0, $DB, $E8, $B4
	    defb $63, $42, $C4
	    defb $E6, $B5, $09, $36, $BE
	    defb $E9, $36, $73, $1B, $5D
	    defb $EC, $D8, $DE, $63, $BE
	    defb $F0, $61, $A1, $B3, $0C
	    defb $04            ;;multiply
	    defb $0F            ;;addition
	    defb $38            ;;end-calc
	    ret
	; ---------------------------------------------------------------------------
	; asn (literal $22, $3833)
	; ---------------------------------------------------------------------------
L3833:
	    rst  30h
	    defb $31            ;;duplicate
	    defb $31            ;;duplicate
	    defb $04            ;;multiply
	    defb $A1            ;;stk-one
	    defb $03            ;;subtract
	    defb $1B            ;;negate
	    defb $28            ;;sqr
	    defb $A1            ;;stk-one
	    defb $0F            ;;addition
	    defb $05            ;;division
	    defb $24            ;;atn
	    defb $31            ;;duplicate
	    defb $0F            ;;addition
	    defb $38            ;;end-calc
	    ret
	; ---------------------------------------------------------------------------
	; acs (literal $23, $3843)
	; ---------------------------------------------------------------------------
L3843:
	    rst  30h
	    defb $22            ;;asn
	    defb $A3            ;;stk-pi/2
	    defb $03            ;;subtract
	    defb $1B            ;;negate
	    defb $38            ;;end-calc
	    ret
	; ---------------------------------------------------------------------------
	; ln (literal $25, $3713)
	; ---------------------------------------------------------------------------
L3713:
	    rst  30h
	    defb $3D            ;;re-stack
	    defb $31            ;;duplicate
	    defb $37            ;;greater-0
	    defb $00            ;;jump-true
	    defb (L371C - $) & 0FFh    ;;a VALID
	    defb $38            ;;end-calc
	    ld   a, ERROR_InvalidArg
	    jp   __ERROR
L371C:
	    defb $A0            ;;stk-zero
	    defb $02            ;;delete
	    defb $38            ;;end-calc
	    ld   a, (hl)
	    ld   (hl), $80
	    call L2D28
	    rst  30h
	    defb $34            ;;stk-data
    defb $38            ;;Exponent: $88, Bytes: 1
	    defb $00
	    defb $03            ;;subtract
	    defb $01            ;;exchange
	    defb $31            ;;duplicate
	    defb $34            ;;stk-data
    defb $F0            ;;Exponent: $80, Bytes: 4
	    defb $4C, $CC, $CC, $CD
	    defb $03            ;;subtract
	    defb $37            ;;greater-0
	    defb $00            ;;jump-true
	    defb (L373D - $) & 0FFh    ;;a GRE.8
	    defb $01            ;;exchange
	    defb $A1            ;;stk-one
	    defb $03            ;;subtract
	    defb $01            ;;exchange
	    defb $38            ;;end-calc
	    inc  (hl)
	    rst  30h
L373D:
	    defb $01            ;;exchange
	    defb $34            ;;stk-data
    defb $F0            ;;Exponent: $80, Bytes: 4
	    defb $31, $72, $17, $F8
	    defb $04            ;;multiply
	    defb $01            ;;exchange
	    defb $A2            ;;stk-half
	    defb $03            ;;subtract
	    defb $A2            ;;stk-half
	    defb $03            ;;subtract
	    defb $31            ;;duplicate
	    defb $34            ;;stk-data
    defb $32            ;;Exponent: $82, Bytes: 1
	    defb $20
	    defb $04            ;;multiply
	    defb $A2            ;;stk-half
	    defb $03            ;;subtract
	    defb $8C            ;;series-0C
	    defb $11, $AC
	    defb $14, $09
	    defb $56, $DA, $A5
	    defb $59, $30, $C5
	    defb $5C, $90, $AA
	    defb $9E, $70, $6F, $61
	    defb $A1, $CB, $DA, $96
	    defb $A4, $31, $9F, $B4
	    defb $E7, $A0, $FE, $5C, $FC
	    defb $EA, $1B, $43, $CA, $36
	    defb $ED, $A7, $9C, $7E, $5E
	    defb $F0, $6E, $23, $80, $93
	    defb $04            ;;multiply
	    defb $0F            ;;addition
	    defb $38            ;;end-calc
	    ret
	; ---------------------------------------------------------------------------
	; exp (literal $26, $36C4)
	; ---------------------------------------------------------------------------
L36C4:
	    rst  30h
	    defb $3D            ;;re-stack
	    defb $34            ;;stk-data
    defb $F1            ;;Exponent: $81, Bytes: 4
	    defb $38, $AA, $3B, $29
	    defb $04            ;;multiply
	    defb $31            ;;duplicate
	    defb $27            ;;int
	    defb $C3            ;;st-mem-3
	    defb $03            ;;subtract
	    defb $31            ;;duplicate
	    defb $0F            ;;addition
	    defb $A1            ;;stk-one
	    defb $03            ;;subtract
	    defb $88            ;;series-08
	    defb $13, $36
	    defb $58, $65, $66
	    defb $9D, $78, $65, $40
	    defb $A2, $60, $32, $C9
	    defb $E7, $21, $F7, $AF, $24
	    defb $EB, $2F, $B0, $B0, $14
	    defb $EE, $7E, $BB, $94, $58
	    defb $F1, $3A, $7E, $F8, $CF
	    defb $E3            ;;get-mem-3
	    defb $38            ;;end-calc
	    call L2DD5
	    jr   nz, L3705      ; N-NEGTV
	    jr   c, L3703       ; REPORT-6b
	    add  a, (hl)
	    jr   nc, L370C      ; RESULT-OK
L3703:
	    ld   a, ERROR_NumberTooBig
	    jp   __ERROR
L3705:
	    jr   c, L370E       ; RSLT-ZERO
	    sub  (hl)
	    jr   nc, L370E      ; RSLT-ZERO
	    neg
L370C:
	    ld   (hl), a
	    ret
L370E:
	    rst  30h
	    defb $02            ;;delete
	    defb $A0            ;;stk-zero
	    defb $38            ;;end-calc
	    ret
	; ---------------------------------------------------------------------------
	; sqr (literal $28, $384A) -- falls into to-power (shared code)
	; ---------------------------------------------------------------------------
L384A:
	    rst  30h
	    defb $31            ;;duplicate
	    defb $30            ;;not
	    defb $00            ;;jump-true
	    defb (L386C - $) & 0FFh    ;;a LAST
	    defb $A2            ;;stk-half
	    defb $38            ;;end-calc
	; ---------------------------------------------------------------------------
	; to-power (literal $06, $3851)
	; ---------------------------------------------------------------------------
L3851:
	    rst  30h
	    defb $01            ;;exchange
	    defb $31            ;;duplicate
	    defb $30            ;;not
	    defb $00            ;;jump-true
	    defb (L385D - $) & 0FFh    ;;a XIS0
	    defb $25            ;;ln
	    defb $04            ;;multiply
	    defb $38            ;;end-calc
	    jp   L36C4
L385D:
	    defb $02            ;;delete
	    defb $31            ;;duplicate
	    defb $30            ;;not
	    defb $00            ;;jump-true
	    defb (L386A - $) & 0FFh    ;;a ONE
	    defb $A0            ;;stk-zero
	    defb $01            ;;exchange
	    defb $37            ;;greater-0
	    defb $00            ;;jump-true
	    defb (L386C - $) & 0FFh    ;;a LAST
	    defb $A1            ;;stk-one
	    defb $01            ;;exchange
	    defb $05            ;;division
L386A:
	    defb $02            ;;delete
	    defb $A1            ;;stk-one
L386C:
	    defb $38            ;;end-calc
	    ret
	; ===========================================================================
	; STK-TO-A / STK-TO-BC / CD-PRMS1
	;
	; ROM helper routines used by DRAW3 (arc mode) and CIRCLE-DRAW. Not
	; calculator literals (not invoked via rst 30h + defb) but ordinary
	; routines that themselves use the calculator above (FP-TO-A, STACK-A, and
	; the sqr/sin/stk-data/etc literals in this file).
	; ===========================================================================
	; ---------------------------------------------------------------------------
	; STK-TO-A ($2314) -- compresses the last FP-stack value into A.
	; C = $01 if positive or zero, $FF if negative.
	; Raises ERROR_IntOutOfRange (replaces REPORT-Bc / RST 08h) if >= 256.
	; ---------------------------------------------------------------------------
L2314:
    call L2DD5          ; FP-TO-A: A = valor comprimido, Z si signo positivo
	    jr   c, L24F9
	    ld   c, $01
	    ret  z
	    ld   c, $FF
	    ret
L24F9:
	    ld   a, ERROR_IntOutOfRange
	    jp   __ERROR
	; ---------------------------------------------------------------------------
; STK-TO-BC ($2307) -- collects two FP-stack values: the older one into
	; BC, the more recent one into DE (sign in E/D).
	; ---------------------------------------------------------------------------
L2307:
	    call L2314
	    ld   b, a
	    push bc
	    call L2314
	    ld   e, c
	    pop  bc
	    ld   d, c
	    ld   c, a
	    ret
	; ---------------------------------------------------------------------------
; CD-PRMS1 ($247D) -- CIRCLE/DRAW PARAMETERS: from the "diameter" z (top of
	; stack) and the total angle in mem-5, computes the number of straight
	; lines (B, a multiple of 4, max 252) and leaves sin(a/2), cos(a) and
	; sin(a) of the step angle "a" = ANGLE/lines in mem-1/mem-3/mem-4.
	; ---------------------------------------------------------------------------
L247D:
	    rst  30h
	    defb $31            ;;duplicate     z, z.
	    defb $28            ;;sqr           z, sqr(z).
	    defb $34            ;;stk-data      z, sqr(z), 2.
    defb $32            ;;Exponent: $82, Bytes: 1
	    defb $00            ;;(+00,+00,+00)
	    defb $01            ;;exchange      z, 2, sqr(z).
	    defb $05            ;;division      z, 2/sqr(z).
	    defb $E5            ;;get-mem-5     z, 2/sqr(z), ANGLE.
	    defb $01            ;;exchange      z, ANGLE, 2/sqr(z)
	    defb $05            ;;division      z, ANGLE*sqr(z)/2 (=num. lineas)
	    defb $2A            ;;abs           (arc mode only)
	    defb $38            ;;end-calc      z, numero de lineas.
	    call L2DD5          ; FP-TO-A
	    jr   c, L247D_USE252
	    and  $FC            ; multiple of 4 (e.g. 29 -> 28)
	    add  a, $04          ; could overflow -> 256
	    jr   nc, L247D_SAVE
L247D_USE252:
	    ld   a, $FC          ; cap of 252 (for arc mode)
L247D_SAVE:
	    push af              ; keep the line count
	    call L2D28           ; push the adjusted count
	    rst  30h
	    defb $E5            ;;get-mem-5     z, A, ANGLE.
	    defb $01            ;;exchange      z, ANGLE, A.
	    defb $05            ;;division      z, ANGLE/A. (angulo de paso = a)
	    defb $31            ;;duplicate     z, a, a.
	    defb $1F            ;;sin           z, a, sin(a)
	    defb $C4            ;;st-mem-4      z, a, sin(a)
	    defb $02            ;;delete        z, a.
	    defb $31            ;;duplicate     z, a, a.
	    defb $A2            ;;stk-half      z, a, a, 1/2.
	    defb $04            ;;multiply      z, a, a/2.
	    defb $1F            ;;sin           z, a, sin(a/2).
	    defb $C1            ;;st-mem-1      z, a, sin(a/2).
	    defb $01            ;;exchange      z, sin(a/2), a.
	    defb $C0            ;;st-mem-0      z, sin(a/2), a.  (arc mode only)
	    defb $02            ;;delete        z, sin(a/2).
	    defb $31            ;;duplicate     z, sin(a/2), sin(a/2).
	    defb $04            ;;multiply      z, sin(a/2)^2.
	    defb $31            ;;duplicate     z, sin(a/2)^2, sin(a/2)^2.
	    defb $0F            ;;addition      z, 2*sin(a/2)^2.
	    defb $A1            ;;stk-one       z, 2*sin(a/2)^2, 1.
	    defb $03            ;;subtract      z, 2*sin(a/2)^2-1.
	    defb $1B            ;;negate        z, 1-2*sin(a/2)^2 = cos(a).
	    defb $C3            ;;st-mem-3      z, cos(a).
	    defb $02            ;;delete        z.
	    defb $38            ;;end-calc      z.
	    pop  bc              ; restore the line count
	    ret
	    pop namespace
#line 10 "src/lib/arch/cpc/runtime/stackf.asm"
	    push namespace core
	; ---------------------------------------------------------------------------
	; __FPSTACK_PUSH -- pushes A,E,D,C,B (5 bytes) onto the FP stack
	; Replaces STK-STORE ($2AB6h, Spectrum ROM)
	; ---------------------------------------------------------------------------
__FPSTACK_PUSH:
	    push bc
	    push af
	    ld   bc, 5
	    call CALC_TEST_ROOM
	    pop  af
	    pop  bc
	    ld   hl, (FP_STKEND)
	    ld   (hl), a
	    inc  hl
	    ld   (hl), e
	    inc  hl
	    ld   (hl), d
	    inc  hl
	    ld   (hl), c
	    inc  hl
	    ld   (hl), b
	    inc  hl
	    ld   (FP_STKEND), hl
	    ret
__FPSTACK_PUSH2: ; Pushes Current A ED CB registers and top of the stack on (SP + 4)
	    ; Second argument to push into the stack calculator is popped out of the stack
	    ; Since the caller routine also receives the parameters into the top of the stack
	    ; four bytes must be removed from SP before pop them out
	    call __FPSTACK_PUSH ; Pushes A ED CB into the FP-STACK
	    exx
	    pop hl       ; Caller-Caller return addr
	    exx
	    pop hl       ; Caller return addr
	    pop af
	    pop de
	    pop bc
	    push hl      ; Caller return addr
	    exx
	    push hl      ; Caller-Caller return addr
	    exx
	    jp __FPSTACK_PUSH
__FPSTACK_I16:	; Pushes 16 bits integer in HL into the FP ROM STACK
	    ; This format is specified in the ZX 48K Manual
	    ; You can push a 16 bit signed integer as
	    ; 0 SS LL HH 0, being SS the sign and LL HH the low
	    ; and High byte respectively
	    ld a, h
	    rla			; sign to Carry
	    sbc	a, a	; 0 if positive, FF if negative
	    ld e, a
	    ld d, l
	    ld c, h
	    xor a
	    ld b, a
	    jp __FPSTACK_PUSH
	; ---------------------------------------------------------------------------
	; __FPSTACK_POP -- pops the last 5 bytes off the FP stack into A,E,D,C,B
	; Replaces STK-FETCH ($2BF1h, Spectrum ROM)
	; ---------------------------------------------------------------------------
__FPSTACK_POP:
	    ld   hl, (FP_STKEND)
	    dec  hl
	    ld   b, (hl)
	    dec  hl
	    ld   c, (hl)
	    dec  hl
	    ld   d, (hl)
	    dec  hl
	    ld   e, (hl)
	    dec  hl
	    ld   a, (hl)
	    ld   (FP_STKEND), hl
	    ret
	    pop namespace
#line 2 "src/lib/arch/cpc/runtime/arith/divf.asm"
	; -------------------------------------------------------------
	; Floating point library using the FP calculator (ported ROM engine)
	; All of them uses C EDHL registers as 1st paramter.
	; For binary operators, the 2n operator must be pushed into the
	; stack, in the order BC DE HL (B not used).
	;
	; Uses CALLEE convention
	; -------------------------------------------------------------
	;
; cpc override: ported from src/lib/arch/zx81sd/runtime/arith/divf.asm.
	; The only change from zx48k's version is where TMP/ERR_SP live. The
	; original uses the Spectrum ROM's DEST (23629) and ERR_SP (23613) system
	; variables to save/restore a stack recovery point around the division (a
	; "longjmp" trick for divide-by-zero) -- on the cpc those addresses would
	; fall inside the program's own compiled code, so DIVF_SCRATCH
	; (sysvars.asm) is dedicated scratch space instead (same mechanism, just
; relocated). In practice this trap is never actually taken: the
	; calculator's own division literal (fp_calc.asm, L31AF) raises
	; ERROR_NumberTooBig directly via `jp __ERROR` on a zero divisor, and
	; __ERROR here never returns (it prints "Error n" and resets), so
	; __DIVBYZERO below is unreachable dead code, kept only for parity with
	; zx48k/zx81sd's own copy.
	    push namespace core
__DIVF:	; Division
	    PROC
	    LOCAL __DIVBYZERO
	    LOCAL TMP, ERR_SP
TMP         EQU DIVF_SCRATCH       ; cpc: dedicated scratch, not DEST
ERR_SP      EQU DIVF_SCRATCH + 2   ; cpc: dedicated scratch, not ERR_SP
	    call __FPSTACK_PUSH2
	    ld hl, (ERR_SP)
	    ld (TMP), hl
	    ld hl, __DIVBYZERO
	    push hl
	    ld (ERR_SP), sp
	    ; ------------- DIV via the FP calculator
	    rst 30h
	    defb 01h	; EXCHANGE
	    defb 05h	; DIV
	    defb 38h;   ; END CALC
	    pop hl
	    ld hl, (TMP)
	    ld (ERR_SP), hl
	    jp __FPSTACK_POP
__DIVBYZERO:
	    ld hl, (TMP)
	    ld (ERR_SP), hl
	    ld a, ERROR_NumberTooBig
	    ld (ERR_NR), a
	    ; Returns 0 on DIV BY ZERO error
	    xor a
	    ld b, a
	    ld c, a
	    ld d, a
	    ld e, a
	    ret
	    ENDP
	    pop namespace
#line 615 "src/lib/arch/cpc/stdlib/play.bas"
#line 1 "src/lib/arch/zx48k/runtime/arith/mul16.asm"
	    push namespace core
__MUL16:	; Mutiplies HL with the last value stored into de stack
	    ; Works for both signed and unsigned
	    PROC
	    LOCAL __MUL16LOOP
	    LOCAL __MUL16NOADD
	    ex de, hl
	    pop hl		; Return address
	    ex (sp), hl ; CALLEE caller convention
__MUL16_FAST:
	    ld b, 16
	    ld a, h
	    ld c, l
	    ld hl, 0
__MUL16LOOP:
	    add hl, hl  ; hl << 1
	    sla c
	    rla         ; a,c << 1
	    jp nc, __MUL16NOADD
	    add hl, de
__MUL16NOADD:
	    djnz __MUL16LOOP
	    ret	; Result in hl (16 lower bits)
	    ENDP
	    pop namespace
#line 616 "src/lib/arch/cpc/stdlib/play.bas"
#line 1 "src/lib/arch/zx48k/runtime/arith/mul8.asm"
	    push namespace core
__MUL8:		; Performs 8bit x 8bit multiplication
	    PROC
	    ;LOCAL __MUL8A
	    LOCAL __MUL8LOOP
	    LOCAL __MUL8B
	    ; 1st operand (byte) in A, 2nd operand into the stack (AF)
	    pop hl	; return address
	    ex (sp), hl ; CALLE convention
;;__MUL8_FAST: ; __FASTCALL__ entry
	;;	ld e, a
	;;	ld d, 0
	;;	ld l, d
	;;
	;;	sla h
	;;	jr nc, __MUL8A
	;;	ld l, e
	;;
;;__MUL8A:
	;;
	;;	ld b, 7
;;__MUL8LOOP:
	;;	add hl, hl
	;;	jr nc, __MUL8B
	;;
	;;	add hl, de
	;;
;;__MUL8B:
	;;	djnz __MUL8LOOP
	;;
	;;	ld a, l ; result = A and HL  (Truncate to lower 8 bits)
__MUL8_FAST: ; __FASTCALL__ entry, a = a * h (8 bit mul) and Carry
	    ld b, 8
	    ld l, a
	    xor a
__MUL8LOOP:
	    add a, a ; a *= 2
	    sla l
	    jp nc, __MUL8B
	    add a, h
__MUL8B:
	    djnz __MUL8LOOP
	    ret		; result = HL
	    ENDP
	    pop namespace
#line 617 "src/lib/arch/cpc/stdlib/play.bas"
#line 1 "src/lib/arch/cpc/runtime/array/array.asm"
; vim: ts=4:et:sw=4:
	; Copyleft (K) by Jose M. Rodriguez de la Rosa
	;  (a.k.a. Boriel)
;  http://www.boriel.com
	; -------------------------------------------------------------------
	; Simple array Index routine
	; Number of total indexes dimensions - 1 at beginning of memory
	; HL = Start of array memory (First two bytes contains N-1 dimensions)
	; Dimension values on the stack, (top of the stack, highest dimension)
	; E.g. A(2, 4) -> PUSH <4>; PUSH <2>
	; For any array of N dimension A(aN-1, ..., a1, a0)
	; and dimensions D[bN-1, ..., b1, b0], the offset is calculated as
	; O = [a0 + b0 * (a1 + b1 * (a2 + ... bN-2(aN-1)))]
; What I will do here is to calculate the following sequence:
	; ((aN-1 * bN-2) + aN-2) * bN-3 + ...
	;
; Amstrad CPC override: only change from zx48k's version is LBOUND_PTR's
	; storage address. zx48k uses the Spectrum ROM's MEMBOT sysvar; on the
	; CPC that address falls inside ordinary program RAM (the compiled .bin
	; starts at $0040), so ARRAY_SCRATCH (sysvars.asm) is a dedicated 8-byte
	; scratch area in the private runtime block instead (same fix zx81sd's
	; own array/array.asm applies).
#line 1 "src/lib/arch/zx48k/runtime/arith/fmul16.asm"
	;; Performs a faster multiply for little 16bit numbs
	    push namespace core
__FMUL16:
	    xor a
	    or h
	    jp nz, __MUL16_FAST
	    or l
	    ret z
	    cp 33
	    jp nc, __MUL16_FAST
	    ld b, l
	    ld l, h  ; HL = 0
1:
	    add hl, de
	    djnz 1b
	    ret
	    pop namespace
#line 26 "src/lib/arch/cpc/runtime/array/array.asm"
#line 31 "src/lib/arch/cpc/runtime/array/array.asm"
	    push namespace core
__ARRAY_PTR:   ;; computes an array offset from a pointer
	    ld c, (hl)
	    inc hl
	    ld h, (hl)
	    ld l, c    ;; HL <-- [HL]
__ARRAY:
	    PROC
	    LOCAL LOOP
	    LOCAL ARRAY_END
	    LOCAL TMP_ARR_PTR            ; Ptr to Array DATA region. Stored temporarily
	    LOCAL LBOUND_PTR, UBOUND_PTR ; LBound and UBound PTR indexes
	    LOCAL RET_ADDR               ; Contains the return address popped from the stack
LBOUND_PTR EQU ARRAY_SCRATCH   ; cpc: dedicated scratch, not MEMBOT
	UBOUND_PTR EQU LBOUND_PTR + 2  ; Next 2 bytes for UBOUND PTR
	RET_ADDR EQU UBOUND_PTR + 2    ; Next 2 bytes for RET_ADDR
	TMP_ARR_PTR EQU RET_ADDR + 2   ; Next 2 bytes for TMP_ARR_PTR
	    ld e, (hl)
	    inc hl
	    ld d, (hl)
	    inc hl      ; DE <-- PTR to Dim sizes table
	    ld (TMP_ARR_PTR), hl  ; HL = Array __DATA__.__PTR__
	    inc hl
	    inc hl
	    ld c, (hl)
	    inc hl
	    ld b, (hl)  ; BC <-- Array __LBOUND__ PTR
	    ld (LBOUND_PTR), bc  ; Store it for later
#line 73 "src/lib/arch/cpc/runtime/array/array.asm"
	    ex de, hl   ; HL <-- PTR to Dim sizes table, DE <-- dummy
	    ex (sp), hl	; Return address in HL, PTR Dim sizes table onto Stack
	    ld (RET_ADDR), hl ; Stores it for later
	    exx
	    pop hl		; Will use H'L' as the pointer to Dim sizes table
	    ld c, (hl)	; Loads Number of dimensions from (hl)
	    inc hl
	    ld b, (hl)
	    inc hl		; Ready
	    exx
	    ld hl, 0	; HL = Element Offset "accumulator"
LOOP:
	    ex de, hl   ; DE = Element Offset
	    ld hl, (LBOUND_PTR)
	    ld a, h
	    or l
	    ld b, h
	    ld c, l
	    jr z, 1f
	    ld c, (hl)
	    inc hl
	    ld b, (hl)
	    inc hl
	    ld (LBOUND_PTR), hl
1:
	    pop hl      ; Get next index (Ai) from the stack
	    sbc hl, bc  ; Subtract LBOUND
#line 123 "src/lib/arch/cpc/runtime/array/array.asm"
	    add hl, de	; Adds current index
	    exx			; Checks if B'C' = 0
	    ld a, b		; Which means we must exit (last element is not multiplied by anything)
	    or c
	    jr z, ARRAY_END		; if B'Ci == 0 we are done
	    dec bc				; Decrements loop counter
	    ld e, (hl)			; Loads next dimension size into D'E'
	    inc hl
	    ld d, (hl)
	    inc hl
	    push de
	    exx
	    pop de				; DE = Max bound Number (i-th dimension)
	    call __FMUL16        ; HL <= HL * DE mod 65536
	    jp LOOP
ARRAY_END:
	    ld a, (hl)
	    exx
#line 153 "src/lib/arch/cpc/runtime/array/array.asm"
	    LOCAL ARRAY_SIZE_LOOP
	    ex de, hl
	    ld hl, 0
	    ld b, a
ARRAY_SIZE_LOOP:
	    add hl, de
	    djnz ARRAY_SIZE_LOOP
#line 163 "src/lib/arch/cpc/runtime/array/array.asm"
	    ex de, hl
	    ld hl, (TMP_ARR_PTR)
	    ld a, (hl)
	    inc hl
	    ld h, (hl)
	    ld l, a
	    add hl, de  ; Adds element start
	    ld de, (RET_ADDR)
	    push de
	    ret
	    ENDP
	    pop namespace
#line 618 "src/lib/arch/cpc/stdlib/play.bas"
#line 1 "src/lib/arch/zx48k/runtime/array/arrayalloc.asm"
#line 1 "src/lib/arch/zx48k/runtime/mem/calloc.asm"
; vim: ts=4:et:sw=4:
	; Copyleft (K) by Jose M. Rodriguez de la Rosa
	;  (a.k.a. Boriel)
;  http://www.boriel.com
	;
	; This ASM library is licensed under the MIT license
	; you can use it for any purpose (even for commercial
	; closed source programs).
	;
	; Please read the MIT license on the internet
#line 1 "src/lib/arch/zx48k/runtime/mem/alloc.asm"
; vim: ts=4:et:sw=4:
	; Copyleft (K) by Jose M. Rodriguez de la Rosa
	;  (a.k.a. Boriel)
;  http://www.boriel.com
	;
	; This ASM library is licensed under the MIT license
	; you can use it for any purpose (even for commercial
	; closed source programs).
	;
	; Please read the MIT license on the internet
	; ----- IMPLEMENTATION NOTES ------
	; The heap is implemented as a linked list of free blocks.
; Each free block contains this info:
	;
	; +----------------+ <-- HEAP START
	; | Size (2 bytes) |
	; |        0       | <-- Size = 0 => DUMMY HEADER BLOCK
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+ <-+
	; | Size (2 bytes) |
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+   |
	; | <free bytes...>|   | <-- If Size > 4, then this contains (size - 4) bytes
	; | (0 if Size = 4)|   |
	; +----------------+ <-+
	; | Size (2 bytes) |
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+   |
	; | <free bytes...>|   |
	; | (0 if Size = 4)|   |
	; +----------------+   |
	;   <Allocated>        | <-- This zone is in use (Already allocated)
	; +----------------+ <-+
	; | Size (2 bytes) |
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+   |
	; | <free bytes...>|   |
	; | (0 if Size = 4)|   |
	; +----------------+ <-+
	; | Next (2 bytes) |--> NULL => END OF LIST
	; |    0 = NULL    |
	; +----------------+
	; | <free bytes...>|
	; | (0 if Size = 4)|
	; +----------------+
	; When a block is FREED, the previous and next pointers are examined to see
	; if we can defragment the heap. If the block to be freed is just next to the
	; previous, or to the next (or both) they will be converted into a single
	; block (so defragmented).
	;   MEMORY MANAGER
	;
	; This library must be initialized calling __MEM_INIT with
	; HL = BLOCK Start & DE = Length.
	; An init directive is useful for initialization routines.
	; They will be added automatically if needed.
#line 1 "src/lib/arch/zx48k/runtime/mem/heapinit.asm"
; vim: ts=4:et:sw=4:
	; Copyleft (K) by Jose M. Rodriguez de la Rosa
	;  (a.k.a. Boriel)
;  http://www.boriel.com
	;
	; This ASM library is licensed under the BSD license
	; you can use it for any purpose (even for commercial
	; closed source programs).
	;
	; Please read the BSD license on the internet
	; ----- IMPLEMENTATION NOTES ------
	; The heap is implemented as a linked list of free blocks.
; Each free block contains this info:
	;
	; +----------------+ <-- HEAP START
	; | Size (2 bytes) |
	; |        0       | <-- Size = 0 => DUMMY HEADER BLOCK
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+ <-+
	; | Size (2 bytes) |
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+   |
	; | <free bytes...>|   | <-- If Size > 4, then this contains (size - 4) bytes
	; | (0 if Size = 4)|   |
	; +----------------+ <-+
	; | Size (2 bytes) |
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+   |
	; | <free bytes...>|   |
	; | (0 if Size = 4)|   |
	; +----------------+   |
	;   <Allocated>        | <-- This zone is in use (Already allocated)
	; +----------------+ <-+
	; | Size (2 bytes) |
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+   |
	; | <free bytes...>|   |
	; | (0 if Size = 4)|   |
	; +----------------+ <-+
	; | Next (2 bytes) |--> NULL => END OF LIST
	; |    0 = NULL    |
	; +----------------+
	; | <free bytes...>|
	; | (0 if Size = 4)|
	; +----------------+
	; When a block is FREED, the previous and next pointers are examined to see
	; if we can defragment the heap. If the block to be breed is just next to the
	; previous, or to the next (or both) they will be converted into a single
	; block (so defragmented).
	;   MEMORY MANAGER
	;
	; This library must be initialized calling __MEM_INIT with
	; HL = BLOCK Start & DE = Length.
	; An init directive is useful for initialization routines.
	; They will be added automatically if needed.
	; ---------------------------------------------------------------------
	;  __MEM_INIT must be called to initalize this library with the
	; standard parameters
	; ---------------------------------------------------------------------
	    push namespace core
__MEM_INIT: ; Initializes the library using (RAMTOP) as start, and
	    ld hl, ZXBASIC_MEM_HEAP  ; Change this with other address of heap start
	    ld de, ZXBASIC_HEAP_SIZE ; Change this with your size
	; ---------------------------------------------------------------------
	;  __MEM_INIT2 initalizes this library
; Parameters:
;   HL : Memory address of 1st byte of the memory heap
;   DE : Length in bytes of the Memory Heap
	; ---------------------------------------------------------------------
__MEM_INIT2:
	    ; HL as TOP
	    PROC
	    dec de
	    dec de
	    dec de
	    dec de        ; DE = length - 4; HL = start
	    ; This is done, because we require 4 bytes for the empty dummy-header block
	    xor a
	    ld (hl), a
	    inc hl
    ld (hl), a ; First "free" block is a header: size=0, Pointer=&(Block) + 4
	    inc hl
	    ld b, h
	    ld c, l
	    inc bc
	    inc bc      ; BC = starts of next block
	    ld (hl), c
	    inc hl
	    ld (hl), b
	    inc hl      ; Pointer to next block
	    ld (hl), e
	    inc hl
	    ld (hl), d
	    inc hl      ; Block size (should be length - 4 at start); This block contains all the available memory
	    ld (hl), a ; NULL (0000h) ; No more blocks (a list with a single block)
	    inc hl
	    ld (hl), a
	    ld a, 201
	    ld (__MEM_INIT), a; "Pokes" with a RET so ensure this routine is not called again
	    ret
	    ENDP
	    pop namespace
#line 70 "src/lib/arch/zx48k/runtime/mem/alloc.asm"
	; ---------------------------------------------------------------------
	; MEM_ALLOC
	;  Allocates a block of memory in the heap.
	;
	; Parameters
	;  BC = Length of requested memory block
	;
; Returns:
	;  HL = Pointer to the allocated block in memory. Returns 0 (NULL)
	;       if the block could not be allocated (out of memory)
	; ---------------------------------------------------------------------
	    push namespace core
MEM_ALLOC:
__MEM_ALLOC: ; Returns the 1st free block found of the given length (in BC)
	    PROC
	    LOCAL __MEM_LOOP
	    LOCAL __MEM_DONE
	    LOCAL __MEM_SUBTRACT
	    LOCAL __MEM_START
	    LOCAL TEMP, TEMP0
	TEMP EQU TEMP0 + 1
	    ld hl, 0
	    ld (TEMP), hl
__MEM_START:
	    ld hl, ZXBASIC_MEM_HEAP  ; This label point to the heap start
	    inc bc
	    inc bc  ; BC = BC + 2 ; block size needs 2 extra bytes for hidden pointer
__MEM_LOOP:  ; Loads lengh at (HL, HL+). If Lenght >= BC, jump to __MEM_DONE
	    ld a, h ;  HL = NULL (No memory available?)
	    or l
#line 113 "src/lib/arch/zx48k/runtime/mem/alloc.asm"
	    ret z ; NULL
#line 115 "src/lib/arch/zx48k/runtime/mem/alloc.asm"
	    ; HL = Pointer to Free block
	    ld e, (hl)
	    inc hl
	    ld d, (hl)
	    inc hl          ; DE = Block Length
	    push hl         ; HL = *pointer to -> next block
	    ex de, hl
	    or a            ; CF = 0
	    sbc hl, bc      ; FREE >= BC (Length)  (HL = BlockLength - Length)
	    jp nc, __MEM_DONE
	    pop hl
	    ld (TEMP), hl
	    ex de, hl
	    ld e, (hl)
	    inc hl
	    ld d, (hl)
	    ex de, hl
	    jp __MEM_LOOP
__MEM_DONE:  ; A free block has been found.
	    ; Check if at least 4 bytes remains free (HL >= 4)
	    push hl
	    exx  ; exx to preserve bc
	    pop hl
	    ld bc, 4
	    or a
	    sbc hl, bc
	    exx
	    jp nc, __MEM_SUBTRACT
	    ; At this point...
	    ; less than 4 bytes remains free. So we return this block entirely
	    ; We must link the previous block with the next to this one
	    ; (DE) => Pointer to next block
	    ; (TEMP) => &(previous->next)
	    pop hl     ; Discard current block pointer
	    push de
	    ex de, hl  ; DE = Previous block pointer; (HL) = Next block pointer
	    ld a, (hl)
	    inc hl
	    ld h, (hl)
	    ld l, a    ; HL = (HL)
	    ex de, hl  ; HL = Previous block pointer; DE = Next block pointer
TEMP0:
	    ld hl, 0   ; Pre-previous block pointer
	    ld (hl), e
	    inc hl
	    ld (hl), d ; LINKED
	    pop hl ; Returning block.
	    ret
__MEM_SUBTRACT:
	    ; At this point we have to store HL value (Length - BC) into (DE - 2)
	    ex de, hl
	    dec hl
	    ld (hl), d
	    dec hl
	    ld (hl), e ; Store new block length
	    add hl, de ; New length + DE => free-block start
	    pop de     ; Remove previous HL off the stack
	    ld (hl), c ; Store length on its 1st word
	    inc hl
	    ld (hl), b
	    inc hl     ; Return hl
	    ret
	    ENDP
	    pop namespace
#line 13 "src/lib/arch/zx48k/runtime/mem/calloc.asm"
	; ---------------------------------------------------------------------
	; MEM_CALLOC
	;  Allocates a block of memory in the heap, and clears it filling it
	;  with 0 bytes
	;
	; Parameters
	;  BC = Length of requested memory block
	;
; Returns:
	;  HL = Pointer to the allocated block in memory. Returns 0 (NULL)
	;       if the block could not be allocated (out of memory)
	; ---------------------------------------------------------------------
	    push namespace core
__MEM_CALLOC:
	    push bc
	    call __MEM_ALLOC
	    pop bc
	    ld a, h
	    or l
	    ret z  ; No memory
	    ld (hl), 0
	    dec bc
	    ld a, b
	    or c
	    ret z  ; Already filled (1 byte-length block)
	    ld d, h
	    ld e, l
	    inc de
	    push hl
	    ldir
	    pop hl
	    ret
	    pop namespace
#line 3 "src/lib/arch/zx48k/runtime/array/arrayalloc.asm"
	; ---------------------------------------------------------------------
	; __ALLOC_LOCAL_ARRAY
	;  Allocates an array element area in the heap, and clears it filling it
	;  with 0 bytes
	;
	; Parameters
	;  HL = Offset to be added to IX => HL = IX + HL
	;  BC = Length of the element area = n.elements * size(element)
	;  DE = PTR to the index table
	;
; Returns:
	;  HL = (IX + HL) + 4
	; ---------------------------------------------------------------------
	    push namespace core
__ALLOC_LOCAL_ARRAY:
	    push de
	    push ix
	    pop de
	    add hl, de  ; hl = ix + hl
	    pop de
	    ld (hl), e
	    inc hl
	    ld (hl), d
	    inc hl
	    push hl
	    call __MEM_CALLOC
	    pop de
	    ex de, hl
	    ld (hl), e
	    inc hl
	    ld (hl), d
	    ret
	; ---------------------------------------------------------------------
	; __ALLOC_INITIALIZED_LOCAL_ARRAY
	;  Allocates an array element area in the heap, and clears it filling it
	;  with data whose pointer (PTR) is in the stack
	;
	; Parameters
	;  HL = Offset to be added to IX => HL = IX + HL
	;  BC = Length of the element area = n.elements * size(element)
	;  DE = PTR to the index table
	;  [SP + 2] = PTR to the element area
	;
; Returns:
	;  HL = (IX + HL) + 4
	; ---------------------------------------------------------------------
__ALLOC_INITIALIZED_LOCAL_ARRAY:
	    push bc
	    call __ALLOC_LOCAL_ARRAY
	    pop bc
	    ;; Swaps [SP], [SP + 2]
	    exx
	    pop hl       ; HL <- RET address
	    ex (sp), hl  ; HL <- Data table, [SP] <- RET address
	    push hl      ; [SP] <- Data table
	    exx
	    ex (sp), hl  ; HL = Data table, (SP) = (IX + HL + 4) - start of array address lbound
	    ; HL = data table
	    ; BC = length
	    ; DE = new data area
	    ldir
	    pop hl  ; HL = addr of LBound area if used
	    ret
#line 142 "src/lib/arch/zx48k/runtime/array/arrayalloc.asm"
	    pop namespace
#line 619 "src/lib/arch/cpc/stdlib/play.bas"
#line 1 "src/lib/arch/cpc/runtime/ay.asm"
	; -----------------------------------------------------------------------
	; Amstrad CPC AY-3-8912 register access
	;
	; Written from scratch for this project (MIT); see core.asm. From the
	; public documentation of the 8255 PPI and the AY-3-8912 as wired in the
	; CPC (cpcwiki.eu, CPC Firmware Guide); no library code.
	;
; The AY sits behind the PPI: port A (&F4xx) is the AY's data bus, and
	; port C (&F6xx) bits 7-6 are the AY's BDIR and BC1 lines (11 = latch a
	; register number, 10 = write data, 01 = read data, 00 = inactive). Port C
	; bits 5-4 are the cassette write data and motor (kept as they are) and
	; bits 3-0 select the keyboard row, which the firmware's own scan (inside
	; its 300 Hz interrupt handler) changes. So every access here has to run
	; with interrupts off, or the handler could slip a keyboard scan between
	; two of the OUTs. The raw routines do not touch the interrupt flag (a
	; caller that already has interrupts off, like the Play library, pays for
	; neither DI nor EI); the _DI variants wrap them and return with
	; interrupts on, as every compiled-code routine does.
	;
	; The PPI must be as the firmware leaves it, control word &82 (port A
	; output, B input, C output).
	;
; Who owns the sound chip: the firmware's sound manager (SOUND/BEEP) runs
	; from the interrupt handler and writes the AY by itself whenever a note
	; is queued, so a program that uses these routines directly must not
	; also queue firmware sounds. Call SOUND_RESET (&BCA7) once first to make
	; the manager idle (Play does).
	;
; Bare-metal mode (-D CPC_BAREMETAL): there is no firmware sound manager,
	; so nothing else writes the AY; BEEP, Play, the music player and these
	; routines are the only users (one at a time).
	;
	; Cost (CPC "NOP" units of 1 us, every instruction rounded up to a whole
; number of them; IN/OUT are 4): __CPC_AY_WRITE 53 us plus 5 for the CALL,
	; 58 us measured (tests/stress/play_tempo.bas). The DI variants add the
; DI, EI, CALL and RET: 12 us.
	    push namespace core
	; __CPC_AY_WRITE -- writes AY register A with the value in C. Interrupts
	; must be off on entry; they are left as they were. Port C is left as it
	; was (cassette bits kept, AY inactive, keyboard row 0). The AY's
	; register select is left on A.
; Firmware entries called: none.
; Registers clobbered: AF, BC, DE (HL is not touched).
__CPC_AY_WRITE:
	    ld   e, c               ; E = value
	    ld   d, a               ; D = register
	    ld   b, $F6
	    in   a, (c)             ; port C (the low byte of the port is not decoded)
	    and  $30                ; cassette bits
	    ld   c, a               ; C = port C "inactive" value
	    ld   a, d
	    ld   b, $F4
	    out  (c), a             ; port A = register number
	    ld   b, $F6
	    ld   a, c
	    or   $C0
    out  (c), a             ; AY: latch register
    out  (c), c             ; AY: inactive
	    ld   b, $F4
	    out  (c), e             ; port A = value
	    ld   b, $F6
	    ld   a, c
	    or   $80
    out  (c), a             ; AY: write
    out  (c), c             ; AY: inactive
	    ret
; __CPC_AY_WRITE_DI -- as __CPC_AY_WRITE, for code that has interrupts on:
	; di, write, ei. Returns with interrupts on, whatever they were on entry.
; Firmware entries called: none.
; Registers clobbered: AF, BC, DE.
__CPC_AY_WRITE_DI:
	    di
	    call __CPC_AY_WRITE
	    ei
	    ret
	; __CPC_AY_READ -- A = AY register -> A = its value (bits the register
	; doesn't implement read as 0). Interrupts must be off on entry; they are
	; left as they were. Port A is switched to input for the read and back
	; to output, which clears the PPI's output latches, so the cassette bits
	; are written back at once (the motor is off for a few microseconds only,
	; and only if it was on). Port C is left as in __CPC_AY_WRITE. Reading
	; register 14 (the keyboard port) gives the keyboard row selected by port
	; C bits 3-0, which is row 0 here.
; Firmware entries called: none.
; Registers clobbered: AF, BC, DE.
__CPC_AY_READ:
	    ld   d, a               ; D = register
	    ld   b, $F6
	    in   a, (c)
	    and  $30
	    ld   e, a               ; E = port C "inactive" value
	    ld   b, $F4
	    out  (c), d             ; port A = register number
	    ld   b, $F6
	    ld   a, e
	    or   $C0
    out  (c), a             ; AY: latch register
    out  (c), e             ; AY: inactive
	    ld   bc, $F792
	    out  (c), c             ; port A becomes an input
	    ld   a, e
	    or   $40
	    ld   b, $F6
    out  (c), a             ; AY: read
	    ld   b, $F4
	    in   a, (c)             ; the value
	    ld   d, a
	    ld   b, $F6
    out  (c), e             ; AY: inactive (before port A drives the bus again)
	    ld   bc, $F782
	    out  (c), c             ; port A back to output (clears the latches)
	    ld   b, $F6
	    out  (c), e             ; cassette bits back
	    ld   a, d
	    ret
; __CPC_AY_READ_DI -- as __CPC_AY_READ, for code that has interrupts on:
	; di, read, ei. Returns with interrupts on.
; Firmware entries called: none.
; Registers clobbered: AF, BC, DE.
__CPC_AY_READ_DI:
	    di
	    call __CPC_AY_READ
	    ei
	    ret
#line 159 "src/lib/arch/cpc/runtime/ay.asm"
	    pop namespace
#line 620 "src/lib/arch/cpc/stdlib/play.bas"
#line 1 "src/lib/arch/zx48k/runtime/bitwise/band16.asm"
; vim:ts=4:et:
	; FASTCALL bitwise and16 version.
	; result in hl
; __FASTCALL__ version (operands: A, H)
	; Performs 16bit or 16bit and returns the boolean
; Input: HL, DE
; Output: HL <- HL AND DE
	    push namespace core
__BAND16:
	    ld a, h
	    and d
	    ld h, a
	    ld a, l
	    and e
	    ld l, a
	    ret
	    pop namespace
#line 621 "src/lib/arch/cpc/stdlib/play.bas"
#line 1 "src/lib/arch/zx48k/runtime/bitwise/bnot16.asm"
; vim:ts=4:et:
	; FASTCALL bitwise or 16 version.
	; result in HL
; __FASTCALL__ version (operands: A, H)
	; Performs 16bit NEGATION
; Input: HL
; Output: HL <- NOT HL
	    push namespace core
__BNOT16:
	    ld a, h
	    cpl
	    ld h, a
	    ld a, l
	    cpl
	    ld l, a
	    ret
	    pop namespace
#line 622 "src/lib/arch/cpc/stdlib/play.bas"
#line 1 "src/lib/arch/zx48k/runtime/cmp/eq16.asm"
	    push namespace core
__EQ16:	; Test if 16bit values HL == DE
    ; Returns result in A: 0 = False, FF = True
	    xor a	; Reset carry flag
	    sbc hl, de
	    ret nz
	    inc a
	    ret
	    pop namespace
#line 624 "src/lib/arch/cpc/stdlib/play.bas"
#line 1 "src/lib/arch/zx48k/runtime/ftou32reg.asm"
#line 1 "src/lib/arch/zx48k/runtime/neg32.asm"
	    push namespace core
__ABS32:
	    bit 7, d
	    ret z
__NEG32: ; Negates DEHL (Two's complement)
	    ld a, l
	    cpl
	    ld l, a
	    ld a, h
	    cpl
	    ld h, a
	    ld a, e
	    cpl
	    ld e, a
	    ld a, d
	    cpl
	    ld d, a
	    inc l
	    ret nz
	    inc h
	    ret nz
	    inc de
	    ret
	    pop namespace
#line 2 "src/lib/arch/zx48k/runtime/ftou32reg.asm"
	    push namespace core
__FTOU32REG:	; Converts a Float to (un)signed 32 bit integer (NOTE: It's ALWAYS 32 bit signed)
	    ; Input FP number in A EDCB (A exponent, EDCB mantissa)
    ; Output: DEHL 32 bit number (signed)
	    PROC
	    LOCAL __IS_FLOAT
	    LOCAL __NEGATE
	    or a
	    jr nz, __IS_FLOAT
	    ; Here if it is a ZX ROM Integer
	    ld h, c
	    ld l, d
	    ld d, e
	    ret
__IS_FLOAT:  ; Jumps here if it is a true floating point number
	    ld h, e
	    push hl  ; Stores it for later (Contains Sign in H)
	    push de
	    push bc
	    exx
	    pop de   ; Loads mantissa into C'B' E'D'
	    pop bc	 ;
	    set 7, c ; Highest mantissa bit is always 1
	    exx
	    ld hl, 0 ; DEHL = 0
	    ld d, h
	    ld e, l
	    ;ld a, c  ; Get exponent
	    sub 128  ; Exponent -= 128
	    jr z, __FTOU32REG_END	; If it was <= 128, we are done (Integers must be > 128)
	    jr c, __FTOU32REG_END	; It was decimal (0.xxx). We are done (return 0)
	    ld b, a  ; Loop counter = exponent - 128
__FTOU32REG_LOOP:
	    exx 	 ; Shift C'B' E'D' << 1, output bit stays in Carry
	    sla d
	    rl e
	    rl b
	    rl c
	    exx		 ; Shift DEHL << 1, inserting the carry on the right
	    rl l
	    rl h
	    rl e
	    rl d
	    djnz __FTOU32REG_LOOP
__FTOU32REG_END:
	    pop af   ; Take the sign bit
	    or a	 ; Sets SGN bit to 1 if negative
	    jp m, __NEGATE ; Negates DEHL
	    ret
__NEGATE:
	    exx
	    ld a, d
	    or e
	    or b
	    or c
	    exx
	    jr z, __END
	    inc l
	    jr nz, __END
	    inc h
	    jr nz, __END
	    inc de
	LOCAL __END
__END:
	    jp __NEG32
	    ENDP
__FTOU8:	; Converts float in C ED LH to Unsigned byte in A
	    call __FTOU32REG
	    ld a, l
	    ret
	    pop namespace
#line 625 "src/lib/arch/cpc/stdlib/play.bas"
#line 1 "src/lib/arch/zx48k/runtime/loadstr.asm"
	; Loads a string (ptr) from HL
	; and duplicates it on dynamic memory again
	; Finally, it returns result pointer in HL
	    push namespace core
__ILOADSTR:		; This is the indirect pointer entry HL = (HL)
	    ld a, h
	    or l
	    ret z
	    ld a, (hl)
	    inc hl
	    ld h, (hl)
	    ld l, a
__LOADSTR:		; __FASTCALL__ entry
	    ld a, h
	    or l
	    ret z	; Return if NULL
	    ld c, (hl)
	    inc hl
	    ld b, (hl)
	    dec hl  ; BC = LEN(a$)
	    inc bc
	    inc bc	; BC = LEN(a$) + 2 (two bytes for length)
	    push hl
	    push bc
	    call __MEM_ALLOC
	    pop bc  ; Recover length
	    pop de  ; Recover origin
	    ld a, h
	    or l
	    ret z	; Return if NULL (No memory)
	    ex de, hl ; ldir takes HL as source, DE as destiny, so SWAP HL,DE
	    push de	; Saves destiny start
	    ldir	; Copies string (length number included)
	    pop hl	; Recovers destiny in hl as result
	    ret
	    pop namespace
#line 627 "src/lib/arch/cpc/stdlib/play.bas"
#line 1 "src/lib/arch/zx48k/runtime/mem/free.asm"
; vim: ts=4:et:sw=4:
	; Copyleft (K) by Jose M. Rodriguez de la Rosa
	;  (a.k.a. Boriel)
;  http://www.boriel.com
	;
	; This ASM library is licensed under the BSD license
	; you can use it for any purpose (even for commercial
	; closed source programs).
	;
	; Please read the BSD license on the internet
	; ----- IMPLEMENTATION NOTES ------
	; The heap is implemented as a linked list of free blocks.
; Each free block contains this info:
	;
	; +----------------+ <-- HEAP START
	; | Size (2 bytes) |
	; |        0       | <-- Size = 0 => DUMMY HEADER BLOCK
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+ <-+
	; | Size (2 bytes) |
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+   |
	; | <free bytes...>|   | <-- If Size > 4, then this contains (size - 4) bytes
	; | (0 if Size = 4)|   |
	; +----------------+ <-+
	; | Size (2 bytes) |
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+   |
	; | <free bytes...>|   |
	; | (0 if Size = 4)|   |
	; +----------------+   |
	;   <Allocated>        | <-- This zone is in use (Already allocated)
	; +----------------+ <-+
	; | Size (2 bytes) |
	; +----------------+
	; | Next (2 bytes) |---+
	; +----------------+   |
	; | <free bytes...>|   |
	; | (0 if Size = 4)|   |
	; +----------------+ <-+
	; | Next (2 bytes) |--> NULL => END OF LIST
	; |    0 = NULL    |
	; +----------------+
	; | <free bytes...>|
	; | (0 if Size = 4)|
	; +----------------+
	; When a block is FREED, the previous and next pointers are examined to see
	; if we can defragment the heap. If the block to be breed is just next to the
	; previous, or to the next (or both) they will be converted into a single
	; block (so defragmented).
	;   MEMORY MANAGER
	;
	; This library must be initialized calling __MEM_INIT with
	; HL = BLOCK Start & DE = Length.
	; An init directive is useful for initialization routines.
	; They will be added automatically if needed.
	; ---------------------------------------------------------------------
	; MEM_FREE
	;  Frees a block of memory
	;
; Parameters:
	;  HL = Pointer to the block to be freed. If HL is NULL (0) nothing
	;  is done
	; ---------------------------------------------------------------------
	    push namespace core
MEM_FREE:
__MEM_FREE: ; Frees the block pointed by HL
	    ; HL DE BC & AF modified
	    PROC
	    LOCAL __MEM_LOOP2
	    LOCAL __MEM_LINK_PREV
	    LOCAL __MEM_JOIN_TEST
	    LOCAL __MEM_BLOCK_JOIN
	    ld a, h
	    or l
	    ret z       ; Return if NULL pointer
	    dec hl
	    dec hl
	    ld b, h
	    ld c, l    ; BC = Block pointer
	    ld hl, ZXBASIC_MEM_HEAP  ; This label point to the heap start
__MEM_LOOP2:
	    inc hl
	    inc hl     ; Next block ptr
	    ld e, (hl)
	    inc hl
	    ld d, (hl) ; Block next ptr
	    ex de, hl  ; DE = &(block->next); HL = block->next
	    ld a, h    ; HL == NULL?
	    or l
	    jp z, __MEM_LINK_PREV; if so, link with previous
	    or a       ; Clear carry flag
	    sbc hl, bc ; Carry if BC > HL => This block if before
	    add hl, bc ; Restores HL, preserving Carry flag
	    jp c, __MEM_LOOP2 ; This block is before. Keep searching PASS the block
	;------ At this point current HL is PAST BC, so we must link (DE) with BC, and HL in BC->next
__MEM_LINK_PREV:    ; Link (DE) with BC, and BC->next with HL
	    ex de, hl
	    push hl
	    dec hl
	    ld (hl), c
	    inc hl
	    ld (hl), b ; (DE) <- BC
	    ld h, b    ; HL <- BC (Free block ptr)
	    ld l, c
	    inc hl     ; Skip block length (2 bytes)
	    inc hl
	    ld (hl), e ; Block->next = DE
	    inc hl
	    ld (hl), d
	    ; --- LINKED ; HL = &(BC->next) + 2
	    call __MEM_JOIN_TEST
	    pop hl
__MEM_JOIN_TEST:   ; Checks for fragmented contiguous blocks and joins them
	    ; hl = Ptr to current block + 2
	    ld d, (hl)
	    dec hl
	    ld e, (hl)
	    dec hl
	    ld b, (hl) ; Loads block length into BC
	    dec hl
	    ld c, (hl) ;
	    push hl    ; Saves it for later
	    add hl, bc ; Adds its length. If HL == DE now, it must be joined
	    or a
	    sbc hl, de ; If Z, then HL == DE => We must join
	    pop hl
	    ret nz
__MEM_BLOCK_JOIN:  ; Joins current block (pointed by HL) with next one (pointed by DE). HL->length already in BC
	    push hl    ; Saves it for later
	    ex de, hl
	    ld e, (hl) ; DE -> block->next->length
	    inc hl
	    ld d, (hl)
	    inc hl
	    ex de, hl  ; DE = &(block->next)
	    add hl, bc ; HL = Total Length
	    ld b, h
	    ld c, l    ; BC = Total Length
	    ex de, hl
	    ld e, (hl)
	    inc hl
	    ld d, (hl) ; DE = block->next
	    pop hl     ; Recovers Pointer to block
	    ld (hl), c
	    inc hl
	    ld (hl), b ; Length Saved
	    inc hl
	    ld (hl), e
	    inc hl
	    ld (hl), d ; Next saved
	    ret
	    ENDP
	    pop namespace
#line 628 "src/lib/arch/cpc/stdlib/play.bas"
#line 1 "src/lib/arch/zx48k/runtime/u32tofreg.asm"
	    push namespace core
__I8TOFREG:
	    ld l, a
	    rlca
	    sbc a, a	; A = SGN(A)
	    ld h, a
	    ld e, a
	    ld d, a
__I32TOFREG:	; Converts a 32bit signed integer (stored in DEHL)
	    ; to a Floating Point Number returned in (A ED CB)
	    ld a, d
	    or a		; Test sign
	    jp p, __U32TOFREG	; It was positive, proceed as 32bit unsigned
	    call __NEG32		; Convert it to positive
	    call __U32TOFREG	; Convert it to Floating point
	    set 7, e			; Put the sign bit (negative) in the 31bit of mantissa
	    ret
__U8TOFREG:
	    ; Converts an unsigned 8 bit (A) to Floating point
	    ld l, a
	    ld h, 0
	    ld e, h
	    ld d, h
__U32TOFREG:	; Converts an unsigned 32 bit integer (DEHL)
	    ; to a Floating point number returned in A ED CB
	    PROC
	    LOCAL __U32TOFREG_END
	    ld a, d
	    or e
	    or h
	    or l
	    ld b, d
	    ld c, e		; Returns 00 0000 0000 if ZERO
	    ret z
	    push de
	    push hl
	    exx
	    pop de  ; Loads integer into B'C' D'E'
	    pop bc
	    exx
	    ld l, 128	; Exponent
	    ld bc, 0	; DEBC = 0
	    ld d, b
	    ld e, c
__U32TOFREG_LOOP: ; Also an entry point for __F16TOFREG
	    exx
	    ld a, d 	; B'C'D'E' == 0 ?
	    or e
	    or b
	    or c
	    jp z, __U32TOFREG_END	; We are done
	    srl b ; Shift B'C' D'E' >> 1, output bit stays in Carry
	    rr c
	    rr d
	    rr e
	    exx
	    rr e ; Shift EDCB >> 1, inserting the carry on the left
	    rr d
	    rr c
	    rr b
	    inc l	; Increment exponent
	    jp __U32TOFREG_LOOP
__U32TOFREG_END:
	    exx
	    ld a, l     ; Puts the exponent in a
	    res 7, e	; Sets the sign bit to 0 (positive)
	    ret
	    ENDP
	    pop namespace
#line 629 "src/lib/arch/cpc/stdlib/play.bas"
.LABEL.__LABEL88:
	DEFB 00h
	DEFB 00h
	DEFB 01h
	END
